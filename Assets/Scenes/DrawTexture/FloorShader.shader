Shader "lcl/Tessell/FloorShader" {
    Properties {
        _FloorTex ("Floor Texture", 2D) = "white" {}
        _FloorColor ("Floor Color", Color) = (1, 1, 1, 1)
        _SnowTex ("Snow Texture", 2D) = "white" {}
        _SnowColor ("Snow Color", Color) = (1, 1, 1, 1)
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
            
            sampler2D _MaskTex;

            sampler2D _FloorTex;
            fixed4 _FloorColor;
            sampler2D _SnowTex;
            fixed4 _SnowColor;

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
            
            struct t2f {
                float4 pos : SV_POSITION;
                float4 normal : NORMAL;
                float2 uv : TEXCOORD0;
                float3 worldNormalDir:TEXCOORD1;
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

                // t2f vert2frag(a2v v) {
                //     t2f o;
                //     o.pos = UnityObjectToClipPos(v.vertex);
                //     o.worldNormalDir = v.worldNormalDir;
                //     return o;
                // }

                // domain 着色器 （细分计算着色器）
                // bary: 重心坐标
                [UNITY_domain("tri")]
                t2f ds(UnityTessellationFactors tessFactors, const OutputPatch<v2t, 3> vi, float3 bary : SV_DomainLocation) {
                    t2f v;
                    v.pos = vi[0].vertex * bary.x + vi[1].vertex * bary.y + vi[2].vertex * bary.z;
                    v.normal = vi[0].normal * bary.x + vi[1].normal * bary.y + vi[2].normal * bary.z;
                    v.uv = vi[0].uv * bary.x + vi[1].uv * bary.y + vi[2].uv * bary.z;

                    float4 maskTexVar = tex2Dlod(_MaskTex,float4(v.uv,0,0));
                    v.pos -= v.normal * maskTexVar.r;

                    // v.worldNormalDir = mul(unity_ObjectToWorld,v.normal).xyz;
                    v.worldNormalDir = mul(v.normal,(float3x3) unity_WorldToObject).xyz;
                    // 最后需要转换到Clip裁剪空间
                    v.pos = UnityObjectToClipPos(v.pos);
                    return v;
                }
            #endif
            

            fixed4 frag(t2f i) : SV_Target {

                fixed3 normalDir = normalize(i.worldNormalDir);
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                //半兰伯特漫反射 值范围0-1
                fixed3 halfLambert = dot(normalDir,lightDir)*0.5+0.5;	
                fixed3 diffuse = _LightColor0.rgb * halfLambert;

                // 积雪下陷
                float4 amount = tex2Dlod(_MaskTex,float4(i.uv,0,0)).r;

                float4 floorCol = tex2D(_FloorTex,i.uv) * _FloorColor;
                float4 snowCol = tex2D(_FloorTex,i.uv)* _SnowColor;
                float4 res = lerp(snowCol,floorCol,amount);

                res.rgb *= diffuse;
                return res;

                // return float4(i.worldNormalDir,1);
            }
            
            ENDCG
        }
    } 
    FallBack "Diffuse"
}