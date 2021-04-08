Shader "lcl/shader3D/CubemapReflect"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_MatCap ("MatCap (RGB)", 2D) = "white" {}
		_RimColor("RimColor", Color) = (0,0,0,0)
		_RimPower("RimPower", Float) = 0
		_colorFactor("Power", Range(0,12)) = 1
		_alphaFactor("AlphaPower", Range(0,1)) = 1
		_MaskTex("MaskTex" , 2D) = "black"{}
		_FlowColor("FlowColor", Color) = (1,1,1,0)
		_FlowSpeed("FlowSpeed" , Range(-5, 5)) = 0.4
		_FlowSpeed_Y("FlowSpeed_Y" , Range(-5, 5)) = 0
		_lightFactor("LightFactor" , Range(0, 1)) = 0.3

		_Specular("Specular Color",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8,200)) = 200
		_Cubemap ("Reflection Cubemap", Cube) = "_Skybox" {}
		// _ReflectAmount ("Reflect Amount", Range(0, 1)) = 1
	}
	
	Subshader
	{
		LOD 400
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			Fog {Mode Global}
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"

			fixed4 _Color;
			half _Gloss;
			fixed4 _Specular;
			samplerCUBE _Cubemap;
			// fixed _ReflectAmount;

			uniform float4 _MainTex_ST;
			uniform float4 _MatCap_ST;
			uniform float4 _MaskTex_ST;
			uniform sampler2D _MainTex;
			uniform sampler2D _MatCap;
			uniform sampler2D _MaskTex;
			uniform float4 _RimColor;
			uniform float _RimPower;
			uniform float _colorFactor;
			uniform float _alphaFactor;

			uniform float _lightFactor;
			uniform float _FlowSpeed;
			uniform float _FlowSpeed_Y;
			uniform float4 _FlowColor;
			
			struct v2f
			{
				float4 pos	: SV_POSITION;
				float4 uv 	: TEXCOORD0;
				float2 cap	: TEXCOORD1;
				float2 uv2	: TEXCOORD2;
				float3 normal : NORMAL;
				float3 viewDir : TEXCOORD3;
				fixed3 worldRefl : TEXCOORD5;

				// fixed3 specularColor:COLOR;
			};			

			v2f vert (appdata_base v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos (v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _MatCap);
				o.uv2 = TRANSFORM_TEX(v.texcoord, _MaskTex);
				float3 worldNorm = normalize(unity_WorldToObject[0].xyz * v.normal.x + unity_WorldToObject[1].xyz * v.normal.y + unity_WorldToObject[2].xyz * v.normal.z);
				worldNorm = mul((float3x3)UNITY_MATRIX_V, worldNorm);
				o.cap.xy = worldNorm.xy * 0.5 + 0.5;
				o.normal = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
				o.viewDir = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, v.vertex));

				// 反射方向
				o.worldRefl = reflect(-o.viewDir, o.normal);

				// // 高光
				// fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				// fixed3 reflectDir = reflect(-lightDir,o.normal);//反射光
				// o.specularColor = pow(max(0,dot(o.viewDir,reflectDir)),_Gloss) * _Specular;

				return o;
			}
			
			fixed4 frag (v2f i) : COLOR
			{
				fixed4 tex = tex2D(_MainTex, i.uv.xy);
				fixed4 maskColor = tex2D(_MaskTex, i.uv);
				
				if (maskColor.a > 0){
					tex = tex2D(_MainTex, i.uv.xy) * _Color;
				}
				
				fixed4 cap = tex2D(_MatCap, i.uv.zw);
				fixed4 normalColor = tex2D(_MatCap, i.cap);
				tex = (tex + (normalColor*2.0) - 1.0);

				float4 NdotV = abs(dot(i.normal, i.viewDir));
				fixed4 c = _RimColor;
				c.a = min(1.0, c.a / pow(NdotV, _RimPower));
				tex.rgb = tex.rgb * (1 - c.a) + c.rgb * c.a;
				tex.rgb *= _colorFactor;
				tex.a *= _alphaFactor;

				float2 uv = i.uv2;
				uv.x += -_Time.y * _FlowSpeed;
				uv.y += -_Time.y * _FlowSpeed_Y;
				fixed flowTexB = tex2D(_MaskTex, uv).b;
				//fixed flowTexB = tex2D(_MaskTex, TRANSFORM_TEX(uv, _MaskTex)).b;
				
				tex = tex + _FlowColor * flowTexB * maskColor.r + maskColor.g * _lightFactor;
				// 高光
				fixed3 specular;
				// 小于200才计算高光
				if(_Gloss < 200){
					fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
					fixed3 reflectDir = reflect(-lightDir,i.normal);//反射光
					specular = pow(max(0,dot(i.viewDir,reflectDir)),_Gloss) * _Specular;
					}else{
					specular = fixed3(0,0,0);
				}
				// cube map
				fixed3 reflection = texCUBE(_Cubemap, i.worldRefl).rgb;
				// fixed3 color = lerp(tex, reflection, _ReflectAmount) + i.specularColor;
				// fixed3 color = lerp(tex, reflection, _ReflectAmount) + specular;
				// mask g 通道控制反射
				fixed3 color = lerp(tex, reflection, 1-maskColor.g) + specular;
				return fixed4(color,1);
				// fixed isShow = step(maskColor.g,0);
				// fixed4 res = tex *  (1-isShow) + fixed4(color, 1.0) * isShow;
				// return res;
			}
			ENDCG
		}
	}

	Subshader
	{
		LOD 200
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			Fog{ Mode Global }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"

			uniform float4 _MainTex_ST;
			uniform float4 _MatCap_ST;
			uniform sampler2D _MainTex;
			uniform sampler2D _MatCap;
			uniform float4 _RimColor;
			uniform float _RimPower;
			uniform float _colorFactor;
			uniform float _alphaFactor;

			struct v2f
			{
				float4 pos	: SV_POSITION;
				float4 uv 	: TEXCOORD0;
				float2 cap	: TEXCOORD1;
				float3 normal : NORMAL;
				float3 viewDir : TEXCOORD3;
			};

			v2f vert(appdata_base v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _MatCap);
				float3 worldNorm = normalize(unity_WorldToObject[0].xyz * v.normal.x + unity_WorldToObject[1].xyz * v.normal.y + unity_WorldToObject[2].xyz * v.normal.z);
				worldNorm = mul((float3x3)UNITY_MATRIX_V, worldNorm);
				o.cap.xy = worldNorm.xy * 0.5 + 0.5;
				o.normal = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
				o.viewDir = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, v.vertex));

				return o;
			}

			fixed4 frag(v2f i) : COLOR
			{
				fixed4 tex = tex2D(_MainTex, i.uv.xy);
				fixed4 cap = tex2D(_MatCap, i.uv.zw);
				fixed4 normalColor = tex2D(_MatCap, i.cap);
				tex = (tex + (normalColor*2.0) - 1.0);

				float4 NdotV = abs(dot(i.normal, i.viewDir));
				fixed4 c = _RimColor;
				c.a = min(1.0, c.a / pow(NdotV, _RimPower));
				tex.rgb = tex.rgb * (1 - c.a) + c.rgb * c.a;
				tex.rgb *= _colorFactor;
				tex.a *= _alphaFactor;

				return tex;
			}
			ENDCG
		}
	}
	
	Fallback "VertexLit"
}