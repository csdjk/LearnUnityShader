Shader "lcl/Tessell/TessellDemo1" {
    Properties {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _TessellationFactors("_TessellationFactors", Vector) = (1, 1, 1, 1)
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

                //InputPatch<v2t, 3> 表示输入的数据有3个v2t结构体，即对于三角形三个顶点
                UnityTessellationFactors hsConstFunc(InputPatch<v2t, 3> v) {
                    //定义曲面细分的参数
                    UnityTessellationFactors o;
                    // 对三角形的三条边进行分割，每条边都分割成对应份数(_TessellationFactors)
                    o.edge[0] = _TessellationFactors.x; 
                    o.edge[1] = _TessellationFactors.y; 
                    o.edge[2] = _TessellationFactors.z;
                    // 指定三角形内部有多少个点，计算方式：对于三角形的每个顶点，将他们的临边分割，然后在分割点上做垂线，得到的交点即为内部点
                    o.inside = _TessellationFactors.w;
                    return o;
                }

                // domain: 指定patch的类型，可选的有：tri(三角形)、quad（四边形）、isoline（线段，苹果的metal api不支持：2018/8/21）。
                [UNITY_domain("tri")]
                //拆分edge的规则，integer,fractional_odd,fractional_even
                [UNITY_partitioning("integer")]
                //输出拓扑结构 有三种：triangle_cw（顺时针环绕三角形）、triangle_ccw（逆时针环绕三角形）、line（线段）
                [UNITY_outputtopology("triangle_cw")]
                //一个patch一共有三个点，但是这三个点都共用这个函数
                [UNITY_patchconstantfunc("hsConstFunc")]
                // 输出的控制点的数量（每个图元），不一定与输入数量相同，也可以新增控制点。
                [UNITY_outputcontrolpoints(3)]
                // 最大细分度，告知驱动程序shader用到的最大细分度，硬件可能会针对这个做出优化。Direct3D 11和OpenGL Core都至少支持64。
                [maxtessfactor(64.0f)]
                // hull 着色器（细分控制着色器）函数 hs 
                // 虽然输入参数是一个三角形 patch 的三个顶点数据，但是 hs 每次只输出一个顶点，需要处理的顶点通过参数 id 指定。
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
    FallBack "Diffuse"
}