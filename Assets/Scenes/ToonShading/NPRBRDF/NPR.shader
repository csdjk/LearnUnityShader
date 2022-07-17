Shader "lcl/NPR"
{
    Properties
    {
        _MainTex ("Albedo Tex", 2D) = "white" { }
        
        [NoScaleOffset]_OcclusionTex ("Occlusion", 2D) = "white" { }
        _Metallic ("Metallic", Range(0, 1)) = 0
        _Roughness ("Roughness", Range(0, 1)) = 0.5
        _OcclusionPower ("Occlusion Power", Range(0, 1)) = 1
        
        [Header(Stylized Diffuse)]
        _DiffuseColor ("Diffuse Color", Color) = (1, 1, 1, 1)
        _DiffuseSmooth ("_DiffuseSmooth", Range(0, 1)) = 1

        [Header(SSS)]
        _SSSColor ("SSS Color", Color) = (1, 0.3, 0.3, 0)
        _FillLightingPower ("_FillLightingPower", Range(0.1, 2)) = 0.3
        _FillLightingScale ("_FillLightingScale", Range(0, 2)) = 2
        _SSSFrontLighting ("_SSSFrontLighting", Range(0, 1)) = 1
        _SSSBackLighting ("_SSSBackLighting", Range(0, 1)) = 1
        
        _SSSDistortion ("_SSSDistortion", Range(0, 2)) = 0.1
        _SSSPower ("_SSSPower", Range(0.1, 10)) = 1
        _SSSScale ("_SSSScale", Range(0, 5)) = 2

        [Header(Stylized Specular)]
        _SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)
        _SpecularThreshold ("Specular Threshold", Range(0, 1)) = 0.5
        _SpecularSmoothness ("Specular Smoothness", Range(0, 1)) = 0.5
        _SpecBlend ("Stylized Specular Blending", Range(0, 1)) = 1.0

        [Header(Rim)]
        [Toggle(RIM_ON)]_RIM_ON ("RimLight Open", float) = 0
        _RimColor ("Rim Color", Color) = (0, 0, 0, 0)
        _RimWidth ("Rim Width", Range(0, 1)) = 0.2
        _RimIntensity ("Rim Intensity", Range(0, 2)) = 0.5
        _RimSmoothness ("Rim Smoothness", Range(0, 1)) = 0.2
    }
    SubShader
    {
        Tags { "Queue" = "Geometry" "IgnoreProjector" = "True" "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM

            #pragma target 3.0

            #pragma shader_feature RIM_ON

            // #define _NORMALMAP
            #define APP_TOON
            #define APP_SGSSS
            #define _EMISSIONGROUP_ON

            #include "UnityCG.cginc"
            #include "NPRCore.cginc"

            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment

            ENDCG
        }

        //  Shadow rendering pass
        // Pass
        // {
        //     Name "ShadowCaster"
        //     Tags { "LightMode" = "ShadowCaster" }
        
        //     CGPROGRAM

        //     #pragma multi_compile_shadowcaster

        //     #pragma vertex vertShadowCaster
        //     #pragma fragment fragShadowCaster
        
        //     #include "ActorShadowCaster.cginc"

        //     ENDCG
        // }

    }
}