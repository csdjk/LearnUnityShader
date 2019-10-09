Shader "lcl/001_Diffuse_vertex" {
	
	SubShader {
		Pass{
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM
			#include "Lighting.cginc"
			#pragma vertex vert
			#pragma fragment frag


			struct a2v {
				float4 vertex : POSITION;
				float3 normal: NORMAL;
			};

			struct v2f{
				float4 position:SV_POSITION;
				fixed3 color:COLOR;
			};

			v2f vert(a2v v){
				v2f f;
				f.position = UnityObjectToClipPos(v.vertex);
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

				fixed3 normalDir = normalize(mul(v.normal,(float3x3) unity_WorldToObject));
				fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 diffuse = _LightColor0.rgb * max(dot(normalDir,lightDir),0);
				f.color = diffuse+ambient;
				return f;
			};


			fixed4 frag(v2f f):SV_TARGET{
				return fixed4(f.color,1);
			};
		
			ENDCG
		}
	}
	FallBack "VertexLit"
}
