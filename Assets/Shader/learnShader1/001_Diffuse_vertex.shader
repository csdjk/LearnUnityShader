//create by 长生但酒狂
//漫反射 - 在顶点着色器计算
Shader "lcl/learnShader1/001_Diffuse_vertex" {
	//属性
	Properties{
		_Diffuse("Diffuse Color",Color) = (1,1,1,1)
	}
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

			float4 _Diffuse;

			// 顶点着色器
			v2f vert(a2v v){
				v2f f;
				// 转换到裁剪空间
				f.position = UnityObjectToClipPos(v.vertex);
				// 环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
				// 法线方向
				fixed3 normalDir = normalize(mul(v.normal,(float3x3) unity_WorldToObject));
				// 灯光方向
				fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				//漫反射计算
				fixed3 diffuse = _LightColor0.rgb * max(dot(normalDir,lightDir),0);
				f.color = (diffuse+ambient) * _Diffuse;
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
