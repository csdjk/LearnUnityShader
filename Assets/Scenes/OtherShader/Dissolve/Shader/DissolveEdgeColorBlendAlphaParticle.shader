Shader "lcl/OtherShader/DissolveEdgeColorBlendAlphaParticle"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_NoiseTex("Noise", 2D) = "white" {}
		_EdgeLength("Edge Length", Range(0.0, 0.2)) = 0.1
		_EdgeSecondColor("EdgeSecondColor", Color) = (1,1,1,1)
	}
	SubShader
	{
		Tags { "Queue"="Transparent" "RenderType"="Transparent" }

		Pass
		{
			Cull Off //要渲染背面保证效果正确
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off 

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 uv : TEXCOORD0;
				float3 edgeColor: TEXCOORD1;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 color : COLOR;
				float4 uv : TEXCOORD0;
				float4 thresholdAndColor : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _NoiseTex;
			float4 _NoiseTex_ST;
			float _EdgeLength;
			fixed3 _EdgeFirstColor;
			fixed3 _EdgeSecondColor;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.uv, _NoiseTex);
				o.color = v.color;
				o.thresholdAndColor.x = v.uv.z;
				o.thresholdAndColor.yzw = v.edgeColor;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float threshold = i.thresholdAndColor.x;
				float3 firstColor = i.thresholdAndColor.yzw;

				//镂空
				fixed cutout = tex2D(_NoiseTex, i.uv.zw).r;
				clip(cutout - threshold);
				//边缘颜色
				float degree = saturate((cutout - threshold) / _EdgeLength); //需要保证在[0,1]以免后面插值时颜色过亮
				fixed3 edgeColor = lerp(firstColor, _EdgeSecondColor, degree);

				fixed4 col = tex2D(_MainTex, i.uv.xy) * i.color;

				fixed3 finalColor = lerp(edgeColor, col, degree);

				return fixed4(finalColor, col.a);
			}
			ENDCG
		}
	}
}
