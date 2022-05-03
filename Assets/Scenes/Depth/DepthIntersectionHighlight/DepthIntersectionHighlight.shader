Shader "lcl/Depth/DepthIntersectionHighlight"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_IntersectionColor("Intersection Color", Color) = (1,1,0,0)
		_IntersectionWidth("Intersection Width", Range(0, 1)) = 0.1
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
				float4 screenPos : TEXCOORD1;
				float eyeZ : TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _CameraDepthTexture;
			fixed4 _IntersectionColor;
			float _IntersectionWidth;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.screenPos = ComputeScreenPos(o.vertex);
				COMPUTE_EYEDEPTH(o.eyeZ);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);

				float screenZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos)));
				
				float halfWidth = _IntersectionWidth / 2;
				float diff = saturate(abs(i.eyeZ - screenZ) / halfWidth);

				fixed4 finalColor = lerp(_IntersectionColor, col, diff);
				// return finalColor;
				return i.eyeZ;
			}
			ENDCG
		}
	}
}