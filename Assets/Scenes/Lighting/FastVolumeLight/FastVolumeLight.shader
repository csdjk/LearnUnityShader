Shader "lcl/Lighting/FastVolumeLight"
{
    Properties
    {
        [KeywordEnum(Sphere, Box, Cylinder, Cone)] _TYPE ("Volume Type", Int) = 0
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _Radius ("_Radius", Range(0, 5)) = 0.5

        _SphereRadFallOut ("Sphere Rad Fall Out", Range(0, 1)) = 0.5
        _SphereIntensity ("Sphere Intensity", Range(0, 2)) = 1

        _RadFallOut ("RadFallOut", Range(0, 1)) = 0.5
        _ZFallOut ("ZFallOut", Range(0, 10)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            ZTest Off
            Blend One One
            // Blend SrcAlpha One
            Cull Front

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
            #pragma multi_compile _TYPE_SPHERE _TYPE_BOX _TYPE_CYLINDER _TYPE_CONE

            half4 _Color;
            half _Radius;

            half _SphereRadFallOut;
            half _SphereIntensity;

            half _RadFallOut;
            half _ZFallOut;
            sampler2D _CameraDepthTexture;

            struct a2v
            {
                float4 vertex : POSITION;
            };
            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 screenPos : TEXCOORD0;
                float3 positionOS : TEXCOORD1;
                float3 positionWS : TEXCOORD3;
            };
            v2f vert(a2v v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.positionOS = v.vertex.xyz;
                o.screenPos = ComputeScreenPos(o.vertex);
                o.positionWS = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            // https://iquilezles.org/articles/intersectors/
            // 与球相交
            float2 SphereIntersect(float3 ro, float3 rd, float3 ce, float ra, float sceneDistance, half radFallOut, half intensity)
            {
                float3 oc = ro - ce;
                float b = dot(oc, rd);
                float c = dot(oc, oc) - ra * ra;
                float h = b * b - c;
                // if (h < 0) return 0;//判断出未相交则返回0
                half result = step(0, h);

                h = sqrt(h);

                // 两个相交点(距离)
                float2 sphere = float2(-b - h, -b + h);

                sphere.x = max(sphere.x, 0);
                sphere.y = min(sphere.y, sceneDistance);//处理深度遮挡
                //相交中点
                float3 mid = ro + rd * ((sphere.x + sphere.y) * 0.5);
                //以中点距离球心的距离作为亮度
                float dist = 1 - length(mid) / ra;

                dist = dist / radFallOut;
                dist = smoothstep(0, 1, dist);
                return dist * intensity * result;
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
                
                float rr = ra - rb;
                float hy = m0 + rr * rr;
                float k2 = m0 * m0 - m2 * m2 * hy;
                float k1 = m0 * m0 * m3 - m1 * m2 * hy + m0 * ra * (rr * m2 * 1.0);
                float k0 = m0 * m0 * m5 - m1 * m1 * hy + m0 * ra * (rr * m1 * 2.0 - m0 * ra);
                float h = k1 * k1 - k2 * k0;
                
                // if (h < 0.0) return 0;//不相交
                half result = step(0, h);

                h = sqrt(h);
                float2 sphere = float2(-k1 - h, -k1 + h) / k2;
                float y = m1 + sphere.x * m2;//处理下方圆盘
                float3 temp2 = oa * m2 - rd * m1;
                if (dot(temp2, temp2) < ra * ra * m2 * m2)
                {
                    if (rd.z < 0.0)
                        sphere.y = -m1 / m2;
                    else
                        sphere.x = -m1 / m2;
                }
                else
                {
                    //处理内部向上看
                    float rc = -m9 / m0 * (ra - rb) + rb;
                    float3 temp = cross(ob, -ba);
                    float rc2 = sqrt(dot(temp, temp) / m0);
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
                return alpha;
            }


            half4 frag(v2f i) : SV_Target
            {
                half2 screenUV = i.screenPos.xy / i.screenPos.w;
                float3 cameraOS = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos.xyz, 1));
                float3 viewDirOS = normalize(i.positionOS - cameraOS.xyz);
                float3 viewDirWS = normalize(i.positionWS - _WorldSpaceCameraPos.xyz);
                
                float sceneDepth = tex2D(_CameraDepthTexture, screenUV);
                sceneDepth = LinearEyeDepth(sceneDepth);

                float3 cameraDir = -normalize(mul(unity_WorldToObject, float4(UNITY_MATRIX_V[2].xyz, 0)).xyz);
                float3 rayDir = viewDirOS;
                float3 rayOrigin = cameraOS;

                float sceneDistance = sceneDepth / dot(viewDirOS, cameraDir);


                float3 rd = rayDir;
                float3 ro = rayOrigin;
                float sr = _Radius;
                // ================================  ================================
                #if defined(_TYPE_SPHERE)
                    // 球形
                    half3 center = 0;
                    half alpha = SphereIntersect(rayOrigin, rayDir, center, _Radius, sceneDistance, _SphereRadFallOut, _SphereIntensity);
                #elif defined(_TYPE_CONE)
                    // 椎体
                    half alpha = ConeIntersection(rayOrigin, rayDir, _Radius, sceneDistance, _ZFallOut, _RadFallOut);
                #else
                    half alpha = 1;
                #endif

                return alpha * _Color;
            }
            ENDCG
        }
    }
}

