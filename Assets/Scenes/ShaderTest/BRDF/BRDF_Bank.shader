Shader "lcl/ShaderTest/BRDF_Bank"
{
    Properties{
        _Diffuse("Diffuse Color",Color) = (1,1,1,1)
        _Specular("Specular Color",Color) = (1,1,1,1)
        _SpecularFactor("Specular Factor",range(0,10)) = 1
        _MirrorFatcor("Mirror Factor",range(0,10)) = 1

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
                float3 viewDir : TEXCOORD0;
            };

            v2f vert(a2v v){
                v2f o;
                o.position = UnityObjectToClipPos(v.vertex);
                o.worldNormalDir = mul(v.normal,(float3x3) unity_WorldToObject);
                o.viewDir = ObjSpaceViewDir(v.vertex);
                return o;
            };

            float4 _Diffuse;
            float4 _Specular;
            
            float _SpecularFactor;
            float _MirrorFatcor;

            half4 frag(v2f i):SV_TARGET{
                // 环境光
                half3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                //法线
                half3 normalDir = normalize(i.worldNormalDir);
                //灯光
                half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                //漫反射计算
                half3 diffuse = _LightColor0.rgb * max(dot(normalDir,lightDir),0);

                // BRDF计算
                // 视野方向
                half3 viewDir = normalize(i.viewDir);

                //计算顶点切向量
                float3 T = normalize(cross(normalDir,viewDir)); 
                // 1
                float lt = dot(lightDir,T);
                float vt = dot(viewDir,T);
                float brdf = _MirrorFatcor * pow(sqrt(1-pow(lt,2)) * sqrt(1-pow(vt,2)) - lt*vt,_SpecularFactor);
                
                half3 specular = _Specular * brdf;


                half3 resultColor = (diffuse + ambient + specular) * _Diffuse;

                return half4(resultColor,1);
            };
            
            ENDCG
        }
    }
    FallBack "VertexLit"
}