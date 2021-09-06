#ifndef TCP2_STANDARD_CORE_INCLUDED
#define TCP2_STANDARD_CORE_INCLUDED

// TOONY COLORS PRO 2
// Fragment shaders, based on UnityStandardCore.cginc

// ------------------------------------------------------------------
//  Base forward pass (directional light, emission, lightmaps, ...)

//TCP2 uses the same vertex shader as Unity Standard currently

half4 fragForwardBaseInternal_TCP2(VertexOutputForwardBase i)
{
	FRAGMENT_SETUP(s)
#if UNITY_OPTIMIZE_TEXCUBELOD
		s.reflUVW = i.reflUVW;
#endif

#if UNITY_VERSION >= 550
	UnityLight mainLight = MainLight();
#else
	UnityLight mainLight = MainLight(s.normalWorld);
#endif

#if UNITY_VERSION >= 560
	UNITY_LIGHT_ATTENUATION(atten, i, s.posWorld);
#else
	half atten = SHADOW_ATTENUATION(i);
#endif

	half occlusion = Occlusion(i.tex.xy);
	UnityGI gi = FragmentGI(s, occlusion, i.ambientOrLightmapUV, 1, mainLight);	//TCP2: replaced atten with 1, atten is done in BRDF now

#if UNITY_VERSION >= 550
	half4 c = TCP2_BRDF_PBS(s.diffColor, s.specColor, s.oneMinusReflectivity, s.smoothness, s.normalWorld, -s.eyeVec, gi.light, gi.indirect,
		/* TCP2 Params */	_RampThreshold, _RampSmooth, _HColor, _SColor, _SpecSmooth, _SpecBlend, fixed3(_RimMin, _RimMax, _RimStrength), atten);
	c.rgb += UNITY_BRDF_GI(s.diffColor, s.specColor, s.oneMinusReflectivity, s.smoothness, s.normalWorld, -s.eyeVec, occlusion, gi);
#else
	half4 c = TCP2_BRDF_PBS(s.diffColor, s.specColor, s.oneMinusReflectivity, s.oneMinusRoughness, s.normalWorld, -s.eyeVec, gi.light, gi.indirect,
		/* TCP2 Params */	_RampThreshold, _RampSmooth, _HColor, _SColor, _SpecSmooth, _SpecBlend, fixed3(_RimMin, _RimMax, _RimStrength), atten);
	c.rgb += UNITY_BRDF_GI(s.diffColor, s.specColor, s.oneMinusReflectivity, s.oneMinusRoughness, s.normalWorld, -s.eyeVec, occlusion, gi);
#endif
	c.rgb += Emission(i.tex.xy);

#if UNITY_VERSION >= 201820
    UNITY_EXTRACT_FOG_FROM_EYE_VEC(i);
    UNITY_APPLY_FOG(_unity_fogCoord, c.rgb);
#else
	UNITY_APPLY_FOG(i.fogCoord, c.rgb);
#endif

	return OutputForward(c, s.alpha);
}

half4 fragForwardBase_TCP2(VertexOutputForwardBase i) : SV_Target	// backward compatibility (this used to be the fragment entry function)
{
	return fragForwardBaseInternal(i);
}

// ------------------------------------------------------------------
//  Additive forward pass (one light per pass)

//TCP2 uses the same vertex shader as Unity Standard currently

half4 fragForwardAddInternal_TCP2(VertexOutputForwardAdd i)
{
	FRAGMENT_SETUP_FWDADD(s)

#if UNITY_VERSION >= 560
	UNITY_LIGHT_ATTENUATION(atten, i, s.posWorld)
	UnityLight light = AdditiveLight(IN_LIGHTDIR_FWDADD(i), atten);
#elif UNITY_VERSION >= 550
	UnityLight light = AdditiveLight(IN_LIGHTDIR_FWDADD(i), LIGHT_ATTENUATION(i));
#else
	UnityLight light = AdditiveLight(s.normalWorld, IN_LIGHTDIR_FWDADD(i), LIGHT_ATTENUATION(i));
#endif
	UnityIndirect noIndirect = ZeroIndirect();

#if UNITY_VERSION >= 550
	half4 c = TCP2_BRDF_PBS(s.diffColor, s.specColor, s.oneMinusReflectivity, s.smoothness, s.normalWorld, -s.eyeVec, light, noIndirect,
		/* TCP2 Params */	_RampThreshold, _RampSmoothAdd, _HColor, _SColor, _SpecSmooth, _SpecBlend, fixed3(_RimMin, _RimMax, _RimStrength), 1);
#else
	half4 c = TCP2_BRDF_PBS(s.diffColor, s.specColor, s.oneMinusReflectivity, s.oneMinusRoughness, s.normalWorld, -s.eyeVec, light, noIndirect,	
		/* TCP2 Params */	_RampThreshold, _RampSmoothAdd, _HColor, _SColor, _SpecSmooth, _SpecBlend, fixed3(_RimMin, _RimMax, _RimStrength), 1);
#endif

#if UNITY_VERSION >= 201820
    UNITY_EXTRACT_FOG_FROM_EYE_VEC(i);
    UNITY_APPLY_FOG_COLOR(_unity_fogCoord, c.rgb, half4(0,0,0,0)); // fog towards black in additive pass
#else
    UNITY_APPLY_FOG_COLOR(i.fogCoord, c.rgb, half4(0, 0, 0, 0)); // fog towards black in additive pass
#endif

	return OutputForward(c, s.alpha);
}

half4 fragForwardAdd_TCP2(VertexOutputForwardAdd i) : SV_Target		// backward compatibility (this used to be the fragment entry function)
{
	return fragForwardAddInternal(i);
}

