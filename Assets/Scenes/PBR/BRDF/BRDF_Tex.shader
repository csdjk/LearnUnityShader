Shader "lcl/BRDF/BRDF_Tex"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_NormalTex("NormalTex",2D)="bump"{}
		_AOTex("AOTex",2D)="white"{}
		_MetallicTex("MetallicTex",2D)="white"{}
		_RoughnessTex("RoughnessTex",2D) = "white"{}
		_IBLLUT("IBLLUT",2D)="white"{}
		_Cube("Cube",CUBE)=""{}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "LightMode"="ForwardBase"}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal:NORMAL;
				float4 tangent:TANGENT;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float3 worldPos:TEXCOORD1;
				float3 worldToTangent1:TEXCOORD2;
				float3 worldToTangent2:TEXCOORD3;
				float3 worldToTangent3:TEXCOORD4;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _NormalTex;
			sampler2D _AOTex;
			sampler2D _MetallicTex;
			sampler2D _RoughnessTex;
			sampler2D _IBLLUT;
			samplerCUBE _Cube;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(UNITY_MATRIX_M, v.vertex).xyz;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				float3 worldBinormal = cross(worldNormal, worldTangent)*v.tangent.w;
				o.worldToTangent1 = worldTangent;
				o.worldToTangent2 = worldBinormal;
				o.worldToTangent3 = worldNormal;
				return o;
			}

			float3 FresnelSchlick(float cosTheta,float3 F0) {
				return F0 + (1.0 - F0)*pow(1.0 - cosTheta, 5.0);
			}

			float3 fresnelSchlickRoughness(float cosTheta, float3 F0, float roughness) {
				return F0+(max(float3(1,1,1)*(1.0 - roughness),F0)-F0)* pow(1.0 - cosTheta, 5.0);
			}

			float DistributionGGX(float3 N, float3 H, float roughness) {
				float a = roughness * roughness;
				float a2 = a * a;
				float NdotH = max(dot(N, H), 0.0);
				float NdotH2 = NdotH * NdotH;

				float num = a2;
				float denom = (NdotH2 * (a2 - 1.0) + 1.0);
				denom = 3.1415926 * denom * denom;

				return num / denom;
			}

			float GeometrySchlickGGX(float NdotV, float roughness)
			{
				float r = (roughness + 1.0);
				float k = (r*r) / 8.0;

				float num = NdotV;
				float denom = NdotV * (1.0 - k) + k;

				return num / denom;
			}

			float GeometrySmith(float3 N, float3 V, float3 L, float roughness)
			{
				float NdotV = max(dot(N, V), 0.0);
				float NdotL = max(dot(N, L), 0.0);
				float ggx2 = GeometrySchlickGGX(NdotV, roughness);
				float ggx1 = GeometrySchlickGGX(NdotL, roughness);

				return ggx1 * ggx2;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 N = UnpackNormal(tex2D(_NormalTex,i.uv));
				float3x3 W2T = float3x3(i.worldToTangent1, i.worldToTangent2, i.worldToTangent3);
				N = mul(N, W2T);

				float3 V = normalize(_WorldSpaceCameraPos.xyz-i.worldPos);
				float3 L = normalize(_WorldSpaceLightPos0.xyz);
				float3 H = normalize(V + L);

				float4 albedo = tex2D(_MainTex, i.uv);
				float roughness = tex2D(_RoughnessTex, i.uv);
				float metallic = tex2D(_MetallicTex, i.uv);
				float ao = tex2D(_AOTex, i.uv);

				float3 F0 = 0.04;
				F0 = lerp(F0, albedo, metallic);
				
				float3 F = FresnelSchlick(saturate(dot(H, V)), F0);
				float D = DistributionGGX(N, H, roughness);
				float G = GeometrySmith(N, V, L, roughness);

				float3 DFG = D * F * G;
				float3 specular = DFG / max((saturate(dot(N, V))*saturate(dot(N, L))),0.001);

				float3 ks = F;
				float3 kd = float3(1,1,1) - ks;
				kd *= (1.0 - metallic);

				float PI = 3.1415926;
				float NdotL = saturate(dot(N, L));

				float3 brdf = (kd*albedo / PI + specular)*_LightColor0.xyz*NdotL;

				//ibl

				float3 iblKS = fresnelSchlickRoughness(saturate(dot(N, V)), F0, roughness);
				float3 iblKD = 1 - iblKS;
				iblKD *= (1 - metallic);

				float3 R = reflect(-V, N);

				float3 iblDiffuse = ShadeSH9(float4(N, 1))*albedo.xyz;
				//cubemap mipmap
				float mip = roughness*6;
				float3 cube = texCUBElod(_Cube,float4(R, mip+5));
				float2 envBRDF = tex2D(_IBLLUT, float2(saturate(dot(N, V)), roughness)).rg;
				float3 iblSpecular = cube * (iblKS*envBRDF.x + envBRDF.y);

				float4 final = 0;
				final.rgb = brdf;

				final.rgb += iblSpecular + iblDiffuse*iblKD;

				final.rgb *= ao;
				final.a = 1;
				return final;
			}
			ENDCG
		}
	}
}

