Shader "lcl/otherShader/CelShaded"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        [Normal]_Normal("Normal", 2D) = "bump" {}
        _LightCutoff("Light cutoff", Range(0,1)) = 0.5
        _ShadowBands("Shadow bands", Range(1,4)) = 1
 
        [Header(Specular)]
        _SpecularMap("Specular map", 2D) = "white" {} 
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        [HDR]_SpecularColor("Specular color", Color) = (0,0,0,1)
 
        [Header(Rim)]
        _RimSize("Rim size", Range(0,1)) = 0
        [HDR]_RimColor("Rim color", Color) = (0,0,0,1)
        [Toggle(SHADOWED_RIM)]
        _ShadowedRim("Rim affected by shadow", float) = 0
         
        [Header(Emission)]
        [HDR]_Emission("Emission", Color) = (0,0,0,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200
 
        CGPROGRAM
        #pragma surface surf CelShaded fullforwardshadows
        #pragma shader_feature SHADOWED_RIM
        #pragma target 3.0
 
 
        fixed4 _Color;
        sampler2D _MainTex;
        sampler2D _Normal;
        float _LightCutoff;
        float _ShadowBands;
 
 
        sampler2D _SpecularMap;
        half _Glossiness;
        fixed4 _SpecularColor;
 
        float _RimSize;
        fixed4 _RimColor;
 
        fixed4 _Emission;
 
        struct Input
        {
            float2 uv_MainTex;
            float2 uv_Normal;
            float2 uv_SpecularMap;
        };
 
        struct SurfaceOutputCelShaded
        {
            fixed3 Albedo;
            fixed3 Normal;
            float Smoothness;
            half3 Emission;
            fixed Alpha;
        };
 
        half4 LightingCelShaded (SurfaceOutputCelShaded s, half3 lightDir, half3 viewDir, half atten) {
            half nDotL = saturate(dot(s.Normal, normalize(lightDir)));
            half diff = round(saturate(nDotL / _LightCutoff) * _ShadowBands) / _ShadowBands;
 
            float3 refl = reflect(normalize(lightDir), s.Normal);
            float vDotRefl = dot(viewDir, -refl);
            float3 specular = _SpecularColor.rgb * step(1 - s.Smoothness, vDotRefl);
             
            float3 rim = _RimColor * step(1 - _RimSize ,1 - saturate(dot(normalize(viewDir), s.Normal)));
 
            half stepAtten = round(atten);
            half shadow = diff * stepAtten;
             
            half3 col = (s.Albedo + specular) * _LightColor0;
 
            half4 c;
            #ifdef SHADOWED_RIM
            c.rgb = (col + rim) * shadow;
            #else
            c.rgb = col * shadow + rim;
            #endif            
            c.a = s.Alpha;
            return c;
        }
 
        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)
 
        void surf (Input IN, inout SurfaceOutputCelShaded o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Normal = UnpackNormal(tex2D(_Normal, IN.uv_Normal));
            o.Smoothness = tex2D(_SpecularMap, IN.uv_SpecularMap).x * _Glossiness;
            o.Emission = o.Albedo * _Emission;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}