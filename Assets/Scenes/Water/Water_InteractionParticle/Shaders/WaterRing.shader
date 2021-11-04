Shader "lcl/Water/WaterRings"
{
	Properties
	{
		_BumpPower("BumpPower", Range( 0 , 50)) = 2
		_TexelRadius("TexelRadius", Range( -10 , 10)) = 1
		[NoScaleOffset]_HeightTex("Height Texture", 2D) = "white" {}
	}
	
	SubShader
	{
		Tags { "RenderType"="Opaque" }

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

			sampler2D _HeightTex;
			float4 _HeightTex_TexelSize;
			float _TexelRadius;
			float _BumpPower;
			
			v2f vert ( appdata v )
			{
				v2f o;
				o.uv = v.uv;
				o.color = v.color;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				float2 uv = i.uv.xy;
				float2 texelSize = _HeightTex_TexelSize.xy * _TexelRadius;
				float color0 = tex2D( _HeightTex, uv + texelSize.xy * half2(-1, 0)).r;
				float color1 = tex2D( _HeightTex, uv + texelSize.xy * half2(1, 0)).r;
				float color2 = tex2D( _HeightTex, uv + texelSize.xy * half2(0, -1)).r;
				float color3 = tex2D( _HeightTex, uv + texelSize.xy * half2(0, 1)).r;

				float4 texCol = tex2D( _HeightTex, uv);

				float2 ddxy = float2( color0 - color1, color2 - color3);
				float3 normal = float3(( ddxy * _BumpPower) , 1.0);
				normal = normalize(normal);
				float4 finalColor = float4(( (  normal * 0.5  + 0.5 ) * texCol.r * i.color.a) , ( texCol.r * i.color.a ));
				
				// finalColor = power;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}