Shader "lcl/Lighting/FastVolumeLight"
{
    Properties
    {
        [Tips()][KeywordEnum(Sphere, Box, Cylinder, Cone)] _TYPE ("Volume Type(尽量用Sphere和Box类型，性能好点)", Int) = 0
        [HDR]_Color ("Color Tint", Color) = (1, 1, 1, 1)
        _Radius ("Radius", Range(0, 1)) = 0.5
        _RadFallOut ("RadFallOut", Range(0.01, 2)) = 1
        _ZFallOut ("ZFallOut", Range(0.01, 2)) = 0
        // _Center ("Center", Vector) = (1, 1, 1, 1)

    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" "DisableBatching" = "True" }
        LOD 300
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            ZTest Off
            // Blend One One
            Blend SrcAlpha One
            Cull Front

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            #pragma multi_compile _TYPE_SPHERE _TYPE_BOX _TYPE_CYLINDER _TYPE_CONE

            sampler2D _CameraDepthTexture;
            half4 _Color;
            half _Radius;

            half _RadFallOut;
            half _ZFallOut;
            // float3 _Center;
            struct a2v
            {
                float4 vertex : POSITION;
            };
            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 screenPos : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float3 cameraOS : TEXCOORD2;
                float3 cameraDir : TEXCOORD3;
            };
            
            v2f vert(a2v v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.vertex);
                o.positionWS = mul(unity_ObjectToWorld, v.vertex);
                o.cameraOS = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos.xyz, 1));
                o.cameraDir = -normalize(UNITY_MATRIX_V[2].xyz);
                return o;
            }

            
            inline half SmoothValue(half V, half threshold, half smoothness)
            {
                half minValue = saturate(threshold - smoothness);
                half maxValue = saturate(threshold + smoothness);
                return smoothstep(minValue, maxValue, V);
            }
            // https://iquilezles.org/articles/intersectors/
            // 与球相交
            float2 SphereIntersect(float3 ro, float3 rd, float sr, float sceneDistance, half radFallOut)
            {
                //这里的rd是没有归一化的，所以可以获得物体缩放值的平方。总之之前椭球公式是这样写的
                float a = dot(rd, rd);
                float b = 2.0 * dot(ro, rd);
                float c = dot(ro, ro) - (sr * sr);
                float d = b * b - 4 * a * c;
                // if (d < 0) return 0;//判断出未相交则返回0
                half result = d < 0 ? 0 : 1;
                
                d = sqrt(d);
                // 得到相交的近点和远点(距离)
                float2 sphere = float2(-b - d, -b + d) / (2 * a);
                sphere.x = max(sphere.x, 0);//处理视点在球内的情况
                sphere.y = min(sphere.y, sceneDistance);//处理深度遮挡

                float3 mid = ro + rd * (sphere.x + sphere.y) * 0.5;//获得中点

                // float alpha = 1 - length(mid-_Center.xyz) / sr;//以中点距离球心的距离作为亮度
                float alpha = 1 - length(mid) / sr;//以中点距离球心的距离作为亮度

                alpha = alpha / radFallOut;
                alpha = smoothstep(0, 1, alpha);
                return alpha * result;
            }

            half BoxIntersection(float3 ro, float3 rd, float3 ra, float sceneDistance, half zFallOut, half radFallOut)
            {
                sceneDistance *= length(rd);
                rd = normalize(rd);

                float3 m = 1.0 / rd;
                float3 n = m * ro;
                float3 k = abs(m) * ra;
                float3 t1 = -n - k;
                float3 t2 = -n + k;
                float tN = max(max(t1.x, t1.y), t1.z);
                float tF = min(min(t2.x, t2.y), t2.z);
                // if (tN > tF || tF < 0.0) return 0;
                half result = (tN > tF || tF < 0.0) ? 0 : 1;

                float2 sphere = float2(tN, tF);
                sphere.x = max(sphere.x, 0);
                sphere.y = min(sphere.y, sceneDistance);
                float alpha = (sphere.y - sphere.x) / ra * 0.5;

                float3 mid = ro + rd * (sphere.x + sphere.y) * 0.5;
                mid = abs(mid) * zFallOut + 1 - zFallOut;
                alpha *= 1 - smoothstep(0, 1, mid.z / ra);
                alpha *= 1 - smoothstep(0, 1, mid.x / ra);
                alpha *= 1 - smoothstep(0, 1, mid.y / ra);

                alpha = alpha / radFallOut;
                // alpha = smoothstep(0, 1, alpha);
                return alpha * result;
            }
            half CylinderIntersection(float3 ro, float3 rd, float3 ra, float sceneDistance, half zFallOut, half radFallOut)
            {
                sceneDistance *= length(rd);
                rd = normalize(rd);

                float3 cb = float3(0, 0, 0);
                float3 ca = float3(0, 0, 1);
                float3 oc = ro - cb;
                float card = dot(ca, rd);
                float caoc = dot(ca, oc);
                float a = 1.0 - card * card;
                float b = dot(oc, rd) - caoc * card;
                float c = dot(oc, oc) - caoc * caoc - ra * ra;
                float h = b * b - a * c;
                // if (h < 0) return 0;
                half result = h < 0 ? 0 : 1;

                h = sqrt(h);
                float2 sphere = float2(-b - h, -b + h) / a;

                sphere.x = max(sphere.x, 0);
                sphere.y = min(sphere.y, sceneDistance);
                float alpha = (sphere.y - sphere.x) / ra * 0.5;

                float3 mid = ro + rd * (sphere.x + sphere.y) * 0.5;
                alpha *= smoothstep(0, 1, max(0, 1 - length(mid.xy) / ra * radFallOut));
                // alpha *= pow(1 - length(mid.z + ra) / ra * 0.5 * zFallOut, 2);

                alpha = alpha / zFallOut;
                return alpha * result;
            }
            half ConeIntersection(float3 ro, float3 rd, float sr, float sceneDistance, half zFallOut, half radFallOut)
            {

                sceneDistance *= length(rd);
                rd = normalize(rd);

                float ra = sr;
                float rb = 0;
                float3 pa = float3(0, 0, -sr);
                float3 pb = float3(0, 0, sr);

                float3 ba = pb - pa;
                float3 oa = ro - pa;
                float3 ob = ro - pb;
                float m0 = dot(ba, ba);
                float m1 = dot(oa, ba);
                float m2 = dot(rd, ba);
                float m3 = dot(rd, oa);
                float m5 = dot(oa, oa);
                float m9 = dot(ob, ba);
                
                // float rr = ra - rb;
                // float hy = m0 + rr * rr;
                // float k2 = m0 * m0 - m2 * m2 * hy;
                // float k1 = m0 * m0 * m3 - m1 * m2 * hy + m0 * ra * (rr * m2 * 1.0);
                // float k0 = m0 * m0 * m5 - m1 * m1 * hy + m0 * ra * (rr * m1 * 2.0 - m0 * ra);
                // float h = k1 * k1 - k2 * k0;

                float m02 = m0 * m0;
                float m0_ra = m0 * ra;
                float rr = ra - rb;
                float m0_ra_rr = m0_ra * rr;
                float hy = m0 + rr * rr;
                float m2_hy = m2 * hy;
                float k2 = m02 - m2 * m2_hy;
                float k1 = m02 * m3 - m1 * m2_hy + m0_ra_rr * m2;
                float k0 = m02 * m5 - m1 * m1 * hy + m0_ra_rr * m1 * 2.0 - m0_ra * m0_ra;
                float h = k1 * k1 - k2 * k0;



                // if (h < 0.0) return 0;//不相交
                half result = step(0, h);

                h = sqrt(h);
                float2 sphere = float2(-k1 - h, -k1 + h) / k2;
                float y = m1 + sphere.x * m2;//处理下方圆盘
                float3 temp2 = oa * m2 - rd * m1;

                UNITY_FLATTEN
                if (dot(temp2, temp2) < ra * ra * m2 * m2)
                {
                    float m1_2 = -m1 / m2;
                    UNITY_FLATTEN
                    if (rd.z < 0.0)
                    {
                        sphere.y = m1_2;
                    }
                    else
                    {
                        sphere.x = m1_2;
                    }
                }
                else
                {
                    //处理内部向上看
                    float rc = -m9 / m0 * (ra - rb) + rb;
                    float3 temp = cross(ob, -ba);
                    float rc2 = sqrt(dot(temp, temp) / m0);
                    UNITY_FLATTEN
                    if (y < 0 || y > m0)
                    {
                        if (rc <= rc2) return 0;
                        sphere.x = 0;
                    }
                }
                sphere.x = max(sphere.x, 0);
                sphere.y = min(sphere.y, sceneDistance);
                float3 mid = ro + rd * (sphere.x + sphere.y) * 0.5;
                float mid_h = saturate((mid.z - pb.z) / (pa.z - pb.z));
                float mid_r = mid_h * (ra - rb) + rb;
                float alpha = smoothstep(0, 1, (sphere.y - sphere.x) / ra);
                alpha *= pow(1 - saturate(length(mid - pb) / sr * 0.5 * zFallOut), 2);
                alpha *= pow(1 - saturate(length(mid.xy) / mid_r * radFallOut), 2);
                return alpha * result;
            }

            half4 frag(v2f i) : SV_Target
            {
                half2 screenUV = i.screenPos.xy / i.screenPos.w;
                float3 cameraDir = normalize(i.cameraDir);

                float3 viewDirWS = normalize(i.positionWS - _WorldSpaceCameraPos.xyz);
                // return half4(viewDirWS, 1);
                // 这里不能归一化
                // float3 viewDirOS = mul(unity_WorldToObject, float4(viewDirWS.xyz, 0));
                float3 viewDirOS = mul(unity_WorldToObject, float4(viewDirWS.xyz, 0));

                float sceneDepth = tex2D(_CameraDepthTexture, screenUV);
                sceneDepth = LinearEyeDepth(sceneDepth);
                float3 sceneDistance = sceneDepth / dot(viewDirWS, cameraDir) ;
                

                float3 rayDir = viewDirOS;
                float3 rayOrigin = i.cameraOS;
                // ================================  ================================
                #if defined(_TYPE_SPHERE)
                    half alpha = SphereIntersect(rayOrigin, rayDir, _Radius, sceneDistance, _RadFallOut);
                #elif defined(_TYPE_BOX)
                    half alpha = BoxIntersection(rayOrigin, rayDir, _Radius, sceneDistance, _ZFallOut, _RadFallOut);
                #elif defined(_TYPE_CYLINDER)
                    half alpha = CylinderIntersection(rayOrigin, rayDir, _Radius, sceneDistance, _ZFallOut, _RadFallOut);
                #elif defined(_TYPE_CONE)
                    half alpha = ConeIntersection(rayOrigin, rayDir, _Radius, sceneDistance, _ZFallOut, _RadFallOut);
                #else
                    half alpha = 1;
                #endif

                half4 res = alpha * _Color;
                res.rgb = max(res.rgb, 0);
                res.a = saturate(res.a);
                return res;
            }
            ENDCG
        }
    }
}
