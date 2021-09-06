#ifndef TCP2_PBS_INCLUDED
#define TCP2_PBS_INCLUDED

// TOONY COLORS PRO 2
// Main PBS included file from the .shader files

//================================================================================================================================
//TCP2 Input

fixed4 _HColor;
fixed4 _SColor;
sampler2D _Ramp;
fixed _RampThreshold;
fixed _RampSmooth;
fixed _RampSmoothAdd;

fixed _SpecSmooth;
fixed _SpecBlend;

fixed _RimStrength;
fixed _RimMin;
fixed _RimMax;

//================================================================================================================================
// Replacement for UnityPBSLighting.cginc

//TCP2 BRDF to use

//Uncomment one of these lines to force a quality level regardless of target platform
//#define TCP2_BRDF_PBS BRDF1_TCP2_PBS
//#define TCP2_BRDF_PBS BRDF2_TCP2_PBS
//#define TCP2_BRDF_PBS BRDF3_TCP2_PBS

#if !defined (TCP2_BRDF_PBS) // allow to explicitly override BRDF in custom shader
// still add safe net for low shader models, otherwise we might end up with shaders failing to compile
// the only exception is WebGL in 5.3 - it will be built with shader target 2.0 but we want it to get rid of constraints, as it is effectively desktop
	#if SHADER_TARGET < 30
		#define TCP2_BRDF_PBS BRDF3_TCP2_PBS
	#elif UNITY_PBS_USE_BRDF3
		#define TCP2_BRDF_PBS BRDF3_TCP2_PBS
	#elif UNITY_PBS_USE_BRDF2
		#define TCP2_BRDF_PBS BRDF2_TCP2_PBS
	#elif UNITY_PBS_USE_BRDF1
		#define TCP2_BRDF_PBS BRDF1_TCP2_PBS
	#elif defined(SHADER_TARGET_SURFACE_ANALYSIS)
		// we do preprocess pass during shader analysis and we dont actually care about brdf as we need only inputs/outputs
		#define TCP2_BRDF_PBS BRDF1_TCP2_PBS
	#else
		#error something broke in auto-choosing BRDF
	#endif
#endif

#include "UnityStandardCore.cginc"
#include "TCP2_PBS_BRDF.cginc"

//================================================================================================================================
// Replacement for UnityStandardCoreForward.cginc

//#if defined(UNITY_NO_FULL_STANDARD_SHADER)
//#	define UNITY_STANDARD_SIMPLE 1
//#endif

#include "UnityStandardConfig.cginc"

//#if UNITY_STANDARD_SIMPLE
//#include "UnityStandardCoreForwardSimple.cginc"
//VertexOutputBaseSimple vertBase(VertexInput v) { return vertForwardBaseSimple(v); }
//VertexOutputForwardAddSimple vertAdd(VertexInput v) { return vertForwardAddSimple(v); }
//half4 fragBase(VertexOutputBaseSimple i) : SV_Target{ return fragForwardBaseSimpleInternal(i); }
//half4 fragAdd(VertexOutputForwardAddSimple i) : SV_Target{ return fragForwardAddSimpleInternal(i); }
//#else
#include "TCP2_PBS_Core.cginc"
VertexOutputForwardBase vertBase(VertexInput v) { return vertForwardBase(v); }
VertexOutputForwardAdd vertAdd(VertexInput v) { return vertForwardAdd(v); }
half4 fragBase(VertexOutputForwardBase i) : SV_Target{ return fragForwardBaseInternal_TCP2(i); }
half4 fragAdd(VertexOutputForwardAdd i) : SV_Target{ return fragForwardAddInternal_TCP2(i); }
//#endif
//================================================================================================================================


#endif // TCP2_PBS_INCLUDED
