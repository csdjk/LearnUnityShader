/*
* @Descripttion: 次表面散射 - part1
* @Author: lichanglong
* @Date: 2021-08-20 18:21:10
 * @FilePath: \LearnUnityShader\Assets\Scenes\SubsurfaceScattering\FastSSS\FastSubfaceScattering1.shader
*/
Shader "lcl/SubsurfaceScattering/FastSubfaceScattering1" {
	Properties{
		_Diffuse("Diffuse Color",Color) = (1,1,1,1)
		_Specular("_Specular Color",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8,200)) = 10

		[Header(SubsurfaceScattering)]
		[Main(frontFactor)] _group ("group", float) = 1
		[Sub(frontFactor)][HDR]_InteriorColor ("Interior Color", Color) = (1,1,1,1)
		[Sub(frontFactor)]_InteriorColorPower ("InteriorColorPower", Range(0,50)) = 0.0
		[Sub(frontFactor)]_Distortion (" Distortion", Range(0,1)) = 0.0
		[Sub(frontFactor)]_Power (" Power", Range(0,10)) = 0.0
		[Sub(frontFactor)]_Scale (" Scale", Range(0,1)) = 0.0
	}
	SubShader {
		Pass{
			Tags { "LightMode"="ForwardBase" }
			
			CGPROGRAM
			#include "Lighting.cginc"
			#include "UnityLightingCommon.cginc"

			#pragma vertex vert
			#pragma fragment frag
			fixed3 _Diffuse;
			half _Gloss;
			fixed4 _Specular;

			float4 _InteriorColor;
			float _InteriorColorPower;

			float _Distortion;
			float _Power;
			float _Scale;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal: NORMAL;
			};

			struct v2f{
				float4 position:SV_POSITION;
				float3 normalDir: TEXCOORD0;
				float3 worldVertex: TEXCOORD1;
				float3 viewDir: TEXCOORD2;
			};

			v2f vert(a2v v){
				v2f o;
				o.position = UnityObjectToClipPos(v.vertex);
				o.worldVertex = mul (unity_ObjectToWorld, v.vertex);
				o.normalDir = UnityObjectToWorldNormal (v.normal);
				o.viewDir = normalize(_WorldSpaceCameraPos.xyz - o.worldVertex.xyz);
				return o;
			};
			
			// inline float SubsurfaceScattering (float3 viewDir, float3 lightDir, float3 normalDir, float subsurfaceDistortion)
			// {
				// 	float3 backLitDir = normalDir * subsurfaceDistortion + lightDir;
				// 	float result = saturate(dot(viewDir, -backLitDir));
				// 	return result;
			// }

			// 计算SSS
			inline float SubsurfaceScattering (float3 viewDir, float3 lightDir, float3 normalDir, float distortion,float power,float scale)
			{
				// float3 H = normalize(lightDir + normalDir * distortion);
				float3 H = (lightDir + normalDir * distortion);
				float I = pow(saturate(dot(viewDir, -H)), power) * scale;
				return I;
			}
			
			
			fixed4 frag(v2f i):SV_TARGET{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
				fixed3 normalDir = i.normalDir;
				fixed3 viewDir = i.viewDir;
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				
				fixed3 diffuse = _LightColor0.rgb * max(dot(normalDir,lightDir),0) * _Diffuse.rgb;
				// //高光反射
				// //fixed3 reflectDir = reflect(-lightDir,normalDir);//反射光
				// fixed3 halfDir = normalize(lightDir+viewDir);
				// fixed3 specular = _LightColor0.rgb * pow(max(0,dot(normalDir,halfDir)),_Gloss) *_Specular;
				// // fixed3 tempColor = diffuse+ambient+specular;


				// 次表面散射
				// fixed3 tempColor = ambient + diffuse + specular + _LightColor0.rgb * I;
				// fixed3 tempColor = diffuse+_LightColor0.rgb * I;

				float sssValue = SubsurfaceScattering(viewDir,lightDir,normalDir,_Distortion,_Power,_Scale);
				fixed3 sssCol = lerp(_InteriorColor, _LightColor0, saturate(pow(sssValue, _InteriorColorPower))).rgb * sssValue;
				// return fixed4(tempColor,1);

				// return fixed4(_LightColor0.rgb * I ,1);
				return float4(sssCol+diffuse,1);
				// return sssValue;
			};
			
			ENDCG
		}
	}
	FallBack "VertexLit"
}