Shader "lcl/Lighting/FastVolumeLight-WorldSpace"
{
    Properties
    {
        [Enum(UnityEngine.Rendering.CullMode)]_CullMode ("CullMode", float) = 2

        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _Radius ("_Radius", Float) = 10
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
            Cull [_CullMode]

            CGPROGRAM
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
                float3 positionWS : TEXCOORD1;
            };
            v2f vert(a2v v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.vertex);
                o.positionWS = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }


            
            half4 frag(v2f i) : SV_Target
            {
                half2 screenUV = i.screenPos.xy / i.screenPos.w;
                float sceneDepth = tex2D(_CameraDepthTexture, screenUV);
                sceneDepth = LinearEyeDepth(sceneDepth);

                float3 cameraDir = -normalize(UNITY_MATRIX_V[2].xyz);
                float3 ce = float3(unity_ObjectToWorld[0].w, unity_ObjectToWorld[1].w, unity_ObjectToWorld[2].w);
                float3 rd = -normalize(UnityWorldSpaceViewDir(i.positionWS));
                float3 ro = _WorldSpaceCameraPos.xyz;
                half ra = _Radius;

                float SceneDistance = sceneDepth / dot(rd, cameraDir);

                //与Sphere相交
                float3 oc = ro - ce;
                float b = dot(oc, rd);
                float c = dot(oc, oc) - ra * ra;
                float h = b * b - c;
                if (h < 0) return 0;//判断出未相交则返回0
                h = sqrt(h);

                float2 sphere = float2(-b - h, -b + h);
                sphere.x = max(sphere.x, 0);
                sphere.y = min(sphere.y, SceneDistance);//处理深度遮挡


                float3 mid = ro + rd * (sphere.x + sphere.y) * 0.5;//获得中点

                float dist = 1 - (distance(mid, ce) / ra); //以中点距离球心的距离作为亮度

                dist = dist / _Soft;
                dist = SmoothValue(dist, 0.5, _Smooth);
                return dist * _Color;
            }
            ENDCG
        }
    }
    FallBack "Reflective/VertexLit"
}

