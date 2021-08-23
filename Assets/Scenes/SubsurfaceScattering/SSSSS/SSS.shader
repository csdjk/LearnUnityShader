// Put together with Amplify's help.
Shader "Silent/Subsurface Scattering"
{
	Properties
	{
		[Header(Standard)]
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex("Albedo", 2D) = "white" {}
		[NoScaleOffset][Normal]_BumpMap("Normal Map", 2D) = "bump" {}
		_BumpScale ("Normal Scale", Float) = 1
		[NoScaleOffset]_MetallicGlossMap("Metallic", 2D) = "black" {}
		_GlossMapScale("Smoothness", Range(0, 1)) = 1.0
		[Toggle(_)]_SmoothnessFromAlbedo("Smoothness stored in Albedo alpha", Float) = 0.0
		[NoScaleOffset]_OcclusionMap("Occlusion", 2D) = "white" {}
		_OcclusionStrength("Occlusion Strength", Range(0, 1)) = 1.0
		[Enum(UV1, 0, UV2, 1)] _OcclusionUVSource("Occlusion UV Source", Float) = 0
		_EmissionMap("Emission", 2D) = "black" {}
		[HDR]_EmissionColor ("Emission Color", Color) = (1,1,1,1)

		[Header(Detail)]
		[NoScaleOffset]_OverlayMap("Overlay", 2D) = "black" {}
		_OverlayColor ("Overlay Color", Color) = (1,1,1,1)
		[NoScaleOffset]_DetailMask("Detail Mask", 2D) = "white" {}
		[Normal]_DetailBumpMap("Detail Normal Map", 2D) = "bump" {}
		_DetailMetallicGlossMap("Detail Metallic", 2D) = "white" {}
		_DetailBumpMapScale ("Detail Scale", Float) = 1
		[Enum(UV1, 0, UV2, 1)] _SecondUVSource("Secondary UV Source", Float) = 0

		[Header(Transmission)]
		[NoScaleOffset]_ThicknessMap("Thickness Map", 2D) = "black" {}
		[Toggle(_)]_ThicknessMapInvert("Invert Thickness", Float) = 0.0
		_ThicknessMapPower ("Thickness Map Power", Range(0.01, 10)) = 1
		[Enum(UV1, 0, UV2, 1)] _ThicknessUVSource("Thickness UV Source", Float) = 0
		[Toggle(_)]_ScatteringByAlbedo("Tint Scattering with Albedo", Float) = 0.0
		_SSSCol ("Scattering Color", Color) = (1,1,1,1)
		_SSSIntensity ("Scattering Intensity", Range(0, 10)) = 1
		_SSSPow ("Scattering Power", Range(0.01, 10)) = 1
		_SSSDist ("Scattering Distance", Range(0, 10)) = 1
		_SSSAmbient ("Scattering Ambient Intensity", Range(0, 0.5)) = 0
		_SSSShadow ("Scattering Shadow Power", Range(0, 1)) = 1

		[Header(Skin)]
		[Toggle(_METALLICGLOSSMAP)]_UseSkinScattering("Use Skin Scattering", Float) = 0.0
		[NoScaleOffset]_BRDFTex("Skin BRDF LUT", 2D) = "white" {}

		[Header(Wrapped Diffuse)]
		_WrappingFactor("Wrapping Factor", Range(0.001, 1)) = 0.01
		[Gamma]_WrappingPowerFactor("Wrapping Power Factor", Float) = 1
		
		[Header(System)]
		[Enum(UnityEngine.Rendering.CullMode)] _CullMode("Cull Mode", Float) = 2
		[Toggle(_ALPHATEST_ON)] _UseCutout("Alpha Test Cutout", Float) = 0
		[Toggle(_ALPHABLEND_ON)] _UseAlphaToMask("Alpha To Coverage Transparency", Float) = 0
		_Cutout("Cutout", Range(0, 1)) = 0.5
		[ToggleOff(_SPECULARHIGHLIGHTS_OFF)]_SpecularHighlights ("Specular Highlights", Float) = 1.0
		[ToggleOff(_GLOSSYREFLECTIONS_OFF)]_GlossyReflections ("Glossy Reflections", Float) = 1.0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" }
        Cull[_CullMode]
        AlphaToMask [_UseAlphaToMask]
        
		CGINCLUDE

		#pragma shader_feature _SPECULARHIGHLIGHTS_OFF
		#pragma shader_feature _GLOSSYREFLECTIONS_OFF
		#pragma shader_feature _ALPHATEST_ON

		// Reuse Standard keywords for features to avoid reaching limit
		// This one is for scattering.
		#pragma shader_feature _METALLICGLOSSMAP

		#define SSS_METALLIC
		#include "SSS_Standard.cginc"

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows
		#pragma target 3.0

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			AlphaToMask Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma shader_feature _ _ALPHATEST_ON		
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2

			#include "SSS_Shadow.cginc"

			ENDCG
		}
	}
	Fallback "Standard"
}
