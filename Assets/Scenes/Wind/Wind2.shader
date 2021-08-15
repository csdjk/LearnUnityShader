Shader "lcl/Wind/Wind2"
{
    Properties
    {
        _Color ("Main Color", Color) = (1,1,1,1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _NoiseTex ("Noise Tex", 2D) = "white" {}
        [PowerSlider(3.0)] _Cutoff ("Alpha cutoff", Range(0,1)) = 0.5

        [PowerSlider(3.0)] _TessellationFactors("_TessellationFactors", Range(1,60)) = 1

        _Direction("Direction",Vector) =(0,0,0,0) //运动的方向
        _TimeScale("TimeScale",float) = 1        //时间
        _TimeDelay("TimeDelay",float) = 1     //延迟
    }
    SubShader
    {
        Tags {"Queue"="AlphaTest" "RenderType"="TransparentCutout"}
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma hull hs
            #pragma domain ds

            #include "UnityCG.cginc"
            #include "Tessellation.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2t
            {
                float4 vertex : INTERNALTESSPOS;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
            };
            
            sampler2D _MainTex;
            sampler2D _NoiseTex;
            fixed4 _Color;
            fixed4 _Direction;
            half _TimeScale;
            half _TimeDelay;
            float _Cutoff;


            v2t vert (a2v v)
            {
                v2t o;
                // fixed4 worldPos =  mul(unity_ObjectToWorld,v.vertex);
                // half dis =  v.uv.y; //这里采用UV的高度来做。也可以用v.vertext.y
                // half time = (_Time.y + _TimeDelay) * _TimeScale;
                // v.vertex.xyz += dis * (sin(time + worldPos.x) * cos(time * 2 / 3) + 0.3)* _Direction.xyz;

                o.uv = v.uv;
                o.vertex = v.vertex;
                o.normal = v.normal;
                // o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }


            //有些硬件不支持曲面细分着色器，定义了该宏就能够在不支持的硬件上不会变粉，也不会报错
            #ifdef UNITY_CAN_COMPILE_TESSELLATION
                struct UnityTessellationFactors {
                    float edge[3] : SV_TessFactor;
                    float inside : SV_InsideTessFactor;
                };

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
                //拆分edge的规则，integer,fractional_odd,fractional_even
                [UNITY_partitioning("fractional_odd")]
                //输出拓扑结构 有三种：triangle_cw（顺时针环绕三角形）、triangle_ccw（逆时针环绕三角形）、line（线段）
                [UNITY_outputtopology("triangle_cw")]
                [UNITY_patchconstantfunc("hsConstFunc")]
                [UNITY_outputcontrolpoints(3)]
                [maxtessfactor(64.0f)]
                v2t hs(InputPatch<v2t, 3> v, uint id : SV_OutputControlPointID) {
                    return v[id];
                }

                v2f vert2frag(a2v v) {
                    v2f o;
                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.normal = v.normal;
                    o.uv = v.uv;
                    return o;
                }

                // domain 着色器 （细分计算着色器）
                [UNITY_domain("tri")]
                v2f ds(UnityTessellationFactors tessFactors, const OutputPatch<v2t, 3> vi, float3 bary : SV_DomainLocation) {
                    a2v v;
                    v.vertex = vi[0].vertex * bary.x + vi[1].vertex * bary.y + vi[2].vertex * bary.z;
                    v.normal = vi[0].normal * bary.x + vi[1].normal * bary.y + vi[2].normal * bary.z;
                    v.uv = vi[0].uv * bary.x + vi[1].uv * bary.y + vi[2].uv * bary.z;

                    // 方法一：
                    // fixed4 worldPos =  mul(unity_ObjectToWorld,v.vertex);
                    half dis =  v.uv.y; //这里采用UV的高度来做。也可以用v.vertext.y
                    half time = (_Time.y + _TimeDelay) * _TimeScale;
                    v.vertex.xyz += dis * (sin(time + v.vertex.x) * cos(time * 2 / 3) + 0.3)* _Direction.xyz;

                    // 二：
                    // 动画
                    // fixed offset = tex2D(_NoiseTex, v.uv).r;
                    // fixed3 windDir = float3(1,0,1);

                    // v.vertex.xz += windDir.xz * offset * 2;
                    // float y = v.vertex.y + _Direction.y;

                    // float x = v.vertex.x;
                    // float len = v.vertex.y;
                    // float len2 = sqrt(pow(len,2) - pow(y,2));
                    // float z = sqrt(pow(len2,2) - pow(x,2));

                    // v.vertex.xyz = float3(x,y,z);

                    // 最后需要转换到Clip裁剪空间
                    return vert2frag(v);
                }
            #endif

            

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 color = tex2D(_MainTex, i.uv);
                clip (color.a-_Cutoff);

                return color;
            }
            ENDCG
        }
    }
}
