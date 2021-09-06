// Toony Colors Pro+Mobile 2
// (c) 2014-2019 Jean Moreno

Shader "Hidden/Toony Colors Pro 2/Outline Only Behind"
{
	Properties
	{
		//OUTLINE
		_Outline ("Outline Width", Float) = 1
		_OutlineColor ("Outline Color", Color) = (0.2, 0.2, 0.2, 1)
		
		//If taking colors from texture
		_MainTex ("Base (RGB) Gloss (A) ", 2D) = "white" {}
		_TexLod ("Texture Outline LOD", Range(0,10)) = 5
		
		//ZSmooth
		_ZSmooth ("Z Correction", Range(-3.0,3.0)) = -0.5
		
		//Z Offset
		_Offset1 ("Z Offset 1", Float) = 0
		_Offset2 ("Z Offset 2", Float) = 0
		
		//Blending
		_SrcBlendOutline ("#BLEND# Blending Source", Float) = 0
		_DstBlendOutline ("#BLEND# Blending Dest", Float) = 0
	}
	
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGINCLUDE
		#include "UnityCG.cginc"
		#include "../Include/TCP2_Outline_Include.cginc"
		ENDCG
		
		//Outline Toony Colors 2
		Pass
		{
			Name "OUTLINE"
			
			Cull Off
			ZWrite Off
			Offset [_Offset1],[_Offset2]
			Tags { "LightMode"="ForwardBase" }
			
			CGPROGRAM
			
			#include "UnityCG.cginc"
			
			#pragma vertex TCP2_Outline_Vert
			#pragma fragment TCP2_Outline_Frag
			
			#pragma multi_compile _ TCP2_ZSMOOTH_ON
			#pragma multi_compile _ TCP2_OUTLINE_CONST_SIZE
			#pragma multi_compile _ TCP2_COLORS_AS_NORMALS TCP2_TANGENT_AS_NORMALS TCP2_UV1_AS_NORMALS TCP2_UV2_AS_NORMALS TCP2_UV3_AS_NORMALS TCP2_UV4_AS_NORMALS
			#pragma multi_compile _ TCP2_UV_NORMALS_FULL TCP2_UV_NORMALS_ZW
			#pragma multi_compile _ TCP2_OUTLINE_TEXTURED
			#pragma multi_compile_instancing
			
			#pragma target 3.0
			
		ENDCG
		}
		
		//Outline Toony Colors 2 - Blended
		Pass
		{
			Name "OUTLINE_BLENDING"
			
			Cull Off
			ZWrite Off
			Offset [_Offset1],[_Offset2]
			Tags { "LightMode"="ForwardBase" "Queue"="Transparent" "IgnoreProjectors"="True" "RenderType"="Transparent" }
			Blend [_SrcBlendOutline] [_DstBlendOutline]
			
			CGPROGRAM
			
			#include "UnityCG.cginc"
			
			#pragma vertex TCP2_Outline_Vert
			#pragma fragment TCP2_Outline_Frag
			
			#pragma multi_compile _ TCP2_ZSMOOTH_ON
			#pragma multi_compile _ TCP2_OUTLINE_CONST_SIZE
			#pragma multi_compile _ TCP2_COLORS_AS_NORMALS TCP2_TANGENT_AS_NORMALS TCP2_UV1_AS_NORMALS TCP2_UV2_AS_NORMALS TCP2_UV3_AS_NORMALS TCP2_UV4_AS_NORMALS
			#pragma multi_compile _ TCP2_UV_NORMALS_FULL TCP2_UV_NORMALS_ZW
			#pragma multi_compile _ TCP2_OUTLINE_TEXTURED
			#pragma multi_compile_instancing
			
			#pragma target 3.0
			
		ENDCG
		}
	}
}
