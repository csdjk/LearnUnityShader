Shader "lcl/Water/WaterRing"
{
	Properties
	{
		_BumpPower ("BumpPower", Range(0, 50)) = 2
		_RingWidth ("RingWidth", Range(0, 0.5)) = 0
		_RingRange ("RingRange", Range(0, 1)) = 0
		_RingSmoothness ("RingSmoothness", Range(0, 0.05)) = 0
	}
	
	SubShader
	{
		Tags { "RenderType" = "Opaque" }

		CGINCLUDE
		#pragma target 3.0
		ENDCG

		Blend OneMinusDstColor One
		// Blend SrcAlpha OneMinusSrcAlpha
		Cull Back
		ZWrite Off
		ZTest LEqual
		
		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			
			// #pragma enable_d3d11_debug_symbols

			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 uv : TEXCOORD0;
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 uv : TEXCOORD0;
				float4 color : COLOR;
			};

			float _BumpPower;
			float _RingWidth;
			float _RingRange;
			float _RingSmoothness;

			v2f vert(appdata v)
			{
				v2f o;
				o.uv = v.uv;
				o.color = v.color;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			fixed doubleSmoothstep(float4 uv)
			{
				float dis = distance(uv, 0.5);
				float halfWidth = _RingWidth * 0.5;
				float range = _RingRange;
				float smoothness = _RingSmoothness;
				float threshold1 = range - halfWidth;
				float threshold2 = range + halfWidth;

				float value = smoothstep(threshold1, threshold1 + smoothness, dis);
				float value2 = smoothstep(threshold2, threshold2 + smoothness, dis);
				
				return value - value2;
			}
			fixed4 frag(v2f i) : SV_Target
			{
				float normalCenter = doubleSmoothstep(i.uv);
				// 波纹法线
				float color0 = doubleSmoothstep(i.uv + half4(-1, 0, 0, 0) * 0.004);
				float color1 = doubleSmoothstep(i.uv + half4(1, 0, 0, 0) * 0.004);
				float color2 = doubleSmoothstep(i.uv + half4(0, -1, 0, 0) * 0.004);
				float color3 = doubleSmoothstep(i.uv + half4(0, 1, 0, 0) * 0.004);

				float2 ddxy = float2(color0 - color1, color2 - color3);
				float3 normal = float3((ddxy * _BumpPower), 1.0);
				normal = normalize(normal);
				float4 finalColor = float4((normal * 0.5 + 0.5) * normalCenter * i.color.a, normalCenter * i.color.a);
				return finalColor;
			}
			ENDCG

		}
	}
}