// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "lcl/shader3D/001_vertexAndUvAnim" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Speed ("Speed", Float) = 0.5

	}
	SubShader {
		Pass{
			Tags { "RenderType"="Opaque" }

			CGPROGRAM

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Speed;

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
				f.uv +=  float2( _Time.y * _Speed,0.0);

				return f;
			};
			/**

			float dist = distance(v.vertex.xyz, float3(0,0,0));

			float h = sin(dist + _Time.z);
			f.position = mul(unity_ObjectToWorld,v.vertex);
			f.position.y = h;
			f.position = mul(unity_WorldToObject,f.position);
			
			f.position = UnityObjectToClipPos(f.position);
			**/

			fixed4 frag(v2f f):SV_TARGET{
				
				fixed4 col = tex2D(_MainTex,f.uv);
				return col;
			};
			ENDCG
		}
	}
	FallBack "Diffuse"
}
