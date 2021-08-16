Shader "lcl/Tessell/FloorShader" {
    Properties {
        _Color ("Color", Color) = (1, 1, 1, 1)
        [PowerSlider(3.0)]_TessellationFactors("_TessellationFactors",Range(1,20)) = 1
    }
    SubShader {
        Pass { 
            Tags { "LightMode"="ForwardBase" }
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            #pragma hull hs
            #pragma domain ds

            #include "UnityCG.cginc"
			#include "Lighting.cginc"
            //引入曲面细分的头文件
            // #include "Tessellation.cginc"

            fixed4 _Color;
            sampler2D _MaskTex;

            struct a2v {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
                float2 uv : TEXCOORD0;
                float3 worldNormalDir:TEXCOORD1;
            };
            
            struct v2t {
                float4 vertex : INTERNALTESSPOS;
                float4 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };
            
            struct v2f {
                float4 pos : SV_POSITION;
            };
            
            // 顶点着色器（简单的对数据进行传输到曲面细分着色器）
            v2t vert(a2v v) {
                v2t o;
                o.vertex = v.vertex;
                o.normal = v.normal;
                o.uv = v.uv;
                return o;
            }

            #ifdef UNITY_CAN_COMPILE_TESSELLATION
                // struct UnityTessellationFactors {
                //     float edge[3] : SV_TessFactor;
                //     float inside : SV_InsideTessFactor;
                // };


                float _TessellationFactors;

                UnityTessellationFactors hsConstFunc(InputPatch<v2t, 3> v) {
                    UnityTessellationFactors o;
                    o.edge[0] = _TessellationFactors; 
                    o.edge[1] = _TessellationFactors; 
                    o.edge[2] = _TessellationFactors;
                    o.inside = _TessellationFactors;
                    return o;
                }

                [UNITY_domain("tri")]
                [UNITY_partitioning("fractional_odd")]
                [UNITY_outputtopology("triangle_cw")]
                [UNITY_patchconstantfunc("hsConstFunc")]
                [UNITY_outputcontrolpoints(3)]
                [maxtessfactor(64.0f)]
                // hull 着色器（细分控制着色器）函数 hs 
                v2t hs(InputPatch<v2t, 3> v, uint id : SV_OutputControlPointID) {
                    return v[id];
                }

                v2f vert2frag(a2v v) {
                    v2f o;
                    o.pos = UnityObjectToClipPos(v.vertex);
                    return o;
                }

                // domain 着色器 （细分计算着色器）
                // bary: 重心坐标
                [UNITY_domain("tri")]
                v2f ds(UnityTessellationFactors tessFactors, const OutputPatch<v2t, 3> vi, float3 bary : SV_DomainLocation) {
                    a2v v;
                    v.vertex = vi[0].vertex * bary.x + vi[1].vertex * bary.y + vi[2].vertex * bary.z;
                    v.normal = vi[0].normal * bary.x + vi[1].normal * bary.y + vi[2].normal * bary.z;
                    v.uv = vi[0].uv * bary.x + vi[1].uv * bary.y + vi[2].uv * bary.z;

                    float4 maskTexVar = tex2Dlod(_MaskTex,float4(v.uv,0,0));
                    v.vertex -= v.normal * maskTexVar.r;

                    v.worldNormalDir = mul(unity_ObjectToWorld,v.normal).xyz;
                    // 最后需要转换到Clip裁剪空间
                    return vert2frag(v);
                }
            #endif
            

            fixed4 frag(v2f i) : SV_Target {

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                fixed3 normalDir = normalize(i.worldNormalDir);
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                //半兰伯特漫反射  值范围0-1
                fixed3 halfLambert = dot(normalDir,lightDir)*0.5+0.5;	
                fixed3 diffuse = _LightColor0.rgb * halfLambert;
                fixed3 resultColor = (diffuse + ambient) * _Diffuse;


                return _Color;
            }
            
            ENDCG
        }
    } 
    FallBack "Diffuse"
}