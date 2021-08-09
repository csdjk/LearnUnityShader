//create by 长生但酒狂
//漫反射 - 在片元着色器计算
Shader "lcl/PBR/BRDF_Test" {
    //属性
    Properties{
        _Diffuse("Diffuse Color",Color) = (1,1,1,1)
        _Roughness ("Roughness", Range(0, 10)) = 1.0
        
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
                float3 worldNormalDir:COLOR0;
				float3 worldPos : TEXCOORD0;
  				fixed3 worldViewDir : TEXCOORD1;
            };

            v2f vert(a2v v){
                v2f o;
                o.position = UnityObjectToClipPos(v.vertex);
                o.worldNormalDir = mul(v.normal,(float3x3) unity_WorldToObject);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
                return o;
            };

            float4 _Diffuse;
            float _Roughness;
            float INV_PI = 1/3.14159;

            float DisneyDiffuse(float3 In, float3 Out,float3 normal)
            {
                float oneMinusCosL = 1.0f - max(dot(normal,In),0);
                float oneMinusCosLSqr = oneMinusCosL * oneMinusCosL;
                float oneMinusCosV = 1.0f - max(dot(normal,Out),0);
                float oneMinusCosVSqr = oneMinusCosV * oneMinusCosV;

                // Roughness是粗糙度，IDotH的意思会在下一篇讲Microfacet模型时提到
                float IDotH = dot(In, normalize(In + Out));
                float F_D90 = 0.5f + 2.0f * IDotH * IDotH * _Roughness;

                return INV_PI * (1.0f + (F_D90 - 1.0f) * oneMinusCosLSqr * oneMinusCosLSqr * oneMinusCosL) *
                (1.0f + (F_D90 - 1.0f) * oneMinusCosVSqr * oneMinusCosVSqr * oneMinusCosV);
            }

            fixed4 frag(v2f i):SV_TARGET{
                // 环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                //法线
                fixed3 normalDir = normalize(i.worldNormalDir);
                //灯光
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                //漫反射计算
                fixed3 diffuse = _LightColor0.rgb * max(dot(normalDir,lightDir),0);
                fixed3 resultColor = (diffuse+ambient) * _Diffuse;


                fixed3 reflectDir = reflect(-lightDir,normalDir);//反射光

				fixed3 worldViewDir = normalize(i.worldViewDir);

                return DisneyDiffuse(lightDir,worldViewDir,normalDir);
            
            };
            
            ENDCG
        }
    }
    FallBack "VertexLit"
}
