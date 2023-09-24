Shader "lcl/SDF/SDFTest"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _BackgroundColor ("Background Color", Color) = (0, 0, 0, 1)
        _EdgeColor ("Edge Color", Color) = (0, 0, 0, 1)

        _Center ("Center", Vector) = (0.5, 0.5, 0, 0)
        _Size ("Size", Vector) = (0.2, 0.2, 0, 0)
        _Smoothness ("Smoothness", Range(0, 1)) = 0.01
        _EdgeWidth ("EdgeWidth", Range(0, 0.1)) = 0.01
        _SegmentCount ("SegmentCount", Vector) = (30, 10, 0, 0)
        _MixValue ("MixValue", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            // #pragma enable_d3d11_debug_symbols
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 screenPos : TEXCOORD1;
            };

            
            fixed4 _Color;
            fixed4 _BackgroundColor;
            fixed4 _EdgeColor;
            float4 _Size;
            float4 _Center;
            float _Smoothness;
            float _EdgeWidth;
            float2 _SegmentCount;
            float _MixValue;


            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.vertex);
                o.uv = v.uv;
                return o;
            }
            // https://iquilezles.org/articles/distfunctions2d/
            float CircleSDF(float2 uv, float2 center, float radius)
            {
                float result = length(uv - center) - radius;
                return result;
            }

            float BoxSDF(float2 p, float2 center, float2 b)
            {
                p -= center;
                float2 d = abs(p) - b;
                return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
            }

            //心形
            float HeartSDF(float2 uv, float2 center)
            {
                uv -= center;
                float a = atan2(uv.x, uv.y) / 3.141593;
                float r = length(uv);
                float h = abs(a);
                float d = 0.5 * (13.0 * h - 22.0 * h * h + 10.0 * h * h * h) / (6.0 - 5.0 * h);
                return r - d;
            }

            //六芒星
            float HexagramSDF(float2 p, float2 center, float r)
            {
                const float4 k = float4(-0.5, 0.8660254038, 0.5773502692, 1.7320508076);
                p -= center;
                p = abs(p);
                p -= 2.0 * min(dot(k.xy, p), 0.0) * k.xy;
                p -= 2.0 * min(dot(k.yx, p), 0.0) * k.yx;
                p -= float2(clamp(p.x, r * k.z, r * k.w), r);
                return length(p) * sign(p.y);
            }

            float EclipseSDF(float2 coord, float2 center, float a, float b)
            {
                float a2 = a * a;
                float b2 = b * b;
                return (b2 * (coord.x - center.x) * (coord.x - center.x) +
                a2 * (coord.y - center.y) * (coord.y - center.y) - a2 * b2) / (a2 * b2);
            }

            

            // float4 Render(float d, float3 color, float stroke)
            // {
            //     float anti = fwidth(d) * 1.0;
            //     float4 colorLayer = float4(color, 1.0 - smoothstep(-anti, anti, d));
            //     if (stroke < 0.000001)
            //     {
            //         return colorLayer;
            //     }

            //     float4 strokeLayer = float4(float3(0.05, 0.05, 0.05), 1.0 - smoothstep(-anti, anti, d - stroke));
            //     return float4(lerp(strokeLayer.rgb, colorLayer.rgb, colorLayer.a), strokeLayer.a);
            // }

            float4 Render(float sdf, float smoothness)
            {
                float lerpValue = smoothstep(smoothness, 0, sdf);
                float4 col = lerp(_BackgroundColor, _Color, lerpValue);
                return col;
            }

            
            float SubtractionSDF(float a, float b)
            {
                return max(a, -b);
            }
            float UnionSDF(float a, float b)
            {
                return min(a, b);
            }
            float IntersectionSDF(float a, float b)
            {
                return max(a, b);
            }
            float MixSDF(float a, float b, float value)
            {
                return lerp(a, b, saturate(value));
            }
            // 边缘
            float Edge(float sdf, float smoothness)
            {
                //边缘附近的SDF绝对值是接近0的。
                float edge = step(smoothness, abs(sdf));
                return edge;
            }

            // 等高线
            float Segment(float sdf)
            {
                float seg = floor(sdf * _SegmentCount.x);
                return seg / _SegmentCount.y;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 scale = float2(_ScreenParams.x / _ScreenParams.y, 1);

                float2 uv = (i.screenPos.xy / i.screenPos.w) * scale;
                float2 center = _Center.xy * scale;
                
                
                
                float circleSDF = CircleSDF(uv, center, _Size);
                // float boxSDF = BoxSDF(uv, center, _Size);
                float heartSDF = HeartSDF(uv, center);
                float hexagramSDF = HexagramSDF(uv,center, _Size);
                
                float sdf = MixSDF(circleSDF, hexagramSDF, _MixValue);
                // float4 color = Render(sdf, _Smoothness);
                // return color;

                // float edge = Edge(sdf, _EdgeWidth);
                // half4 color = lerp(_Color, _EdgeColor, edge);
                // return edge;

                //等高线
                // float seg = Segment(sdf);
                // half4 color = lerp(_Color, _EdgeColor, seg);
                
                sdf *= 30;
                float seg = floor(sdf); //离散化
                half4 color = lerp(_Color, _EdgeColor, seg / 5.0); //缩小系数
                seg = sdf - seg; //连续减离散区间，得到[0,1]的取值范围
                //seg - 0.5 ----取值范围[-0.5, 0.5]
                //abs(seg - 0.5) --- 取值范围 [0, 0.5] ，注意绝对值取值，函数图像已然变成倒三角: VVV
                //0.5 - abs(seg - 0.5) 对倒三角函数图像取反 : ∧∧∧∧
                //step(0.1, 0.5 - abs(seg - 0.5)) 以 0.1 为基准进行二值化
                color = lerp(half4(0, 0, 0, 1), color, smoothstep(0, 0.1, 0.5 - abs(seg - 0.5)));
                color = lerp(half4(1, 0, 0, 1), color, Edge(sdf, _EdgeWidth)); //查找边缘
                return color;


                // float4 layer1 = Render(sdf, _Color, fwidth(sdf) * 2.0);
                // return lerp(_BackgroundColor, layer1, layer1.a);

            }
            ENDCG
        }
    }
}
