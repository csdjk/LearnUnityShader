Shader "lcl/Tessell/TessellDemo1" {
    Properties {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _TessellationFactors("_TessellationFactors", Vector) = (1, 1, 1, 1)
        [Enum(UnityEngine.Rendering.CompareFunction)]_StencilComp ("Stencil Comparison", Float) = 8
        // [Enum(First,1,Second,2,Third,3,Fourth,4,Fifth,5,Sixth,6)] _ColorType ("Color Type", Int) = 1   
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
            //引入曲面细分的头文件
            #include "Tessellation.cginc"

            fixed4 _Color;

            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            
            struct v2t {
                float4 vertex : INTERNALTESSPOS;
                float3 normal : NORMAL;
            };
            
            struct v2f {
                float4 pos : SV_POSITION;
            };
            
            // 顶点着色器（简单的对数据进行传输到曲面细分着色器）
            v2t vert(a2v v) {
                v2t o;
                o.vertex = v.vertex;
                o.normal = v.normal;
                return o;
            }

            //有些硬件不支持曲面细分着色器，定义了该宏就能够在不支持的硬件上不会变粉，也不会报错
            #ifdef UNITY_CAN_COMPILE_TESSELLATION
                struct UnityTessellationFactors {
                    float edge[3] : SV_TessFactor;
                    float inside : SV_InsideTessFactor;
                };


                float4 _TessellationFactors;
                UnityTessellationFactors hsConstFunc(InputPatch<v2t, 3> v) {
                    //定义曲面细分的参数
                    UnityTessellationFactors o;
                    o.edge[0] = _TessellationFactors.x; 
                    o.edge[1] = _TessellationFactors.y; 
                    o.edge[2] = _TessellationFactors.z;
                    o.inside = _TessellationFactors.w;
                    return o;
                }

                [UNITY_domain("tri")]
                [UNITY_partitioning("fractional_odd")]//拆分edge的规则，equal_spacing,fractional_odd,fractional_even
                [UNITY_outputtopology("triangle_cw")]
                [UNITY_patchconstantfunc("hsConstFunc")]//一个patch一共有三个点，但是这三个点都共用这个函数
                [UNITY_outputcontrolpoints(3)]
                // hull 着色器
                v2t hs(InputPatch<v2t, 3> v, uint id : SV_OutputControlPointID) {
                    return v[id];
                }

                v2f vert2frag(a2v v) {
                    v2f o;
                    o.pos = UnityObjectToClipPos(v.vertex);
                    return o;
                }

                // domain 着色器
                [UNITY_domain("tri")]
                v2f ds(UnityTessellationFactors tessFactors, const OutputPatch<v2t, 3> vi, float3 bary : SV_DomainLocation) {
                    a2v v;
                    v.vertex = vi[0].vertex * bary.x + vi[1].vertex * bary.y + vi[2].vertex * bary.z;
                    v.normal = vi[0].normal * bary.x + vi[1].normal * bary.y + vi[2].normal * bary.z;
                    // 最后需要转换到Clip裁剪空间
                    return vert2frag(v);
                }
            #endif
            

            fixed4 frag(v2f i) : SV_Target {
                return _Color;
            }
            
            ENDCG
        }
    } 
    FallBack "Specular"
}