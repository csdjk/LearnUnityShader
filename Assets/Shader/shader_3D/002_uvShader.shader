Shader "lcl/shader3D/002_uvShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_rippleTex ("rippleTex", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _rippleTex;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float2 uv_offset = float2(0,0);
				uv_offset.x = _Time.y * 0.25;
				uv_offset.y = _Time.y * 0.25;

				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 rippleCol = tex2D(_rippleTex, i.uv+uv_offset);
				
				return col+rippleCol;
			}
			ENDCG
		}
	}
}
