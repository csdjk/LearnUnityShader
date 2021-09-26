// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "lcl/shader3D/screenCaptrue" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" "Queue"="Overlay"}
		GrabPass{} //截图通道
		Pass{

			CGPROGRAM

			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _GrabTexture;
			float4 _GrabTexture_ST;

			#include "Lighting.cginc"
			#pragma vertex vert
			#pragma fragment frag


			struct a2v {
				float4 vertex : POSITION;
				float2 uv:TEXCOORD0;
			};

			struct v2f{
				float4 position:SV_POSITION;
				float2 uv:TEXCOORD0;

			};

			

			v2f vert(a2v v){
				v2f f;
				float dist = distance(v.vertex.xyz, float3(0,0,0));

				float h = sin(dist * 2 + _Time.z) / 5;
				v.vertex.y = h;
				f.position = UnityObjectToClipPos(v.vertex);
				f.uv = TRANSFORM_TEX(v.uv,_MainTex);
				return f;
			};

			fixed4 frag(v2f f):SV_TARGET{
				
				fixed4 col = tex2D(_GrabTexture,f.uv);
				return col;
			};
			ENDCG
		}
	}
	FallBack "Diffuse"
}
