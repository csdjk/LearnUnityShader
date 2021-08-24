Shader "lcl/SubsurfaceScattering/FastSSSOrigin/FastSSSOrigin"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _ThicknessTex("Thickness(R)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Ambient("Ambient", Range(0, 5)) = 0
        _BackAttenuation("Back Attenuation", Range(0, 4)) = 1
        _Distortion("Distortion", Range(0, 2)) = 1
        _BackPower("Back Power", Range(0, 4)) = 1
        _BackScale("Back Scale", Range(0, 2)) = 1
        _FrontAttenuation("Front Attenuation", Range(0, 4)) = 1
        _FrontPower("Front Power", Range(0, 4)) = 1
        _FrontScale("Front Scale", Range(0, 2)) = 1
        _FrontRange("Front Range", Range(0, 5)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf ForgedSSS fullforwardshadows
        #pragma target 3.0

        sampler2D _MainTex, _ThicknessTex;

        struct Input
        {
            float2 uv_MainTex;
        };
        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        half _Thickness;
        float _Ambient;
        float _BackAttenuation, _BackPower, _BackScale, _Distortion;
        float _FrontAttenuation, _FrontPower, _FrontScale, _FrontRange;
        float3 lightCol;
        #include "UnityPBSLighting.cginc"

        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)

        inline fixed4 LightingForgedSSS(SurfaceOutputStandard s, fixed3 viewDir, UnityGI gi)
        {
            fixed4 pbr = LightingStandard(s, viewDir, gi);
            float3 L = gi.light.dir;
            float3 V = viewDir;
            float3 N = s.Normal;
            float3 H = normalize(L + N * _Distortion);
            float VdotH = pow(saturate(dot(V, -H)), _BackPower) * _BackScale;
            float3 I_back = _BackAttenuation * (VdotH + _Ambient) * _Thickness;
            float LdotNMax = max(dot(L, N), 0);
            float3 x_k = normalize(cross(L, N));
            float3 y_k = normalize(cross(N, x_k));
            LdotNMax = max(LdotNMax, dot(L, N + x_k * _FrontRange));
            LdotNMax = max(LdotNMax, dot(L, N + y_k * _FrontRange));
            LdotNMax = max(LdotNMax, dot(L, N - x_k * _FrontRange));
            LdotNMax = max(LdotNMax, dot(L, N - y_k * _FrontRange));
            float LdotN = pow(LdotNMax, _FrontPower) * _FrontScale;
            float3 I_front = saturate(_FrontAttenuation * (LdotN + _Ambient) * _Thickness * 0.25);
            pbr.rgb = pbr.rgb * (1 - I_front) + lightCol * (I_front + I_back);
            return pbr;
        }

        void LightingForgedSSS_GI(SurfaceOutputStandard s, UnityGIInput data, inout UnityGI gi)
        {
            lightCol = data.light.color;
            LightingStandard_GI(s, data, gi);
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
            _Thickness = 1 - tex2D(_ThicknessTex, IN.uv_MainTex).r;
        }
        ENDCG
    }
    FallBack "Diffuse"
}