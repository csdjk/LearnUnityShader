Shader "Custom/SSSShader" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        [Normal]_Normal("Normal", 2D) = "bump" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        
        _ThicknessMap("Thickness map", 2D) = "black" {}
        _Distortion("Normal Distortion", float) = 0
        _SSSConcentration("SSS Area Concentration", float) = 0
        _SSSScale("SSS Scale", float) = 0
        [HDR]_SSSColor("SSS color", Color) = (1,1,1,1)
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200
        
        CGPROGRAM
        #pragma surface surf SSS fullforwardshadows
        #include "UnityPBSLighting.cginc"
        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0
        
        sampler2D _MainTex;
        sampler2D _Normal;
        
        struct Input {
            float2 uv_MainTex;
            float2 uv_Normal;
        };
        
        struct SurfaceOutputSSS
        {
            fixed3 Albedo;
            fixed3 Normal;
            half3 Emission;
            half Metallic;
            half Smoothness;
            half Occlusion;
            fixed Alpha;
            float Thickness;
        };
        
        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        
        sampler2D _ThicknessMap;
        float _Distortion;
        float _SSSConcentration;
        float _SSSScale;
        fixed4 _SSSColor;
        
        half4 LightingSSS(SurfaceOutputSSS s, half3 viewDir, UnityGI gi){
            float3 lightColor = gi.light.color;
            float3 lightDir = gi.light.dir + s.Normal * _Distortion;
            half sssAmount = pow(saturate(dot(normalize(viewDir), -normalize(lightDir))), _SSSConcentration) * _SSSScale * (1.0 - s.Thickness);
            fixed4 sssColor = sssAmount * _SSSColor * fixed4(lightColor, 1);
            
            SurfaceOutputStandard r;
            r.Albedo = s.Albedo;
            r.Normal = s.Normal;
            r.Emission = s.Emission;
            r.Metallic = s.Metallic;
            r.Smoothness = s.Smoothness;
            r.Occlusion = s.Occlusion;
            r.Alpha = s.Alpha;
            return LightingStandard(r, viewDir, gi) + sssColor;
        }
        
        inline void LightingSSS_GI(SurfaceOutputSSS s, UnityGIInput data, inout UnityGI gi )
        {
            UNITY_GI(gi, s, data);
        }
        
        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
        // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)
        
        
        void surf (Input IN, inout SurfaceOutputSSS o) {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Thickness = tex2D(_ThicknessMap, IN.uv_MainTex);
            o.Albedo = c.rgb;
            o.Normal = UnpackNormal(tex2D(_Normal, IN.uv_Normal));
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}