Shader "lcl/shader3D/uvScaleShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_DistorValue ("_DistorValue",Range(0,1)) = 1.0
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
			float _DistorValue;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float2 distorCenter = float2(0.5,0.5);
				//偏移方向
				float2 dir = i.uv - distorCenter.xy;

				// float2 offset = sin(_Time.y*0.5) * normalize(dir) * (1 - length(dir));
				float2 offset = _DistorValue * normalize(dir) * (1 - length(dir));

				fixed4 col = tex2D(_MainTex, i.uv+offset);
				
				return col;
			}
			ENDCG
		}
	}
}
