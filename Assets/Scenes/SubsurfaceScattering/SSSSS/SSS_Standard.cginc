#ifndef SSS_INPUT_INCLUDED
#define SSS_INPUT_INCLUDED

#include "UnityPBSLighting.cginc"
#include "Lighting.cginc"

#ifdef UNITY_PASS_SHADOWCASTER
	#undef INTERNAL_DATA
	#undef WorldReflectionVector
	#undef WorldNormalVector
	#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
	#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
	#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
#endif

struct Input
{
	float3 worldNormal;
	float4 screenPos;
	INTERNAL_DATA
	float2 uv_texcoord;
	float2 uv2_texcoord2;
	half facing : VFACE;
};

struct SurfaceOutputCustomLightingCustom
{
	half3 Albedo;
	half3 Normal;
	half3 Emission;
	half3 Specular;
	half Smoothness;
	half Occlusion;
	half Alpha;
    half Thickness;
    half3 SubsurfaceColour;
	Input SurfInput;
	UnityGIInput GIData;
};

uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
uniform sampler2D _BumpMap;
uniform sampler2D _MetallicGlossMap;
uniform sampler2D _OcclusionMap;
uniform sampler2D _ThicknessMap;
uniform sampler2D _OverlayMap;
uniform sampler2D _EmissionMap;
uniform sampler2D _DetailMask;
uniform sampler2D _DetailBumpMap; uniform float4 _DetailBumpMap_ST;
uniform sampler2D _DetailMetallicGlossMap; uniform float4 _DetailMetallicGlossMap_ST;

uniform float _ThicknessMapPower;
uniform float _ThicknessMapInvert;
uniform float3 _SSSCol;
uniform float _SSSAmbient;
uniform float _SSSIntensity;
uniform float _SSSPow;
uniform float _SSSDist; 
uniform float _SSSShadow; 
uniform float4 _Color; 
uniform float3 _OverlayColor; 
uniform float3 _EmissionColor; 

uniform float _DetailBumpMapScale; 
uniform float _ScatteringByAlbedo; 
uniform float _SmoothnessFromAlbedo; 
uniform float _BumpScale; 
uniform float _OcclusionStrength; 
uniform float _GlossMapScale; 
uniform float _Cutout; 

uniform float _WrappingFactor; 
uniform float _WrappingPowerFactor; 

uniform float _SecondUVSource; 
uniform float _OcclusionUVSource; 
uniform float _ThicknessUVSource; 

#include "SSS_Utils.cginc"
#include "SSS_Core.cginc"

inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
{
	s.GIData = data;
}

void surf( Input i , inout SurfaceOutputCustomLightingCustom s1 )
{
	s1.SurfInput = i;

	float2 scaledUV = TRANSFORM_TEX(i.uv_texcoord, _MainTex);

	float4 _MainTex_var = tex2D( _MainTex, scaledUV );
	float2 texcoord2 = _SecondUVSource? i.uv2_texcoord2 : scaledUV;
	float detailMask = tex2D( _DetailMask, scaledUV ).a;
	float3 overlayMask = tex2D(_OverlayMap,texcoord2).rgb*detailMask;

	#if defined(USE_DETAIL_AS_ALPHA)
		_Color.a = lerp( _Color.a, tex2D( _OverlayMap, texcoord2 ).rgb,
			detailMask);
	#endif

	#if !(defined(_ALPHATEST_ON) || defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON))
		s1.Alpha = 1.0;
	#else
		s1.Alpha = (_SmoothnessFromAlbedo? 1.0 : _MainTex_var.a) * _Color.a;
		s1.Alpha = ((s1.Alpha - _Cutout) / max(fwidth(s1.Alpha), 0.0001) + 0.5);
		clip(s1.Alpha - 1.0/255.0 );
	#endif

	#if defined(USE_DETAIL_AS_ALPHA)
		s1.Albedo = _MainTex_var.rgb * _Color;
	#else
		s1.Albedo = lerp(_MainTex_var.rgb * _Color, _OverlayColor, overlayMask);
	#endif

	s1.Normal = NormalInTangentSpace(scaledUV, texcoord2, detailMask);

	s1.Emission = tex2D( _EmissionMap, scaledUV ).rgb * _EmissionColor.rgb;
	float4 _MetallicGlossMap_var = tex2D( _MetallicGlossMap, scaledUV );
	float4 detailMetallicGlossMap_var = tex2D (_DetailMetallicGlossMap, TRANSFORM_TEX(texcoord2, _DetailMetallicGlossMap));
	_MetallicGlossMap_var *= lerp(1.0, detailMetallicGlossMap_var, detailMask);

	#if defined(SSS_METALLIC)
		s1.Specular = _MetallicGlossMap_var.r;
	#else
		s1.Specular = _MetallicGlossMap_var.rgb;
	#endif

	s1.Smoothness = _SmoothnessFromAlbedo? _MainTex_var.a : _MetallicGlossMap_var.a;
	s1.Smoothness *= _GlossMapScale;

	float2 occlusionUV = _OcclusionUVSource? i.uv2_texcoord2 : scaledUV;
	s1.Occlusion = LerpOneTo(tex2D( _OcclusionMap, occlusionUV ).g, _OcclusionStrength);

	float2 thicknessUV = _ThicknessUVSource? i.uv2_texcoord2 : scaledUV;
	float3 thicknessMap_var = tex2D( _ThicknessMap, thicknessUV ).rgb;
	s1.Thickness = pow(abs(_ThicknessMapInvert-thicknessMap_var), _ThicknessMapPower);
	s1.SubsurfaceColour = _ScatteringByAlbedo? _SSSCol*s1.Albedo : _SSSCol;
}

inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
{
	UnityGIInput data = s.GIData;
	Input i = s.SurfInput;
	half4 c = 0;

	#if defined(SSS_METALLIC)
		SurfaceOutputStandardSSSS s1 = (SurfaceOutputStandardSSSS ) 0;
	#else
		SurfaceOutputStandardSpecularSSSS s1 = (SurfaceOutputStandardSpecularSSSS ) 0;
	#endif

	s1.Albedo = s.Albedo;
	s1.Normal = s.Normal;
	s1.Emission = s.Emission;
	#if defined(SSS_METALLIC)
	s1.Metallic = s.Specular.r;
	#else
	s1.Specular = s.Specular;
	#endif
	s1.Smoothness = s.Smoothness;
	s1.Occlusion = s.Occlusion;
	s1.Alpha = s.Alpha;
	s1.Thickness = s.Thickness;

	s1.Smoothness = GeometricNormalFiltering(s1.Smoothness, i.worldNormal, 0.25, 0.5);

	data.light = gi.light;

	UnityGI gi1 = gi;
	#ifdef UNITY_PASS_FORWARDBASE
	Unity_GlossyEnvironmentData g1 = 
		UnityGlossyEnvironmentSetup( s.Smoothness, data.worldViewDir, s1.Normal, float3(0,0,0));
	gi1 = UnityGlobalIllumination_Geom( data, 1.0, s1.Normal, g1, s1.Thickness);
	#endif

	#if 1
	float  NdotV = saturate(abs(dot(s1.Normal, viewDir)));
	float  occlusion    = ComputeMicroShadowing(s1.Occlusion * 0.8 + 0.3, NdotV, 1.0);
	float3 occlusionCol = GTAOMultiBounce( saturate(occlusion * 1.2), s1.Albedo);
	gi1.indirect.diffuse *= occlusionCol;
	gi1.indirect.specular *= occlusion;

	float NdotL = saturate(abs(dot(s1.Normal, gi.light.dir)));
	occlusion    = ComputeMicroShadowing(s1.Occlusion * 0.8 + 0.3, NdotL, 1.0);
	occlusionCol = GTAOMultiBounce( saturate(occlusion * 1.2), s1.Albedo);
	gi.light.color *= occlusionCol;
	#endif

	#ifdef UNITY_PASS_FORWARDBASE
	float ase_lightAtten = data.atten;
	if( _LightColor0.a == 0)
	ase_lightAtten = 0;
	#else
	float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
	float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
	#endif

	#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
	half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
	float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
	float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
	ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
	#endif

	#if defined(SSS_METALLIC)
	float3 finalResult = LightingStandardSSSS ( s1, data, gi1 ).rgb;
	#else
	float3 finalResult = LightingStandardSSSSSpecular ( s1, data, gi1 ).rgb;
	#endif

	finalResult += getSubsurfaceScatteringLight(gi.light.color, gi.light.dir, s1.Normal, data.worldViewDir,
		LerpOneTo(ase_lightAtten, _SSSShadow), s1.Thickness, gi1.indirect.diffuse, s.SubsurfaceColour );

	finalResult += s1.Emission;

	c.rgb = finalResult;
	c.a = s1.Alpha;

	return c;
}

#endif // SSS_INPUT_INCLUDED