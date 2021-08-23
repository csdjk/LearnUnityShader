/*
* @Descripttion: 次表面散射
* @Author: lichanglong
* @Date: 2021-08-20 18:21:10
 * @FilePath: \LearnUnityShader\Assets\Scenes\SubsurfaceScattering\FastSSS\FastSubfaceScattering.shader
*/
Shader "lcl/SubsurfaceScattering/FastSubfaceScattering" {
	Properties{
		_MainTex ("Texture", 2D) = "white" {}
		_BaseColor("Base Color",Color) = (1,1,1,1)
		_Specular("_Specular Color",Color) = (1,1,1,1)
		[PowerSlider()]_Gloss("Gloss",Range(0,200)) = 10
		
		// fresnel
		_RimPower("Rim Power", Range(0.0, 36)) = 0.1
		_RimIntensity("Rim Intensity", Range(0, 1)) = 0.2
		
		[Header(SubsurfaceScattering)]
		[Main(frontFactor)] _group ("group", float) = 1
		[Sub(frontFactor)][HDR]_InteriorColor ("Interior Color", Color) = (1,1,1,1)
		[Sub(frontFactor)]_InteriorColorPower ("InteriorColorPower", Range(0,50)) = 0.0
		[Title(frontFactor, Back SSS Factor)]
		[Sub(frontFactor)]_DistortionBack ("Back Distortion", Range(0,1)) = 0.0
		[Sub(frontFactor)]_PowerBack ("Back Power", Range(0,10)) = 0.0
		[Sub(frontFactor)]_ScaleBack ("Back Scale", Range(0,1)) = 0.0
		[Title(frontFactor, Front SSS Factor)]
		[Sub(frontFactor)]_FrontSssIntensity ("Front SSS Intensity", Range(0,1)) = 0.2
		[Sub(frontFactor)]_DistortionFont ("Front Distortion", Range(0,1)) = 0.0
		[Sub(frontFactor)]_PowerFont ("Front Power", Range(0,10)) = 0.0
		[Sub(frontFactor)]_ScaleFont ("Front Scale", Range(0,1)) = 0.0
	}
	SubShader {
		Pass{
			Tags { "LightMode"="Forwardbase" }
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityLightingCommon.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _BaseColor;
			half _Gloss;
			float3 _Specular;
			float  _RimPower;
			float _RimIntensity;

			float4 _InteriorColor;
			float _InteriorColorPower;

			float _DistortionBack;
			float _PowerBack;
			float _ScaleBack;
			
			float _FrontSssIntensity;
			float _DistortionFont;
			float _PowerFont;
			float _ScaleFont;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal: NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f{
				float4 position:SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 normalDir: TEXCOORD1;
				float3 worldPos: TEXCOORD2;
				float3 viewDir: TEXCOORD3;
				float3 lightDir: TEXCOORD4;
			};

			v2f vert(a2v v){
				v2f o;
				o.position = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldPos = mul (unity_ObjectToWorld, v.vertex);
				o.normalDir = UnityObjectToWorldNormal (v.normal);
				o.viewDir = normalize(UnityWorldSpaceViewDir(o.worldPos));
				// o.viewDir = normalize(_WorldSpaceCameraPos.xyz - o.worldPos.xyz);
				o.lightDir = normalize(UnityWorldSpaceLightDir(o.worldPos));

				return o;
			};
			
			// 计算SSS
			inline float SubsurfaceScattering (float3 viewDir, float3 lightDir, float3 normalDir, float distortion,float power,float scale)
			{
				// float3 H = normalize(lightDir + normalDir * distortion);
				float3 H = (lightDir + normalDir * distortion);
				float I = pow(saturate(dot(viewDir, -H)), power) * scale;
				return I;
			}
			
			
			fixed4 frag(v2f i): SV_TARGET{
				fixed4 col = tex2D(_MainTex, i.uv) * _BaseColor;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
				fixed3 normalDir = i.normalDir;
				fixed3 viewDir = i.viewDir;
				float3 lightDir = i.lightDir;

				// fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos );

				// -------------Diffuse1-------------
				// fixed3 diffuse = _LightColor0.rgb * max(dot(normalDir,lightDir),0.3);
				// diffuse *= col * _InteriorColor;

				// -------------Diffuse2-------------
				fixed3 diffuse = _LightColor0.rgb * max(dot(normalDir,lightDir),0);
				fixed4 unlitCol = col * _InteriorColor * 0.5;
				diffuse = lerp(unlitCol, col, diffuse); 

				// -------------Specular - BlinnPhong-------------
				// float specularPow = exp2 ((1 - _Gloss) * 10.0 + 1.0);
				fixed3 halfDir = normalize(lightDir+viewDir);
				fixed3 specular = _LightColor0.rgb * pow(max(0,dot(normalDir,halfDir)),_Gloss) * _Specular;
				// fixed3 reflectDir = reflect(-lightDir,normalDir);//反射光
				// fixed3 specular = _LightColor0.rgb * pow(max(0,dot(viewDir,reflectDir)),_Gloss) *_Specular;
				
				// ---------------次表面散射-----------
				// 背面
				float sssValueBack = SubsurfaceScattering(viewDir,lightDir,normalDir,_DistortionBack,_PowerBack,_ScaleBack);
				// 正面
				float sssValueFont = SubsurfaceScattering(viewDir,-lightDir,normalDir,_DistortionFont,_PowerFont,_ScaleFont);
				float sssValue = saturate(sssValueFont * _FrontSssIntensity + sssValueBack);
				fixed3 sssCol = lerp(_InteriorColor, _LightColor0, saturate(pow(sssValue, _InteriorColorPower))).rgb * sssValue;


				// ---------------Rim---------------
				float rim = 1.0 - max(0, dot(normalDir, viewDir));
				float rimValue = lerp(rim, 0, sssValue);
				float3 rimCol = lerp(_InteriorColor, _LightColor0.rgb, rimValue) * pow(rimValue, _RimPower) * _RimIntensity;  
				
				// 点光源
				float3 pointLightPos = float3(unity_4LightPosX0[0],unity_4LightPosY0[0],unity_4LightPosZ0[0]);
				float3 pointLightDir = normalize(pointLightPos - i.worldPos);
				float pointSssValue = SubsurfaceScattering(viewDir,pointLightDir,normalDir,_DistortionBack,_PowerBack,_ScaleBack);
				// UNITY_LIGHT_ATTENUATION(attenuation, 0, i.worldPos);


				float3 pL = Shade4PointLights(unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
				unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
				unity_4LightAtten0,
				i.worldPos, normalDir);
				// pL = lerp()

				fixed3 resCol = sssCol + diffuse.rgb + specular + rimCol + pL*sssValue;
				
				return float4(resCol,1);
				// return float4(sssCol+diffuse,1);
				// return float4(pL*sssValue,1);

				// return float4(,1);
				// return sssValue;
			};
			
			ENDCG
		}

		Pass{
			Tags { "LightMode"="ForwardAdd" }
			Blend One One
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdadd

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _BaseColor;
			half _Gloss;
			float3 _Specular;
			float  _RimPower;
			float _RimIntensity;

			float4 _InteriorColor;
			float _InteriorColorPower;

			float _DistortionBack;
			float _PowerBack;
			float _ScaleBack;
			
			float _FrontSssIntensity;
			float _DistortionFont;
			float _PowerFont;
			float _ScaleFont;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal: NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f{
				float4 position:SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 normalDir: TEXCOORD1;
				float3 worldPos: TEXCOORD2;
				float3 viewDir: TEXCOORD3;
				float3 lightDir: TEXCOORD4;
			};

			v2f vert(a2v v){
				v2f o;
				o.position = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldPos = mul (unity_ObjectToWorld, v.vertex);
				o.normalDir = UnityObjectToWorldNormal (v.normal);
				o.viewDir = normalize(UnityWorldSpaceViewDir(o.worldPos));
				o.lightDir = normalize(UnityWorldSpaceLightDir(o.worldPos));
				return o;
			};
			
			// 计算SSS
			inline float SubsurfaceScattering (float3 viewDir, float3 lightDir, float3 normalDir, float distortion,float power,float scale)
			{
				// float3 H = normalize(lightDir + normalDir * distortion);
				float3 H = (lightDir + normalDir * distortion);
				float I = pow(saturate(dot(viewDir, -H)), power) * scale;
				return I;
			}
			
			
			fixed4 frag(v2f i): SV_TARGET{
				fixed4 col = tex2D(_MainTex, i.uv) * _BaseColor;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
				fixed3 normalDir = i.normalDir;
				fixed3 viewDir = i.viewDir;
				float3 lightDir = i.lightDir;

				// -------------Diffuse1-------------
				// fixed3 diffuse = _LightColor0.rgb * max(dot(normalDir,lightDir),0.3);
				// diffuse *= col * _InteriorColor;

				// -------------Diffuse2-------------
				fixed3 diffuse = _LightColor0.rgb * max(dot(normalDir,lightDir),0);
				fixed4 unlitCol = col * _InteriorColor * 0.5;
				diffuse = lerp(unlitCol, col, diffuse); 

				// -------------Specular - BlinnPhong-------------
				// float specularPow = exp2 ((1 - _Gloss) * 10.0 + 1.0);
				fixed3 halfDir = normalize(lightDir+viewDir);
				fixed3 specular = _LightColor0.rgb * pow(max(0,dot(normalDir,halfDir)),_Gloss) * _Specular;
				// fixed3 reflectDir = reflect(-lightDir,normalDir);//反射光
				// fixed3 specular = _LightColor0.rgb * pow(max(0,dot(viewDir,reflectDir)),_Gloss) *_Specular;
				
				// ---------------次表面散射-----------
				// 背面
				float sssValueBack = SubsurfaceScattering(viewDir,lightDir,normalDir,_DistortionBack,_PowerBack,_ScaleBack);
				// 正面
				float sssValueFont = SubsurfaceScattering(viewDir,-lightDir,normalDir,_DistortionFont,_PowerFont,_ScaleFont);
				float sssValue = saturate(sssValueFont * _FrontSssIntensity + sssValueBack);
				fixed3 sssCol = lerp(_InteriorColor, _LightColor0, saturate(pow(sssValue, _InteriorColorPower))).rgb * sssValue;

				// ---------------Rim---------------
				float rim = 1.0 - max(0, dot(normalDir, viewDir));
				float rimValue = lerp(rim, 0, sssValue);
				float3 rimCol = lerp(_InteriorColor, _LightColor0.rgb, rimValue) * pow(rimValue, _RimPower) * _RimIntensity;  
				
				// 衰减
				UNITY_LIGHT_ATTENUATION(atten, 0, i.worldPos);

				fixed3 resCol = sssCol + diffuse.rgb + specular + rimCol;
				
				// return float4(_LightColor0.rgb*atten*2*sssValue,1);
				return float4(_LightColor0.rgb * atten,1);
			};
			
			ENDCG
		}
	}
	FallBack "Diffuse"
}