// TOONY COLORS PRO 2
// ShadowCaster and Meta passes to be used with generated PBS shaders
// Need to be in separate file so that they don't get the CGINCLUDE code from the generated shader file

Shader "Hidden/Toony Colors Pro 2/PBS Shadow Meta"
{
	Properties
	{
		_Color("Main Color", Color) = (1,1,1,1)
	}

	SubShader
	{
		Pass
		{
			Name "SHADOW_CASTER"
			Tags { "LightMode" = "ShadowCaster" }
			
			ZWrite On ZTest LEqual

			CGPROGRAM
			
			#pragma target 3.0
			#define TCP2_SHADOW_CASTER
			
			// -------------------------------------
			
			#pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
			#pragma multi_compile_shadowcaster
			
			#pragma vertex vertShadowCaster
			#pragma fragment fragShadowCaster
			
			#include "UnityStandardShadow.cginc"

			ENDCG
		}

		Pass
		{
			Name "META" 
			Tags { "LightMode"="Meta" }
			
			Cull Off
			
			CGPROGRAM
			#pragma vertex vert_meta
			#pragma fragment frag_meta
			
			#pragma shader_feature _EMISSION
			#pragma shader_feature _METALLICGLOSSMAP
			#pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
			#pragma shader_feature ___ _DETAIL_MULX2
			
			#include "UnityStandardMeta.cginc"
			ENDCG
		}
	}
}
