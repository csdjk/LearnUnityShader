// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "lcl/PointLight/DifSpecPoint" {
    Properties {
        _Spec ("Spec", Color) = (1,1,1,1)  //高光颜色
        _Shin ("Shin", range(1,32)) = 2      //高光强度系数
    }
    SubShader {
        pass {
            tags{ "lightmode" = "forwardbase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "unitycg.cginc"
            #include "lighting.cginc"
            fixed4 _Spec;
            float _Shin;
            struct v2f{
                float4 pos:POSITION;
                float3 normal:NORMAL;
                float4 vertex:TEXCOORD2;
            };
            v2f vert(appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normal = normalize(v.normal);
                o.vertex = v.vertex;
                return o;
            }
            fixed4 frag(v2f IN):COLOR
            {
                float3 wpos = mul(unity_ObjectToWorld, IN.vertex).xyz;  //计算世界坐标系空间中的物体坐标（三维向量）
                //diffuse 漫反射
                float3 N = UnityObjectToWorldNormal(IN.normal);     //计算世界坐标空间中的法线向量
                float3 L = normalize(_WorldSpaceLightPos0).xyz;    //计算世界坐标空间中平行光向量
                float ndotl = saturate(dot(N, L));                                    //点积得平行光颜色系数
                fixed4 col = _LightColor0*ndotl;                                   //平行光颜色*系数得颜色
                //specular  高光
                float3 V = normalize(WorldSpaceViewDir(IN.vertex));    //计算世界坐标空间中的视向量
                float3 R = 2 * dot(N, L)*N - L;	//phong                                //反射向量
                float3 H = normalize(V + L);	//blinnphong                         //半角向量：点到光源+点到摄像的单位向量，平均值
                float specScale = pow(saturate(dot(R, V)), _Shin);	//phong
                //specScale = pow(saturate(dot(H, N)), _Shin);		//blinnphong
                col += _Spec*specScale;                                       //颜色+高光*高光系数
                
                //pointlight  接收点光源
                //Shade4PointLights来自unitycg.cginc
                //其中用的参数前七个unity_4LightPosX0~unity4LightAtten0来自UnityShaderVariables.cginc，内建不需引用
                float3 pL = Shade4PointLights(unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
                unity_4LightAtten0,
                wpos, N);
                col.rgb += pL;     //颜色+点光源反光

                col += UNITY_LIGHTMODEL_AMBIENT;  //最后加上环境光
                return col;
            }
            ENDCG
        }
    }
}