Shader "lcl/Lighting/FastVolumeLight-ObjectSpace"
{
    Properties
    {
        [Enum(UnityEngine.Rendering.CullMode)]_CullMode ("CullMode", float) = 2

        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _Radius ("_Radius", Float) = 0.5
        _Soft ("Soft", Range(0, 10)) = 0.5
        _Smooth ("Smooth", Range(0, 1)) = 0.5
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
            Cull [_CullMode]

            CGPROGRAM
            // #pragma enable_d3d11_debug_symbols
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            #include "Assets\Shader\ShaderLibs\Node.cginc"
            half4 _Color;
            half _Radius;
            half _Soft;
            half _Smooth;
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
            float2 SphereIntersect(float3 ro, float3 rd, float3 ce, float ra)
            {
                float3 oc = ro - ce;
                float b = dot(oc, rd);
                float c = dot(oc, oc) - ra * ra;
                float h = b * b - c;
                if (h < 0) return 0;//判断出未相交则返回0
                h = sqrt(h);

                // 返回两个相交点(距离)
                return float2(-b - h, -b + h);
            }

            // float2 BoxIntersection(in float3 ro, in float3 rd, float3 boxSize, out float3 outNormal)
            // {
            //     float3 m = 1.0 / rd; // can precompute if traversing a set of aligned boxes
            //     float3 n = m * ro;   // can precompute if traversing a set of aligned boxes
            //     float3 k = abs(m) * boxSize;
            //     float3 t1 = -n - k;
            //     float3 t2 = -n + k;
            //     float tN = max(max(t1.x, t1.y), t1.z);
            //     float tF = min(min(t2.x, t2.y), t2.z);
            //     if (tN > tF || tF < 0.0) return float2(-1.0); // no intersection
            //     outNormal = (tN > 0.0) ? step(float3(tN), t1)) : // ro ouside the box
            //     step(t2, float3(tF)));  // ro inside the box
            //     outNormal *= -sign(rd);
            //     return float2(tN, tF);
            // }
            half4 frag(v2f i) : SV_Target
            {
                half2 screenUV = i.screenPos.xy / i.screenPos.w;
                float3 cameraOS = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos.xyz, 1));
                float3 viewDirOS = normalize(i.positionOS - cameraOS.xyz);
                float3 viewDirWS = normalize(i.positionWS - _WorldSpaceCameraPos.xyz);
                
                float sceneDepth = tex2D(_CameraDepthTexture, screenUV);
                sceneDepth = LinearEyeDepth(sceneDepth);


                float3 cameraDir = -normalize(mul(unity_WorldToObject, float4(UNITY_MATRIX_V[2].xyz, 0)).xyz);
                // float3 cameraDir = -normalize(UNITY_MATRIX_V[2].xyz);
                float3 rayDir = viewDirOS;
                float3 rayOrigin = cameraOS;

                float sceneDistance = sceneDepth / dot(viewDirOS, cameraDir);

                //与Sphere相交
                float2 sphere = SphereIntersect(rayOrigin, rayDir, 0, _Radius);
                sphere.x = max(sphere.x, 0);
                sphere.y = min(sphere.y, sceneDistance);//处理深度遮挡

                //相交中点
                float3 mid = rayOrigin + rayDir * ((sphere.x + sphere.y) * 0.5);

                //以中点距离球心的距离作为亮度
                float dist = 1 - length(mid) / _Radius;

                dist = dist / _Soft;
                dist = SmoothValue(dist, 0.5, _Smooth);
                return dist * _Color;
            }
            ENDCG
        }
    }
    FallBack "Reflective/VertexLit"
}

