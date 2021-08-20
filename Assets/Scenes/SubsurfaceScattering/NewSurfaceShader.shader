Shader "Custom/NewSurfaceShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Distortion ("Distortion", Range(0,1)) = 0.0
        _Power ("Power", Range(0,1)) = 0.0
        _Scale ("Scale", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf StandardTranslucent fullforwardshadows
        #pragma target 3.0
        #include "UnityPBSLighting.cginc"
        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        sampler2D _MainTex;

        float _Distortion;
        float _Power;
        float _Scale;

        struct Input
        {
            float2 uv_MainTex;
            float3 vertex;
        };

        inline fixed4 LightingStandardTranslucent(SurfaceOutputStandard s, fixed3 viewDir, UnityGI gi)
        {
            // Original colour
            fixed4 pbr = LightingStandard(s, viewDir, gi);
            
            // --- Translucency ---
            float3 L = gi.light.dir;
            float3 V = viewDir;
            float3 N = s.Normal;

            float3 H = normalize(L + N * _Distortion);
            float I = pow(saturate(dot(V, -H)), _Power) * _Scale;

            // Final add
            pbr.rgb = pbr.rgb + gi.light.color * I;
            return pbr;
        }
        
        void LightingStandardTranslucent_GI(SurfaceOutputStandard s, UnityGIInput data, inout UnityGI gi)
        {
            LightingStandard_GI(s, data, gi);        
        }
        // void surf (Input IN, inout SurfaceOutputStandard o) {
            //     // Albedo comes from a texture tinted by color
            //     fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            //     o.Albedo = c.rgb;
            //     // Metallic and smoothness come from slider variables
            //     o.Metallic = _Metallic;
            //     o.Smoothness = _Glossiness;
            //     o.Alpha = c.a;
        // }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            // o.Albedo = c.rgb;
            // UnityGI o_gi = UnityGlobalIllumination (IN, 1.0, o.Normal);
            float3 viewDir = normalize(WorldSpaceViewDir(vertex));

            o.Albedo = LightingStandardTranslucent(o,viewDir,o_gi);
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
