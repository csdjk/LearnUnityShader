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
		
		[Main(frontFactor)] _group ("SubsurfaceScattering", float) = 1
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
			// #pragma enable_d3d11_debug_symbols

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
				float3 color: Color;
				float2 uv : TEXCOORD0;
			};

			struct v2f{
				float4 position:SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 normalDir: TEXCOORD1;
				float3 worldPos: TEXCOORD2;
				float3 viewDir: TEXCOORD3;
				float3 lightDir: TEXCOORD4;
				float3 thickness: TEXCOORD5;
			};

			v2f vert(a2v v){
				v2f o;
				o.position = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldPos = mul (unity_ObjectToWorld, v.vertex);
				o.normalDir = UnityObjectToWorldNormal (v.normal);
				o.viewDir = UnityWorldSpaceViewDir(o.worldPos);
				o.lightDir = UnityWorldSpaceLightDir(o.worldPos);
				o.lightDir = UnityWorldSpaceLightDir(o.worldPos);
				o.thickness = v.color;
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
			
			// 计算点光源衰减（参考UnityCG.cginc 中的Shade4PointLights）
			float3 CalculatePointLightColor (
			float4 lightPosX, float4 lightPosY, float4 lightPosZ,
			float3 lightColor0, float3 lightColor1, float3 lightColor2, float3 lightColor3,
			float4 lightAttenSq,
			float3 pos
			)
			{
				// to light vectors
				float4 toLightX = lightPosX - pos.x;
				float4 toLightY = lightPosY - pos.y;
				float4 toLightZ = lightPosZ - pos.z;
				// squared lengths
				float4 lengthSq = 0;
				lengthSq += toLightX * toLightX;
				lengthSq += toLightY * toLightY;
				lengthSq += toLightZ * toLightZ;
				// don't produce NaNs if some vertex position overlaps with the light
				lengthSq = max(lengthSq, 0.000001);

				float4 atten = 1.0 / (1.0 + lengthSq * lightAttenSq);
				// final color
				float3 col = 0;
				col += lightColor0 * atten.x;
				col += lightColor1 * atten.y;
				col += lightColor2 * atten.z;
				col += lightColor3 * atten.w;
				return col;
			}
			
			fixed4 frag(v2f i): SV_TARGET{
				fixed4 col = tex2D(_MainTex, i.uv) * _BaseColor;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
				fixed3 normalDir = normalize(i.normalDir);
				fixed3 viewDir = normalize(i.viewDir);
				float3 lightDir = normalize(i.lightDir);

				// -------------Diffuse1-------------
				// fixed3 diffuse = _LightColor0.rgb * max(dot(normalDir,lightDir),0.3);
				// diffuse *= col * _InteriorColor;

				// -------------Diffuse2-------------
				fixed3 diffuse = _LightColor0.rgb * max(dot(normalDir,lightDir),0);
				fixed4 unlitCol = col * _InteriorColor * 0.5;
				diffuse = lerp(unlitCol, col, diffuse); 

				// -------------Specular-BlinnPhong-------------
				fixed3 halfDir = normalize(lightDir+viewDir);
				fixed3 specular = _LightColor0.rgb * pow(max(0,dot(normalDir,halfDir)),_Gloss) * _Specular;
				
				// ---------------次表面散射-----------
				// 背面
				float sssValueBack = SubsurfaceScattering(viewDir,lightDir,normalDir,_DistortionBack,_PowerBack,_ScaleBack);
				// 正面
				float sssValueFont = SubsurfaceScattering(viewDir,-lightDir,normalDir,_DistortionFont,_PowerFont,_ScaleFont);
				float sssValue = saturate(sssValueFont * _FrontSssIntensity + sssValueBack);
				fixed3 sssCol = lerp(_InteriorColor, _LightColor0, saturate(pow(sssValue, _InteriorColorPower))).rgb * sssValue;
				sssCol = sssCol * i.thickness * _RimPower;

				// ---------------Rim---------------
				// float rim = 1.0 - max(0, dot(normalDir, viewDir));
				// float rimValue = lerp(rim, 0, sssValue);
				// float3 rimCol = lerp(_InteriorColor, _LightColor0.rgb, rimValue) * pow(rimValue, _RimPower) * _RimIntensity;  
				
				// --------------点光源--------------
				float3 pointColor = CalculatePointLightColor(unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
				unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
				unity_4LightAtten0,
				i.worldPos);

				fixed3 resCol = sssCol + diffuse.rgb + specular + pointColor;
				return float4(resCol,1);

				// return float4(sssCol,1);
				// return sssValue;

			};
			
			ENDCG
		}

	}
	FallBack "Diffuse"
}