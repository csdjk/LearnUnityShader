Shader "lcl/CommandBuffer/FixIlsandEdges"
{
	
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM

			#pragma  vertex   vert
			#pragma  fragment frag
			
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
			uniform float4		_MainTex_TexelSize;
			sampler2D _IlsandMap;
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				float map = tex2D(_IlsandMap, i.uv);
				
				float3 average = col;
				if (map.x < 0.2)
				{
					int n = 0;
					average = float3(0., 0., 0.);
					for (float x = -1.5; x <= 1.5; x++)
					{
						for (float y = -1.5; y <= 1.5; y++)
						{
							float3 c = tex2D(_MainTex, i.uv + _MainTex_TexelSize.xy * float2(x, y));
							float m = tex2D(_IlsandMap, i.uv + _MainTex_TexelSize.xy * float2(x, y));
							n += step(0.1, m);
							average += c * step(0.1, m);
						}
					}
					average /= n;
				}
				col.xyz = average;
				return col;
			}
			ENDCG

		}
	}
}