// ------------------------------------------------------------------
//  Deferred pass

//TCP2: Deferred is currently not supported in TCP2

/*
struct VertexOutputDeferred
{
float4 pos							: SV_POSITION;
float4 tex							: TEXCOORD0;
half3 eyeVec 						: TEXCOORD1;
half4 tangentToWorldAndParallax[3]	: TEXCOORD2;	// [3x3:tangentToWorld | 1x3:viewDirForParallax]
half4 ambientOrLightmapUV			: TEXCOORD5;	// SH or Lightmap UVs
#if UNITY_SPECCUBE_BOX_PROJECTION
float3 posWorld						: TEXCOORD6;
#endif
#if UNITY_OPTIMIZE_TEXCUBELOD
#if UNITY_SPECCUBE_BOX_PROJECTION
half3 reflUVW				: TEXCOORD7;
#else
half3 reflUVW				: TEXCOORD6;
#endif
#endif

};

VertexOutputDeferred vertDeferred (VertexInput v)
{
VertexOutputDeferred o;
UNITY_INITIALIZE_OUTPUT(VertexOutputDeferred, o);

float4 posWorld = mul(_Object2World, v.vertex);
#if UNITY_SPECCUBE_BOX_PROJECTION
o.posWorld = posWorld;
#endif
o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
o.tex = TexCoords(v);
o.eyeVec = NormalizePerVertexNormal(posWorld.xyz - _WorldSpaceCameraPos);
float3 normalWorld = UnityObjectToWorldNormal(v.normal);
#ifdef _TANGENT_TO_WORLD
float4 tangentWorld = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);

float3x3 tangentToWorld = CreateTangentToWorldPerVertex(normalWorld, tangentWorld.xyz, tangentWorld.w);
o.tangentToWorldAndParallax[0].xyz = tangentToWorld[0];
o.tangentToWorldAndParallax[1].xyz = tangentToWorld[1];
o.tangentToWorldAndParallax[2].xyz = tangentToWorld[2];
#else
o.tangentToWorldAndParallax[0].xyz = 0;
o.tangentToWorldAndParallax[1].xyz = 0;
o.tangentToWorldAndParallax[2].xyz = normalWorld;
#endif

o.ambientOrLightmapUV = 0;
#ifndef LIGHTMAP_OFF
o.ambientOrLightmapUV.xy = v.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
#elif UNITY_SHOULD_SAMPLE_SH
o.ambientOrLightmapUV.rgb = ShadeSHPerVertex (normalWorld, o.ambientOrLightmapUV.rgb);
#endif
#ifdef DYNAMICLIGHTMAP_ON
o.ambientOrLightmapUV.zw = v.uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
#endif

#ifdef _PARALLAXMAP
TANGENT_SPACE_ROTATION;
half3 viewDirForParallax = mul (rotation, ObjSpaceViewDir(v.vertex));
o.tangentToWorldAndParallax[0].w = viewDirForParallax.x;
o.tangentToWorldAndParallax[1].w = viewDirForParallax.y;
o.tangentToWorldAndParallax[2].w = viewDirForParallax.z;
#endif

#if UNITY_OPTIMIZE_TEXCUBELOD
o.reflUVW		= reflect(o.eyeVec, normalWorld);
#endif

return o;
}
*/

/*
void fragDeferred (
VertexOutputDeferred i,
out half4 outDiffuse : SV_Target0,			// RT0: diffuse color (rgb), occlusion (a)
out half4 outSpecSmoothness : SV_Target1,	// RT1: spec color (rgb), smoothness (a)
out half4 outNormal : SV_Target2,			// RT2: normal (rgb), --unused, very low precision-- (a)
out half4 outEmission : SV_Target3			// RT3: emission (rgb), --unused-- (a)
)
{
#if (SHADER_TARGET < 30)
outDiffuse = 1;
outSpecSmoothness = 1;
outNormal = 0;
outEmission = 0;
return;
#endif

FRAGMENT_SETUP(s)
#if UNITY_OPTIMIZE_TEXCUBELOD
s.reflUVW		= i.reflUVW;
#endif

// no analytic lights in this pass
UnityLight dummyLight = DummyLight (s.normalWorld);
half atten = 1;

// only GI
half occlusion = Occlusion(i.tex.xy);
#if UNITY_ENABLE_REFLECTION_BUFFERS
bool sampleReflectionsInDeferred = false;
#else
bool sampleReflectionsInDeferred = true;
#endif

UnityGI gi = FragmentGI (s, occlusion, i.ambientOrLightmapUV, atten, dummyLight, sampleReflectionsInDeferred);

half3 color = TCP2_BRDF_PBS (s.diffColor, s.specColor, s.oneMinusReflectivity, s.oneMinusRoughness, s.normalWorld, -s.eyeVec, gi.light, gi.indirect,
_RampThreshold, _RampSmooth, _HColor, _SColor, _SpecSmooth, _SpecBlend, fixed3(_RimMin, _RimMax, _RimStrength), atten).rgb;	//TCP2 Params
color += UNITY_BRDF_GI (s.diffColor, s.specColor, s.oneMinusReflectivity, s.oneMinusRoughness, s.normalWorld, -s.eyeVec, occlusion, gi);

#ifdef _EMISSION
color += Emission (i.tex.xy);
#endif

#ifndef UNITY_HDR_ON
color.rgb = exp2(-color.rgb);
#endif

outDiffuse = half4(s.diffColor, occlusion);
outSpecSmoothness = half4(s.specColor, s.oneMinusRoughness);
outNormal = half4(s.normalWorld*0.5+0.5,1);
outEmission = half4(color, 1);
}
*/

#endif // TCP2_STANDARD_CORE_INCLUDED
