// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "lcl/learnShader1/005_Specular_fargment" {
	//高光反射计算
	Properties{
		_Diffuse("Diffuse Color",Color) = (1,1,1,1)
		_Specular("_Specular Color",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8,200)) = 10
	}
	SubShader {
		Pass{
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM
			#include "Lighting.cginc"
			#pragma vertex vert
			#pragma fragment frag
			fixed4 _Diffuse;
			half _Gloss;
			fixed4 _Specular;


			struct a2v {
				float4 vertex : POSITION;
				float3 normal: NORMAL;
			};

			struct v2f{
				float4 position:SV_POSITION;
				float3 worldNormal: TEXCOORD0;
				float3 worldVertex: TEXCOORD1;

			};

			v2f vert(a2v v){
				v2f f;
				f.position = UnityObjectToClipPos(v.vertex);
				f.worldNormal = mul(v.normal,(float3x3) unity_WorldToObject);
				f.worldVertex = mul(v.vertex,unity_WorldToObject).xyz;
				return f;
			};


			fixed4 frag(v2f f):SV_TARGET{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

				fixed3 normalDir = normalize(f.worldNormal);
				fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 diffuse = _LightColor0.rgb * max(dot(normalDir,lightDir),0) * _Diffuse.rgb;
				//高光反射
				fixed3 reflectDir = reflect(-lightDir,normalDir);//反射光
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz -f.worldVertex );
				fixed3 specular = _LightColor0.rgb * pow(max(0,dot(viewDir,reflectDir)),_Gloss) *_Specular;
				fixed3 tempColor = diffuse+ambient+specular;

				return fixed4(tempColor,1);
			};
		
			ENDCG
		}
	}
	FallBack "VertexLit"
}