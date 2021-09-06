// Toony Colors Pro+Mobile 2
// (c) 2014-2019 Jean Moreno


Shader "Toony Colors Pro 2/Outline Only/Blended"
{
	Properties
	{
		//OUTLINE
		_Outline ("Outline Width", Float) = 1
		_OutlineColor ("Outline Color", Color) = (0.2, 0.2, 0.2, 1)
		
		//If taking colors from texture
		_TexLod ("#OUTLINETEX# Texture LOD", Range(0,10)) = 5
		_MainTex ("#OUTLINETEX# Texture (RGB)", 2D) = "white" {}
		
		//ZSmooth
		_ZSmooth ("#OUTLINEZ# Z Correction", Range(-3.0,3.0)) = -0.5
		
		//Z Offset
		_Offset1 ("#OUTLINEZ# Z Offset 1", Float) = 0
		_Offset2 ("#OUTLINEZ# Z Offset 2", Float) = 0
		
		//Blending
		_SrcBlendOutline ("#BLEND# Blending Source", Float) = 0
		_DstBlendOutline ("#BLEND# Blending Dest", Float) = 0
	}
	
	SubShader
	{
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		
		UsePass "Hidden/Toony Colors Pro 2/Outline Only/OUTLINE_BLENDING"
	}
	
	CustomEditor "TCP2_OutlineInspector"
}
