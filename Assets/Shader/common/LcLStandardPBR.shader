Shader "lcl/LcLStandardPBR"
{
   Properties
    {
        _MainTex ("Albedo Tex", 2D) = "white" { }
        _DiffuseColor ("Diffuse Color", Color) = (1, 1, 1, 1)
        _SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)

        [NoScaleOffset]_NormalTex ("Normal Tex", 2D) = "bump" { }
        _NormalScale ("Normal Scale", Range(0, 10)) = 1
        
        [NoScaleOffset]_MaskTex ("Mask Tex(Roughness-Metallic-Emission-AO)", 2D) = "white" { }

        _Metallic ("Metallic", Range(0, 1)) = 0
        _Roughness ("Roughness", Range(0, 1)) = 0.1

        
        [Toggle(ANISO_ON)]_ANISO ("Anisotropy", float) = 0
        _Anisotropy ("Anisotropy", Range(0, 1)) = 0
        
        // _EmissionTex ("Emission Tex", 2D) = "white" { }
        [Toggle(EMISSION_ON)]_EMISSION ("Emission", float) = 0
        [HDR]_EmissionColor ("Emission Color", Color) = (0, 0, 0, 0)
     
        [Header(Rim)]
        [Toggle(RIM_ON)]_RIM_ON ("RimLight", float) = 0
	    _RimColor("Rim Color", Color) = (0,0,0,0)
        _RimWidth ("Rim Width", Range(0, 1)) = 0.25
        _RimIntensity ("Rim Intensity", Range(0, 2)) = 0.5
        _RimSmoothness ("Rim Smoothness", Range(0, 1)) = 0.15
    }
    SubShader
    {
        Tags { "Queue" = "Geometry" "IgnoreProjector" = "True" "RenderType" = "Opaque" }
        LOD 100

        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM

            #pragma target 3.0
            #pragma multi_compile_fwdbase

            #pragma shader_feature RIM_ON
            #pragma shader_feature EMISSION_ON
            #pragma shader_feature ANISO_ON

            #define _NORMALMAP
            // #define _EMISSIONGROUP_ON
            // #define _ANISO_ON

            #include "UnityCG.cginc"
            #include "../ShaderLibs/LcLLighting.cginc"

            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment
            ENDCG
        }

    }
}