//================================================================================================================================
// Toony Colors Pro+Mobile 2
// (c) 2014-2020 Jean Moreno
//
// UNITY_SHADER_NO_UPGRADE
//
// This file has been automatically generated and has merged *all* .hlslinc
// files needed for URP support for the Hybrid Shader within a single file.
//
// This is needed to avoid #include errors for built-in files not found
// when URP isn't installed in a Project.
//
// All content is (c) Unity Technologies
// License information: https://github.com/UnityTechnologies/ScriptableRenderPipeline/blob/master/LICENSE.md
//================================================================================================================================




//================================================================================================================================
// File start: com.unity.render-pipelines.universal@7.3.1/ShaderLibrary/Lighting.hlsl


#ifndef UNIVERSAL_LIGHTING_INCLUDED
#define UNIVERSAL_LIGHTING_INCLUDED

//================================================================================================================================
// File start: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/Common.hlsl


#ifndef UNITY_COMMON_INCLUDED
#define UNITY_COMMON_INCLUDED

// Convention:

// Unity is Y up and left handed in world space
// Caution: When going from world space to view space, unity is right handed in view space and the determinant of the matrix is negative
// For cubemap capture (reflection probe) view space is still left handed (cubemap convention) and the determinant is positive.

// The lighting code assume that 1 Unity unit (1uu) == 1 meters.  This is very important regarding physically based light unit and inverse square attenuation

// space at the end of the variable name
// WS: world space
// RWS: Camera-Relative world space. A space where the translation of the camera have already been substract in order to improve precision
// VS: view space
// OS: object space
// CS: Homogenous clip spaces
// TS: tangent space
// TXS: texture space
// Example: NormalWS

// normalized / unormalized vector
// normalized direction are almost everywhere, we tag unormalized vector with un.
// Example: unL for unormalized light vector

// use capital letter for regular vector, vector are always pointing outward the current pixel position (ready for lighting equation)
// capital letter mean the vector is normalize, unless we put 'un' in front of it.
// V: View vector  (no eye vector)
// L: Light vector
// N: Normal vector
// H: Half vector

// Input/Outputs structs in PascalCase and prefixed by entry type
// struct AttributesDefault
// struct VaryingsDefault
// use input/output as variable name when using these structures

// Entry program name
// VertDefault
// FragDefault / FragForward / FragDeferred

// constant floating number written as 1.0  (not 1, not 1.0f, not 1.0h)

// uniform have _ as prefix + uppercase _LowercaseThenCamelCase

// Do not use "in", only "out" or "inout" as califier, no "inline" keyword either, useless.
// When declaring "out" argument of function, they are always last

// headers from ShaderLibrary do not include "common.hlsl", this should be included in the .shader using it (or Material.hlsl)

// All uniforms should be in contant buffer (nothing in the global namespace).
// The reason is that for compute shader we need to guarantee that the layout of CBs is consistent across kernels. Something that we can't control with the global namespace (uniforms get optimized out if not used, modifying the global CBuffer layout per kernel)

// Structure definition that are share between C# and hlsl.
// These structures need to be align on float4 to respect various packing rules from shader language. This mean that these structure need to be padded.
// Rules: When doing an array for constant buffer variables, we always use float4 to avoid any packing issue, particularly between compute shader and pixel shaders
// i.e don't use SetGlobalFloatArray or SetComputeFloatParams
// The array can be alias in hlsl. Exemple:
// uniform float4 packedArray[3];
// static float unpackedArray[12] = (float[12])packedArray;

// The function of the shader library are stateless, no uniform declare in it.
// Any function that require an explicit precision, use float or half qualifier, when the function can support both, it use real (see below)
// If a function require to have both a half and a float version, then both need to be explicitly define
#ifndef real

// The including shader should define whether half
// precision is suitable for its needs.  The shader
// API (for now) can indicate whether half is possible.
#if defined(SHADER_API_MOBILE) || defined(SHADER_API_SWITCH)
#define HAS_HALF 1
#else
#define HAS_HALF 0
#endif

#ifndef PREFER_HALF
#define PREFER_HALF 1
#endif

#if HAS_HALF && PREFER_HALF
#define REAL_IS_HALF 1
#else
#define REAL_IS_HALF 0
#endif // Do we have half?

#if REAL_IS_HALF
#define real half
#define real2 half2
#define real3 half3
#define real4 half4

#define real2x2 half2x2
#define real2x3 half2x3
#define real3x2 half3x2
#define real3x3 half3x3
#define real3x4 half3x4
#define real4x3 half4x3
#define real4x4 half4x4

#define half min16float
#define half2 min16float2
#define half3 min16float3
#define half4 min16float4

#define half2x2 min16float2x2
#define half2x3 min16float2x3
#define half3x2 min16float3x2
#define half3x3 min16float3x3
#define half3x4 min16float3x4
#define half4x3 min16float4x3
#define half4x4 min16float4x4

#define REAL_MIN HALF_MIN
#define REAL_MAX HALF_MAX
#define REAL_EPS HALF_EPS
#define TEMPLATE_1_REAL TEMPLATE_1_HALF
#define TEMPLATE_2_REAL TEMPLATE_2_HALF
#define TEMPLATE_3_REAL TEMPLATE_3_HALF

#else

#define real float
#define real2 float2
#define real3 float3
#define real4 float4

#define real2x2 float2x2
#define real2x3 float2x3
#define real3x2 float3x2
#define real3x3 float3x3
#define real3x4 float3x4
#define real4x3 float4x3
#define real4x4 float4x4

#define REAL_MIN FLT_MIN
#define REAL_MAX FLT_MAX
#define REAL_EPS FLT_EPS
#define TEMPLATE_1_REAL TEMPLATE_1_FLT
#define TEMPLATE_2_REAL TEMPLATE_2_FLT
#define TEMPLATE_3_REAL TEMPLATE_3_FLT

#endif // REAL_IS_HALF

#endif // #ifndef real

// Target in compute shader are supported in 2018.2, for now define ours
// (Note only 45 and above support compute shader)
#ifdef  SHADER_STAGE_COMPUTE
#   ifndef SHADER_TARGET
#       if defined(SHADER_API_METAL)
#       define SHADER_TARGET 45
#       else
#       define SHADER_TARGET 50
#       endif
#   endif
#endif

// Include language header
#if defined(SHADER_API_XBOXONE)
//================================================================================================================================
// WARNING: File not found: com.unity.render-pipelines.xboxone/ShaderLibrary/API/XBoxOne.hlsl
//================================================================================================================================

#elif defined(SHADER_API_PSSL)
//================================================================================================================================
// WARNING: File not found: com.unity.render-pipelines.ps4/ShaderLibrary/API/PSSL.hlsl
//================================================================================================================================

#elif defined(SHADER_API_D3D11)
//================================================================================================================================
// File start: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/API/D3D11.hlsl


// This file assume SHADER_API_D3D11 is defined

#define UNITY_UV_STARTS_AT_TOP 1
#define UNITY_REVERSED_Z 1
#define UNITY_NEAR_CLIP_VALUE (1.0)
// This value will not go through any matrix projection conversion
#define UNITY_RAW_FAR_CLIP_VALUE (0.0)
#define VERTEXID_SEMANTIC SV_VertexID
#define INSTANCEID_SEMANTIC SV_InstanceID
#define FRONT_FACE_SEMANTIC SV_IsFrontFace
#define FRONT_FACE_TYPE bool
#define IS_FRONT_VFACE(VAL, FRONT, BACK) ((VAL) ? (FRONT) : (BACK))

#define CBUFFER_START(name) cbuffer name {
#define CBUFFER_END };

#define PLATFORM_SUPPORTS_EXPLICIT_BINDING
#define PLATFORM_NEEDS_UNORM_UAV_SPECIFIER
#define PLATFORM_SUPPORTS_BUFFER_ATOMICS_IN_PIXEL_SHADER


// flow control attributes
#define UNITY_BRANCH        [branch]
#define UNITY_FLATTEN       [flatten]
#define UNITY_UNROLL        [unroll]
#define UNITY_UNROLLX(_x)   [unroll(_x)]
#define UNITY_LOOP          [loop]

// Initialize arbitrary structure with zero values.
// Do not exist on some platform, in this case we need to have a standard name that call a function that will initialize all parameters to 0
#define ZERO_INITIALIZE(type, name) name = (type)0;
#define ZERO_INITIALIZE_ARRAY(type, name, arraySize) { for (int arrayIndex = 0; arrayIndex < arraySize; arrayIndex++) { name[arrayIndex] = (type)0; } }

// Texture util abstraction

#define CALCULATE_TEXTURE2D_LOD(textureName, samplerName, coord2) textureName.CalculateLevelOfDetail(samplerName, coord2)

// Texture abstraction

#define TEXTURE2D(textureName)                Texture2D textureName
#define TEXTURE2D_ARRAY(textureName)          Texture2DArray textureName
#define TEXTURECUBE(textureName)              TextureCube textureName
#define TEXTURECUBE_ARRAY(textureName)        TextureCubeArray textureName
#define TEXTURE3D(textureName)                Texture3D textureName

#define TEXTURE2D_FLOAT(textureName)          TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_FLOAT(textureName)    TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_FLOAT(textureName)        TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_FLOAT(textureName)  TEXTURECUBE_ARRAY(textureName)
#define TEXTURE3D_FLOAT(textureName)          TEXTURE3D(textureName)

#define TEXTURE2D_HALF(textureName)           TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_HALF(textureName)     TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_HALF(textureName)         TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_HALF(textureName)   TEXTURECUBE_ARRAY(textureName)
#define TEXTURE3D_HALF(textureName)           TEXTURE3D(textureName)

#define TEXTURE2D_SHADOW(textureName)         TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_SHADOW(textureName)   TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_SHADOW(textureName)       TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_SHADOW(textureName) TEXTURECUBE_ARRAY(textureName)

#define RW_TEXTURE2D(type, textureName)       RWTexture2D<type> textureName
#define RW_TEXTURE2D_ARRAY(type, textureName) RWTexture2DArray<type> textureName
#define RW_TEXTURE3D(type, textureName)       RWTexture3D<type> textureName

#define SAMPLER(samplerName)                  SamplerState samplerName
#define SAMPLER_CMP(samplerName)              SamplerComparisonState samplerName

#define TEXTURE2D_PARAM(textureName, samplerName)                 TEXTURE2D(textureName),         SAMPLER(samplerName)
#define TEXTURE2D_ARRAY_PARAM(textureName, samplerName)           TEXTURE2D_ARRAY(textureName),   SAMPLER(samplerName)
#define TEXTURECUBE_PARAM(textureName, samplerName)               TEXTURECUBE(textureName),       SAMPLER(samplerName)
#define TEXTURECUBE_ARRAY_PARAM(textureName, samplerName)         TEXTURECUBE_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURE3D_PARAM(textureName, samplerName)                 TEXTURE3D(textureName),         SAMPLER(samplerName)

#define TEXTURE2D_SHADOW_PARAM(textureName, samplerName)          TEXTURE2D(textureName),         SAMPLER_CMP(samplerName)
#define TEXTURE2D_ARRAY_SHADOW_PARAM(textureName, samplerName)    TEXTURE2D_ARRAY(textureName),   SAMPLER_CMP(samplerName)
#define TEXTURECUBE_SHADOW_PARAM(textureName, samplerName)        TEXTURECUBE(textureName),       SAMPLER_CMP(samplerName)
#define TEXTURECUBE_ARRAY_SHADOW_PARAM(textureName, samplerName)  TEXTURECUBE_ARRAY(textureName), SAMPLER_CMP(samplerName)

#define TEXTURE2D_ARGS(textureName, samplerName)                textureName, samplerName
#define TEXTURE2D_ARRAY_ARGS(textureName, samplerName)          textureName, samplerName
#define TEXTURECUBE_ARGS(textureName, samplerName)              textureName, samplerName
#define TEXTURECUBE_ARRAY_ARGS(textureName, samplerName)        textureName, samplerName
#define TEXTURE3D_ARGS(textureName, samplerName)                textureName, samplerName

#define TEXTURE2D_SHADOW_ARGS(textureName, samplerName)         textureName, samplerName
#define TEXTURE2D_ARRAY_SHADOW_ARGS(textureName, samplerName)   textureName, samplerName
#define TEXTURECUBE_SHADOW_ARGS(textureName, samplerName)       textureName, samplerName
#define TEXTURECUBE_ARRAY_SHADOW_ARGS(textureName, samplerName) textureName, samplerName

#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2)                               textureName.Sample(samplerName, coord2)
#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod)                      textureName.SampleLevel(samplerName, coord2, lod)
#define SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)                    textureName.SampleBias(samplerName, coord2, bias)
#define SAMPLE_TEXTURE2D_GRAD(textureName, samplerName, coord2, dpdx, dpdy)              textureName.SampleGrad(samplerName, coord2, dpdx, dpdy)
#define SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)                  textureName.Sample(samplerName, float3(coord2, index))
#define SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, index, lod)         textureName.SampleLevel(samplerName, float3(coord2, index), lod)
#define SAMPLE_TEXTURE2D_ARRAY_BIAS(textureName, samplerName, coord2, index, bias)       textureName.SampleBias(samplerName, float3(coord2, index), bias)
#define SAMPLE_TEXTURE2D_ARRAY_GRAD(textureName, samplerName, coord2, index, dpdx, dpdy) textureName.SampleGrad(samplerName, float3(coord2, index), dpdx, dpdy)
#define SAMPLE_TEXTURECUBE(textureName, samplerName, coord3)                             textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURECUBE_LOD(textureName, samplerName, coord3, lod)                    textureName.SampleLevel(samplerName, coord3, lod)
#define SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, bias)                  textureName.SampleBias(samplerName, coord3, bias)
#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)                textureName.Sample(samplerName, float4(coord3, index))
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)       textureName.SampleLevel(samplerName, float4(coord3, index), lod)
#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)     textureName.SampleBias(samplerName, float4(coord3, index), bias)
#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3)                               textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURE3D_LOD(textureName, samplerName, coord3, lod)                      textureName.SampleLevel(samplerName, coord3, lod)

#define SAMPLE_TEXTURE2D_SHADOW(textureName, samplerName, coord3)                    textureName.SampleCmpLevelZero(samplerName, (coord3).xy, (coord3).z)
#define SAMPLE_TEXTURE2D_ARRAY_SHADOW(textureName, samplerName, coord3, index)       textureName.SampleCmpLevelZero(samplerName, float3((coord3).xy, index), (coord3).z)
#define SAMPLE_TEXTURECUBE_SHADOW(textureName, samplerName, coord4)                  textureName.SampleCmpLevelZero(samplerName, (coord4).xyz, (coord4).w)
#define SAMPLE_TEXTURECUBE_ARRAY_SHADOW(textureName, samplerName, coord4, index)     textureName.SampleCmpLevelZero(samplerName, float4((coord4).xyz, index), (coord4).w)

#define SAMPLE_DEPTH_TEXTURE(textureName, samplerName, coord2)          SAMPLE_TEXTURE2D(textureName, samplerName, coord2).r
#define SAMPLE_DEPTH_TEXTURE_LOD(textureName, samplerName, coord2, lod) SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod).r

#define LOAD_TEXTURE2D(textureName, unCoord2)                                   textureName.Load(int3(unCoord2, 0))
#define LOAD_TEXTURE2D_LOD(textureName, unCoord2, lod)                          textureName.Load(int3(unCoord2, lod))
#define LOAD_TEXTURE2D_MSAA(textureName, unCoord2, sampleIndex)                 textureName.Load(unCoord2, sampleIndex)
#define LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, index)                      textureName.Load(int4(unCoord2, index, 0))
#define LOAD_TEXTURE2D_ARRAY_MSAA(textureName, unCoord2, index, sampleIndex)    textureName.Load(int3(unCoord2, index), sampleIndex)
#define LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, index, lod)             textureName.Load(int4(unCoord2, index, lod))
#define LOAD_TEXTURE3D(textureName, unCoord3)                                   textureName.Load(int4(unCoord3, 0))
#define LOAD_TEXTURE3D_LOD(textureName, unCoord3, lod)                          textureName.Load(int4(unCoord3, lod))

#define PLATFORM_SUPPORT_GATHER
#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                textureName.Gather(samplerName, coord2)
#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)   textureName.Gather(samplerName, float3(coord2, index))
#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)              textureName.Gather(samplerName, coord3)
#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index) textureName.Gather(samplerName, float4(coord3, index))
#define GATHER_RED_TEXTURE2D(textureName, samplerName, coord2)            textureName.GatherRed(samplerName, coord2)
#define GATHER_GREEN_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherGreen(samplerName, coord2)
#define GATHER_BLUE_TEXTURE2D(textureName, samplerName, coord2)           textureName.GatherBlue(samplerName, coord2)
#define GATHER_ALPHA_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherAlpha(samplerName, coord2)

// File end: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/API/D3D11.hlsl
//================================================================================================================================



#elif defined(SHADER_API_METAL)
//================================================================================================================================
// File start: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/API/Metal.hlsl


// This file assumes SHADER_API_METAL is defined
// TODO: This is a straight copy from D3D11.hlsl. Go through all this stuff and adjust where needed.

#define UNITY_UV_STARTS_AT_TOP 1
#define UNITY_REVERSED_Z 1
#define UNITY_NEAR_CLIP_VALUE (1.0)
// This value will not go through any matrix projection conversion
#define UNITY_RAW_FAR_CLIP_VALUE (0.0)
#define VERTEXID_SEMANTIC SV_VertexID
#define INSTANCEID_SEMANTIC SV_InstanceID
#define FRONT_FACE_SEMANTIC SV_IsFrontFace
#define FRONT_FACE_TYPE bool
#define IS_FRONT_VFACE(VAL, FRONT, BACK) ((VAL) ? (FRONT) : (BACK))

#define CBUFFER_START(name) cbuffer name {
#define CBUFFER_END };

#define PLATFORM_SUPPORTS_EXPLICIT_BINDING
#define PLATFORM_NEEDS_UNORM_UAV_SPECIFIER
#define PLATFORM_SUPPORTS_BUFFER_ATOMICS_IN_PIXEL_SHADER

// flow control attributes
#define UNITY_BRANCH        [branch]
#define UNITY_FLATTEN       [flatten]
#define UNITY_UNROLL        [unroll]
#define UNITY_UNROLLX(_x)   [unroll(_x)]
#define UNITY_LOOP          [loop]

// Initialize arbitrary structure with zero values.
// Do not exist on some platform, in this case we need to have a standard name that call a function that will initialize all parameters to 0
#define ZERO_INITIALIZE(type, name) name = (type)0;
#define ZERO_INITIALIZE_ARRAY(type, name, arraySize) { for (int arrayIndex = 0; arrayIndex < arraySize; arrayIndex++) { name[arrayIndex] = (type)0; } }

// Texture util abstraction

#define CALCULATE_TEXTURE2D_LOD(textureName, samplerName, coord2) textureName.CalculateLevelOfDetail(samplerName, coord2)

// Texture abstraction

#define TEXTURE2D(textureName)                Texture2D textureName
#define TEXTURE2D_ARRAY(textureName)          Texture2DArray textureName
#define TEXTURECUBE(textureName)              TextureCube textureName
#define TEXTURECUBE_ARRAY(textureName)        TextureCubeArray textureName
#define TEXTURE3D(textureName)                Texture3D textureName

#define TEXTURE2D_FLOAT(textureName)          Texture2D_float textureName
#define TEXTURE2D_ARRAY_FLOAT(textureName)    Texture2DArray textureName    // no support to _float on Array, it's being added
#define TEXTURECUBE_FLOAT(textureName)        TextureCube_float textureName
#define TEXTURECUBE_ARRAY_FLOAT(textureName)  TextureCubeArray textureName  // no support to _float on Array, it's being added
#define TEXTURE3D_FLOAT(textureName)          Texture3D_float textureName

#define TEXTURE2D_HALF(textureName)           Texture2D_half textureName
#define TEXTURE2D_ARRAY_HALF(textureName)     Texture2DArray textureName    // no support to _float on Array, it's being added
#define TEXTURECUBE_HALF(textureName)         TextureCube_half textureName
#define TEXTURECUBE_ARRAY_HALF(textureName)   TextureCubeArray textureName  // no support to _float on Array, it's being added
#define TEXTURE3D_HALF(textureName)           Texture3D_half textureName

#define TEXTURE2D_SHADOW(textureName)         TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_SHADOW(textureName)   TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_SHADOW(textureName)       TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_SHADOW(textureName) TEXTURECUBE_ARRAY(textureName)

#define RW_TEXTURE2D(type, textureName)       RWTexture2D<type> textureName
#define RW_TEXTURE2D_ARRAY(type, textureName) RWTexture2DArray<type> textureName
#define RW_TEXTURE3D(type, textureName)       RWTexture3D<type> textureName

#define SAMPLER(samplerName)                  SamplerState samplerName
#define SAMPLER_CMP(samplerName)              SamplerComparisonState samplerName

#define TEXTURE2D_PARAM(textureName, samplerName)                 TEXTURE2D(textureName),         SAMPLER(samplerName)
#define TEXTURE2D_ARRAY_PARAM(textureName, samplerName)           TEXTURE2D_ARRAY(textureName),   SAMPLER(samplerName)
#define TEXTURECUBE_PARAM(textureName, samplerName)               TEXTURECUBE(textureName),       SAMPLER(samplerName)
#define TEXTURECUBE_ARRAY_PARAM(textureName, samplerName)         TEXTURECUBE_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURE3D_PARAM(textureName, samplerName)                 TEXTURE3D(textureName),         SAMPLER(samplerName)

#define TEXTURE2D_SHADOW_PARAM(textureName, samplerName)          TEXTURE2D(textureName),         SAMPLER_CMP(samplerName)
#define TEXTURE2D_ARRAY_SHADOW_PARAM(textureName, samplerName)    TEXTURE2D_ARRAY(textureName),   SAMPLER_CMP(samplerName)
#define TEXTURECUBE_SHADOW_PARAM(textureName, samplerName)        TEXTURECUBE(textureName),       SAMPLER_CMP(samplerName)
#define TEXTURECUBE_ARRAY_SHADOW_PARAM(textureName, samplerName)  TEXTURECUBE_ARRAY(textureName), SAMPLER_CMP(samplerName)

#define TEXTURE2D_ARGS(textureName, samplerName)                textureName, samplerName
#define TEXTURE2D_ARRAY_ARGS(textureName, samplerName)          textureName, samplerName
#define TEXTURECUBE_ARGS(textureName, samplerName)              textureName, samplerName
#define TEXTURECUBE_ARRAY_ARGS(textureName, samplerName)        textureName, samplerName
#define TEXTURE3D_ARGS(textureName, samplerName)                textureName, samplerName

#define TEXTURE2D_SHADOW_ARGS(textureName, samplerName)         textureName, samplerName
#define TEXTURE2D_ARRAY_SHADOW_ARGS(textureName, samplerName)   textureName, samplerName
#define TEXTURECUBE_SHADOW_ARGS(textureName, samplerName)       textureName, samplerName
#define TEXTURECUBE_ARRAY_SHADOW_ARGS(textureName, samplerName) textureName, samplerName

#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2)                               textureName.Sample(samplerName, coord2)
#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod)                      textureName.SampleLevel(samplerName, coord2, lod)
#define SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)                    textureName.SampleBias(samplerName, coord2, bias)
#define SAMPLE_TEXTURE2D_GRAD(textureName, samplerName, coord2, dpdx, dpdy)              textureName.SampleGrad(samplerName, coord2, dpdx, dpdy)
#define SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)                  textureName.Sample(samplerName, float3(coord2, index))
#define SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, index, lod)         textureName.SampleLevel(samplerName, float3(coord2, index), lod)
#define SAMPLE_TEXTURE2D_ARRAY_BIAS(textureName, samplerName, coord2, index, bias)       textureName.SampleBias(samplerName, float3(coord2, index), bias)
#define SAMPLE_TEXTURE2D_ARRAY_GRAD(textureName, samplerName, coord2, index, dpdx, dpdy) textureName.SampleGrad(samplerName, float3(coord2, index), dpdx, dpdy)
#define SAMPLE_TEXTURECUBE(textureName, samplerName, coord3)                             textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURECUBE_LOD(textureName, samplerName, coord3, lod)                    textureName.SampleLevel(samplerName, coord3, lod)
#define SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, bias)                  textureName.SampleBias(samplerName, coord3, bias)
#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)                textureName.Sample(samplerName, float4(coord3, index))
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)       textureName.SampleLevel(samplerName, float4(coord3, index), lod)
#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)     textureName.SampleBias(samplerName, float4(coord3, index), bias)
#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3)                               textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURE3D_LOD(textureName, samplerName, coord3, lod)                      textureName.SampleLevel(samplerName, coord3, lod)

#define SAMPLE_TEXTURE2D_SHADOW(textureName, samplerName, coord3)                    textureName.SampleCmpLevelZero(samplerName, (coord3).xy, (coord3).z)
#define SAMPLE_TEXTURE2D_ARRAY_SHADOW(textureName, samplerName, coord3, index)       textureName.SampleCmpLevelZero(samplerName, float3((coord3).xy, index), (coord3).z)
#define SAMPLE_TEXTURECUBE_SHADOW(textureName, samplerName, coord4)                  textureName.SampleCmpLevelZero(samplerName, (coord4).xyz, (coord4).w)
#define SAMPLE_TEXTURECUBE_ARRAY_SHADOW(textureName, samplerName, coord4, index)     textureName.SampleCmpLevelZero(samplerName, float4((coord4).xyz, index), (coord4).w)

#define SAMPLE_DEPTH_TEXTURE(textureName, samplerName, coord2)          SAMPLE_TEXTURE2D(textureName, samplerName, coord2).r
#define SAMPLE_DEPTH_TEXTURE_LOD(textureName, samplerName, coord2, lod) SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod).r

#define LOAD_TEXTURE2D(textureName, unCoord2)                                   textureName.Load(int3(unCoord2, 0))
#define LOAD_TEXTURE2D_LOD(textureName, unCoord2, lod)                          textureName.Load(int3(unCoord2, lod))
#define LOAD_TEXTURE2D_MSAA(textureName, unCoord2, sampleIndex)                 textureName.Load(unCoord2, sampleIndex)
#define LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, index)                      textureName.Load(int4(unCoord2, index, 0))
#define LOAD_TEXTURE2D_ARRAY_MSAA(textureName, unCoord2, index, sampleIndex)    textureName.Load(int3(unCoord2, index), sampleIndex)
#define LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, index, lod)             textureName.Load(int4(unCoord2, index, lod))
#define LOAD_TEXTURE3D(textureName, unCoord3)                                   textureName.Load(int4(unCoord3, 0))
#define LOAD_TEXTURE3D_LOD(textureName, unCoord3, lod)                          textureName.Load(int4(unCoord3, lod))

#define PLATFORM_SUPPORT_GATHER
#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                textureName.Gather(samplerName, coord2)
#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)   textureName.Gather(samplerName, float3(coord2, index))
#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)              textureName.Gather(samplerName, coord3)
#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index) textureName.Gather(samplerName, float4(coord3, index))
#define GATHER_RED_TEXTURE2D(textureName, samplerName, coord2)            textureName.GatherRed(samplerName, coord2)
#define GATHER_GREEN_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherGreen(samplerName, coord2)
#define GATHER_BLUE_TEXTURE2D(textureName, samplerName, coord2)           textureName.GatherBlue(samplerName, coord2)
#define GATHER_ALPHA_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherAlpha(samplerName, coord2)

// File end: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/API/Metal.hlsl
//================================================================================================================================



#elif defined(SHADER_API_VULKAN)
//================================================================================================================================
// File start: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/API/Vulkan.hlsl


// This file assume SHADER_API_VULKAN is defined
// TODO: This is a straight copy from D3D11.hlsl. Go through all this stuff and adjust where needed.

#define UNITY_UV_STARTS_AT_TOP 1
#define UNITY_REVERSED_Z 1
#define UNITY_NEAR_CLIP_VALUE (1.0)
// This value will not go through any matrix projection conversion
#define UNITY_RAW_FAR_CLIP_VALUE (0.0)
#define VERTEXID_SEMANTIC SV_VertexID
#define INSTANCEID_SEMANTIC SV_InstanceID
#define FRONT_FACE_SEMANTIC SV_IsFrontFace
#define FRONT_FACE_TYPE bool
#define IS_FRONT_VFACE(VAL, FRONT, BACK) ((VAL) ? (FRONT) : (BACK))

#define CBUFFER_START(name) cbuffer name {
#define CBUFFER_END };

#define PLATFORM_SUPPORTS_EXPLICIT_BINDING
#define PLATFORM_NEEDS_UNORM_UAV_SPECIFIER
#define PLATFORM_SUPPORTS_BUFFER_ATOMICS_IN_PIXEL_SHADER

// flow control attributes
#define UNITY_BRANCH        [branch]
#define UNITY_FLATTEN       [flatten]
#define UNITY_UNROLL        [unroll]
#define UNITY_UNROLLX(_x)   [unroll(_x)]
#define UNITY_LOOP          [loop]

// Initialize arbitrary structure with zero values.
// Do not exist on some platform, in this case we need to have a standard name that call a function that will initialize all parameters to 0
#define ZERO_INITIALIZE(type, name) name = (type)0;
#define ZERO_INITIALIZE_ARRAY(type, name, arraySize) { for (int arrayIndex = 0; arrayIndex < arraySize; arrayIndex++) { name[arrayIndex] = (type)0; } }

// Texture util abstraction

#define CALCULATE_TEXTURE2D_LOD(textureName, samplerName, coord2) textureName.CalculateLevelOfDetail(samplerName, coord2)

// Texture abstraction

#define TEXTURE2D(textureName)                Texture2D textureName
#define TEXTURE2D_ARRAY(textureName)          Texture2DArray textureName
#define TEXTURECUBE(textureName)              TextureCube textureName
#define TEXTURECUBE_ARRAY(textureName)        TextureCubeArray textureName
#define TEXTURE3D(textureName)                Texture3D textureName

#define TEXTURE2D_FLOAT(textureName)          Texture2D_float textureName
#define TEXTURE2D_ARRAY_FLOAT(textureName)    Texture2DArray textureName    // no support to _float on Array, it's being added
#define TEXTURECUBE_FLOAT(textureName)        TextureCube_float textureName
#define TEXTURECUBE_ARRAY_FLOAT(textureName)  TextureCubeArray textureName  // no support to _float on Array, it's being added
#define TEXTURE3D_FLOAT(textureName)          Texture3D_float textureName

#define TEXTURE2D_HALF(textureName)           Texture2D_half textureName
#define TEXTURE2D_ARRAY_HALF(textureName)     Texture2DArray textureName    // no support to _float on Array, it's being added
#define TEXTURECUBE_HALF(textureName)         TextureCube_half textureName
#define TEXTURECUBE_ARRAY_HALF(textureName)   TextureCubeArray textureName  // no support to _float on Array, it's being added
#define TEXTURE3D_HALF(textureName)           Texture3D_half textureName

#define TEXTURE2D_SHADOW(textureName)         TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_SHADOW(textureName)   TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_SHADOW(textureName)       TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_SHADOW(textureName) TEXTURECUBE_ARRAY(textureName)

#define RW_TEXTURE2D(type, textureName)       RWTexture2D<type> textureName
#define RW_TEXTURE2D_ARRAY(type, textureName) RWTexture2DArray<type> textureName
#define RW_TEXTURE3D(type, textureName)       RWTexture3D<type> textureName

#define SAMPLER(samplerName)                  SamplerState samplerName
#define SAMPLER_CMP(samplerName)              SamplerComparisonState samplerName

#define TEXTURE2D_PARAM(textureName, samplerName)                 TEXTURE2D(textureName),         SAMPLER(samplerName)
#define TEXTURE2D_ARRAY_PARAM(textureName, samplerName)           TEXTURE2D_ARRAY(textureName),   SAMPLER(samplerName)
#define TEXTURECUBE_PARAM(textureName, samplerName)               TEXTURECUBE(textureName),       SAMPLER(samplerName)
#define TEXTURECUBE_ARRAY_PARAM(textureName, samplerName)         TEXTURECUBE_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURE3D_PARAM(textureName, samplerName)                 TEXTURE3D(textureName),         SAMPLER(samplerName)

#define TEXTURE2D_SHADOW_PARAM(textureName, samplerName)          TEXTURE2D(textureName),         SAMPLER_CMP(samplerName)
#define TEXTURE2D_ARRAY_SHADOW_PARAM(textureName, samplerName)    TEXTURE2D_ARRAY(textureName),   SAMPLER_CMP(samplerName)
#define TEXTURECUBE_SHADOW_PARAM(textureName, samplerName)        TEXTURECUBE(textureName),       SAMPLER_CMP(samplerName)
#define TEXTURECUBE_ARRAY_SHADOW_PARAM(textureName, samplerName)  TEXTURECUBE_ARRAY(textureName), SAMPLER_CMP(samplerName)

#define TEXTURE2D_ARGS(textureName, samplerName)                textureName, samplerName
#define TEXTURE2D_ARRAY_ARGS(textureName, samplerName)          textureName, samplerName
#define TEXTURECUBE_ARGS(textureName, samplerName)              textureName, samplerName
#define TEXTURECUBE_ARRAY_ARGS(textureName, samplerName)        textureName, samplerName
#define TEXTURE3D_ARGS(textureName, samplerName)                textureName, samplerName

#define TEXTURE2D_SHADOW_ARGS(textureName, samplerName)         textureName, samplerName
#define TEXTURE2D_ARRAY_SHADOW_ARGS(textureName, samplerName)   textureName, samplerName
#define TEXTURECUBE_SHADOW_ARGS(textureName, samplerName)       textureName, samplerName
#define TEXTURECUBE_ARRAY_SHADOW_ARGS(textureName, samplerName) textureName, samplerName

#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2)                               textureName.Sample(samplerName, coord2)
#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod)                      textureName.SampleLevel(samplerName, coord2, lod)
#define SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)                    textureName.SampleBias(samplerName, coord2, bias)
#define SAMPLE_TEXTURE2D_GRAD(textureName, samplerName, coord2, dpdx, dpdy)              textureName.SampleGrad(samplerName, coord2, dpdx, dpdy)
#define SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)                  textureName.Sample(samplerName, float3(coord2, index))
#define SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, index, lod)         textureName.SampleLevel(samplerName, float3(coord2, index), lod)
#define SAMPLE_TEXTURE2D_ARRAY_BIAS(textureName, samplerName, coord2, index, bias)       textureName.SampleBias(samplerName, float3(coord2, index), bias)
#define SAMPLE_TEXTURE2D_ARRAY_GRAD(textureName, samplerName, coord2, index, dpdx, dpdy) textureName.SampleGrad(samplerName, float3(coord2, index), dpdx, dpdy)
#define SAMPLE_TEXTURECUBE(textureName, samplerName, coord3)                             textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURECUBE_LOD(textureName, samplerName, coord3, lod)                    textureName.SampleLevel(samplerName, coord3, lod)
#define SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, bias)                  textureName.SampleBias(samplerName, coord3, bias)
#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)                textureName.Sample(samplerName, float4(coord3, index))
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)       textureName.SampleLevel(samplerName, float4(coord3, index), lod)
#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)     textureName.SampleBias(samplerName, float4(coord3, index), bias)
#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3)                               textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURE3D_LOD(textureName, samplerName, coord3, lod)                      textureName.SampleLevel(samplerName, coord3, lod)

#define SAMPLE_TEXTURE2D_SHADOW(textureName, samplerName, coord3)                    textureName.SampleCmpLevelZero(samplerName, (coord3).xy, (coord3).z)
#define SAMPLE_TEXTURE2D_ARRAY_SHADOW(textureName, samplerName, coord3, index)       textureName.SampleCmpLevelZero(samplerName, float3((coord3).xy, index), (coord3).z)
#define SAMPLE_TEXTURECUBE_SHADOW(textureName, samplerName, coord4)                  textureName.SampleCmpLevelZero(samplerName, (coord4).xyz, (coord4).w)
#define SAMPLE_TEXTURECUBE_ARRAY_SHADOW(textureName, samplerName, coord4, index)     textureName.SampleCmpLevelZero(samplerName, float4((coord4).xyz, index), (coord4).w)

#define SAMPLE_DEPTH_TEXTURE(textureName, samplerName, coord2)          SAMPLE_TEXTURE2D(textureName, samplerName, coord2).r
#define SAMPLE_DEPTH_TEXTURE_LOD(textureName, samplerName, coord2, lod) SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod).r

#define LOAD_TEXTURE2D(textureName, unCoord2)                                   textureName.Load(int3(unCoord2, 0))
#define LOAD_TEXTURE2D_LOD(textureName, unCoord2, lod)                          textureName.Load(int3(unCoord2, lod))
#define LOAD_TEXTURE2D_MSAA(textureName, unCoord2, sampleIndex)                 textureName.Load(unCoord2, sampleIndex)
#define LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, index)                      textureName.Load(int4(unCoord2, index, 0))
#define LOAD_TEXTURE2D_ARRAY_MSAA(textureName, unCoord2, index, sampleIndex)    textureName.Load(int3(unCoord2, index), sampleIndex)
#define LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, index, lod)             textureName.Load(int4(unCoord2, index, lod))
#define LOAD_TEXTURE3D(textureName, unCoord3)                                   textureName.Load(int4(unCoord3, 0))
#define LOAD_TEXTURE3D_LOD(textureName, unCoord3, lod)                          textureName.Load(int4(unCoord3, lod))

#define PLATFORM_SUPPORT_GATHER
#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                textureName.Gather(samplerName, coord2)
#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)   textureName.Gather(samplerName, float3(coord2, index))
#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)              textureName.Gather(samplerName, coord3)
#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index) textureName.Gather(samplerName, float4(coord3, index))
#define GATHER_RED_TEXTURE2D(textureName, samplerName, coord2)            textureName.GatherRed(samplerName, coord2)
#define GATHER_GREEN_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherGreen(samplerName, coord2)
#define GATHER_BLUE_TEXTURE2D(textureName, samplerName, coord2)           textureName.GatherBlue(samplerName, coord2)
#define GATHER_ALPHA_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherAlpha(samplerName, coord2)

// File end: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/API/Vulkan.hlsl
//================================================================================================================================



#elif defined(SHADER_API_SWITCH)
//================================================================================================================================
// File start: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/API/Switch.hlsl


// This file assume SHADER_API_SWITCH is defined
// TODO: This is a straight copy from D3D11.hlsl. Go through all this stuff and adjust where needed.

#define UNITY_UV_STARTS_AT_TOP 1
#define UNITY_REVERSED_Z 1
#define UNITY_NEAR_CLIP_VALUE (1.0)
// This value will not go through any matrix projection conversion
#define UNITY_RAW_FAR_CLIP_VALUE (0.0)
#define VERTEXID_SEMANTIC SV_VertexID
#define INSTANCEID_SEMANTIC SV_InstanceID
#define FRONT_FACE_SEMANTIC SV_IsFrontFace
#define FRONT_FACE_TYPE bool
#define IS_FRONT_VFACE(VAL, FRONT, BACK) ((VAL) ? (FRONT) : (BACK))

#define CBUFFER_START(name) cbuffer name {
#define CBUFFER_END };

#define PLATFORM_SUPPORTS_EXPLICIT_BINDING
#define PLATFORM_NEEDS_UNORM_UAV_SPECIFIER
#define PLATFORM_LANE_COUNT 32

// flow control attributes
#define UNITY_BRANCH        [branch]
#define UNITY_FLATTEN       [flatten]
#define UNITY_UNROLL        [unroll]
#define UNITY_UNROLLX(_x)   [unroll(_x)]
#define UNITY_LOOP          [loop]

// Initialize arbitrary structure with zero values.
// Do not exist on some platform, in this case we need to have a standard name that call a function that will initialize all parameters to 0
#define ZERO_INITIALIZE(type, name) name = (type)0;
#define ZERO_INITIALIZE_ARRAY(type, name, arraySize) { for (int arrayIndex = 0; arrayIndex < arraySize; arrayIndex++) { name[arrayIndex] = (type)0; } }

// Texture util abstraction

#define CALCULATE_TEXTURE2D_LOD(textureName, samplerName, coord2) textureName.CalculateLevelOfDetail(samplerName, coord2)

// Texture abstraction

#define TEXTURE2D(textureName)                Texture2D textureName
#define TEXTURE2D_ARRAY(textureName)          Texture2DArray textureName
#define TEXTURECUBE(textureName)              TextureCube textureName
#define TEXTURECUBE_ARRAY(textureName)        TextureCubeArray textureName
#define TEXTURE3D(textureName)                Texture3D textureName

#define TEXTURE2D_FLOAT(textureName)          Texture2D_float textureName
#define TEXTURE2D_ARRAY_FLOAT(textureName)    Texture2DArray textureName    // no support to _float on Array, it's being added
#define TEXTURECUBE_FLOAT(textureName)        TextureCube_float textureName
#define TEXTURECUBE_ARRAY_FLOAT(textureName)  TextureCubeArray textureName  // no support to _float on Array, it's being added
#define TEXTURE3D_FLOAT(textureName)          Texture3D_float textureName

#define TEXTURE2D_HALF(textureName)           Texture2D_half textureName
#define TEXTURE2D_ARRAY_HALF(textureName)     Texture2DArray textureName    // no support to _float on Array, it's being added
#define TEXTURECUBE_HALF(textureName)         TextureCube_half textureName
#define TEXTURECUBE_ARRAY_HALF(textureName)   TextureCubeArray textureName  // no support to _float on Array, it's being added
#define TEXTURE3D_HALF(textureName)           Texture3D_half textureName

#define TEXTURE2D_SHADOW(textureName)         TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_SHADOW(textureName)   TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_SHADOW(textureName)       TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_SHADOW(textureName) TEXTURECUBE_ARRAY(textureName)

#define RW_TEXTURE2D(type, textureName)       RWTexture2D<type> textureName
#define RW_TEXTURE2D_ARRAY(type, textureName) RWTexture2DArray<type> textureName
#define RW_TEXTURE3D(type, textureName)       RWTexture3D<type> textureName

#define SAMPLER(samplerName)                  SamplerState samplerName
#define SAMPLER_CMP(samplerName)              SamplerComparisonState samplerName

#define TEXTURE2D_PARAM(textureName, samplerName)                 TEXTURE2D(textureName),         SAMPLER(samplerName)
#define TEXTURE2D_ARRAY_PARAM(textureName, samplerName)           TEXTURE2D_ARRAY(textureName),   SAMPLER(samplerName)
#define TEXTURECUBE_PARAM(textureName, samplerName)               TEXTURECUBE(textureName),       SAMPLER(samplerName)
#define TEXTURECUBE_ARRAY_PARAM(textureName, samplerName)         TEXTURECUBE_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURE3D_PARAM(textureName, samplerName)                 TEXTURE3D(textureName),         SAMPLER(samplerName)

#define TEXTURE2D_SHADOW_PARAM(textureName, samplerName)          TEXTURE2D(textureName),         SAMPLER_CMP(samplerName)
#define TEXTURE2D_ARRAY_SHADOW_PARAM(textureName, samplerName)    TEXTURE2D_ARRAY(textureName),   SAMPLER_CMP(samplerName)
#define TEXTURECUBE_SHADOW_PARAM(textureName, samplerName)        TEXTURECUBE(textureName),       SAMPLER_CMP(samplerName)
#define TEXTURECUBE_ARRAY_SHADOW_PARAM(textureName, samplerName)  TEXTURECUBE_ARRAY(textureName), SAMPLER_CMP(samplerName)

#define TEXTURE2D_ARGS(textureName, samplerName)                textureName, samplerName
#define TEXTURE2D_ARRAY_ARGS(textureName, samplerName)          textureName, samplerName
#define TEXTURECUBE_ARGS(textureName, samplerName)              textureName, samplerName
#define TEXTURECUBE_ARRAY_ARGS(textureName, samplerName)        textureName, samplerName
#define TEXTURE3D_ARGS(textureName, samplerName)                textureName, samplerName

#define TEXTURE2D_SHADOW_ARGS(textureName, samplerName)         textureName, samplerName
#define TEXTURE2D_ARRAY_SHADOW_ARGS(textureName, samplerName)   textureName, samplerName
#define TEXTURECUBE_SHADOW_ARGS(textureName, samplerName)       textureName, samplerName
#define TEXTURECUBE_ARRAY_SHADOW_ARGS(textureName, samplerName) textureName, samplerName

#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2)                               textureName.Sample(samplerName, coord2)
#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod)                      textureName.SampleLevel(samplerName, coord2, lod)
#define SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)                    textureName.SampleBias(samplerName, coord2, bias)
#define SAMPLE_TEXTURE2D_GRAD(textureName, samplerName, coord2, dpdx, dpdy)              textureName.SampleGrad(samplerName, coord2, dpdx, dpdy)
#define SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)                  textureName.Sample(samplerName, float3(coord2, index))
#define SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, index, lod)         textureName.SampleLevel(samplerName, float3(coord2, index), lod)
#define SAMPLE_TEXTURE2D_ARRAY_BIAS(textureName, samplerName, coord2, index, bias)       textureName.SampleBias(samplerName, float3(coord2, index), bias)
#define SAMPLE_TEXTURE2D_ARRAY_GRAD(textureName, samplerName, coord2, index, dpdx, dpdy) textureName.SampleGrad(samplerName, float3(coord2, index), dpdx, dpdy)
#define SAMPLE_TEXTURECUBE(textureName, samplerName, coord3)                             textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURECUBE_LOD(textureName, samplerName, coord3, lod)                    textureName.SampleLevel(samplerName, coord3, lod)
#define SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, bias)                  textureName.SampleBias(samplerName, coord3, bias)
#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)                textureName.Sample(samplerName, float4(coord3, index))
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)       textureName.SampleLevel(samplerName, float4(coord3, index), lod)
#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)     textureName.SampleBias(samplerName, float4(coord3, index), bias)
#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3)                               textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURE3D_LOD(textureName, samplerName, coord3, lod)                      textureName.SampleLevel(samplerName, coord3, lod)

#define SAMPLE_TEXTURE2D_SHADOW(textureName, samplerName, coord3)                    textureName.SampleCmpLevelZero(samplerName, (coord3).xy, (coord3).z)
#define SAMPLE_TEXTURE2D_ARRAY_SHADOW(textureName, samplerName, coord3, index)       textureName.SampleCmpLevelZero(samplerName, float3((coord3).xy, index), (coord3).z)
#define SAMPLE_TEXTURECUBE_SHADOW(textureName, samplerName, coord4)                  textureName.SampleCmpLevelZero(samplerName, (coord4).xyz, (coord4).w)
#define SAMPLE_TEXTURECUBE_ARRAY_SHADOW(textureName, samplerName, coord4, index)     textureName.SampleCmpLevelZero(samplerName, float4((coord4).xyz, index), (coord4).w)

#define SAMPLE_DEPTH_TEXTURE(textureName, samplerName, coord2)          SAMPLE_TEXTURE2D(textureName, samplerName, coord2).r
#define SAMPLE_DEPTH_TEXTURE_LOD(textureName, samplerName, coord2, lod) SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod).r

#define LOAD_TEXTURE2D(textureName, unCoord2)                       textureName.Load(int3(unCoord2, 0))
#define LOAD_TEXTURE2D_LOD(textureName, unCoord2, lod)              textureName.Load(int3(unCoord2, lod))
#define LOAD_TEXTURE2D_MSAA(textureName, unCoord2, sampleIndex)     textureName.Load(unCoord2, sampleIndex)
#define LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, index)          textureName.Load(int4(unCoord2, index, 0))
#define LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, index, lod) textureName.Load(int4(unCoord2, index, lod))
#define LOAD_TEXTURE3D(textureName, unCoord3)                       textureName.Load(int4(unCoord3, 0))
#define LOAD_TEXTURE3D_LOD(textureName, unCoord3, lod)              textureName.Load(int4(unCoord3, lod))

#define PLATFORM_SUPPORT_GATHER
#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                textureName.Gather(samplerName, coord2)
#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)   textureName.Gather(samplerName, float3(coord2, index))
#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)              textureName.Gather(samplerName, coord3)
#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index) textureName.Gather(samplerName, float4(coord3, index))
#define GATHER_RED_TEXTURE2D(textureName, samplerName, coord2)            textureName.GatherRed(samplerName, coord2)
#define GATHER_GREEN_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherGreen(samplerName, coord2)
#define GATHER_BLUE_TEXTURE2D(textureName, samplerName, coord2)           textureName.GatherBlue(samplerName, coord2)
#define GATHER_ALPHA_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherAlpha(samplerName, coord2)

// File end: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/API/Switch.hlsl
//================================================================================================================================



#elif defined(SHADER_API_GLCORE)
//================================================================================================================================
// File start: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/API/GLCore.hlsl


#ifndef SHADER_API_GLCORE
#error GLES.hlsl should not be included if SHADER_API_GLCORE is not defined
#endif

#define UNITY_UV_STARTS_AT_TOP 0
#define UNITY_REVERSED_Z 0
#define UNITY_NEAR_CLIP_VALUE (-1.0)

// This value will not go through any matrix projection convertion
#define UNITY_RAW_FAR_CLIP_VALUE (1.0)
#define VERTEXID_SEMANTIC SV_VertexID
#define INSTANCEID_SEMANTIC SV_InstanceID
#define FRONT_FACE_SEMANTIC VFACE
#define FRONT_FACE_TYPE float
#define IS_FRONT_VFACE(VAL, FRONT, BACK) ((VAL > 0.0) ? (FRONT) : (BACK))

#define ERROR_ON_UNSUPPORTED_FUNCTION(funcName) #error #funcName is not supported on GLCORE

#define CBUFFER_START(name) cbuffer name {
#define CBUFFER_END };

#define PLATFORM_SUPPORTS_EXPLICIT_BINDING

// flow control attributes
#define UNITY_BRANCH        [branch]
#define UNITY_FLATTEN       [flatten]
#define UNITY_UNROLL        [unroll]
#define UNITY_UNROLLX(_x)   [unroll(_x)]
#define UNITY_LOOP          [loop]

// OpenGL 4.1 SM 5.0 https://docs.unity3d.com/Manual/SL-ShaderCompileTargets.html
#if (SHADER_TARGET >= 46)
#define OPENGL4_1_SM5 1
#else
#define OPENGL4_1_SM5 0
#endif

// Initialize arbitrary structure with zero values.
// Do not exist on some platform, in this case we need to have a standard name that call a function that will initialize all parameters to 0
#define ZERO_INITIALIZE(type, name) name = (type)0;
#define ZERO_INITIALIZE_ARRAY(type, name, arraySize) { for (int arrayIndex = 0; arrayIndex < arraySize; arrayIndex++) { name[arrayIndex] = (type)0; } }

// Texture util abstraction

#define CALCULATE_TEXTURE2D_LOD(textureName, samplerName, coord2) textureName.CalculateLevelOfDetail(samplerName, coord2)

// Texture abstraction

#define TEXTURE2D(textureName)                  Texture2D textureName
#define TEXTURE2D_ARRAY(textureName)            Texture2DArray textureName
#define TEXTURECUBE(textureName)                TextureCube textureName
#define TEXTURECUBE_ARRAY(textureName)          TextureCubeArray textureName
#define TEXTURE3D(textureName)                  Texture3D textureName

#define TEXTURE2D_FLOAT(textureName)            TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_FLOAT(textureName)      TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_FLOAT(textureName)          TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_FLOAT(textureName)    TEXTURECUBE_ARRAY(textureName)
#define TEXTURE3D_FLOAT(textureName)            TEXTURE3D(textureName)

#define TEXTURE2D_HALF(textureName)             TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_HALF(textureName)       TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_HALF(textureName)           TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_HALF(textureName)     TEXTURECUBE_ARRAY(textureName)
#define TEXTURE3D_HALF(textureName)             TEXTURE3D(textureName)

#define TEXTURE2D_SHADOW(textureName)           TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_SHADOW(textureName)     TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_SHADOW(textureName)         TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_SHADOW(textureName)   TEXTURECUBE_ARRAY(textureName)

#define RW_TEXTURE2D(type, textureName)         RWTexture2D<type> textureName
#define RW_TEXTURE2D_ARRAY(type, textureName)   RWTexture2DArray<type> textureName
#define RW_TEXTURE3D(type, textureName)         RWTexture3D<type> textureName

#define SAMPLER(samplerName)                    SamplerState samplerName
#define SAMPLER_CMP(samplerName)                SamplerComparisonState samplerName

#define TEXTURE2D_PARAM(textureName, samplerName)                 TEXTURE2D(textureName),         SAMPLER(samplerName)
#define TEXTURE2D_ARRAY_PARAM(textureName, samplerName)           TEXTURE2D_ARRAY(textureName),   SAMPLER(samplerName)
#define TEXTURECUBE_PARAM(textureName, samplerName)               TEXTURECUBE(textureName),       SAMPLER(samplerName)
#define TEXTURECUBE_ARRAY_PARAM(textureName, samplerName)         TEXTURECUBE_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURE3D_PARAM(textureName, samplerName)                 TEXTURE3D(textureName),         SAMPLER(samplerName)

#define TEXTURE2D_SHADOW_PARAM(textureName, samplerName)          TEXTURE2D(textureName),         SAMPLER_CMP(samplerName)
#define TEXTURE2D_ARRAY_SHADOW_PARAM(textureName, samplerName)    TEXTURE2D_ARRAY(textureName),   SAMPLER_CMP(samplerName)
#define TEXTURECUBE_SHADOW_PARAM(textureName, samplerName)        TEXTURECUBE(textureName),       SAMPLER_CMP(samplerName)
#define TEXTURECUBE_ARRAY_SHADOW_PARAM(textureName, samplerName)  TEXTURECUBE_ARRAY(textureName), SAMPLER_CMP(samplerName)

#define TEXTURE2D_ARGS(textureName, samplerName)                textureName, samplerName
#define TEXTURE2D_ARRAY_ARGS(textureName, samplerName)          textureName, samplerName
#define TEXTURECUBE_ARGS(textureName, samplerName)              textureName, samplerName
#define TEXTURECUBE_ARRAY_ARGS(textureName, samplerName)        textureName, samplerName
#define TEXTURE3D_ARGS(textureName, samplerName)                textureName, samplerName

#define TEXTURE2D_SHADOW_ARGS(textureName, samplerName)         textureName, samplerName
#define TEXTURE2D_ARRAY_SHADOW_ARGS(textureName, samplerName)   textureName, samplerName
#define TEXTURECUBE_SHADOW_ARGS(textureName, samplerName)       textureName, samplerName
#define TEXTURECUBE_ARRAY_SHADOW_ARGS(textureName, samplerName) textureName, samplerName

#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2)                               textureName.Sample(samplerName, coord2)
#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod)                      textureName.SampleLevel(samplerName, coord2, lod)
#define SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)                    textureName.SampleBias(samplerName, coord2, bias)
#define SAMPLE_TEXTURE2D_GRAD(textureName, samplerName, coord2, ddx, ddy)                textureName.SampleGrad(samplerName, coord2, ddx, ddy)
#define SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)                  textureName.Sample(samplerName, float3(coord2, index))
#define SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, index, lod)         textureName.SampleLevel(samplerName, float3(coord2, index), lod)
#define SAMPLE_TEXTURE2D_ARRAY_BIAS(textureName, samplerName, coord2, index, bias)       textureName.SampleBias(samplerName, float3(coord2, index), bias)
#define SAMPLE_TEXTURE2D_ARRAY_GRAD(textureName, samplerName, coord2, index, dpdx, dpdy) textureName.SampleGrad(samplerName, float3(coord2, index), dpdx, dpdy)
#define SAMPLE_TEXTURECUBE(textureName, samplerName, coord3)                             textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURECUBE_LOD(textureName, samplerName, coord3, lod)                    textureName.SampleLevel(samplerName, coord3, lod)
#define SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, bias)                  textureName.SampleBias(samplerName, coord3, bias)
#ifdef UNITY_NO_CUBEMAP_ARRAY
#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)           ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY)
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)  ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY_LOD)
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, bias) ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY_LOD)
#else
#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)           textureName.Sample(samplerName, float4(coord3, index))
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)  textureName.SampleLevel(samplerName, float4(coord3, index), lod)
#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)textureName.SampleBias(samplerName, float4(coord3, index), bias)
#endif
#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3)                          textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURE3D_LOD(textureName, samplerName, coord3, lod)                 textureName.SampleLevel(samplerName, coord3, lod)

#define SAMPLE_TEXTURE2D_SHADOW(textureName, samplerName, coord3)                   textureName.SampleCmpLevelZero(samplerName, (coord3).xy, (coord3).z)
#define SAMPLE_TEXTURE2D_ARRAY_SHADOW(textureName, samplerName, coord3, index)      textureName.SampleCmpLevelZero(samplerName, float3((coord3).xy, index), (coord3).z)
#define SAMPLE_TEXTURECUBE_SHADOW(textureName, samplerName, coord4)                 textureName.SampleCmpLevelZero(samplerName, (coord4).xyz, (coord4).w)
#define SAMPLE_TEXTURECUBE_ARRAY_SHADOW(textureName, samplerName, coord4, index)    textureName.SampleCmpLevelZero(samplerName, float4((coord4).xyz, index), (coord4).w)

#define SAMPLE_DEPTH_TEXTURE(textureName, samplerName, coord2)                      SAMPLE_TEXTURE2D(textureName, samplerName, coord2).r
#define SAMPLE_DEPTH_TEXTURE_LOD(textureName, samplerName, coord2, lod)             SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod).r

#define LOAD_TEXTURE2D(textureName, unCoord2)                                   textureName.Load(int3(unCoord2, 0))
#define LOAD_TEXTURE2D_LOD(textureName, unCoord2, lod)                          textureName.Load(int3(unCoord2, lod))
#define LOAD_TEXTURE2D_MSAA(textureName, unCoord2, sampleIndex)                 textureName.Load(unCoord2, sampleIndex)
#define LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, index)                      textureName.Load(int4(unCoord2, index, 0))
#define LOAD_TEXTURE2D_ARRAY_MSAA(textureName, unCoord2, index, sampleIndex)    textureName.Load(int3(unCoord2, index), sampleIndex)
#define LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, index, lod)             textureName.Load(int4(unCoord2, index, lod))

#if OPENGL4_1_SM5
#define PLATFORM_SUPPORT_GATHER
#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                  textureName.Gather(samplerName, coord2)
#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)     textureName.Gather(samplerName, float3(coord2, index))
#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)                textureName.Gather(samplerName, coord3)
#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)   textureName.Gather(samplerName, float4(coord3, index))
#else
#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                  ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURE2D)
#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)     ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURE2D_ARRAY)
#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)                ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURECUBE)
#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)   ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURECUBE_ARRAY)
#endif


// File end: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/API/GLCore.hlsl
//================================================================================================================================



#elif defined(SHADER_API_GLES3)
//================================================================================================================================
// File start: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/API/GLES3.hlsl


#ifndef SHADER_API_GLES3
#error GLES.hlsl should not be included if SHADER_API_GLES3 is not defined
#endif

#define UNITY_UV_STARTS_AT_TOP 0
#define UNITY_REVERSED_Z 0
#define UNITY_NEAR_CLIP_VALUE (-1.0)

// This value will not go through any matrix projection convertion
#define UNITY_RAW_FAR_CLIP_VALUE (1.0)
#define VERTEXID_SEMANTIC SV_VertexID
#define INSTANCEID_SEMANTIC SV_InstanceID
#define FRONT_FACE_SEMANTIC VFACE
#define FRONT_FACE_TYPE float
#define IS_FRONT_VFACE(VAL, FRONT, BACK) ((VAL > 0.0) ? (FRONT) : (BACK))

#define ERROR_ON_UNSUPPORTED_FUNCTION(funcName) #error #funcName is not supported on GLES 3.0

#define CBUFFER_START(name) cbuffer name {
#define CBUFFER_END };


// flow control attributes
#define UNITY_BRANCH        [branch]
#define UNITY_FLATTEN       [flatten]
#define UNITY_UNROLL        [unroll]
#define UNITY_UNROLLX(_x)   [unroll(_x)]
#define UNITY_LOOP          [loop]

// GLES 3.1 + AEP shader feature https://docs.unity3d.com/Manual/SL-ShaderCompileTargets.html
#if (SHADER_TARGET >= 40)
#define GLES3_1_AEP 1
#else
#define GLES3_1_AEP 0
#endif

// Initialize arbitrary structure with zero values.
// Do not exist on some platform, in this case we need to have a standard name that call a function that will initialize all parameters to 0
#define ZERO_INITIALIZE(type, name) name = (type)0;
#define ZERO_INITIALIZE_ARRAY(type, name, arraySize) { for (int arrayIndex = 0; arrayIndex < arraySize; arrayIndex++) { name[arrayIndex] = (type)0; } }

// Texture util abstraction

#define CALCULATE_TEXTURE2D_LOD(textureName, samplerName, coord2) textureName.CalculateLevelOfDetail(samplerName, coord2)

// Texture abstraction

#define TEXTURE2D(textureName)                  Texture2D textureName
#define TEXTURE2D_ARRAY(textureName)            Texture2DArray textureName
#define TEXTURECUBE(textureName)                TextureCube textureName
#define TEXTURECUBE_ARRAY(textureName)          TextureCubeArray textureName
#define TEXTURE3D(textureName)                  Texture3D textureName

#define TEXTURE2D_FLOAT(textureName)            Texture2D_float textureName
#define TEXTURE2D_ARRAY_FLOAT(textureName)      Texture2DArray textureName    // no support to _float on Array, it's being added
#define TEXTURECUBE_FLOAT(textureName)          TextureCube_float textureName
#define TEXTURECUBE_ARRAY_FLOAT(textureName)    TextureCubeArray textureName  // no support to _float on Array, it's being added
#define TEXTURE3D_FLOAT(textureName)            Texture3D_float textureName

#define TEXTURE2D_HALF(textureName)             Texture2D_half textureName
#define TEXTURE2D_ARRAY_HALF(textureName)       Texture2DArray textureName    // no support to _float on Array, it's being added
#define TEXTURECUBE_HALF(textureName)           TextureCube_half textureName
#define TEXTURECUBE_ARRAY_HALF(textureName)     TextureCubeArray textureName  // no support to _float on Array, it's being added
#define TEXTURE3D_HALF(textureName)             Texture3D_half textureName

#define TEXTURE2D_SHADOW(textureName)           TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_SHADOW(textureName)     TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_SHADOW(textureName)         TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_SHADOW(textureName)   TEXTURECUBE_ARRAY(textureName)

#if GLES3_1_AEP
#define RW_TEXTURE2D(type, textureName)         RWTexture2D<type> textureName
#define RW_TEXTURE2D_ARRAY(type, textureName)   RWTexture2DArray<type> textureName
#define RW_TEXTURE3D(type, textureName)         RWTexture3D<type> textureName
#else
#define RW_TEXTURE2D(type, textureName)         ERROR_ON_UNSUPPORTED_FUNCTION(RWTexture2D)
#define RW_TEXTURE2D_ARRAY(type, textureName)   ERROR_ON_UNSUPPORTED_FUNCTION(RWTexture2DArray)
#define RW_TEXTURE3D(type, textureName)         ERROR_ON_UNSUPPORTED_FUNCTION(RWTexture3D)
#endif

#define SAMPLER(samplerName)                    SamplerState samplerName
#define SAMPLER_CMP(samplerName)                SamplerComparisonState samplerName

#define TEXTURE2D_PARAM(textureName, samplerName)                 TEXTURE2D(textureName),         SAMPLER(samplerName)
#define TEXTURE2D_ARRAY_PARAM(textureName, samplerName)           TEXTURE2D_ARRAY(textureName),   SAMPLER(samplerName)
#define TEXTURECUBE_PARAM(textureName, samplerName)               TEXTURECUBE(textureName),       SAMPLER(samplerName)
#define TEXTURECUBE_ARRAY_PARAM(textureName, samplerName)         TEXTURECUBE_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURE3D_PARAM(textureName, samplerName)                 TEXTURE3D(textureName),         SAMPLER(samplerName)

#define TEXTURE2D_SHADOW_PARAM(textureName, samplerName)          TEXTURE2D(textureName),         SAMPLER_CMP(samplerName)
#define TEXTURE2D_ARRAY_SHADOW_PARAM(textureName, samplerName)    TEXTURE2D_ARRAY(textureName),   SAMPLER_CMP(samplerName)
#define TEXTURECUBE_SHADOW_PARAM(textureName, samplerName)        TEXTURECUBE(textureName),       SAMPLER_CMP(samplerName)
#define TEXTURECUBE_ARRAY_SHADOW_PARAM(textureName, samplerName)  TEXTURECUBE_ARRAY(textureName), SAMPLER_CMP(samplerName)

#define TEXTURE2D_ARGS(textureName, samplerName)                textureName, samplerName
#define TEXTURE2D_ARRAY_ARGS(textureName, samplerName)          textureName, samplerName
#define TEXTURECUBE_ARGS(textureName, samplerName)              textureName, samplerName
#define TEXTURECUBE_ARRAY_ARGS(textureName, samplerName)        textureName, samplerName
#define TEXTURE3D_ARGS(textureName, samplerName)                textureName, samplerName

#define TEXTURE2D_SHADOW_ARGS(textureName, samplerName)         textureName, samplerName
#define TEXTURE2D_ARRAY_SHADOW_ARGS(textureName, samplerName)   textureName, samplerName
#define TEXTURECUBE_SHADOW_ARGS(textureName, samplerName)       textureName, samplerName
#define TEXTURECUBE_ARRAY_SHADOW_ARGS(textureName, samplerName) textureName, samplerName

#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2)                               textureName.Sample(samplerName, coord2)
#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod)                      textureName.SampleLevel(samplerName, coord2, lod)
#define SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)                    textureName.SampleBias(samplerName, coord2, bias)
#define SAMPLE_TEXTURE2D_GRAD(textureName, samplerName, coord2, ddx, ddy)                textureName.SampleGrad(samplerName, coord2, ddx, ddy)
#define SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)                  textureName.Sample(samplerName, float3(coord2, index))
#define SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, index, lod)         textureName.SampleLevel(samplerName, float3(coord2, index), lod)
#define SAMPLE_TEXTURE2D_ARRAY_BIAS(textureName, samplerName, coord2, index, bias)       textureName.SampleBias(samplerName, float3(coord2, index), bias)
#define SAMPLE_TEXTURE2D_ARRAY_GRAD(textureName, samplerName, coord2, index, dpdx, dpdy) textureName.SampleGrad(samplerName, float3(coord2, index), dpdx, dpdy)
#define SAMPLE_TEXTURECUBE(textureName, samplerName, coord3)                             textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURECUBE_LOD(textureName, samplerName, coord3, lod)                    textureName.SampleLevel(samplerName, coord3, lod)
#define SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, bias)                  textureName.SampleBias(samplerName, coord3, bias)

#ifdef UNITY_NO_CUBEMAP_ARRAY
#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)           ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY)
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)  ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY_LOD)
#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY_BIAS)
#else
#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)           textureName.Sample(samplerName, float4(coord3, index))
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)  textureName.SampleLevel(samplerName, float4(coord3, index), lod)
#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)textureName.SampleBias(samplerName, float4(coord3, index), bias)
#endif

#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3)                          textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURE3D_LOD(textureName, samplerName, coord3, lod)                 textureName.SampleLevel(samplerName, coord3, lod)

#define SAMPLE_TEXTURE2D_SHADOW(textureName, samplerName, coord3)                   textureName.SampleCmpLevelZero(samplerName, (coord3).xy, (coord3).z)
#define SAMPLE_TEXTURE2D_ARRAY_SHADOW(textureName, samplerName, coord3, index)      textureName.SampleCmpLevelZero(samplerName, float3((coord3).xy, index), (coord3).z)
#define SAMPLE_TEXTURECUBE_SHADOW(textureName, samplerName, coord4)                 textureName.SampleCmpLevelZero(samplerName, (coord4).xyz, (coord4).w)
#define SAMPLE_TEXTURECUBE_ARRAY_SHADOW(textureName, samplerName, coord4, index)    textureName.SampleCmpLevelZero(samplerName, float4((coord4).xyz, index), (coord4).w)

#define SAMPLE_DEPTH_TEXTURE(textureName, samplerName, coord2)                      SAMPLE_TEXTURE2D(textureName, samplerName, coord2).r
#define SAMPLE_DEPTH_TEXTURE_LOD(textureName, samplerName, coord2, lod)             SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod).r

#define LOAD_TEXTURE2D(textureName, unCoord2)                                       textureName.Load(int3(unCoord2, 0))
#define LOAD_TEXTURE2D_LOD(textureName, unCoord2, lod)                              textureName.Load(int3(unCoord2, lod))
#define LOAD_TEXTURE2D_MSAA(textureName, unCoord2, sampleIndex)                     textureName.Load(unCoord2, sampleIndex)
#define LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, index)                          textureName.Load(int4(unCoord2, index, 0))
#define LOAD_TEXTURE2D_ARRAY_MSAA(textureName, unCoord2, index, sampleIndex)        textureName.Load(int3(unCoord2, index), sampleIndex)
#define LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, index, lod)                 textureName.Load(int4(unCoord2, index, lod))
#define LOAD_TEXTURE3D(textureName, unCoord3)                                       textureName.Load(int4(unCoord3, 0))
#define LOAD_TEXTURE3D_LOD(textureName, unCoord3, lod)                              textureName.Load(int4(unCoord3, lod))

#if GLES3_1_AEP
#define PLATFORM_SUPPORT_GATHER
#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                  textureName.Gather(samplerName, coord2)
#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)     textureName.Gather(samplerName, float3(coord2, index))
#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)                textureName.Gather(samplerName, coord3)
#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)   textureName.Gather(samplerName, float4(coord3, index))
#define GATHER_RED_TEXTURE2D(textureName, samplerName, coord2)              textureName.GatherRed(samplerName, coord2)
#define GATHER_GREEN_TEXTURE2D(textureName, samplerName, coord2)            textureName.GatherGreen(samplerName, coord2)
#define GATHER_BLUE_TEXTURE2D(textureName, samplerName, coord2)             textureName.GatherBlue(samplerName, coord2)
#define GATHER_ALPHA_TEXTURE2D(textureName, samplerName, coord2)            textureName.GatherAlpha(samplerName, coord2)
#else
#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                  ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURE2D)
#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)     ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURE2D_ARRAY)
#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)                ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURECUBE)
#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)   ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURECUBE_ARRAY)
#define GATHER_RED_TEXTURE2D(textureName, samplerName, coord2)              ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_RED_TEXTURE2D)
#define GATHER_GREEN_TEXTURE2D(textureName, samplerName, coord2)            ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_GREEN_TEXTURE2D)
#define GATHER_BLUE_TEXTURE2D(textureName, samplerName, coord2)             ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_BLUE_TEXTURE2D)
#define GATHER_ALPHA_TEXTURE2D(textureName, samplerName, coord2)            ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_ALPHA_TEXTURE2D)
#endif


// File end: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/API/GLES3.hlsl
//================================================================================================================================



#elif defined(SHADER_API_GLES)
//================================================================================================================================
// File start: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/API/GLES2.hlsl


#ifndef SHADER_API_GLES
#error GLES.hlsl should not be included if SHADER_API_GLES is not defined
#endif

#define UNITY_UV_STARTS_AT_TOP 0
#define UNITY_REVERSED_Z 0
#define UNITY_NEAR_CLIP_VALUE (-1.0)

// This value will not go through any matrix projection convertion
#define UNITY_RAW_FAR_CLIP_VALUE (1.0)
#define VERTEXID_SEMANTIC gl_VertexID
#define INSTANCEID_SEMANTIC gl_InstanceID
#define FRONT_FACE_SEMANTIC VFACE
#define FRONT_FACE_TYPE float
#define IS_FRONT_VFACE(VAL, FRONT, BACK) ((VAL > 0.0) ? (FRONT) : (BACK))

#define CBUFFER_START(name)
#define CBUFFER_END

// flow control attributes
#define UNITY_BRANCH        [branch]
#define UNITY_FLATTEN       [flatten]
#define UNITY_UNROLL        [unroll]
#define UNITY_UNROLLX(_x)   [unroll(_x)]
#define UNITY_LOOP          [loop]

#define uint int

#define rcp(x) 1.0 / (x)
#define ddx_fine ddx
#define ddy_fine ddy
#define asfloat
#define asuint(x) asint(x)
#define f32tof16
#define f16tof32

#define ERROR_ON_UNSUPPORTED_FUNCTION(funcName) #error #funcName is not supported on GLES 2.0

// Initialize arbitrary structure with zero values.
// Do not exist on some platform, in this case we need to have a standard name that call a function that will initialize all parameters to 0
#define ZERO_INITIALIZE(type, name) name = (type)0;
#define ZERO_INITIALIZE_ARRAY(type, name, arraySize) { for (int arrayIndex = 0; arrayIndex < arraySize; arrayIndex++) { name[arrayIndex] = (type)0; } }

// GLES2 might not have shadow hardware comparison support
#if defined(UNITY_ENABLE_NATIVE_SHADOWS_LOOKUPS)
#define SHADOW2D_TEXTURE_AND_SAMPLER sampler2DShadow
#define SHADOWCUBE_TEXTURE_AND_SAMPLER samplerCUBEShadow
#define SHADOW2D_SAMPLE(textureName, samplerName, coord3) shadow2D(textureName, coord3)
#define SHADOWCUBE_SAMPLE(textureName, samplerName, coord4) ((texCUBE(textureName,(coord4).xyz) < (coord4).w) ? 0.0 : 1.0)
#else
// emulate hardware comparison
#define SHADOW2D_TEXTURE_AND_SAMPLER sampler2D_float
#define SHADOWCUBE_TEXTURE_AND_SAMPLER samplerCUBE_float
#define SHADOW2D_SAMPLE(textureName, samplerName, coord3) ((SAMPLE_DEPTH_TEXTURE(textureName, samplerName, (coord3).xy) < (coord3).z) ? 0.0 : 1.0)
#define SHADOWCUBE_SAMPLE(textureName, samplerName, coord4) ((texCUBE(textureName,(coord4).xyz).r < (coord4).w) ? 0.0 : 1.0)
#endif

// Texture util abstraction

#define CALCULATE_TEXTURE2D_LOD(textureName, samplerName, coord2) #error calculate Level of Detail not supported in GLES2

// Texture abstraction

#define TEXTURE2D(textureName)                          sampler2D textureName
#define TEXTURE2D_ARRAY(textureName)                    samplerCUBE textureName // No support to texture2DArray
#define TEXTURECUBE(textureName)                        samplerCUBE textureName
#define TEXTURECUBE_ARRAY(textureName)                  samplerCUBE textureName // No supoport to textureCubeArray and can't emulate with texture2DArray
#define TEXTURE3D(textureName)                          sampler3D textureName

#define TEXTURE2D_FLOAT(textureName)                    sampler2D_float textureName
#define TEXTURE2D_ARRAY_FLOAT(textureName)              TEXTURECUBE_FLOAT(textureName) // No support to texture2DArray
#define TEXTURECUBE_FLOAT(textureName)                  samplerCUBE_float textureName
#define TEXTURECUBE_ARRAY_FLOAT(textureName)            TEXTURECUBE_FLOAT(textureName) // No support to textureCubeArray
#define TEXTURE3D_FLOAT(textureName)                    sampler3D_float textureName

#define TEXTURE2D_HALF(textureName)                     sampler2D_half textureName
#define TEXTURE2D_ARRAY_HALF(textureName)               TEXTURECUBE_HALF(textureName) // No support to texture2DArray
#define TEXTURECUBE_HALF(textureName)                   samplerCUBE_half textureName
#define TEXTURECUBE_ARRAY_HALF(textureName)             TEXTURECUBE_HALF(textureName) // No support to textureCubeArray
#define TEXTURE3D_HALF(textureName)                     sampler3D_half textureName

#define TEXTURE2D_SHADOW(textureName)                   SHADOW2D_TEXTURE_AND_SAMPLER textureName
#define TEXTURE2D_ARRAY_SHADOW(textureName)             TEXTURECUBE_SHADOW(textureName) // No support to texture array
#define TEXTURECUBE_SHADOW(textureName)                 SHADOWCUBE_TEXTURE_AND_SAMPLER textureName
#define TEXTURECUBE_ARRAY_SHADOW(textureName)           TEXTURECUBE_SHADOW(textureName) // No support to texture array

#define RW_TEXTURE2D(type, textureNam)                  ERROR_ON_UNSUPPORTED_FUNCTION(RWTexture2D)
#define RW_TEXTURE2D_ARRAY(type, textureName)           ERROR_ON_UNSUPPORTED_FUNCTION(RWTexture2DArray)
#define RW_TEXTURE3D(type, textureNam)                  ERROR_ON_UNSUPPORTED_FUNCTION(RWTexture3D)

#define SAMPLER(samplerName)
#define SAMPLER_CMP(samplerName)

#define TEXTURE2D_PARAM(textureName, samplerName)                sampler2D textureName
#define TEXTURE2D_ARRAY_PARAM(textureName, samplerName)          samplerCUBE textureName
#define TEXTURECUBE_PARAM(textureName, samplerName)              samplerCUBE textureName
#define TEXTURECUBE_ARRAY_PARAM(textureName, samplerName)        samplerCUBE textureName
#define TEXTURE3D_PARAM(textureName, samplerName)                sampler3D textureName
#define TEXTURE2D_SHADOW_PARAM(textureName, samplerName)         SHADOW2D_TEXTURE_AND_SAMPLER textureName
#define TEXTURE2D_ARRAY_SHADOW_PARAM(textureName, samplerName)   SHADOWCUBE_TEXTURE_AND_SAMPLER textureName
#define TEXTURECUBE_SHADOW_PARAM(textureName, samplerName)       SHADOWCUBE_TEXTURE_AND_SAMPLER textureName

#define TEXTURE2D_ARGS(textureName, samplerName)               textureName
#define TEXTURE2D_ARRAY_ARGS(textureName, samplerName)         textureName
#define TEXTURECUBE_ARGS(textureName, samplerName)             textureName
#define TEXTURECUBE_ARRAY_ARGS(textureName, samplerName)       textureName
#define TEXTURE3D_ARGS(textureName, samplerName)               textureName
#define TEXTURE2D_SHADOW_ARGS(textureName, samplerName)        textureName
#define TEXTURE2D_ARRAY_SHADOW_ARGS(textureName, samplerName)  textureName
#define TEXTURECUBE_SHADOW_ARGS(textureName, samplerName)      textureName

#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2) tex2D(textureName, coord2)

#if (SHADER_TARGET >= 30)
    #define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod) tex2Dlod(textureName, float4(coord2, 0, lod))
#else
    // No lod support. Very poor approximation with bias.
    #define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod) SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, lod)
#endif

#define SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)                       tex2Dbias(textureName, float4(coord2, 0, bias))
#define SAMPLE_TEXTURE2D_GRAD(textureName, samplerName, coord2, ddx, ddy)                   SAMPLE_TEXTURE2D(textureName, samplerName, coord2)
#define SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)                     ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURE2D_ARRAY)
#define SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, index, lod)            ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURE2D_ARRAY_LOD)
#define SAMPLE_TEXTURE2D_ARRAY_BIAS(textureName, samplerName, coord2, index, bias)          ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURE2D_ARRAY_BIAS)
#define SAMPLE_TEXTURE2D_ARRAY_GRAD(textureName, samplerName, coord2, index, dpdx, dpdy)    ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURE2D_ARRAY_GRAD)
#define SAMPLE_TEXTURECUBE(textureName, samplerName, coord3)                                texCUBE(textureName, coord3)
// No lod support. Very poor approximation with bias.
#define SAMPLE_TEXTURECUBE_LOD(textureName, samplerName, coord3, lod)                       SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, lod)
#define SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, bias)                     texCUBEbias(textureName, float4(coord3, bias))
#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)                   ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY)
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)          ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY_LOD)
#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)        ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY_BIAS)
#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3)                                  tex3D(textureName, coord3)
#define SAMPLE_TEXTURE3D_LOD(textureName, samplerName, coord3, lod)                         ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURE3D_LOD)

#define SAMPLE_TEXTURE2D_SHADOW(textureName, samplerName, coord3)                           SHADOW2D_SAMPLE(textureName, samplerName, coord3)
#define SAMPLE_TEXTURE2D_ARRAY_SHADOW(textureName, samplerName, coord3, index)              ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURE2D_ARRAY_SHADOW)
#define SAMPLE_TEXTURECUBE_SHADOW(textureName, samplerName, coord4)                         SHADOWCUBE_SAMPLE(textureName, samplerName, coord4)
#define SAMPLE_TEXTURECUBE_ARRAY_SHADOW(textureName, samplerName, coord4, index)            ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY_SHADOW)

#define SAMPLE_DEPTH_TEXTURE(textureName, samplerName, coord2)                              SAMPLE_TEXTURE2D(textureName, samplerName, coord2).r
#define SAMPLE_DEPTH_TEXTURE_LOD(textureName, samplerName, coord2, lod)                     SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod).r

// Not supported. Can't define as error because shader library is calling these functions.
#define LOAD_TEXTURE2D(textureName, unCoord2)                                               half4(0, 0, 0, 0)
#define LOAD_TEXTURE2D_LOD(textureName, unCoord2, lod)                                      half4(0, 0, 0, 0)
#define LOAD_TEXTURE2D_MSAA(textureName, unCoord2, sampleIndex)                             half4(0, 0, 0, 0)
#define LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, index)                                  half4(0, 0, 0, 0)
#define LOAD_TEXTURE2D_ARRAY_MSAA(textureName, unCoord2, index, sampleIndex)                half4(0, 0, 0, 0)
#define LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, index, lod)                         half4(0, 0, 0, 0)
#define LOAD_TEXTURE3D(textureName, unCoord3)                                               ERROR_ON_UNSUPPORTED_FUNCTION(LOAD_TEXTURE3D)
#define LOAD_TEXTURE3D_LOD(textureName, unCoord3, lod)                                      ERROR_ON_UNSUPPORTED_FUNCTION(LOAD_TEXTURE3D_LOD)

// Gather not supported. Fallback to regular texture sampling.
#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                  ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURE2D)
#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)     ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURE2D_ARRAY)
#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)                ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURECUBE)
#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)   ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURECUBE_ARRAY)
#define GATHER_RED_TEXTURE2D(textureName, samplerName, coord2)              ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_RED_TEXTURE2D)
#define GATHER_GREEN_TEXTURE2D(textureName, samplerName, coord2)            ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_GREEN_TEXTURE2D)
#define GATHER_BLUE_TEXTURE2D(textureName, samplerName, coord2)             ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_BLUE_TEXTURE2D)
#define GATHER_ALPHA_TEXTURE2D(textureName, samplerName, coord2)            ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_ALPHA_TEXTURE2D)

// File end: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/API/GLES2.hlsl
//================================================================================================================================



#else
#error unsupported shader api
#endif
//================================================================================================================================
// File start: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/API/Validate.hlsl


// Wait for a fix from Trunk #error not supported yet
/*
#define REQUIRE_DEFINED(X_) \
    #ifndef X_  \
        #error X_ must be defined (in) the platform include \
    #endif X_  \

REQUIRE_DEFINED(UNITY_UV_STARTS_AT_TOP)
REQUIRE_DEFINED(UNITY_REVERSED_Z)
REQUIRE_DEFINED(UNITY_NEAR_CLIP_VALUE)
REQUIRE_DEFINED(FACE)

REQUIRE_DEFINED(CBUFFER_START)
REQUIRE_DEFINED(CBUFFER_END)

REQUIRE_DEFINED(INITIALIZE_OUTPUT)

*/


// Default values for things that have not been defined in the platform headers

// default flow control attributes
#ifndef UNITY_BRANCH
#   define UNITY_BRANCH
#endif
#ifndef UNITY_FLATTEN
#   define UNITY_FLATTEN
#endif
#ifndef UNITY_UNROLL
#   define UNITY_UNROLL
#endif
#ifndef UNITY_UNROLLX
#   define UNITY_UNROLLX(_x)
#endif
#ifndef UNITY_LOOP
#   define UNITY_LOOP
#endif

// File end: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/API/Validate.hlsl
//================================================================================================================================




//================================================================================================================================
// File start: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/Macros.hlsl


#ifndef UNITY_MACROS_INCLUDED
#define UNITY_MACROS_INCLUDED

// Some shader compiler don't support to do multiple ## for concatenation inside the same macro, it require an indirection.
// This is the purpose of this macro
#define MERGE_NAME(X, Y) X##Y
#define CALL_MERGE_NAME(X, Y) MERGE_NAME(X, Y)

// These define are use to abstract the way we sample into a cubemap array.
// Some platform don't support cubemap array so we fallback on 2D latlong
#ifdef  UNITY_NO_CUBEMAP_ARRAY
#define TEXTURECUBE_ARRAY_ABSTRACT TEXTURE2D_ARRAY
#define TEXTURECUBE_ARRAY_PARAM_ABSTRACT TEXTURE2D_ARRAY_PARAM
#define TEXTURECUBE_ARRAY_ARGS_ABSTRACT TEXTURE2D_ARRAY_ARGS
#define SAMPLE_TEXTURECUBE_ARRAY_LOD_ABSTRACT(textureName, samplerName, coord3, index, lod) SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, DirectionToLatLongCoordinate(coord3), index, lod)
#else
#define TEXTURECUBE_ARRAY_ABSTRACT TEXTURECUBE_ARRAY
#define TEXTURECUBE_ARRAY_PARAM_ABSTRACT TEXTURECUBE_ARRAY_PARAM
#define TEXTURECUBE_ARRAY_ARGS_ABSTRACT TEXTURECUBE_ARRAY_ARGS
#define SAMPLE_TEXTURECUBE_ARRAY_LOD_ABSTRACT(textureName, samplerName, coord3, index, lod) SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)
#endif

#define PI          3.14159265358979323846
#define TWO_PI      6.28318530717958647693
#define FOUR_PI     12.5663706143591729538
#define INV_PI      0.31830988618379067154
#define INV_TWO_PI  0.15915494309189533577
#define INV_FOUR_PI 0.07957747154594766788
#define HALF_PI     1.57079632679489661923
#define INV_HALF_PI 0.63661977236758134308
#define LOG2_E      1.44269504088896340736

#define MILLIMETERS_PER_METER 1000
#define METERS_PER_MILLIMETER rcp(MILLIMETERS_PER_METER)
#define CENTIMETERS_PER_METER 100
#define METERS_PER_CENTIMETER rcp(CENTIMETERS_PER_METER)

#define FLT_INF  asfloat(0x7F800000)
#define FLT_EPS  5.960464478e-8  // 2^-24, machine epsilon: 1 + EPS = 1 (half of the ULP for 1.0f)
#define FLT_MIN  1.175494351e-38 // Minimum normalized positive floating-point number
#define FLT_MAX  3.402823466e+38 // Maximum representable floating-point number
#define HALF_EPS 4.8828125e-4    // 2^-11, machine epsilon: 1 + EPS = 1 (half of the ULP for 1.0f)
#define HALF_MIN 6.103515625e-5  // 2^-14, the same value for 10, 11 and 16-bit: https://www.khronos.org/opengl/wiki/Small_Float_Formats
#define HALF_MAX 65504.0
#define UINT_MAX 0xFFFFFFFFu


#ifdef SHADER_API_GLES

#define GENERATE_INT_FLOAT_1_ARG(FunctionName, Parameter1, FunctionBody) \
    float  FunctionName(float  Parameter1) { FunctionBody; } \
    int    FunctionName(int  Parameter1) { FunctionBody; } 
#else

#define GENERATE_INT_FLOAT_1_ARG(FunctionName, Parameter1, FunctionBody) \
    float  FunctionName(float  Parameter1) { FunctionBody; } \
    uint   FunctionName(uint  Parameter1) { FunctionBody; } \
    int    FunctionName(int  Parameter1) { FunctionBody; } 

#endif

#define TEMPLATE_1_FLT(FunctionName, Parameter1, FunctionBody) \
    float  FunctionName(float  Parameter1) { FunctionBody; } \
    float2 FunctionName(float2 Parameter1) { FunctionBody; } \
    float3 FunctionName(float3 Parameter1) { FunctionBody; } \
    float4 FunctionName(float4 Parameter1) { FunctionBody; }

#define TEMPLATE_1_HALF(FunctionName, Parameter1, FunctionBody) \
    half  FunctionName(half  Parameter1) { FunctionBody; } \
    half2 FunctionName(half2 Parameter1) { FunctionBody; } \
    half3 FunctionName(half3 Parameter1) { FunctionBody; } \
    half4 FunctionName(half4 Parameter1) { FunctionBody; } \
    float  FunctionName(float  Parameter1) { FunctionBody; } \
    float2 FunctionName(float2 Parameter1) { FunctionBody; } \
    float3 FunctionName(float3 Parameter1) { FunctionBody; } \
    float4 FunctionName(float4 Parameter1) { FunctionBody; }

#ifdef SHADER_API_GLES
    #define TEMPLATE_1_INT(FunctionName, Parameter1, FunctionBody) \
    int    FunctionName(int    Parameter1) { FunctionBody; } \
    int2   FunctionName(int2   Parameter1) { FunctionBody; } \
    int3   FunctionName(int3   Parameter1) { FunctionBody; } \
    int4   FunctionName(int4   Parameter1) { FunctionBody; }
#else
    #define TEMPLATE_1_INT(FunctionName, Parameter1, FunctionBody) \
    int    FunctionName(int    Parameter1) { FunctionBody; } \
    int2   FunctionName(int2   Parameter1) { FunctionBody; } \
    int3   FunctionName(int3   Parameter1) { FunctionBody; } \
    int4   FunctionName(int4   Parameter1) { FunctionBody; } \
    uint   FunctionName(uint   Parameter1) { FunctionBody; } \
    uint2  FunctionName(uint2  Parameter1) { FunctionBody; } \
    uint3  FunctionName(uint3  Parameter1) { FunctionBody; } \
    uint4  FunctionName(uint4  Parameter1) { FunctionBody; }
#endif

#define TEMPLATE_2_FLT(FunctionName, Parameter1, Parameter2, FunctionBody) \
    float  FunctionName(float  Parameter1, float  Parameter2) { FunctionBody; } \
    float2 FunctionName(float2 Parameter1, float2 Parameter2) { FunctionBody; } \
    float3 FunctionName(float3 Parameter1, float3 Parameter2) { FunctionBody; } \
    float4 FunctionName(float4 Parameter1, float4 Parameter2) { FunctionBody; }

#define TEMPLATE_2_HALF(FunctionName, Parameter1, Parameter2, FunctionBody) \
    half  FunctionName(half  Parameter1, half  Parameter2) { FunctionBody; } \
    half2 FunctionName(half2 Parameter1, half2 Parameter2) { FunctionBody; } \
    half3 FunctionName(half3 Parameter1, half3 Parameter2) { FunctionBody; } \
    half4 FunctionName(half4 Parameter1, half4 Parameter2) { FunctionBody; } \
    float  FunctionName(float  Parameter1, float  Parameter2) { FunctionBody; } \
    float2 FunctionName(float2 Parameter1, float2 Parameter2) { FunctionBody; } \
    float3 FunctionName(float3 Parameter1, float3 Parameter2) { FunctionBody; } \
    float4 FunctionName(float4 Parameter1, float4 Parameter2) { FunctionBody; }


#ifdef SHADER_API_GLES
    #define TEMPLATE_2_INT(FunctionName, Parameter1, Parameter2, FunctionBody) \
    int    FunctionName(int    Parameter1, int    Parameter2) { FunctionBody; } \
    int2   FunctionName(int2   Parameter1, int2   Parameter2) { FunctionBody; } \
    int3   FunctionName(int3   Parameter1, int3   Parameter2) { FunctionBody; } \
    int4   FunctionName(int4   Parameter1, int4   Parameter2) { FunctionBody; }
#else
    #define TEMPLATE_2_INT(FunctionName, Parameter1, Parameter2, FunctionBody) \
    int    FunctionName(int    Parameter1, int    Parameter2) { FunctionBody; } \
    int2   FunctionName(int2   Parameter1, int2   Parameter2) { FunctionBody; } \
    int3   FunctionName(int3   Parameter1, int3   Parameter2) { FunctionBody; } \
    int4   FunctionName(int4   Parameter1, int4   Parameter2) { FunctionBody; } \
    uint   FunctionName(uint   Parameter1, uint   Parameter2) { FunctionBody; } \
    uint2  FunctionName(uint2  Parameter1, uint2  Parameter2) { FunctionBody; } \
    uint3  FunctionName(uint3  Parameter1, uint3  Parameter2) { FunctionBody; } \
    uint4  FunctionName(uint4  Parameter1, uint4  Parameter2) { FunctionBody; }
#endif

#define TEMPLATE_3_FLT(FunctionName, Parameter1, Parameter2, Parameter3, FunctionBody) \
    float  FunctionName(float  Parameter1, float  Parameter2, float  Parameter3) { FunctionBody; } \
    float2 FunctionName(float2 Parameter1, float2 Parameter2, float2 Parameter3) { FunctionBody; } \
    float3 FunctionName(float3 Parameter1, float3 Parameter2, float3 Parameter3) { FunctionBody; } \
    float4 FunctionName(float4 Parameter1, float4 Parameter2, float4 Parameter3) { FunctionBody; }

#define TEMPLATE_3_HALF(FunctionName, Parameter1, Parameter2, Parameter3, FunctionBody) \
    half  FunctionName(half  Parameter1, half  Parameter2, half  Parameter3) { FunctionBody; } \
    half2 FunctionName(half2 Parameter1, half2 Parameter2, half2 Parameter3) { FunctionBody; } \
    half3 FunctionName(half3 Parameter1, half3 Parameter2, half3 Parameter3) { FunctionBody; } \
    half4 FunctionName(half4 Parameter1, half4 Parameter2, half4 Parameter3) { FunctionBody; } \
    float  FunctionName(float  Parameter1, float  Parameter2, float  Parameter3) { FunctionBody; } \
    float2 FunctionName(float2 Parameter1, float2 Parameter2, float2 Parameter3) { FunctionBody; } \
    float3 FunctionName(float3 Parameter1, float3 Parameter2, float3 Parameter3) { FunctionBody; } \
    float4 FunctionName(float4 Parameter1, float4 Parameter2, float4 Parameter3) { FunctionBody; }

#ifdef SHADER_API_GLES
    #define TEMPLATE_3_INT(FunctionName, Parameter1, Parameter2, Parameter3, FunctionBody) \
    int    FunctionName(int    Parameter1, int    Parameter2, int    Parameter3) { FunctionBody; } \
    int2   FunctionName(int2   Parameter1, int2   Parameter2, int2   Parameter3) { FunctionBody; } \
    int3   FunctionName(int3   Parameter1, int3   Parameter2, int3   Parameter3) { FunctionBody; } \
    int4   FunctionName(int4   Parameter1, int4   Parameter2, int4   Parameter3) { FunctionBody; }
#else
    #define TEMPLATE_3_INT(FunctionName, Parameter1, Parameter2, Parameter3, FunctionBody) \
    int    FunctionName(int    Parameter1, int    Parameter2, int    Parameter3) { FunctionBody; } \
    int2   FunctionName(int2   Parameter1, int2   Parameter2, int2   Parameter3) { FunctionBody; } \
    int3   FunctionName(int3   Parameter1, int3   Parameter2, int3   Parameter3) { FunctionBody; } \
    int4   FunctionName(int4   Parameter1, int4   Parameter2, int4   Parameter3) { FunctionBody; } \
    uint   FunctionName(uint   Parameter1, uint   Parameter2, uint   Parameter3) { FunctionBody; } \
    uint2  FunctionName(uint2  Parameter1, uint2  Parameter2, uint2  Parameter3) { FunctionBody; } \
    uint3  FunctionName(uint3  Parameter1, uint3  Parameter2, uint3  Parameter3) { FunctionBody; } \
    uint4  FunctionName(uint4  Parameter1, uint4  Parameter2, uint4  Parameter3) { FunctionBody; }
#endif

#ifdef SHADER_API_GLES
    #define TEMPLATE_SWAP(FunctionName) \
    void FunctionName(inout real  a, inout real  b) { real  t = a; a = b; b = t; } \
    void FunctionName(inout real2 a, inout real2 b) { real2 t = a; a = b; b = t; } \
    void FunctionName(inout real3 a, inout real3 b) { real3 t = a; a = b; b = t; } \
    void FunctionName(inout real4 a, inout real4 b) { real4 t = a; a = b; b = t; } \
    void FunctionName(inout int    a, inout int    b) { int    t = a; a = b; b = t; } \
    void FunctionName(inout int2   a, inout int2   b) { int2   t = a; a = b; b = t; } \
    void FunctionName(inout int3   a, inout int3   b) { int3   t = a; a = b; b = t; } \
    void FunctionName(inout int4   a, inout int4   b) { int4   t = a; a = b; b = t; } \
    void FunctionName(inout bool   a, inout bool   b) { bool   t = a; a = b; b = t; } \
    void FunctionName(inout bool2  a, inout bool2  b) { bool2  t = a; a = b; b = t; } \
    void FunctionName(inout bool3  a, inout bool3  b) { bool3  t = a; a = b; b = t; } \
    void FunctionName(inout bool4  a, inout bool4  b) { bool4  t = a; a = b; b = t; }
#else
    #if REAL_IS_HALF
        #define TEMPLATE_SWAP(FunctionName) \
        void FunctionName(inout real  a, inout real  b) { real  t = a; a = b; b = t; } \
        void FunctionName(inout real2 a, inout real2 b) { real2 t = a; a = b; b = t; } \
        void FunctionName(inout real3 a, inout real3 b) { real3 t = a; a = b; b = t; } \
        void FunctionName(inout real4 a, inout real4 b) { real4 t = a; a = b; b = t; } \
        void FunctionName(inout float  a, inout float  b) { float  t = a; a = b; b = t; } \
        void FunctionName(inout float2 a, inout float2 b) { float2 t = a; a = b; b = t; } \
        void FunctionName(inout float3 a, inout float3 b) { float3 t = a; a = b; b = t; } \
        void FunctionName(inout float4 a, inout float4 b) { float4 t = a; a = b; b = t; } \
        void FunctionName(inout int    a, inout int    b) { int    t = a; a = b; b = t; } \
        void FunctionName(inout int2   a, inout int2   b) { int2   t = a; a = b; b = t; } \
        void FunctionName(inout int3   a, inout int3   b) { int3   t = a; a = b; b = t; } \
        void FunctionName(inout int4   a, inout int4   b) { int4   t = a; a = b; b = t; } \
        void FunctionName(inout uint   a, inout uint   b) { uint   t = a; a = b; b = t; } \
        void FunctionName(inout uint2  a, inout uint2  b) { uint2  t = a; a = b; b = t; } \
        void FunctionName(inout uint3  a, inout uint3  b) { uint3  t = a; a = b; b = t; } \
        void FunctionName(inout uint4  a, inout uint4  b) { uint4  t = a; a = b; b = t; } \
        void FunctionName(inout bool   a, inout bool   b) { bool   t = a; a = b; b = t; } \
        void FunctionName(inout bool2  a, inout bool2  b) { bool2  t = a; a = b; b = t; } \
        void FunctionName(inout bool3  a, inout bool3  b) { bool3  t = a; a = b; b = t; } \
        void FunctionName(inout bool4  a, inout bool4  b) { bool4  t = a; a = b; b = t; }
    #else
        #define TEMPLATE_SWAP(FunctionName) \
        void FunctionName(inout real  a, inout real  b) { real  t = a; a = b; b = t; } \
        void FunctionName(inout real2 a, inout real2 b) { real2 t = a; a = b; b = t; } \
        void FunctionName(inout real3 a, inout real3 b) { real3 t = a; a = b; b = t; } \
        void FunctionName(inout real4 a, inout real4 b) { real4 t = a; a = b; b = t; } \
        void FunctionName(inout int    a, inout int    b) { int    t = a; a = b; b = t; } \
        void FunctionName(inout int2   a, inout int2   b) { int2   t = a; a = b; b = t; } \
        void FunctionName(inout int3   a, inout int3   b) { int3   t = a; a = b; b = t; } \
        void FunctionName(inout int4   a, inout int4   b) { int4   t = a; a = b; b = t; } \
        void FunctionName(inout uint   a, inout uint   b) { uint   t = a; a = b; b = t; } \
        void FunctionName(inout uint2  a, inout uint2  b) { uint2  t = a; a = b; b = t; } \
        void FunctionName(inout uint3  a, inout uint3  b) { uint3  t = a; a = b; b = t; } \
        void FunctionName(inout uint4  a, inout uint4  b) { uint4  t = a; a = b; b = t; } \
        void FunctionName(inout bool   a, inout bool   b) { bool   t = a; a = b; b = t; } \
        void FunctionName(inout bool2  a, inout bool2  b) { bool2  t = a; a = b; b = t; } \
        void FunctionName(inout bool3  a, inout bool3  b) { bool3  t = a; a = b; b = t; } \
        void FunctionName(inout bool4  a, inout bool4  b) { bool4  t = a; a = b; b = t; }
    #endif
#endif


// MACRO from Legacy Untiy
// Transforms 2D UV by scale/bias property
#define TRANSFORM_TEX(tex, name) ((tex.xy) * name##_ST.xy + name##_ST.zw)
#define GET_TEXELSIZE_NAME(name) (name##_TexelSize)

#if UNITY_REVERSED_Z
# define COMPARE_DEVICE_DEPTH_CLOSER(shadowMapDepth, zDevice)      (shadowMapDepth >  zDevice) 
# define COMPARE_DEVICE_DEPTH_CLOSEREQUAL(shadowMapDepth, zDevice) (shadowMapDepth >= zDevice) 
#else
# define COMPARE_DEVICE_DEPTH_CLOSER(shadowMapDepth, zDevice)      (shadowMapDepth <  zDevice) 
# define COMPARE_DEVICE_DEPTH_CLOSEREQUAL(shadowMapDepth, zDevice) (shadowMapDepth <= zDevice) 
#endif

#endif // UNITY_MACROS_INCLUDED

// File end: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/Macros.hlsl
//================================================================================================================================



//================================================================================================================================
// File start: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/Random.hlsl


#ifndef UNITY_RANDOM_INCLUDED
#define UNITY_RANDOM_INCLUDED

#if !defined(SHADER_API_GLES)

// A single iteration of Bob Jenkins' One-At-A-Time hashing algorithm.
uint JenkinsHash(uint x)
{
    x += (x << 10u);
    x ^= (x >>  6u);
    x += (x <<  3u);
    x ^= (x >> 11u);
    x += (x << 15u);
    return x;
}

// Compound versions of the hashing algorithm.
uint JenkinsHash(uint2 v)
{
    return JenkinsHash(v.x ^ JenkinsHash(v.y));
}

uint JenkinsHash(uint3 v)
{
    return JenkinsHash(v.x ^ JenkinsHash(v.yz));
}

uint JenkinsHash(uint4 v)
{
    return JenkinsHash(v.x ^ JenkinsHash(v.yzw));
}

// Construct a float with half-open range [0, 1) using low 23 bits.
// All zeros yields 0, all ones yields the next smallest representable value below 1.
float ConstructFloat(int m) {
    const int ieeeMantissa = 0x007FFFFF; // Binary FP32 mantissa bitmask
    const int ieeeOne      = 0x3F800000; // 1.0 in FP32 IEEE

    m &= ieeeMantissa;                   // Keep only mantissa bits (fractional part)
    m |= ieeeOne;                        // Add fractional part to 1.0

    float  f = asfloat(m);               // Range [1, 2)
    return f - 1;                        // Range [0, 1)
}

float ConstructFloat(uint m)
{
    return ConstructFloat(asint(m));
}

// Pseudo-random value in half-open range [0, 1). The distribution is reasonably uniform.
// Ref: https://stackoverflow.com/a/17479300
float GenerateHashedRandomFloat(uint x)
{
    return ConstructFloat(JenkinsHash(x));
}

float GenerateHashedRandomFloat(uint2 v)
{
    return ConstructFloat(JenkinsHash(v));
}

float GenerateHashedRandomFloat(uint3 v)
{
    return ConstructFloat(JenkinsHash(v));
}

float GenerateHashedRandomFloat(uint4 v)
{
    return ConstructFloat(JenkinsHash(v));
}

float Hash(uint s)
{
    s = s ^ 2747636419u;
    s = s * 2654435769u;
    s = s ^ (s >> 16);
    s = s * 2654435769u;
    s = s ^ (s >> 16);
    s = s * 2654435769u;
    return float(s) * rcp(4294967296.0); // 2^-32
}

float2 InitRandom(float2 input)
{
    float2 r;
    r.x = Hash(uint(input.x * UINT_MAX));
    r.y = Hash(uint(input.y * UINT_MAX));

    return r;
}
#endif // SHADER_API_GLES

//From  Next Generation Post Processing in Call of Duty: Advanced Warfare [Jimenez 2014]
// http://advances.realtimerendering.com/s2014/index.html
float InterleavedGradientNoise(float2 pixCoord, int frameCount)
{
    const float3 magic = float3(0.06711056f, 0.00583715f, 52.9829189f);
    float2 frameMagicScale = float2(2.083f, 4.867f);
    pixCoord += frameCount * frameMagicScale;
    return frac(magic.z * frac(dot(pixCoord, magic.xy)));
}

#endif // UNITY_RANDOM_INCLUDED

// File end: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/Random.hlsl
//================================================================================================================================




// ----------------------------------------------------------------------------
// Common intrinsic (general implementation of intrinsic available on some platform)
// ----------------------------------------------------------------------------

// Error on GLES2 undefined functions
#ifdef SHADER_API_GLES
#define BitFieldExtract ERROR_ON_UNSUPPORTED_FUNCTION(BitFieldExtract)
#define IsBitSet ERROR_ON_UNSUPPORTED_FUNCTION(IsBitSet)
#define SetBit ERROR_ON_UNSUPPORTED_FUNCTION(SetBit)
#define ClearBit ERROR_ON_UNSUPPORTED_FUNCTION(ClearBit)
#define ToggleBit ERROR_ON_UNSUPPORTED_FUNCTION(ToggleBit)
#define FastMulBySignOfNegZero ERROR_ON_UNSUPPORTED_FUNCTION(FastMulBySignOfNegZero)
#define LODDitheringTransition ERROR_ON_UNSUPPORTED_FUNCTION(LODDitheringTransition)
#endif

// On everything but GCN consoles we error on cross-lane operations
#ifndef PLATFORM_SUPPORTS_WAVE_INTRINSICS
#define WaveActiveAllTrue ERROR_ON_UNSUPPORTED_FUNCTION(WaveActiveAllTrue)
#define WaveActiveAnyTrue ERROR_ON_UNSUPPORTED_FUNCTION(WaveActiveAnyTrue)
#define WaveGetLaneIndex ERROR_ON_UNSUPPORTED_FUNCTION(WaveGetLaneIndex)
#define WaveIsFirstLane ERROR_ON_UNSUPPORTED_FUNCTION(WaveIsFirstLane)
#define GetWaveID ERROR_ON_UNSUPPORTED_FUNCTION(GetWaveID)
#define WaveActiveMin ERROR_ON_UNSUPPORTED_FUNCTION(WaveActiveMin)
#define WaveActiveMax ERROR_ON_UNSUPPORTED_FUNCTION(WaveActiveMax)
#define WaveActiveBallot ERROR_ON_UNSUPPORTED_FUNCTION(WaveActiveBallot)
#define WaveActiveSum ERROR_ON_UNSUPPORTED_FUNCTION(WaveActiveSum)
#define WaveActiveBitAnd ERROR_ON_UNSUPPORTED_FUNCTION(WaveActiveBitAnd)
#define WaveActiveBitOr ERROR_ON_UNSUPPORTED_FUNCTION(WaveActiveBitOr)
#define WaveGetLaneCount ERROR_ON_UNSUPPORTED_FUNCTION(WaveGetLaneCount)
#endif

//================================================================================================================================
// File start: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/CommonDeprecated.hlsl


#ifndef UNITY_COMMON_DEPRECATED_INCLUDED
#define UNITY_COMMON_DEPRECATED_INCLUDED

// Function that are in this file shouldn't be use. they are obsolete and could be removed in the future
// they are here to keep compatibility with previous version
#if !defined(SHADER_API_GLES)
// Please use void LODDitheringTransition(uint2 fadeMaskSeed, float ditherFactor)
void LODDitheringTransition(uint3 fadeMaskSeed, float ditherFactor)
{
    ditherFactor = ditherFactor < 0.0 ? 1 + ditherFactor : ditherFactor;

    float p = GenerateHashedRandomFloat(fadeMaskSeed);
    p = (ditherFactor >= 0.5) ? p : 1 - p;
    clip(ditherFactor - p);
}
#endif

#endif

// File end: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/CommonDeprecated.hlsl
//================================================================================================================================




#if !defined(SHADER_API_GLES)

#ifndef INTRINSIC_BITFIELD_EXTRACT
// Unsigned integer bit field extraction.
// Note that the intrinsic itself generates a vector instruction.
// Wrap this function with WaveReadLaneFirst() to get scalar output.
uint BitFieldExtract(uint data, uint offset, uint numBits)
{
    uint mask = (1u << numBits) - 1u;
    return (data >> offset) & mask;
}
#endif // INTRINSIC_BITFIELD_EXTRACT

#ifndef INTRINSIC_BITFIELD_EXTRACT_SIGN_EXTEND
// Integer bit field extraction with sign extension.
// Note that the intrinsic itself generates a vector instruction.
// Wrap this function with WaveReadLaneFirst() to get scalar output.
int BitFieldExtractSignExtend(int data, uint offset, uint numBits)
{
    int  shifted = data >> offset;      // Sign-extending (arithmetic) shift
    int  signBit = shifted & (1u << (numBits - 1u));
    uint mask    = (1u << numBits) - 1u;

    return -signBit | (shifted & mask); // Use 2-complement for negation to replicate the sign bit
}
#endif // INTRINSIC_BITFIELD_EXTRACT_SIGN_EXTEND

#ifndef INTRINSIC_BITFIELD_INSERT
// Inserts the bits indicated by 'mask' from 'src' into 'dst'.
uint BitFieldInsert(uint mask, uint src, uint dst)
{
    return (src & mask) | (dst & ~mask);
}
#endif // INTRINSIC_BITFIELD_INSERT

bool IsBitSet(uint data, uint offset)
{
    return BitFieldExtract(data, offset, 1u) != 0;
}

void SetBit(inout uint data, uint offset)
{
    data |= 1u << offset;
}

void ClearBit(inout uint data, uint offset)
{
    data &= ~(1u << offset);
}

void ToggleBit(inout uint data, uint offset)
{
    data ^= 1u << offset;
}
#endif

#ifndef INTRINSIC_WAVEREADFIRSTLANE
    // Warning: for correctness, the argument's value must be the same across all lanes of the wave.
    TEMPLATE_1_REAL(WaveReadLaneFirst, scalarValue, return scalarValue)
    TEMPLATE_1_INT(WaveReadLaneFirst, scalarValue, return scalarValue)
#endif

#ifndef INTRINSIC_MUL24
    TEMPLATE_2_INT(Mul24, a, b, return a * b)
#endif // INTRINSIC_MUL24

#ifndef INTRINSIC_MAD24
    TEMPLATE_3_INT(Mad24, a, b, c, return a * b + c)
#endif // INTRINSIC_MAD24

#ifndef INTRINSIC_MINMAX3
    TEMPLATE_3_REAL(Min3, a, b, c, return min(min(a, b), c))
    TEMPLATE_3_INT(Min3, a, b, c, return min(min(a, b), c))
    TEMPLATE_3_REAL(Max3, a, b, c, return max(max(a, b), c))
    TEMPLATE_3_INT(Max3, a, b, c, return max(max(a, b), c))
#endif // INTRINSIC_MINMAX3

TEMPLATE_3_REAL(Avg3, a, b, c, return (a + b + c) * 0.33333333)

#ifndef INTRINSIC_QUAD_SHUFFLE
    // Important! Only valid in pixel shaders!
    float QuadReadAcrossX(float value, int2 screenPos)
    {
        return value - (ddx_fine(value) * (float(screenPos.x & 1) * 2.0 - 1.0));
    }

    float QuadReadAcrossY(float value, int2 screenPos)
    {
        return value - (ddy_fine(value) * (float(screenPos.y & 1) * 2.0 - 1.0));
    }

    float QuadReadAcrossDiagonal(float value, int2 screenPos)
    {
        float dX = ddx_fine(value);
        float dY = ddy_fine(value);
        float2 quadDir = float2(float(screenPos.x & 1) * 2.0 - 1.0, float(screenPos.y & 1) * 2.0 - 1.0);
        float X = value - (dX * quadDir.x);
        return X - (ddy_fine(value) * quadDir.y);
    }
#endif

TEMPLATE_SWAP(Swap) // Define a Swap(a, b) function for all types

#define CUBEMAPFACE_POSITIVE_X 0
#define CUBEMAPFACE_NEGATIVE_X 1
#define CUBEMAPFACE_POSITIVE_Y 2
#define CUBEMAPFACE_NEGATIVE_Y 3
#define CUBEMAPFACE_POSITIVE_Z 4
#define CUBEMAPFACE_NEGATIVE_Z 5

#ifndef INTRINSIC_CUBEMAP_FACE_ID
float CubeMapFaceID(float3 dir)
{
    float faceID;

    if (abs(dir.z) >= abs(dir.x) && abs(dir.z) >= abs(dir.y))
    {
        faceID = (dir.z < 0.0) ? CUBEMAPFACE_NEGATIVE_Z : CUBEMAPFACE_POSITIVE_Z;
    }
    else if (abs(dir.y) >= abs(dir.x))
    {
        faceID = (dir.y < 0.0) ? CUBEMAPFACE_NEGATIVE_Y : CUBEMAPFACE_POSITIVE_Y;
    }
    else
    {
        faceID = (dir.x < 0.0) ? CUBEMAPFACE_NEGATIVE_X : CUBEMAPFACE_POSITIVE_X;
    }

    return faceID;
}
#endif // INTRINSIC_CUBEMAP_FACE_ID

#if !defined(SHADER_API_GLES)
// Intrinsic isnan can't be used because it require /Gic to be enabled on fxc that we can't do. So use AnyIsNan instead
bool IsNaN(float x)
{
    return (asuint(x) & 0x7FFFFFFF) > 0x7F800000;
}

bool AnyIsNaN(float2 v)
{
    return (IsNaN(v.x) || IsNaN(v.y));
}

bool AnyIsNaN(float3 v)
{
    return (IsNaN(v.x) || IsNaN(v.y) || IsNaN(v.z));
}

bool AnyIsNaN(float4 v)
{
    return (IsNaN(v.x) || IsNaN(v.y) || IsNaN(v.z) || IsNaN(v.w));
}

bool IsInf(float x)
{
    return (asuint(x) & 0x7FFFFFFF) == 0x7F800000;
}

bool AnyIsInf(float2 v)
{
    return (IsInf(v.x) || IsInf(v.y));
}

bool AnyIsInf(float3 v)
{
    return (IsInf(v.x) || IsInf(v.y) || IsInf(v.z));
}

bool AnyIsInf(float4 v)
{
    return (IsInf(v.x) || IsInf(v.y) || IsInf(v.z) || IsInf(v.w));
}

bool IsFinite(float x)
{
    return (asuint(x) & 0x7F800000) != 0x7F800000;
}

float SanitizeFinite(float x)
{
    return IsFinite(x) ? x : 0;
}

bool IsPositiveFinite(float x)
{
    return asuint(x) < 0x7F800000;
}

float SanitizePositiveFinite(float x)
{
    return IsPositiveFinite(x) ? x : 0;
}

#endif

// ----------------------------------------------------------------------------
// Common math functions
// ----------------------------------------------------------------------------

real DegToRad(real deg)
{
    return deg * (PI / 180.0);
}

real RadToDeg(real rad)
{
    return rad * (180.0 / PI);
}

// Square functions for cleaner code
TEMPLATE_1_REAL(Sq, x, return (x) * (x))
TEMPLATE_1_INT(Sq, x, return (x) * (x))

bool IsPower2(uint x)
{
    return (x & (x - 1)) == 0;
}

// Input [0, 1] and output [0, PI/2]
// 9 VALU
real FastACosPos(real inX)
{
    real x = abs(inX);
    real res = (0.0468878 * x + -0.203471) * x + 1.570796; // p(x)
    res *= sqrt(1.0 - x);

    return res;
}

// Ref: https://seblagarde.wordpress.com/2014/12/01/inverse-trigonometric-functions-gpu-optimization-for-amd-gcn-architecture/
// Input [-1, 1] and output [0, PI]
// 12 VALU
real FastACos(real inX)
{
    real res = FastACosPos(inX);

    return (inX >= 0) ? res : PI - res; // Undo range reduction
}

// Same cost as Acos + 1 FR
// Same error
// input [-1, 1] and output [-PI/2, PI/2]
real FastASin(real x)
{
    return HALF_PI - FastACos(x);
}

// max absolute error 1.3x10^-3
// Eberly's odd polynomial degree 5 - respect bounds
// 4 VGPR, 14 FR (10 FR, 1 QR), 2 scalar
// input [0, infinity] and output [0, PI/2]
real FastATanPos(real x)
{
    real t0 = (x < 1.0) ? x : 1.0 / x;
    real t1 = t0 * t0;
    real poly = 0.0872929;
    poly = -0.301895 + poly * t1;
    poly = 1.0 + poly * t1;
    poly = poly * t0;
    return (x < 1.0) ? poly : HALF_PI - poly;
}

// 4 VGPR, 16 FR (12 FR, 1 QR), 2 scalar
// input [-infinity, infinity] and output [-PI/2, PI/2]
real FastATan(real x)
{
    real t0 = FastATanPos(abs(x));
    return (x < 0.0) ? -t0 : t0;
}

#if (SHADER_TARGET >= 45)
uint FastLog2(uint x)
{
    return firstbithigh(x);
}
#endif

// Using pow often result to a warning like this
// "pow(f, e) will not work for negative f, use abs(f) or conditionally handle negative values if you expect them"
// PositivePow remove this warning when you know the value is positive or 0 and avoid inf/NAN.
// Note: https://msdn.microsoft.com/en-us/library/windows/desktop/bb509636(v=vs.85).aspx pow(0, >0) == 0
TEMPLATE_2_REAL(PositivePow, base, power, return pow(abs(base), power))

// Composes a floating point value with the magnitude of 'x' and the sign of 's'.
// See the comment about FastSign() below.
float CopySign(float x, float s, bool ignoreNegZero = true)
{
#if !defined(SHADER_API_GLES)
    if (ignoreNegZero)
    {
        return (s >= 0) ? abs(x) : -abs(x);
    }
    else
    {
        uint negZero = 0x80000000u;
        uint signBit = negZero & asuint(s);
        return asfloat(BitFieldInsert(negZero, signBit, asuint(x)));
    }
#else
    return (s >= 0) ? abs(x) : -abs(x);
#endif
}

// Returns -1 for negative numbers and 1 for positive numbers.
// 0 can be handled in 2 different ways.
// The IEEE floating point standard defines 0 as signed: +0 and -0.
// However, mathematics typically treats 0 as unsigned.
// Therefore, we treat -0 as +0 by default: FastSign(+0) = FastSign(-0) = 1.
// If (ignoreNegZero = false), FastSign(-0, false) = -1.
// Note that the sign() function in HLSL implements signum, which returns 0 for 0.
float FastSign(float s, bool ignoreNegZero = true)
{
    return CopySign(1.0, s, ignoreNegZero);
}

// Orthonormalizes the tangent frame using the Gram-Schmidt process.
// We assume that the normal is normalized and that the two vectors
// aren't collinear.
// Returns the new tangent (the normal is unaffected).
real3 Orthonormalize(real3 tangent, real3 normal)
{
    // TODO: use SafeNormalize()?
    return normalize(tangent - dot(tangent, normal) * normal);
}

// [start, end] -> [0, 1] : (x - start) / (end - start) = x * rcpLength - (start * rcpLength)
TEMPLATE_3_REAL(Remap01, x, rcpLength, startTimesRcpLength, return saturate(x * rcpLength - startTimesRcpLength))

// [start, end] -> [1, 0] : (end - x) / (end - start) = (end * rcpLength) - x * rcpLength
TEMPLATE_3_REAL(Remap10, x, rcpLength, endTimesRcpLength, return saturate(endTimesRcpLength - x * rcpLength))

// Remap: [0.5 / size, 1 - 0.5 / size] -> [0, 1]
real2 RemapHalfTexelCoordTo01(real2 coord, real2 size)
{
    const real2 rcpLen              = size * rcp(size - 1);
    const real2 startTimesRcpLength = 0.5 * rcp(size - 1);

    return Remap01(coord, rcpLen, startTimesRcpLength);
}

// Remap: [0, 1] -> [0.5 / size, 1 - 0.5 / size]
real2 Remap01ToHalfTexelCoord(real2 coord, real2 size)
{
    const real2 start = 0.5 * rcp(size);
    const real2 len   = 1 - rcp(size);

    return coord * len + start;
}

// smoothstep that assumes that 'x' lies within the [0, 1] interval.
real Smoothstep01(real x)
{
    return x * x * (3 - (2 * x));
}

real Smootherstep01(real x)
{
  return x * x * x * (x * (x * 6 - 15) + 10);
}

real Smootherstep(real a, real b, real t)
{
    real r = rcp(b - a);
    real x = Remap01(t, r, a * r);
    return Smootherstep01(x);
}

float3 NLerp(float3 A, float3 B, float t)
{
    return normalize(lerp(A, B, t));
}

float Length2(float3 v)
{
    return dot(v, v);
}

real Pow4(real x)
{
    return (x * x) * (x * x);
}

TEMPLATE_3_FLT(RangeRemap, min, max, t, return saturate((t - min) / (max - min)))

// ----------------------------------------------------------------------------
// Texture utilities
// ----------------------------------------------------------------------------

float ComputeTextureLOD(float2 uvdx, float2 uvdy, float2 scale)
{
    float2 ddx_ = scale * uvdx;
    float2 ddy_ = scale * uvdy;
    float d = max(dot(ddx_, ddx_), dot(ddy_, ddy_));

    return max(0.5 * log2(d), 0.0);
}

float ComputeTextureLOD(float2 uv)
{
    float2 ddx_ = ddx(uv);
    float2 ddy_ = ddy(uv);

    return ComputeTextureLOD(ddx_, ddy_, 1.0);
}

// x contains width, w contains height
float ComputeTextureLOD(float2 uv, float2 texelSize)
{
    uv *= texelSize;

    return ComputeTextureLOD(uv);
}

// LOD clamp is optional and happens outside the function.
float ComputeTextureLOD(float3 duvw_dx, float3 duvw_dy, float3 duvw_dz, float scale)
{
    float d = Max3(dot(duvw_dx, duvw_dx), dot(duvw_dy, duvw_dy), dot(duvw_dz, duvw_dz));
    return 0.5 * log2(d * (scale * scale));
}


uint GetMipCount(Texture2D tex)
{
#if defined(SHADER_API_D3D11) || defined(SHADER_API_D3D12) || defined(SHADER_API_D3D11_9X) || defined(SHADER_API_XBOXONE) || defined(SHADER_API_PSSL)
    #define MIP_COUNT_SUPPORTED 1
#endif
#if (defined(SHADER_API_OPENGL) || defined(SHADER_API_VULKAN)) && !defined(SHADER_STAGE_COMPUTE)
    // OpenGL only supports textureSize for width, height, depth
    // textureQueryLevels (GL_ARB_texture_query_levels) needs OpenGL 4.3 or above and doesn't compile in compute shaders
    // tex.GetDimensions converted to textureQueryLevels
    #define MIP_COUNT_SUPPORTED 1
#endif
    // Metal doesn't support high enough OpenGL version

#if defined(MIP_COUNT_SUPPORTED)
    uint mipLevel, width, height, mipCount;
    mipLevel = width = height = mipCount = 0;
    tex.GetDimensions(mipLevel, width, height, mipCount);
    return mipCount;
#else
    return 0;
#endif
}

// ----------------------------------------------------------------------------
// Texture format sampling
// ----------------------------------------------------------------------------

float2 DirectionToLatLongCoordinate(float3 unDir)
{
    float3 dir = normalize(unDir);
    // coordinate frame is (-Z, X) meaning negative Z is primary axis and X is secondary axis.
    return float2(1.0 - 0.5 * INV_PI * atan2(dir.x, -dir.z), asin(dir.y) * INV_PI + 0.5);
}

float3 LatlongToDirectionCoordinate(float2 coord)
{
    float theta = coord.y * PI;
    float phi = (coord.x * 2.f * PI - PI*0.5f);

    float cosTheta = cos(theta);
    float sinTheta = sqrt(1.0 - min(1.0, cosTheta*cosTheta));
    float cosPhi = cos(phi);
    float sinPhi = sin(phi);

    float3 direction = float3(sinTheta*cosPhi, cosTheta, sinTheta*sinPhi);
    direction.xy *= -1.0;
    return direction;
}

// ----------------------------------------------------------------------------
// Depth encoding/decoding
// ----------------------------------------------------------------------------

// Z buffer to linear 0..1 depth (0 at near plane, 1 at far plane).
// Does NOT correctly handle oblique view frustums.
// Does NOT work with orthographic projection.
// zBufferParam = { (f-n)/n, 1, (f-n)/n*f, 1/f }
float Linear01DepthFromNear(float depth, float4 zBufferParam)
{
    return 1.0 / (zBufferParam.x + zBufferParam.y / depth);
}

// Z buffer to linear 0..1 depth (0 at camera position, 1 at far plane).
// Does NOT work with orthographic projections.
// Does NOT correctly handle oblique view frustums.
// zBufferParam = { (f-n)/n, 1, (f-n)/n*f, 1/f }
float Linear01Depth(float depth, float4 zBufferParam)
{
    return 1.0 / (zBufferParam.x * depth + zBufferParam.y);
}

// Z buffer to linear depth.
// Does NOT correctly handle oblique view frustums.
// Does NOT work with orthographic projection.
// zBufferParam = { (f-n)/n, 1, (f-n)/n*f, 1/f }
float LinearEyeDepth(float depth, float4 zBufferParam)
{
    return 1.0 / (zBufferParam.z * depth + zBufferParam.w);
}

// Z buffer to linear depth.
// Correctly handles oblique view frustums.
// Does NOT work with orthographic projection.
// Ref: An Efficient Depth Linearization Method for Oblique View Frustums, Eq. 6.
float LinearEyeDepth(float2 positionNDC, float deviceDepth, float4 invProjParam)
{
    float4 positionCS = float4(positionNDC * 2.0 - 1.0, deviceDepth, 1.0);
    float  viewSpaceZ = rcp(dot(positionCS, invProjParam));

    // If the matrix is right-handed, we have to flip the Z axis to get a positive value.
    return abs(viewSpaceZ);
}

// Z buffer to linear depth.
// Works in all cases.
// Typically, this is the cheapest variant, provided you've already computed 'positionWS'.
// Assumes that the 'positionWS' is in front of the camera.
float LinearEyeDepth(float3 positionWS, float4x4 viewMatrix)
{
    float viewSpaceZ = mul(viewMatrix, float4(positionWS, 1.0)).z;

    // If the matrix is right-handed, we have to flip the Z axis to get a positive value.
    return abs(viewSpaceZ);
}

// 'z' is the view space Z position (linear depth).
// saturate(z) the output of the function to clamp them to the [0, 1] range.
// d = log2(c * (z - n) + 1) / log2(c * (f - n) + 1)
//   = log2(c * (z - n + 1/c)) / log2(c * (f - n) + 1)
//   = log2(c) / log2(c * (f - n) + 1) + log2(z - (n - 1/c)) / log2(c * (f - n) + 1)
//   = E + F * log2(z - G)
// encodingParams = { E, F, G, 0 }
float EncodeLogarithmicDepthGeneralized(float z, float4 encodingParams)
{
    // Use max() to avoid NaNs.
    return encodingParams.x + encodingParams.y * log2(max(0, z - encodingParams.z));
}

// 'd' is the logarithmically encoded depth value.
// saturate(d) to clamp the output of the function to the [n, f] range.
// z = 1/c * (pow(c * (f - n) + 1, d) - 1) + n
//   = 1/c * pow(c * (f - n) + 1, d) + n - 1/c
//   = 1/c * exp2(d * log2(c * (f - n) + 1)) + (n - 1/c)
//   = L * exp2(d * M) + N
// decodingParams = { L, M, N, 0 }
// Graph: https://www.desmos.com/calculator/qrtatrlrba
float DecodeLogarithmicDepthGeneralized(float d, float4 decodingParams)
{
    return decodingParams.x * exp2(d * decodingParams.y) + decodingParams.z;
}

// 'z' is the view-space Z position (linear depth).
// saturate(z) the output of the function to clamp them to the [0, 1] range.
// encodingParams = { n, log2(f/n), 1/n, 1/log2(f/n) }
// This is an optimized version of EncodeLogarithmicDepthGeneralized() for (c = 2).
float EncodeLogarithmicDepth(float z, float4 encodingParams)
{
    // Use max() to avoid NaNs.
    // TODO: optimize to (log2(z) - log2(n)) / (log2(f) - log2(n)).
    return log2(max(0, z * encodingParams.z)) * encodingParams.w;
}

// 'd' is the logarithmically encoded depth value.
// saturate(d) to clamp the output of the function to the [n, f] range.
// encodingParams = { n, log2(f/n), 1/n, 1/log2(f/n) }
// This is an optimized version of DecodeLogarithmicDepthGeneralized() for (c = 2).
// Graph: https://www.desmos.com/calculator/qrtatrlrba
float DecodeLogarithmicDepth(float d, float4 encodingParams)
{
    // TODO: optimize to exp2(d * y + log2(x)).
    return encodingParams.x * exp2(d * encodingParams.y);
}

real4 CompositeOver(real4 front, real4 back)
{
    return front + (1 - front.a) * back;
}

void CompositeOver(real3 colorFront, real3 alphaFront,
                   real3 colorBack,  real3 alphaBack,
                   out real3 color,  out real3 alpha)
{
    color = colorFront + (1 - alphaFront) * colorBack;
    alpha = alphaFront + (1 - alphaFront) * alphaBack;
}

// ----------------------------------------------------------------------------
// Space transformations
// ----------------------------------------------------------------------------

static const float3x3 k_identity3x3 = {1, 0, 0,
                                       0, 1, 0,
                                       0, 0, 1};

static const float4x4 k_identity4x4 = {1, 0, 0, 0,
                                       0, 1, 0, 0,
                                       0, 0, 1, 0,
                                       0, 0, 0, 1};

float4 ComputeClipSpacePosition(float2 positionNDC, float deviceDepth)
{
    float4 positionCS = float4(positionNDC * 2.0 - 1.0, deviceDepth, 1.0);

#if UNITY_UV_STARTS_AT_TOP
    // Our world space, view space, screen space and NDC space are Y-up.
    // Our clip space is flipped upside-down due to poor legacy Unity design.
    // The flip is baked into the projection matrix, so we only have to flip
    // manually when going from CS to NDC and back.
    positionCS.y = -positionCS.y;
#endif

    return positionCS;
}

// Use case examples:
// (position = positionCS) => (clipSpaceTransform = use default)
// (position = positionVS) => (clipSpaceTransform = UNITY_MATRIX_P)
// (position = positionWS) => (clipSpaceTransform = UNITY_MATRIX_VP)
float4 ComputeClipSpacePosition(float3 position, float4x4 clipSpaceTransform = k_identity4x4)
{
    return mul(clipSpaceTransform, float4(position, 1.0));
}

// The returned Z value is the depth buffer value (and NOT linear view space Z value).
// Use case examples:
// (position = positionCS) => (clipSpaceTransform = use default)
// (position = positionVS) => (clipSpaceTransform = UNITY_MATRIX_P)
// (position = positionWS) => (clipSpaceTransform = UNITY_MATRIX_VP)
float3 ComputeNormalizedDeviceCoordinatesWithZ(float3 position, float4x4 clipSpaceTransform = k_identity4x4)
{
    float4 positionCS = ComputeClipSpacePosition(position, clipSpaceTransform);

#if UNITY_UV_STARTS_AT_TOP
    // Our world space, view space, screen space and NDC space are Y-up.
    // Our clip space is flipped upside-down due to poor legacy Unity design.
    // The flip is baked into the projection matrix, so we only have to flip
    // manually when going from CS to NDC and back.
    positionCS.y = -positionCS.y;
#endif

    positionCS *= rcp(positionCS.w);
    positionCS.xy = positionCS.xy * 0.5 + 0.5;

    return positionCS.xyz;
}

// Use case examples:
// (position = positionCS) => (clipSpaceTransform = use default)
// (position = positionVS) => (clipSpaceTransform = UNITY_MATRIX_P)
// (position = positionWS) => (clipSpaceTransform = UNITY_MATRIX_VP)
float2 ComputeNormalizedDeviceCoordinates(float3 position, float4x4 clipSpaceTransform = k_identity4x4)
{
    return ComputeNormalizedDeviceCoordinatesWithZ(position, clipSpaceTransform).xy;
}

float3 ComputeViewSpacePosition(float2 positionNDC, float deviceDepth, float4x4 invProjMatrix)
{
    float4 positionCS = ComputeClipSpacePosition(positionNDC, deviceDepth);
    float4 positionVS = mul(invProjMatrix, positionCS);
    // The view space uses a right-handed coordinate system.
    positionVS.z = -positionVS.z;
    return positionVS.xyz / positionVS.w;
}

float3 ComputeWorldSpacePosition(float2 positionNDC, float deviceDepth, float4x4 invViewProjMatrix)
{
    float4 positionCS  = ComputeClipSpacePosition(positionNDC, deviceDepth);
    float4 hpositionWS = mul(invViewProjMatrix, positionCS);
    return hpositionWS.xyz / hpositionWS.w;
}

// ----------------------------------------------------------------------------
// PositionInputs
// ----------------------------------------------------------------------------

// Note: if you modify this struct, be sure to update the CustomPassFullscreenShader.template
struct PositionInputs
{
    float3 positionWS;  // World space position (could be camera-relative)
    float2 positionNDC; // Normalized screen coordinates within the viewport    : [0, 1) (with the half-pixel offset)
    uint2  positionSS;  // Screen space pixel coordinates                       : [0, NumPixels)
    uint2  tileCoord;   // Screen tile coordinates                              : [0, NumTiles)
    float  deviceDepth; // Depth from the depth buffer                          : [0, 1] (typically reversed)
    float  linearDepth; // View space Z coordinate                              : [Near, Far]
};

// This function is use to provide an easy way to sample into a screen texture, either from a pixel or a compute shaders.
// This allow to easily share code.
// If a compute shader call this function positionSS is an integer usually calculate like: uint2 positionSS = groupId.xy * BLOCK_SIZE + groupThreadId.xy
// else it is current unormalized screen coordinate like return by SV_Position
PositionInputs GetPositionInput(float2 positionSS, float2 invScreenSize, uint2 tileCoord)   // Specify explicit tile coordinates so that we can easily make it lane invariant for compute evaluation.
{
    PositionInputs posInput;
    ZERO_INITIALIZE(PositionInputs, posInput);

    posInput.positionNDC = positionSS;
#if defined(SHADER_STAGE_COMPUTE) || defined(SHADER_STAGE_RAY_TRACING)
    // In case of compute shader an extra half offset is added to the screenPos to shift the integer position to pixel center.
    posInput.positionNDC.xy += float2(0.5, 0.5);
#endif
    posInput.positionNDC *= invScreenSize;
    posInput.positionSS = uint2(positionSS);
    posInput.tileCoord = tileCoord;

    return posInput;
}

PositionInputs GetPositionInput(float2 positionSS, float2 invScreenSize)
{
    return GetPositionInput(positionSS, invScreenSize, uint2(0, 0));
}

// From forward
// deviceDepth and linearDepth come directly from .zw of SV_Position
PositionInputs GetPositionInput(float2 positionSS, float2 invScreenSize, float deviceDepth, float linearDepth, float3 positionWS, uint2 tileCoord)
{
    PositionInputs posInput = GetPositionInput(positionSS, invScreenSize, tileCoord);
    posInput.positionWS = positionWS;
    posInput.deviceDepth = deviceDepth;
    posInput.linearDepth = linearDepth;

    return posInput;
}

PositionInputs GetPositionInput(float2 positionSS, float2 invScreenSize, float deviceDepth, float linearDepth, float3 positionWS)
{
    return GetPositionInput(positionSS, invScreenSize, deviceDepth, linearDepth, positionWS, uint2(0, 0));
}

// From deferred or compute shader
// depth must be the depth from the raw depth buffer. This allow to handle all kind of depth automatically with the inverse view projection matrix.
// For information. In Unity Depth is always in range 0..1 (even on OpenGL) but can be reversed.
PositionInputs GetPositionInput(float2 positionSS, float2 invScreenSize, float deviceDepth,
    float4x4 invViewProjMatrix, float4x4 viewMatrix,
    uint2 tileCoord)
{
    PositionInputs posInput = GetPositionInput(positionSS, invScreenSize, tileCoord);
    posInput.positionWS = ComputeWorldSpacePosition(posInput.positionNDC, deviceDepth, invViewProjMatrix);
    posInput.deviceDepth = deviceDepth;
    posInput.linearDepth = LinearEyeDepth(posInput.positionWS, viewMatrix);

    return posInput;
}

PositionInputs GetPositionInput(float2 positionSS, float2 invScreenSize, float deviceDepth,
                                float4x4 invViewProjMatrix, float4x4 viewMatrix)
{
    return GetPositionInput(positionSS, invScreenSize, deviceDepth, invViewProjMatrix, viewMatrix, uint2(0, 0));
}

// The view direction 'V' points towards the camera.
// 'depthOffsetVS' is always applied in the opposite direction (-V).
void ApplyDepthOffsetPositionInput(float3 V, float depthOffsetVS, float3 viewForwardDir, float4x4 viewProjMatrix, inout PositionInputs posInput)
{
    posInput.positionWS += depthOffsetVS * (-V);
    posInput.deviceDepth = ComputeNormalizedDeviceCoordinatesWithZ(posInput.positionWS, viewProjMatrix).z;

    // Transform the displacement along the view vector to the displacement along the forward vector.
    // Use abs() to make sure we get the sign right.
    // 'depthOffsetVS' applies in the direction away from the camera.
    posInput.linearDepth += depthOffsetVS * abs(dot(V, viewForwardDir));
}

// ----------------------------------------------------------------------------
// Terrain/Brush heightmap encoding/decoding
// ----------------------------------------------------------------------------

#if defined(SHADER_API_VULKAN) || defined(SHADER_API_GLES) || defined(SHADER_API_GLES3)

real4 PackHeightmap(real height)
{
    uint a = (uint)(65535.0 * height);
    return real4((a >> 0) & 0xFF, (a >> 8) & 0xFF, 0, 0) / 255.0;
}

real UnpackHeightmap(real4 height)
{
    return (height.r + height.g * 256.0) / 257.0; // (255.0 * height.r + 255.0 * 256.0 * height.g) / 65535.0
}

#else

real4 PackHeightmap(real height)
{
    return real4(height, 0, 0, 0);
}

real UnpackHeightmap(real4 height)
{
    return height.r;
}

#endif

// ----------------------------------------------------------------------------
// Misc utilities
// ----------------------------------------------------------------------------

// Simple function to test a bitfield
bool HasFlag(uint bitfield, uint flag)
{
    return (bitfield & flag) != 0;
}

// Normalize that account for vectors with zero length
real3 SafeNormalize(float3 inVec)
{
    float dp3 = max(FLT_MIN, dot(inVec, inVec));
    return inVec * rsqrt(dp3);
}

// Division which returns 1 for (inf/inf) and (0/0).
// If any of the input parameters are NaNs, the result is a NaN.
real SafeDiv(real numer, real denom)
{
    return (numer != denom) ? numer / denom : 1;
}

// Assumes that (0 <= x <= Pi).
real SinFromCos(real cosX)
{
    return sqrt(saturate(1 - cosX * cosX));
}

// Dot product in spherical coordinates.
real SphericalDot(real cosTheta1, real phi1, real cosTheta2, real phi2)
{
    return SinFromCos(cosTheta1) * SinFromCos(cosTheta2) * cos(phi1 - phi2) + cosTheta1 * cosTheta2;
}

// Generates a triangle in homogeneous clip space, s.t.
// v0 = (-1, -1, 1), v1 = (3, -1, 1), v2 = (-1, 3, 1).
float2 GetFullScreenTriangleTexCoord(uint vertexID)
{
#if UNITY_UV_STARTS_AT_TOP
    return float2((vertexID << 1) & 2, 1.0 - (vertexID & 2));
#else
    return float2((vertexID << 1) & 2, vertexID & 2);
#endif
}

float4 GetFullScreenTriangleVertexPosition(uint vertexID, float z = UNITY_NEAR_CLIP_VALUE)
{
    float2 uv = float2((vertexID << 1) & 2, vertexID & 2);
    return float4(uv * 2.0 - 1.0, z, 1.0);
}


// draw procedural with 2 triangles has index order (0,1,2)  (0,2,3)

// 0 - 0,0
// 1 - 0,1
// 2 - 1,1
// 3 - 1,0

float2 GetQuadTexCoord(uint vertexID)
{
    uint topBit = vertexID >> 1;
    uint botBit = (vertexID & 1);
    float u = topBit;
    float v = (topBit + botBit) & 1; // produces 0 for indices 0,3 and 1 for 1,2
#if UNITY_UV_STARTS_AT_TOP
    v = 1.0 - v;
#endif
    return float2(u, v);
}

// 0 - 0,1
// 1 - 0,0
// 2 - 1,0
// 3 - 1,1
float4 GetQuadVertexPosition(uint vertexID, float z = UNITY_NEAR_CLIP_VALUE)
{
    uint topBit = vertexID >> 1;
    uint botBit = (vertexID & 1);
    float x = topBit;
    float y = 1 - (topBit + botBit) & 1; // produces 1 for indices 0,3 and 0 for 1,2
    return float4(x, y, z, 1.0);
}

#if !defined(SHADER_API_GLES) && !defined(SHADER_STAGE_RAY_TRACING)

// LOD dithering transition helper
// LOD0 must use this function with ditherFactor 1..0
// LOD1 must use this function with ditherFactor -1..0
// This is what is provided by unity_LODFade
void LODDitheringTransition(uint2 fadeMaskSeed, float ditherFactor)
{
    // Generate a spatially varying pattern.
    // Unfortunately, varying the pattern with time confuses the TAA, increasing the amount of noise.
    float p = GenerateHashedRandomFloat(fadeMaskSeed);

    // This preserves the symmetry s.t. if LOD 0 has f = x, LOD 1 has f = -x.
    float f = ditherFactor - CopySign(p, ditherFactor);
    clip(f);
}

#endif

// The resource that is bound when binding a stencil buffer from the depth buffer is two channel. On D3D11 the stencil value is in the green channel,
// while on other APIs is in the red channel. Note that on some platform, always using the green channel might work, but is not guaranteed.
uint GetStencilValue(uint2 stencilBufferVal)
{
#if defined(SHADER_API_D3D11) || defined(SHADER_API_XBOXONE)  
    return stencilBufferVal.y;
#else
    return stencilBufferVal.x;
#endif
} 

#endif // UNITY_COMMON_INCLUDED

// File end: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/Common.hlsl
//================================================================================================================================



//================================================================================================================================
// File start: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/EntityLighting.hlsl


#ifndef UNITY_ENTITY_LIGHTING_INCLUDED
#define UNITY_ENTITY_LIGHTING_INCLUDED


#define LIGHTMAP_RGBM_MAX_GAMMA     real(5.0)       // NB: Must match value in RGBMRanges.h
#define LIGHTMAP_RGBM_MAX_LINEAR    real(34.493242) // LIGHTMAP_RGBM_MAX_GAMMA ^ 2.2

#ifdef UNITY_LIGHTMAP_RGBM_ENCODING
    #ifdef UNITY_COLORSPACE_GAMMA
        #define LIGHTMAP_HDR_MULTIPLIER LIGHTMAP_RGBM_MAX_GAMMA
        #define LIGHTMAP_HDR_EXPONENT   real(1.0)   // Not used in gamma color space
    #else
        #define LIGHTMAP_HDR_MULTIPLIER LIGHTMAP_RGBM_MAX_LINEAR
        #define LIGHTMAP_HDR_EXPONENT   real(2.2)
    #endif
#elif defined(UNITY_LIGHTMAP_DLDR_ENCODING)
    #ifdef UNITY_COLORSPACE_GAMMA
        #define LIGHTMAP_HDR_MULTIPLIER real(2.0)
    #else
        #define LIGHTMAP_HDR_MULTIPLIER real(4.59) // 2.0 ^ 2.2
    #endif
    #define LIGHTMAP_HDR_EXPONENT real(0.0)
#else // (UNITY_LIGHTMAP_FULL_HDR)
    #define LIGHTMAP_HDR_MULTIPLIER real(1.0)
    #define LIGHTMAP_HDR_EXPONENT real(1.0)
#endif

// TODO: Check if PI is correctly handled!

// Ref: "Efficient Evaluation of Irradiance Environment Maps" from ShaderX 2
real3 SHEvalLinearL0L1(real3 N, real4 shAr, real4 shAg, real4 shAb)
{
    real4 vA = real4(N, 1.0);

    real3 x1;
    // Linear (L1) + constant (L0) polynomial terms
    x1.r = dot(shAr, vA);
    x1.g = dot(shAg, vA);
    x1.b = dot(shAb, vA);

    return x1;
}

real3 SHEvalLinearL2(real3 N, real4 shBr, real4 shBg, real4 shBb, real4 shC)
{
    real3 x2;
    // 4 of the quadratic (L2) polynomials
    real4 vB = N.xyzz * N.yzzx;
    x2.r = dot(shBr, vB);
    x2.g = dot(shBg, vB);
    x2.b = dot(shBb, vB);

    // Final (5th) quadratic (L2) polynomial
    real vC = N.x * N.x - N.y * N.y;
    real3 x3 = shC.rgb * vC;

    return x2 + x3;
}

#if HAS_HALF
half3 SampleSH9(half4 SHCoefficients[7], half3 N)
{
    half4 shAr = SHCoefficients[0];
    half4 shAg = SHCoefficients[1];
    half4 shAb = SHCoefficients[2];
    half4 shBr = SHCoefficients[3];
    half4 shBg = SHCoefficients[4];
    half4 shBb = SHCoefficients[5];
    half4 shCr = SHCoefficients[6];

    // Linear + constant polynomial terms
    half3 res = SHEvalLinearL0L1(N, shAr, shAg, shAb);

    // Quadratic polynomials
    res += SHEvalLinearL2(N, shBr, shBg, shBb, shCr);

    return res;
}
#endif
float3 SampleSH9(float4 SHCoefficients[7], float3 N)
{
    float4 shAr = SHCoefficients[0];
    float4 shAg = SHCoefficients[1];
    float4 shAb = SHCoefficients[2];
    float4 shBr = SHCoefficients[3];
    float4 shBg = SHCoefficients[4];
    float4 shBb = SHCoefficients[5];
    float4 shCr = SHCoefficients[6];

    // Linear + constant polynomial terms
    float3 res = SHEvalLinearL0L1(N, shAr, shAg, shAb);

    // Quadratic polynomials
    res += SHEvalLinearL2(N, shBr, shBg, shBb, shCr);

    return res;
}


// texture3dLod is not supported on gles2.
#if !defined(SHADER_API_GLES)
// This sample a 3D volume storing SH
// Volume is store as 3D texture with 4 R, G, B, Occ set of 4 coefficient store atlas in same 3D texture. Occ is use for occlusion.
// TODO: the packing here is inefficient as we will fetch values far away from each other and they may not fit into the cache - Suggest we pack RGB continuously
// TODO: The calcul of texcoord could be perform with a single matrix multicplication calcualted on C++ side that will fold probeVolumeMin and probeVolumeSizeInv into it and handle the identity case, no reasons to do it in C++ (ask Ionut about it)
// It should also handle the camera relative path (if the render pipeline use it)
float3 SampleProbeVolumeSH4(TEXTURE3D_PARAM(SHVolumeTexture, SHVolumeSampler), float3 positionWS, float3 normalWS, float4x4 WorldToTexture,
                            float transformToLocal, float texelSizeX, float3 probeVolumeMin, float3 probeVolumeSizeInv)
{
    float3 position = (transformToLocal == 1.0) ? mul(WorldToTexture, float4(positionWS, 1.0)).xyz : positionWS;
    float3 texCoord = (position - probeVolumeMin) * probeVolumeSizeInv.xyz;
    // Each component is store in the same texture 3D. Each use one quater on the x axis
    // Here we get R component then increase by step size (0.25) to get other component. This assume 4 component
    // but last one is not used.
    // Clamp to edge of the "internal" texture, as R is from half texel to size of R texture minus half texel.
    // This avoid leaking
    texCoord.x = clamp(texCoord.x * 0.25, 0.5 * texelSizeX, 0.25 - 0.5 * texelSizeX);

    float4 shAr = SAMPLE_TEXTURE3D_LOD(SHVolumeTexture, SHVolumeSampler, texCoord, 0);
    texCoord.x += 0.25;
    float4 shAg = SAMPLE_TEXTURE3D_LOD(SHVolumeTexture, SHVolumeSampler, texCoord, 0);
    texCoord.x += 0.25;
    float4 shAb = SAMPLE_TEXTURE3D_LOD(SHVolumeTexture, SHVolumeSampler, texCoord, 0);

    return SHEvalLinearL0L1(normalWS, shAr, shAg, shAb);
}

// The SphericalHarmonicsL2 coefficients are packed into 7 coefficients per color channel instead of 9.
// The packing from 9 to 7 is done from engine code and will use the alpha component of the pixel to store an additional SH coefficient.
// The 3D atlas texture will contain 7 SH coefficient parts.
float3 SampleProbeVolumeSH9(TEXTURE3D_PARAM(SHVolumeTexture, SHVolumeSampler), float3 positionWS, float3 normalWS, float4x4 WorldToTexture,
                                           float transformToLocal, float texelSizeX, float3 probeVolumeMin, float3 probeVolumeSizeInv)
{
    float3 position = (transformToLocal == 1.0f) ? mul(WorldToTexture, float4(positionWS, 1.0)).xyz : positionWS;
    float3 texCoord = (position - probeVolumeMin) * probeVolumeSizeInv;

    const uint shCoeffCount = 7;
    const float invShCoeffCount = 1.0f / float(shCoeffCount);

    // We need to compute proper X coordinate to sample into the atlas.
    texCoord.x = texCoord.x / shCoeffCount;

    // Clamp the x coordinate otherwise we'll have leaking between RGB coefficients.
    float texCoordX = clamp(texCoord.x, 0.5f * texelSizeX, invShCoeffCount - 0.5f * texelSizeX);

    float4 SHCoefficients[7];

    for (uint i = 0; i < shCoeffCount; i++)
    {
        texCoord.x = texCoordX + i * invShCoeffCount;
        SHCoefficients[i] = SAMPLE_TEXTURE3D_LOD(SHVolumeTexture, SHVolumeSampler, texCoord, 0);
    }

    return SampleSH9(SHCoefficients, normalize(normalWS));
}
#endif

float4 SampleProbeOcclusion(TEXTURE3D_PARAM(SHVolumeTexture, SHVolumeSampler), float3 positionWS, float4x4 WorldToTexture,
                            float transformToLocal, float texelSizeX, float3 probeVolumeMin, float3 probeVolumeSizeInv)
{
    float3 position = (transformToLocal == 1.0) ? mul(WorldToTexture, float4(positionWS, 1.0)).xyz : positionWS;
    float3 texCoord = (position - probeVolumeMin) * probeVolumeSizeInv.xyz;

    // Sample fourth texture in the atlas
    // We need to compute proper U coordinate to sample.
    // Clamp the coordinate otherwize we'll have leaking between ShB coefficients and Probe Occlusion(Occ) info
    texCoord.x = max(texCoord.x * 0.25 + 0.75, 0.75 + 0.5 * texelSizeX);

    return SAMPLE_TEXTURE3D(SHVolumeTexture, SHVolumeSampler, texCoord);
}

// Following functions are to sample enlighten lightmaps (or lightmaps encoded the same way as our
// enlighten implementation). They assume use of RGB9E5 for dynamic illuminance map and RGBM for baked ones.
// It is required for other platform that aren't supporting this format to implement variant of these functions
// (But these kind of platform should use regular render loop and not news shaders).

// TODO: This is the max value allowed for emissive (bad name - but keep for now to retrieve it) (It is 8^2.2 (gamma) and 8 is the limit of punctual light slider...), comme from UnityCg.cginc. Fix it!
// Ask Jesper if this can be change for HDRenderPipeline
#define EMISSIVE_RGBM_SCALE 97.0

// RGBM stuff is temporary. For now baked lightmap are in RGBM and the RGBM range for lightmaps is specific so we can't use the generic method.
// In the end baked lightmaps are going to be BC6H so the code will be the same as dynamic lightmaps.
// Same goes for emissive packed as an input for Enlighten with another hard coded multiplier.

// TODO: This function is used with the LightTransport pass to encode lightmap or emissive
real4 PackEmissiveRGBM(real3 rgb)
{
    real kOneOverRGBMMaxRange = 1.0 / EMISSIVE_RGBM_SCALE;
    const real kMinMultiplier = 2.0 * 1e-2;

    real4 rgbm = real4(rgb * kOneOverRGBMMaxRange, 1.0);
        rgbm.a = max(max(rgbm.r, rgbm.g), max(rgbm.b, kMinMultiplier));
    rgbm.a = ceil(rgbm.a * 255.0) / 255.0;

    // Division-by-zero warning from d3d9, so make compiler happy.
    rgbm.a = max(rgbm.a, kMinMultiplier);

    rgbm.rgb /= rgbm.a;
    return rgbm;
}

real3 UnpackLightmapRGBM(real4 rgbmInput, real4 decodeInstructions)
{
#ifdef UNITY_COLORSPACE_GAMMA
    return rgbmInput.rgb * (rgbmInput.a * decodeInstructions.x);
#else
    return rgbmInput.rgb * (PositivePow(rgbmInput.a, decodeInstructions.y) * decodeInstructions.x);
#endif
}

real3 UnpackLightmapDoubleLDR(real4 encodedColor, real4 decodeInstructions)
{
    return encodedColor.rgb * decodeInstructions.x;
}

real3 DecodeLightmap(real4 encodedIlluminance, real4 decodeInstructions)
{
#if defined(UNITY_LIGHTMAP_RGBM_ENCODING)
    return UnpackLightmapRGBM(encodedIlluminance, decodeInstructions);
#elif defined(UNITY_LIGHTMAP_DLDR_ENCODING)
    return UnpackLightmapDoubleLDR(encodedIlluminance, decodeInstructions);
#else // (UNITY_LIGHTMAP_FULL_HDR)
    return encodedIlluminance.rgb;
#endif
}

real3 DecodeHDREnvironment(real4 encodedIrradiance, real4 decodeInstructions)
{
    // Take into account texture alpha if decodeInstructions.w is true(the alpha value affects the RGB channels)
    real alpha = max(decodeInstructions.w * (encodedIrradiance.a - 1.0) + 1.0, 0.0);

    // If Linear mode is not supported we can skip exponent part
    return (decodeInstructions.x * PositivePow(alpha, decodeInstructions.y)) * encodedIrradiance.rgb;
}

real3 SampleSingleLightmap(TEXTURE2D_PARAM(lightmapTex, lightmapSampler), float2 uv, float4 transform, bool encodedLightmap, real4 decodeInstructions)
{
    // transform is scale and bias
    uv = uv * transform.xy + transform.zw;
    real3 illuminance = real3(0.0, 0.0, 0.0);
    // Remark: baked lightmap is RGBM for now, dynamic lightmap is RGB9E5
    if (encodedLightmap)
    {
        real4 encodedIlluminance = SAMPLE_TEXTURE2D(lightmapTex, lightmapSampler, uv).rgba;
        illuminance = DecodeLightmap(encodedIlluminance, decodeInstructions);
    }
    else
    {
        illuminance = SAMPLE_TEXTURE2D(lightmapTex, lightmapSampler, uv).rgb;
    }
    return illuminance;
}

real3 SampleDirectionalLightmap(TEXTURE2D_PARAM(lightmapTex, lightmapSampler), TEXTURE2D_PARAM(lightmapDirTex, lightmapDirSampler), float2 uv, float4 transform, float3 normalWS, bool encodedLightmap, real4 decodeInstructions)
{
    // In directional mode Enlighten bakes dominant light direction
    // in a way, that using it for half Lambert and then dividing by a "rebalancing coefficient"
    // gives a result close to plain diffuse response lightmaps, but normalmapped.

    // Note that dir is not unit length on purpose. Its length is "directionality", like
    // for the directional specular lightmaps.

    // transform is scale and bias
    uv = uv * transform.xy + transform.zw;

    real4 direction = SAMPLE_TEXTURE2D(lightmapDirTex, lightmapDirSampler, uv);
    // Remark: baked lightmap is RGBM for now, dynamic lightmap is RGB9E5
    real3 illuminance = real3(0.0, 0.0, 0.0);
    if (encodedLightmap)
    {
        real4 encodedIlluminance = SAMPLE_TEXTURE2D(lightmapTex, lightmapSampler, uv).rgba;
        illuminance = DecodeLightmap(encodedIlluminance, decodeInstructions);
    }
    else
    {
        illuminance = SAMPLE_TEXTURE2D(lightmapTex, lightmapSampler, uv).rgb;
    }
    real halfLambert = dot(normalWS, direction.xyz - 0.5) + 0.5;
    return illuminance * halfLambert / max(1e-4, direction.w);
}

#endif // UNITY_ENTITY_LIGHTING_INCLUDED

// File end: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/EntityLighting.hlsl
//================================================================================================================================



//================================================================================================================================
// File start: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/ImageBasedLighting.hlsl


#ifndef UNITY_IMAGE_BASED_LIGHTING_INCLUDED
#define UNITY_IMAGE_BASED_LIGHTING_INCLUDED

//================================================================================================================================
// File start: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/CommonLighting.hlsl


#ifndef UNITY_COMMON_LIGHTING_INCLUDED
#define UNITY_COMMON_LIGHTING_INCLUDED

// These clamping function to max of floating point 16 bit are use to prevent INF in code in case of extreme value
TEMPLATE_1_REAL(ClampToFloat16Max, value, return min(value, HALF_MAX))

// Ligthing convention
// Light direction is oriented backward (-Z). i.e in shader code, light direction is -lightData.forward

//-----------------------------------------------------------------------------
// Helper functions
//-----------------------------------------------------------------------------

// Performs the mapping of the vector 'v' centered within the axis-aligned cube
// of dimensions [-1, 1]^3 to a vector centered within the unit sphere.
// The function expects 'v' to be within the cube (possibly unexpected results otherwise).
// Ref: http://mathproofs.blogspot.com/2005/07/mapping-cube-to-sphere.html
real3 MapCubeToSphere(real3 v)
{
    real3 v2 = v * v;
    real2 vr3 = v2.xy * rcp(3.0);
    return v * sqrt((real3)1.0 - 0.5 * v2.yzx - 0.5 * v2.zxy + vr3.yxx * v2.zzy);
}

// Computes the squared magnitude of the vector computed by MapCubeToSphere().
real ComputeCubeToSphereMapSqMagnitude(real3 v)
{
    real3 v2 = v * v;
    // Note: dot(v, v) is often computed before this function is called,
    // so the compiler should optimize and use the precomputed result here.
    return dot(v, v) - v2.x * v2.y - v2.y * v2.z - v2.z * v2.x + v2.x * v2.y * v2.z;
}

// texelArea = 4.0 / (resolution * resolution).
// Ref: http://bpeers.com/blog/?itemid=1017
// This version is less accurate, but much faster than this one:
// http://www.rorydriscoll.com/2012/01/15/cubemap-texel-solid-angle/
real ComputeCubemapTexelSolidAngle(real3 L, real texelArea)
{
    // Stretch 'L' by (1/d) so that it points at a side of a [-1, 1]^2 cube.
    real d = Max3(abs(L.x), abs(L.y), abs(L.z));
    // Since 'L' is a unit vector, we can directly compute its
    // new (inverse) length without dividing 'L' by 'd' first.
    real invDist = d;

    // dw = dA * cosTheta / (dist * dist), cosTheta = 1.0 / dist,
    // where 'dA' is the area of the cube map texel.
    return texelArea * invDist * invDist * invDist;
}

// Only makes sense for Monte-Carlo integration.
// Normalize by dividing by the total weight (or the number of samples) in the end.
// Integrate[6*(u^2+v^2+1)^(-3/2), {u,-1,1},{v,-1,1}] = 4 * Pi
// Ref: "Stupid Spherical Harmonics Tricks", p. 9.
real ComputeCubemapTexelSolidAngle(real2 uv)
{
    real u = uv.x, v = uv.y;
    return pow(1 + u * u + v * v, -1.5);
}

real ConvertEvToLuminance(real ev)
{
    return exp2(ev - 3.0);
}

real ConvertLuminanceToEv(real luminance)
{
    real k = 12.5f;

    return log2((luminance * 100.0) / k);
}

//-----------------------------------------------------------------------------
// Attenuation functions
//-----------------------------------------------------------------------------

// Ref: Moving Frostbite to PBR.

// Non physically based hack to limit light influence to attenuationRadius.
// Square the result to smoothen the function.
real DistanceWindowing(real distSquare, real rangeAttenuationScale, real rangeAttenuationBias)
{
    // If (range attenuation is enabled)
    //   rangeAttenuationScale = 1 / r^2
    //   rangeAttenuationBias  = 1
    // Else
    //   rangeAttenuationScale = 2^12 / r^2
    //   rangeAttenuationBias  = 2^24
    return saturate(rangeAttenuationBias - Sq(distSquare * rangeAttenuationScale));
}

real SmoothDistanceWindowing(real distSquare, real rangeAttenuationScale, real rangeAttenuationBias)
{
    real factor = DistanceWindowing(distSquare, rangeAttenuationScale, rangeAttenuationBias);
    return Sq(factor);
}

#define PUNCTUAL_LIGHT_THRESHOLD 0.01 // 1cm (in Unity 1 is 1m)

// Return physically based quadratic attenuation + influence limit to reach 0 at attenuationRadius
real SmoothWindowedDistanceAttenuation(real distSquare, real distRcp, real rangeAttenuationScale, real rangeAttenuationBias)
{
    real attenuation = min(distRcp, 1.0 / PUNCTUAL_LIGHT_THRESHOLD);
    attenuation *= DistanceWindowing(distSquare, rangeAttenuationScale, rangeAttenuationBias);

    // Effectively results in (distRcp)^2 * SmoothDistanceWindowing(...).
    return Sq(attenuation);
}

// Square the result to smoothen the function.
real AngleAttenuation(real cosFwd, real lightAngleScale, real lightAngleOffset)
{
    return saturate(cosFwd * lightAngleScale + lightAngleOffset);
}

real SmoothAngleAttenuation(real cosFwd, real lightAngleScale, real lightAngleOffset)
{
    real attenuation = AngleAttenuation(cosFwd, lightAngleScale, lightAngleOffset);
    return Sq(attenuation);
}

// Combines SmoothWindowedDistanceAttenuation() and SmoothAngleAttenuation() in an efficient manner.
// distances = {d, d^2, 1/d, d_proj}, where d_proj = dot(lightToSample, lightData.forward).
real PunctualLightAttenuation(real4 distances, real rangeAttenuationScale, real rangeAttenuationBias,
                              real lightAngleScale, real lightAngleOffset)
{
    real distSq   = distances.y;
    real distRcp  = distances.z;
    real distProj = distances.w;
    real cosFwd   = distProj * distRcp;

    real attenuation = min(distRcp, 1.0 / PUNCTUAL_LIGHT_THRESHOLD);
    attenuation *= DistanceWindowing(distSq, rangeAttenuationScale, rangeAttenuationBias);
    attenuation *= AngleAttenuation(cosFwd, lightAngleScale, lightAngleOffset);

    // Effectively results in SmoothWindowedDistanceAttenuation(...) * SmoothAngleAttenuation(...).
    return Sq(attenuation);
}

// Applies SmoothDistanceWindowing() after transforming the attenuation ellipsoid into a sphere.
// If r = rsqrt(invSqRadius), then the ellipsoid is defined s.t. r1 = r / invAspectRatio, r2 = r3 = r.
// The transformation is performed along the major axis of the ellipsoid (corresponding to 'r1').
// Both the ellipsoid (e.i. 'axis') and 'unL' should be in the same coordinate system.
// 'unL' should be computed from the center of the ellipsoid.
real EllipsoidalDistanceAttenuation(real3 unL, real3 axis, real invAspectRatio,
                                    real rangeAttenuationScale, real rangeAttenuationBias)
{
    // Project the unnormalized light vector onto the axis.
    real projL = dot(unL, axis);

    // Transform the light vector so that we can work with
    // with the ellipsoid as if it was a sphere with the radius of light's range.
    real diff = projL - projL * invAspectRatio;
    unL -= diff * axis;

    real sqDist = dot(unL, unL);
    return SmoothDistanceWindowing(sqDist, rangeAttenuationScale, rangeAttenuationBias);
}

// Applies SmoothDistanceWindowing() using the axis-aligned ellipsoid of the given dimensions.
// Both the ellipsoid and 'unL' should be in the same coordinate system.
// 'unL' should be computed from the center of the ellipsoid.
real EllipsoidalDistanceAttenuation(real3 unL, real3 invHalfDim,
                                    real rangeAttenuationScale, real rangeAttenuationBias)
{
    // Transform the light vector so that we can work with
    // with the ellipsoid as if it was a unit sphere.
    unL *= invHalfDim;

    real sqDist = dot(unL, unL);
    return SmoothDistanceWindowing(sqDist, rangeAttenuationScale, rangeAttenuationBias);
}

// Applies SmoothDistanceWindowing() after mapping the axis-aligned box to a sphere.
// If the diagonal of the box is 'd', invHalfDim = rcp(0.5 * d).
// Both the box and 'unL' should be in the same coordinate system.
// 'unL' should be computed from the center of the box.
real BoxDistanceAttenuation(real3 unL, real3 invHalfDim,
                            real rangeAttenuationScale, real rangeAttenuationBias)
{
    real attenuation = 0.0;

    // Transform the light vector so that we can work with
    // with the box as if it was a [-1, 1]^2 cube.
    unL *= invHalfDim;

    // Our algorithm expects the input vector to be within the cube.
    if (!(Max3(abs(unL.x), abs(unL.y), abs(unL.z)) > 1.0))
    {
        real sqDist = ComputeCubeToSphereMapSqMagnitude(unL);
        attenuation = SmoothDistanceWindowing(sqDist, rangeAttenuationScale, rangeAttenuationBias);
    }
    return attenuation;
}

//-----------------------------------------------------------------------------
// IES Helper
//-----------------------------------------------------------------------------

real2 GetIESTextureCoordinate(real3x3 lightToWord, real3 L)
{
    // IES need to be sample in light space
    real3 dir = mul(lightToWord, -L); // Using matrix on left side do a transpose

    // convert to spherical coordinate
    real2 sphericalCoord; // .x is theta, .y is phi
    // Texture is encoded with cos(phi), scale from -1..1 to 0..1
    sphericalCoord.y = (dir.z * 0.5) + 0.5;
    real theta = atan2(dir.y, dir.x);
    sphericalCoord.x = theta * INV_TWO_PI;

    return sphericalCoord;
}

//-----------------------------------------------------------------------------
// Lighting functions
//-----------------------------------------------------------------------------

// Ref: Horizon Occlusion for Normal Mapped Reflections: http://marmosetco.tumblr.com/post/81245981087
real GetHorizonOcclusion(real3 V, real3 normalWS, real3 vertexNormal, real horizonFade)
{
    real3 R = reflect(-V, normalWS);
    real specularOcclusion = saturate(1.0 + horizonFade * dot(R, vertexNormal));
    // smooth it
    return specularOcclusion * specularOcclusion;
}

// Ref: Moving Frostbite to PBR - Gotanda siggraph 2011
// Return specular occlusion based on ambient occlusion (usually get from SSAO) and view/roughness info
real GetSpecularOcclusionFromAmbientOcclusion(real NdotV, real ambientOcclusion, real roughness)
{
    return saturate(PositivePow(NdotV + ambientOcclusion, exp2(-16.0 * roughness - 1.0)) - 1.0 + ambientOcclusion);
}

// ref: Practical Realtime Strategies for Accurate Indirect Occlusion
// Update ambient occlusion to colored ambient occlusion based on statitics of how light is bouncing in an object and with the albedo of the object
real3 GTAOMultiBounce(real visibility, real3 albedo)
{
    real3 a =  2.0404 * albedo - 0.3324;
    real3 b = -4.7951 * albedo + 0.6417;
    real3 c =  2.7552 * albedo + 0.6903;

    real x = visibility;
    return max(x, ((x * a + b) * x + c) * x);
}

// Based on Oat and Sander's 2008 technique
// Area/solidAngle of intersection of two cone
real SphericalCapIntersectionSolidArea(real cosC1, real cosC2, real cosB)
{
    real r1 = FastACos(cosC1);
    real r2 = FastACos(cosC2);
    real rd = FastACos(cosB);
    real area = 0.0;

    if (rd <= max(r1, r2) - min(r1, r2))
    {
        // One cap is completely inside the other
        area = TWO_PI - TWO_PI * max(cosC1, cosC2);
    }
    else if (rd >= r1 + r2)
    {
        // No intersection exists
        area = 0.0;
    }
    else
    {
        real diff = abs(r1 - r2);
        real den = r1 + r2 - diff;
        real x = 1.0 - saturate((rd - diff) / max(den, 0.0001));
        area = smoothstep(0.0, 1.0, x);
        area *= TWO_PI - TWO_PI * max(cosC1, cosC2);
    }

    return area;
}

// ref: Practical Realtime Strategies for Accurate Indirect Occlusion
// http://blog.selfshadow.com/publications/s2016-shading-course/#course_content
// Original Cone-Cone method with cosine weighted assumption (p129 s2016_pbs_activision_occlusion)
real GetSpecularOcclusionFromBentAO(real3 V, real3 bentNormalWS, real3 normalWS, real ambientOcclusion, real roughness)
{
    // Retrieve cone angle
    // Ambient occlusion is cosine weighted, thus use following equation. See slide 129
    real cosAv = sqrt(1.0 - ambientOcclusion);
    roughness = max(roughness, 0.01); // Clamp to 0.01 to avoid edge cases
    real cosAs = exp2((-log(10.0) / log(2.0)) * Sq(roughness));
    real cosB = dot(bentNormalWS, reflect(-V, normalWS));
    return SphericalCapIntersectionSolidArea(cosAv, cosAs, cosB) / (TWO_PI * (1.0 - cosAs));
}

// Ref: Steve McAuley - Energy-Conserving Wrapped Diffuse
real ComputeWrappedDiffuseLighting(real NdotL, real w)
{
    return saturate((NdotL + w) / ((1.0 + w) * (1.0 + w)));
}

// Jimenez variant for eye
real ComputeWrappedPowerDiffuseLighting(real NdotL, real w, real p)
{
    return pow(saturate((NdotL + w) / (1.0 + w)), p) * (p + 1) / (w * 2.0 + 2.0);
}

// Ref: The Technical Art of Uncharted 4 - Brinck and Maximov 2016
real ComputeMicroShadowing(real AO, real NdotL, real opacity)
{
	real aperture = 2.0 * AO * AO;
	real microshadow = saturate(NdotL + aperture - 1.0);
	return lerp(1.0, microshadow, opacity);
}

real3 ComputeShadowColor(real shadow, real3 shadowTint, real penumbraFlag)
{
    // The origin expression is
    // lerp(real3(1.0, 1.0, 1.0) - ((1.0 - shadow) * (real3(1.0, 1.0, 1.0) - shadowTint))
    //            , shadow * lerp(shadowTint, lerp(shadowTint, real3(1.0, 1.0, 1.0), shadow), shadow)
    //            , penumbraFlag);
    // it has been simplified to this
    real3 invTint = real3(1.0, 1.0, 1.0) - shadowTint;
    real shadow3 = shadow * shadow * shadow;
    return lerp(real3(1.0, 1.0, 1.0) - ((1.0 - shadow) * invTint)
                , shadow3 * invTint + shadow * shadowTint,
                penumbraFlag);

}

// This is the same method as the one above. Simply the shadow is a real3 to support colored shadows.
real3 ComputeShadowColor(real3 shadow, real3 shadowTint, real penumbraFlag)
{
    // The origin expression is
    // lerp(real3(1.0, 1.0, 1.0) - ((1.0 - shadow) * (real3(1.0, 1.0, 1.0) - shadowTint))
    //            , shadow * lerp(shadowTint, lerp(shadowTint, real3(1.0, 1.0, 1.0), shadow), shadow)
    //            , penumbraFlag);
    // it has been simplified to this
    real3 invTint = real3(1.0, 1.0, 1.0) - shadowTint;
    real3 shadow3 = shadow * shadow * shadow;
    return lerp(real3(1.0, 1.0, 1.0) - ((1.0 - shadow) * invTint)
                , shadow3 * invTint + shadow * shadowTint,
                penumbraFlag);

}

//-----------------------------------------------------------------------------
// Helper functions
//--------------------------------------------------------------------------- --

// Ref: "Crafting a Next-Gen Material Pipeline for The Order: 1886".
real ClampNdotV(real NdotV)
{
    return max(NdotV, 0.0001); // Approximately 0.0057 degree bias
}

// Helper function to return a set of common angle used when evaluating BSDF
// NdotL and NdotV are unclamped
void GetBSDFAngle(real3 V, real3 L, real NdotL, real NdotV,
                  out real LdotV, out real NdotH, out real LdotH, out real invLenLV)
{
    // Optimized math. Ref: PBR Diffuse Lighting for GGX + Smith Microsurfaces (slide 114).
    LdotV = dot(L, V);
    invLenLV = rsqrt(max(2.0 * LdotV + 2.0, FLT_EPS));    // invLenLV = rcp(length(L + V)), clamp to avoid rsqrt(0) = inf, inf * 0 = NaN
    NdotH = saturate((NdotL + NdotV) * invLenLV);
    LdotH = saturate(invLenLV * LdotV + invLenLV);
}

// Inputs:    normalized normal and view vectors.
// Outputs:   front-facing normal, and the new non-negative value of the cosine of the view angle.
// Important: call Orthonormalize() on the tangent and recompute the bitangent afterwards.
real3 GetViewReflectedNormal(real3 N, real3 V, out real NdotV)
{
    // Fragments of front-facing geometry can have back-facing normals due to interpolation,
    // normal mapping and decals. This can cause visible artifacts from both direct (negative or
    // extremely high values) and indirect (incorrect lookup direction) lighting.
    // There are several ways to avoid this problem. To list a few:
    //
    // 1. Setting { NdotV = max(<N,V>, SMALL_VALUE) }. This effectively removes normal mapping
    // from the affected fragments, making the surface appear flat.
    //
    // 2. Setting { NdotV = abs(<N,V>) }. This effectively reverses the convexity of the surface.
    // It also reduces light leaking from non-shadow-casting lights. Note that 'NdotV' can still
    // be 0 in this case.
    //
    // It's important to understand that simply changing the value of the cosine is insufficient.
    // For one, it does not solve the incorrect lookup direction problem, since the normal itself
    // is not modified. There is a more insidious issue, however. 'NdotV' is a constituent element
    // of the mathematical system describing the relationships between different vectors - and
    // not just normal and view vectors, but also light vectors, half vectors, tangent vectors, etc.
    // Changing only one angle (or its cosine) leaves the system in an inconsistent state, where
    // certain relationships can take on different values depending on whether 'NdotV' is used
    // in the calculation or not. Therefore, it is important to change the normal (or another
    // vector) in order to leave the system in a consistent state.
    //
    // We choose to follow the conceptual approach (2) by reflecting the normal around the
    // (<N,V> = 0) boundary if necessary, as it allows us to preserve some normal mapping details.

    NdotV = dot(N, V);

    // N = (NdotV >= 0.0) ? N : (N - 2.0 * NdotV * V);
    N += (2.0 * saturate(-NdotV)) * V;
    NdotV = abs(NdotV);

    return N;
}

// Generates an orthonormal (row-major) basis from a unit vector. TODO: make it column-major.
// The resulting rotation matrix has the determinant of +1.
// Ref: 'ortho_basis_pixar_r2' from http://marc-b-reynolds.github.io/quaternions/2016/07/06/Orthonormal.html
real3x3 GetLocalFrame(real3 localZ)
{
    real x  = localZ.x;
    real y  = localZ.y;
    real z  = localZ.z;
    real sz = FastSign(z);
    real a  = 1 / (sz + z);
    real ya = y * a;
    real b  = x * ya;
    real c  = x * sz;

    real3 localX = real3(c * x * a - 1, sz * b, c);
    real3 localY = real3(b, y * ya - sz, y);

    // Note: due to the quaternion formulation, the generated frame is rotated by 180 degrees,
    // s.t. if localZ = {0, 0, 1}, then localX = {-1, 0, 0} and localY = {0, -1, 0}.
    return real3x3(localX, localY, localZ);
}

// Generates an orthonormal (row-major) basis from a unit vector. TODO: make it column-major.
// The resulting rotation matrix has the determinant of +1.
real3x3 GetLocalFrame(real3 localZ, real3 localX)
{
    real3 localY = cross(localZ, localX);

    return real3x3(localX, localY, localZ);
}

// Construct a right-handed view-dependent orthogonal basis around the normal:
// b0-b2 is the view-normal aka reflection plane.
real3x3 GetOrthoBasisViewNormal(real3 V, real3 N, real unclampedNdotV, bool testSingularity = false)
{
    real3x3 orthoBasisViewNormal;
    if (testSingularity && (abs(1.0 - unclampedNdotV) <= FLT_EPS))
    {
        // In this case N == V, and azimuth orientation around N shouldn't matter for the caller,
        // we can use any quaternion-based method, like Frisvad or Reynold's (Pixar): 
        orthoBasisViewNormal = GetLocalFrame(N);
    }
    else
    {
        orthoBasisViewNormal[0] = normalize(V - N * unclampedNdotV);
        orthoBasisViewNormal[2] = N;
        orthoBasisViewNormal[1] = cross(orthoBasisViewNormal[2], orthoBasisViewNormal[0]);
    }
    return orthoBasisViewNormal;
}

// Move this here since it's used by both LightLoop.hlsl and RaytracingLightLoop.hlsl
bool IsMatchingLightLayer(uint lightLayers, uint renderingLayers)
{
    return (lightLayers & renderingLayers) != 0;
}

#endif // UNITY_COMMON_LIGHTING_INCLUDED

// File end: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/CommonLighting.hlsl
//================================================================================================================================



//================================================================================================================================
// File start: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/CommonMaterial.hlsl


#ifndef UNITY_COMMON_MATERIAL_INCLUDED
#define UNITY_COMMON_MATERIAL_INCLUDED

//-----------------------------------------------------------------------------
// Define constants
//-----------------------------------------------------------------------------

#define DEFAULT_SPECULAR_VALUE 0.04

// Following constant are used when we use clear coat properties that can't be store in the Gbuffer (with the Lit shader)
#define CLEAR_COAT_IOR 1.5
#define CLEAR_COAT_IETA (1.0 / CLEAR_COAT_IOR) // IETA is the inverse eta which is the ratio of IOR of two interface
#define CLEAR_COAT_F0 0.04 // IORToFresnel0(CLEAR_COAT_IOR)
#define CLEAR_COAT_ROUGHNESS 0.01
#define CLEAR_COAT_PERCEPTUAL_SMOOTHNESS RoughnessToPerceptualSmoothness(CLEAR_COAT_ROUGHNESS)
#define CLEAR_COAT_PERCEPTUAL_ROUGHNESS RoughnessToPerceptualRoughness(CLEAR_COAT_ROUGHNESS)

//-----------------------------------------------------------------------------
// Helper functions for roughness
//-----------------------------------------------------------------------------

real PerceptualRoughnessToRoughness(real perceptualRoughness)
{
    return perceptualRoughness * perceptualRoughness;
}

real RoughnessToPerceptualRoughness(real roughness)
{
    return sqrt(roughness);
}

real RoughnessToPerceptualSmoothness(real roughness)
{
    return 1.0 - sqrt(roughness);
}

real PerceptualSmoothnessToRoughness(real perceptualSmoothness)
{
    return (1.0 - perceptualSmoothness) * (1.0 - perceptualSmoothness);
}

real PerceptualSmoothnessToPerceptualRoughness(real perceptualSmoothness)
{
    return (1.0 - perceptualSmoothness);
}

// Beckmann to GGX roughness "conversions":
//
// As also noted for NormalVariance in this file, Beckmann microfacet models use a Gaussian distribution of slopes
// and the roughness parameter absorbs constants in the canonical Gaussian formula and is thus not exactly the variance.
// The relationship is:
//
// roughnessBeckmann^2 = 2 variance (where variance is usually denoted sigma^2 but some comp gfx papers use sigma for
// variance or even sigma for roughness itself.)
//
// Microfacet BRDF models with a GGX NDF implies a Cauchy distribution of slopes (also corresponds to the distribution
// of slopes on an ellipsoid). Cauchy distributions don't have second moments, which precludes having a variance,
// but chopping the far tails of GGX and keeping 94% of the mass yields a distribution with a defined variance where
// we can then relate the roughness of GGX to a variance (see Ray Tracing Gems p153 - the reference is wrong though,
// the Conty paper doesn't mention this at all, but it can be found in stats using quantiles):
// 
// roughnessGGX^2 = variance / 2
// 
// From the two previous, if we want roughly comparable variances of slopes between a Beckmann and a GGX NDF, we can
// equate the variances and get a conversion of their roughnesses:
//
// 2 * roughnessGGX^2 = roughnessBeckmann^2 / 2      <==>
// 4 * roughnessGGX^2 = roughnessBeckmann^2          <==>
// 2 * roughnessGGX = roughnessBeckmann
//
// (Note that the Ray Tracing Gems paper makes an error on p154 writing sqrt(2) * roughnessGGX = roughnessBeckmann;
// Their validation study using ray tracing and LEADR - which looks good - is for the *variance to GGX* roughness mapping,
// not the Beckmann to GGX roughness "conversion")
real BeckmannRoughnessToGGXRoughness(real roughnessBeckmann)
{
    return 0.5 * roughnessBeckmann;
}

real PerceptualRoughnessBeckmannToGGX(real perceptualRoughnessBeckmann)
{
    //sqrt(a_ggx) = sqrt(0.5) sqrt(a_beckmann)
    return sqrt(0.5) * perceptualRoughnessBeckmann;
}

real GGXRoughnessToBeckmannRoughness(real roughnessGGX)
{
    return 2.0 * roughnessGGX;
}

real PerceptualRoughnessToPerceptualSmoothness(real perceptualRoughness)
{
    return (1.0 - perceptualRoughness);
}

// WARNING: this has been deprecated, and should not be used!
// Using roughness values of 0 leads to INFs and NANs. The only sensible place to use the roughness
// value of 0 is IBL, so we do not modify the perceptual roughness which is used to select the MIP map level.
// Note: making the constant too small results in aliasing.
real ClampRoughnessForAnalyticalLights(real roughness)
{
    return max(roughness, 1.0 / 1024.0);
}

// Given that the GGX model is invalid for a roughness of 0.0. This values have been experimentally evaluated to be the limit for the roughness
// for integration.
real ClampRoughnessForRaytracing(real roughness)
{
    return max(roughness, 0.001225);
}
real ClampPerceptualRoughnessForRaytracing(real perceptualRoughness)
{
    return max(perceptualRoughness, 0.035);
}

void ConvertValueAnisotropyToValueTB(real value, real anisotropy, out real valueT, out real valueB)
{
    // Use the parametrization of Sony Imageworks.
    // Ref: Revisiting Physically Based Shading at Imageworks, p. 15.
    valueT = value * (1 + anisotropy);
    valueB = value * (1 - anisotropy);
}

void ConvertAnisotropyToRoughness(real perceptualRoughness, real anisotropy, out real roughnessT, out real roughnessB)
{
    real roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
    ConvertValueAnisotropyToValueTB(roughness, anisotropy, roughnessT, roughnessB);
}

void ConvertRoughnessTAndAnisotropyToRoughness(real roughnessT, real anisotropy, out real roughness)
{
    roughness = roughnessT / (1 + anisotropy);
}

void ConvertRoughnessToAnisotropy(real roughnessT, real roughnessB, out real anisotropy)
{
    anisotropy = ((roughnessT - roughnessB) / max(roughnessT + roughnessB, 0.0001));
}

// WARNING: this has been deprecated, and should not be used!
// Same as ConvertAnisotropyToRoughness but
// roughnessT and roughnessB are clamped, and are meant to be used with punctual and directional lights.
void ConvertAnisotropyToClampRoughness(real perceptualRoughness, real anisotropy, out real roughnessT, out real roughnessB)
{
    ConvertAnisotropyToRoughness(perceptualRoughness, anisotropy, roughnessT, roughnessB);

    roughnessT = ClampRoughnessForAnalyticalLights(roughnessT);
    roughnessB = ClampRoughnessForAnalyticalLights(roughnessB);
}

// Use with stack BRDF (clear coat / coat) - This only used same equation to convert from Blinn-Phong spec power to Beckmann roughness
real RoughnessToVariance(real roughness)
{
    return 2.0 / Sq(roughness) - 2.0;
}

real VarianceToRoughness(real variance)
{
    return sqrt(2.0 / (variance + 2.0));
}

// Normal Map Filtering - This must match HDRP\Editor\AssetProcessors\NormalMapFilteringTexturePostprocessor.cs - highestVarianceAllowed (TODO: Move in core)
#define NORMALMAP_HIGHEST_VARIANCE 0.03125

float DecodeVariance(float gradientW)
{
    return gradientW * NORMALMAP_HIGHEST_VARIANCE;
}

// Return modified perceptualSmoothness based on provided variance (get from GeometricNormalVariance + TextureNormalVariance)
float NormalFiltering(float perceptualSmoothness, float variance, float threshold)
{
    float roughness = PerceptualSmoothnessToRoughness(perceptualSmoothness);
    // Ref: Geometry into Shading - http://graphics.pixar.com/library/BumpRoughness/paper.pdf - equation (3)
    float squaredRoughness = saturate(roughness * roughness + min(2.0 * variance, threshold * threshold)); // threshold can be really low, square the value for easier control

    return RoughnessToPerceptualSmoothness(sqrt(squaredRoughness));
}

// Reference: Error Reduction and Simplification for Shading Anti-Aliasing
// Specular antialiasing for geometry-induced normal (and NDF) variations: Tokuyoshi / Kaplanyan et al.'s method.
// This is the deferred approximation, which works reasonably well so we keep it for forward too for now.
// screenSpaceVariance should be at most 0.5^2 = 0.25, as that corresponds to considering
// a gaussian pixel reconstruction kernel with a standard deviation of 0.5 of a pixel, thus 2 sigma covering the whole pixel.
float GeometricNormalVariance(float3 geometricNormalWS, float screenSpaceVariance)
{
    float3 deltaU = ddx(geometricNormalWS);
    float3 deltaV = ddy(geometricNormalWS);

    return screenSpaceVariance * (dot(deltaU, deltaU) + dot(deltaV, deltaV));
}

// Return modified perceptualSmoothness
float GeometricNormalFiltering(float perceptualSmoothness, float3 geometricNormalWS, float screenSpaceVariance, float threshold)
{
    float variance = GeometricNormalVariance(geometricNormalWS, screenSpaceVariance);
    return NormalFiltering(perceptualSmoothness, variance, threshold);
}

// Normal map filtering based on The Order : 1886 SIGGRAPH course notes implementation.
// Basically Toksvig with an intermediate single vMF lobe induced dispersion (Han et al. 2007)
//
// This returns 2 times the variance of the induced "mesoNDF" lobe (an NDF induced from a section of
// the normal map) from the level 0 mip normals covered by the "current texel".
//
// avgNormalLength gives the dispersion information for the covered normals.
//
// Note that hw filtering on the normal map should be trilinear to be conservative, while anisotropic
// risk underfiltering. Could also compute average normal on the fly with a proper normal map format,
// like Toksvig.
float TextureNormalVariance(float avgNormalLength)
{
    float variance = 0.0;

    if (avgNormalLength < 1.0)
    {
        float avgNormLen2 = avgNormalLength * avgNormalLength;
        float kappa = (3.0 * avgNormalLength - avgNormalLength * avgNormLen2) / (1.0 - avgNormLen2);

        // Ref: Frequency Domain Normal Map Filtering - http://www.cs.columbia.edu/cg/normalmap/normalmap.pdf (equation 21)
        // Relationship between between the standard deviation of a Gaussian distribution and the roughness parameter of a Beckmann distribution.
        // is roughness^2 = 2 variance    (note: variance is sigma^2)
        // (Ref: Filtering Distributions of Normals for Shading Antialiasing - Equation just after (14))
        // Relationship between gaussian lobe and vMF lobe is 2 * variance = 1 / (2 * kappa) = roughness^2
        // (Equation 36 of  Normal map filtering based on The Order : 1886 SIGGRAPH course notes implementation).
        // So to get variance we must use variance = 1 / (4 * kappa)
        variance = 0.25 / kappa;
    }

    return variance;
}

float TextureNormalFiltering(float perceptualSmoothness, float avgNormalLength, float threshold)
{
    float variance = TextureNormalVariance(avgNormalLength);
    return NormalFiltering(perceptualSmoothness, variance, threshold);
}

// ----------------------------------------------------------------------------
// Helper for Disney parametrization
// ----------------------------------------------------------------------------

float3 ComputeDiffuseColor(float3 baseColor, float metallic)
{
    return baseColor * (1.0 - metallic);
}

float3 ComputeFresnel0(float3 baseColor, float metallic, float dielectricF0)
{
    return lerp(dielectricF0.xxx, baseColor, metallic);
}

// ----------------------------------------------------------------------------
// Helper for normal blending
// ----------------------------------------------------------------------------

// ref https://www.gamedev.net/topic/678043-how-to-blend-world-space-normals/#entry5287707
// assume compositing in world space
// Note: Using vtxNormal = real3(0, 0, 1) give the BlendNormalRNM formulation.
// TODO: Untested
real3 BlendNormalWorldspaceRNM(real3 n1, real3 n2, real3 vtxNormal)
{
    // Build the shortest-arc quaternion
    real4 q = real4(cross(vtxNormal, n2), dot(vtxNormal, n2) + 1.0) / sqrt(2.0 * (dot(vtxNormal, n2) + 1));

    // Rotate the normal
    return n1 * (q.w * q.w - dot(q.xyz, q.xyz)) + 2 * q.xyz * dot(q.xyz, n1) + 2 * q.w * cross(q.xyz, n1);
}

// ref http://blog.selfshadow.com/publications/blending-in-detail/
// ref https://gist.github.com/selfshadow/8048308
// Reoriented Normal Mapping
// Blending when n1 and n2 are already 'unpacked' and normalised
// assume compositing in tangent space
real3 BlendNormalRNM(real3 n1, real3 n2)
{
    real3 t = n1.xyz + real3(0.0, 0.0, 1.0);
    real3 u = n2.xyz * real3(-1.0, -1.0, 1.0);
    real3 r = (t / t.z) * dot(t, u) - u;
    return r;
}

// assume compositing in tangent space
real3 BlendNormal(real3 n1, real3 n2)
{
    return normalize(real3(n1.xy * n2.z + n2.xy * n1.z, n1.z * n2.z));
}

// ----------------------------------------------------------------------------
// Helper for triplanar
// ----------------------------------------------------------------------------

// Ref: http://http.developer.nvidia.com/GPUGems3/gpugems3_ch01.html / http://www.slideshare.net/icastano/cascades-demo-secrets
real3 ComputeTriplanarWeights(real3 normal)
{
    // Determine the blend weights for the 3 planar projections.
    real3 blendWeights = abs(normal);
    // Tighten up the blending zone
    blendWeights = (blendWeights - 0.2);
    blendWeights = blendWeights * blendWeights * blendWeights; // pow(blendWeights, 3);
    // Force weights to sum to 1.0 (very important!)
    blendWeights = max(blendWeights, real3(0.0, 0.0, 0.0));
    blendWeights /= dot(blendWeights, 1.0);

    return blendWeights;
}

// Planar/Triplanar convention for Unity in world space
void GetTriplanarCoordinate(float3 position, out float2 uvXZ, out float2 uvXY, out float2 uvZY)
{
    // Caution: This must follow the same rule as what is use for SurfaceGradient triplanar
    // TODO: Currently the normal mapping looks wrong without SURFACE_GRADIENT option because we don't handle corretly the tangent space
    uvXZ = float2(position.x, position.z);
    uvXY = float2(position.x, position.y);
    uvZY = float2(position.z, position.y);
}

// ----------------------------------------------------------------------------
// Helper for detail map operation
// ----------------------------------------------------------------------------

real LerpWhiteTo(real b, real t)
{
    real oneMinusT = 1.0 - t;
    return oneMinusT + b * t;
}

real3 LerpWhiteTo(real3 b, real t)
{
    real oneMinusT = 1.0 - t;
    return real3(oneMinusT, oneMinusT, oneMinusT) + b * t;
}

#endif // UNITY_COMMON_MATERIAL_INCLUDED

// File end: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/CommonMaterial.hlsl
//================================================================================================================================



//================================================================================================================================
// File start: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/BSDF.hlsl


#ifndef UNITY_BSDF_INCLUDED
#define UNITY_BSDF_INCLUDED

//================================================================================================================================
// File start: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/Color.hlsl


#ifndef UNITY_COLOR_INCLUDED
#define UNITY_COLOR_INCLUDED

//================================================================================================================================
// File start: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/ACES.hlsl


#ifndef __ACES__
#define __ACES__

/**
 * https://github.com/ampas/aces-dev
 *
 * Academy Color Encoding System (ACES) software and tools are provided by the
 * Academy under the following terms and conditions: A worldwide, royalty-free,
 * non-exclusive right to copy, modify, create derivatives, and use, in source and
 * binary forms, is hereby granted, subject to acceptance of this license.
 *
 * Copyright 2015 Academy of Motion Picture Arts and Sciences (A.M.P.A.S.).
 * Portions contributed by others as indicated. All rights reserved.
 *
 * Performance of any of the aforementioned acts indicates acceptance to be bound
 * by the following terms and conditions:
 *
 * * Copies of source code, in whole or in part, must retain the above copyright
 * notice, this list of conditions and the Disclaimer of Warranty.
 *
 * * Use in binary form must retain the above copyright notice, this list of
 * conditions and the Disclaimer of Warranty in the documentation and/or other
 * materials provided with the distribution.
 *
 * * Nothing in this license shall be deemed to grant any rights to trademarks,
 * copyrights, patents, trade secrets or any other intellectual property of
 * A.M.P.A.S. or any contributors, except as expressly stated herein.
 *
 * * Neither the name "A.M.P.A.S." nor the name of any other contributors to this
 * software may be used to endorse or promote products derivative of or based on
 * this software without express prior written permission of A.M.P.A.S. or the
 * contributors, as appropriate.
 *
 * This license shall be construed pursuant to the laws of the State of
 * California, and any disputes related thereto shall be subject to the
 * jurisdiction of the courts therein.
 *
 * Disclaimer of Warranty: THIS SOFTWARE IS PROVIDED BY A.M.P.A.S. AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND
 * NON-INFRINGEMENT ARE DISCLAIMED. IN NO EVENT SHALL A.M.P.A.S., OR ANY
 * CONTRIBUTORS OR DISTRIBUTORS, BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, RESITUTIONARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * WITHOUT LIMITING THE GENERALITY OF THE FOREGOING, THE ACADEMY SPECIFICALLY
 * DISCLAIMS ANY REPRESENTATIONS OR WARRANTIES WHATSOEVER RELATED TO PATENT OR
 * OTHER INTELLECTUAL PROPERTY RIGHTS IN THE ACADEMY COLOR ENCODING SYSTEM, OR
 * APPLICATIONS THEREOF, HELD BY PARTIES OTHER THAN A.M.P.A.S.,WHETHER DISCLOSED OR
 * UNDISCLOSED.
 */

//================================================================================================================================
// WARNING: File not found: Common.hlsl
//================================================================================================================================


#define ACEScc_MAX      1.4679964
#define ACEScc_MIDGRAY  0.4135884

//
// Precomputed matrices (pre-transposed)
// See https://github.com/ampas/aces-dev/blob/master/transforms/ctl/README-MATRIX.md
//
static const half3x3 sRGB_2_AP0 = {
    0.4397010, 0.3829780, 0.1773350,
    0.0897923, 0.8134230, 0.0967616,
    0.0175440, 0.1115440, 0.8707040
};

static const half3x3 sRGB_2_AP1 = {
    0.61319, 0.33951, 0.04737,
    0.07021, 0.91634, 0.01345,
    0.02062, 0.10957, 0.86961
};

static const half3x3 AP0_2_sRGB = {
    2.52169, -1.13413, -0.38756,
    -0.27648, 1.37272, -0.09624,
    -0.01538, -0.15298, 1.16835,
};

static const half3x3 AP1_2_sRGB = {
    1.70505, -0.62179, -0.08326,
    -0.13026, 1.14080, -0.01055,
    -0.02400, -0.12897, 1.15297,
};

static const half3x3 AP0_2_AP1_MAT = {
     1.4514393161, -0.2365107469, -0.2149285693,
    -0.0765537734,  1.1762296998, -0.0996759264,
     0.0083161484, -0.0060324498,  0.9977163014
};

static const half3x3 AP1_2_AP0_MAT = {
     0.6954522414, 0.1406786965, 0.1638690622,
     0.0447945634, 0.8596711185, 0.0955343182,
    -0.0055258826, 0.0040252103, 1.0015006723
};

static const half3x3 AP1_2_XYZ_MAT = {
     0.6624541811, 0.1340042065, 0.1561876870,
     0.2722287168, 0.6740817658, 0.0536895174,
    -0.0055746495, 0.0040607335, 1.0103391003
};

static const half3x3 XYZ_2_AP1_MAT = {
     1.6410233797, -0.3248032942, -0.2364246952,
    -0.6636628587,  1.6153315917,  0.0167563477,
     0.0117218943, -0.0082844420,  0.9883948585
};

static const half3x3 XYZ_2_REC709_MAT = {
     3.2409699419, -1.5373831776, -0.4986107603,
    -0.9692436363,  1.8759675015,  0.0415550574,
     0.0556300797, -0.2039769589,  1.0569715142
};

static const half3x3 XYZ_2_REC2020_MAT = {
     1.7166511880, -0.3556707838, -0.2533662814,
    -0.6666843518,  1.6164812366,  0.0157685458,
     0.0176398574, -0.0427706133,  0.9421031212
};

static const half3x3 XYZ_2_DCIP3_MAT = {
     2.7253940305, -1.0180030062, -0.4401631952,
    -0.7951680258,  1.6897320548,  0.0226471906,
     0.0412418914, -0.0876390192,  1.1009293786
};

static const half3 AP1_RGB2Y = half3(0.272229, 0.674082, 0.0536895);

static const half3x3 RRT_SAT_MAT = {
    0.9708890, 0.0269633, 0.00214758,
    0.0108892, 0.9869630, 0.00214758,
    0.0108892, 0.0269633, 0.96214800
};

static const half3x3 ODT_SAT_MAT = {
    0.949056, 0.0471857, 0.00375827,
    0.019056, 0.9771860, 0.00375827,
    0.019056, 0.0471857, 0.93375800
};

static const half3x3 D60_2_D65_CAT = {
     0.98722400, -0.00611327, 0.0159533,
    -0.00759836,  1.00186000, 0.0053302,
     0.00307257, -0.00509595, 1.0816800
};

//
// Unity to ACES
//
// converts Unity raw (sRGB primaries) to
//          ACES2065-1 (AP0 w/ linear encoding)
//
half3 unity_to_ACES(half3 x)
{
    x = mul(sRGB_2_AP0, x);
    return x;
}

//
// ACES to Unity
//
// converts ACES2065-1 (AP0 w/ linear encoding)
//          Unity raw (sRGB primaries) to
//
half3 ACES_to_unity(half3 x)
{
    x = mul(AP0_2_sRGB, x);
    return x;
}

//
// Unity to ACEScg
//
// converts Unity raw (sRGB primaries) to
//          ACEScg (AP1 w/ linear encoding)
//
half3 unity_to_ACEScg(half3 x)
{
    x = mul(sRGB_2_AP1, x);
    return x;
}

//
// ACEScg to Unity
//
// converts ACEScg (AP1 w/ linear encoding) to
//          Unity raw (sRGB primaries)
//
half3 ACEScg_to_unity(half3 x)
{
    x = mul(AP1_2_sRGB, x);
    return x;
}

//
// ACES Color Space Conversion - ACES to ACEScc
//
// converts ACES2065-1 (AP0 w/ linear encoding) to
//          ACEScc (AP1 w/ logarithmic encoding)
//
// This transform follows the formulas from section 4.4 in S-2014-003
//
half ACES_to_ACEScc(half x)
{
    if (x <= 0.0)
        return -0.35828683; // = (log2(pow(2.0, -15.0) * 0.5) + 9.72) / 17.52
    else if (x < pow(2.0, -15.0))
        return (log2(pow(2.0, -16.0) + x * 0.5) + 9.72) / 17.52;
    else // (x >= pow(2.0, -15.0))
        return (log2(x) + 9.72) / 17.52;
}

half3 ACES_to_ACEScc(half3 x)
{
    x = clamp(x, 0.0, HALF_MAX);

    // x is clamped to [0, HALF_MAX], skip the <= 0 check
    return (x < 0.00003051757) ? (log2(0.00001525878 + x * 0.5) + 9.72) / 17.52 : (log2(x) + 9.72) / 17.52;

    /*
    return half3(
        ACES_to_ACEScc(x.r),
        ACES_to_ACEScc(x.g),
        ACES_to_ACEScc(x.b)
    );
    */
}

//
// ACES Color Space Conversion - ACEScc to ACES
//
// converts ACEScc (AP1 w/ ACESlog encoding) to
//          ACES2065-1 (AP0 w/ linear encoding)
//
// This transform follows the formulas from section 4.4 in S-2014-003
//
half ACEScc_to_ACES(half x)
{
    // TODO: Optimize me
    if (x < -0.3013698630) // (9.72 - 15) / 17.52
        return (pow(2.0, x * 17.52 - 9.72) - pow(2.0, -16.0)) * 2.0;
    else if (x < (log2(HALF_MAX) + 9.72) / 17.52)
        return pow(2.0, x * 17.52 - 9.72);
    else // (x >= (log2(HALF_MAX) + 9.72) / 17.52)
        return HALF_MAX;
}

half3 ACEScc_to_ACES(half3 x)
{
    return half3(
        ACEScc_to_ACES(x.r),
        ACEScc_to_ACES(x.g),
        ACEScc_to_ACES(x.b)
    );
}

//
// ACES Color Space Conversion - ACES to ACEScg
//
// converts ACES2065-1 (AP0 w/ linear encoding) to
//          ACEScg (AP1 w/ linear encoding)
//
half3 ACES_to_ACEScg(half3 x)
{
    return mul(AP0_2_AP1_MAT, x);
}

//
// ACES Color Space Conversion - ACEScg to ACES
//
// converts ACEScg (AP1 w/ linear encoding) to
//          ACES2065-1 (AP0 w/ linear encoding)
//
half3 ACEScg_to_ACES(half3 x)
{
    return mul(AP1_2_AP0_MAT, x);
}

//
// Reference Rendering Transform (RRT)
//
//   Input is ACES
//   Output is OCES
//
half rgb_2_saturation(half3 rgb)
{
    const half TINY = 1e-4;
    half mi = Min3(rgb.r, rgb.g, rgb.b);
    half ma = Max3(rgb.r, rgb.g, rgb.b);
    return (max(ma, TINY) - max(mi, TINY)) / max(ma, 1e-2);
}

half rgb_2_yc(half3 rgb)
{
    const half ycRadiusWeight = 1.75;

    // Converts RGB to a luminance proxy, here called YC
    // YC is ~ Y + K * Chroma
    // Constant YC is a cone-shaped surface in RGB space, with the tip on the
    // neutral axis, towards white.
    // YC is normalized: RGB 1 1 1 maps to YC = 1
    //
    // ycRadiusWeight defaults to 1.75, although can be overridden in function
    // call to rgb_2_yc
    // ycRadiusWeight = 1 -> YC for pure cyan, magenta, yellow == YC for neutral
    // of same value
    // ycRadiusWeight = 2 -> YC for pure red, green, blue  == YC for  neutral of
    // same value.

    half r = rgb.x;
    half g = rgb.y;
    half b = rgb.z;
    half k = b * (b - g) + g * (g - r) + r * (r - b);
#if defined(SHADER_API_SWITCH)
    half chroma = k == 0.0 ? 0.0 : sqrt(k); // Fix NaN on Nintendo Switch (should not happen in theory).
#else
    half chroma = sqrt(k);
#endif
    return (b + g + r + ycRadiusWeight * chroma) / 3.0;
}

half rgb_2_hue(half3 rgb)
{
    // Returns a geometric hue angle in degrees (0-360) based on RGB values.
    // For neutral colors, hue is undefined and the function will return a quiet NaN value.
    half hue;
    if (rgb.x == rgb.y && rgb.y == rgb.z)
        hue = 0.0; // RGB triplets where RGB are equal have an undefined hue
    else
        hue = (180.0 / PI) * atan2(sqrt(3.0) * (rgb.y - rgb.z), 2.0 * rgb.x - rgb.y - rgb.z);

    if (hue < 0.0) hue = hue + 360.0;

    return hue;
}

half center_hue(half hue, half centerH)
{
    half hueCentered = hue - centerH;
    if (hueCentered < -180.0) hueCentered = hueCentered + 360.0;
    else if (hueCentered > 180.0) hueCentered = hueCentered - 360.0;
    return hueCentered;
}

half sigmoid_shaper(half x)
{
    // Sigmoid function in the range 0 to 1 spanning -2 to +2.

    half t = max(1.0 - abs(x / 2.0), 0.0);
    half y = 1.0 + FastSign(x) * (1.0 - t * t);

    return y / 2.0;
}

half glow_fwd(half ycIn, half glowGainIn, half glowMid)
{
    half glowGainOut;

    if (ycIn <= 2.0 / 3.0 * glowMid)
        glowGainOut = glowGainIn;
    else if (ycIn >= 2.0 * glowMid)
        glowGainOut = 0.0;
    else
        glowGainOut = glowGainIn * (glowMid / ycIn - 1.0 / 2.0);

    return glowGainOut;
}

/*
half cubic_basis_shaper
(
    half x,
    half w   // full base width of the shaper function (in degrees)
)
{
    half M[4][4] = {
        { -1.0 / 6,  3.0 / 6, -3.0 / 6,  1.0 / 6 },
        {  3.0 / 6, -6.0 / 6,  3.0 / 6,  0.0 / 6 },
        { -3.0 / 6,  0.0 / 6,  3.0 / 6,  0.0 / 6 },
        {  1.0 / 6,  4.0 / 6,  1.0 / 6,  0.0 / 6 }
    };

    half knots[5] = {
        -w / 2.0,
        -w / 4.0,
             0.0,
         w / 4.0,
         w / 2.0
    };

    half y = 0.0;
    if ((x > knots[0]) && (x < knots[4]))
    {
        half knot_coord = (x - knots[0]) * 4.0 / w;
        int j = knot_coord;
        half t = knot_coord - j;

        half monomials[4] = { t*t*t, t*t, t, 1.0 };

        // (if/else structure required for compatibility with CTL < v1.5.)
        if (j == 3)
        {
            y = monomials[0] * M[0][0] + monomials[1] * M[1][0] +
                monomials[2] * M[2][0] + monomials[3] * M[3][0];
        }
        else if (j == 2)
        {
            y = monomials[0] * M[0][1] + monomials[1] * M[1][1] +
                monomials[2] * M[2][1] + monomials[3] * M[3][1];
        }
        else if (j == 1)
        {
            y = monomials[0] * M[0][2] + monomials[1] * M[1][2] +
                monomials[2] * M[2][2] + monomials[3] * M[3][2];
        }
        else if (j == 0)
        {
            y = monomials[0] * M[0][3] + monomials[1] * M[1][3] +
                monomials[2] * M[2][3] + monomials[3] * M[3][3];
        }
        else
        {
            y = 0.0;
        }
    }

    return y * 3.0 / 2.0;
}
*/

static const half3x3 M = {
     0.5, -1.0, 0.5,
    -1.0,  1.0, 0.0,
     0.5,  0.5, 0.0
};

half segmented_spline_c5_fwd(half x)
{
    const half coefsLow[6] = { -4.0000000000, -4.0000000000, -3.1573765773, -0.4852499958, 1.8477324706, 1.8477324706 }; // coefs for B-spline between minPoint and midPoint (units of log luminance)
    const half coefsHigh[6] = { -0.7185482425, 2.0810307172, 3.6681241237, 4.0000000000, 4.0000000000, 4.0000000000 }; // coefs for B-spline between midPoint and maxPoint (units of log luminance)
    const half2 minPoint = half2(0.18 * exp2(-15.0), 0.0001); // {luminance, luminance} linear extension below this
    const half2 midPoint = half2(0.18, 0.48); // {luminance, luminance}
    const half2 maxPoint = half2(0.18 * exp2(18.0), 10000.0); // {luminance, luminance} linear extension above this
    const half slopeLow = 0.0; // log-log slope of low linear extension
    const half slopeHigh = 0.0; // log-log slope of high linear extension

    const int N_KNOTS_LOW = 4;
    const int N_KNOTS_HIGH = 4;

    // Check for negatives or zero before taking the log. If negative or zero,
    // set to ACESMIN.1
    float xCheck = x;
    if (xCheck <= 0.0) xCheck = 0.00006103515; // = pow(2.0, -14.0);

    half logx = log10(xCheck);
    half logy;

    if (logx <= log10(minPoint.x))
    {
        logy = logx * slopeLow + (log10(minPoint.y) - slopeLow * log10(minPoint.x));
    }
    else if ((logx > log10(minPoint.x)) && (logx < log10(midPoint.x)))
    {
        half knot_coord = (N_KNOTS_LOW - 1) * (logx - log10(minPoint.x)) / (log10(midPoint.x) - log10(minPoint.x));
        int j = knot_coord;
        half t = knot_coord - j;

        half3 cf = half3(coefsLow[j], coefsLow[j + 1], coefsLow[j + 2]);
        half3 monomials = half3(t * t, t, 1.0);
        logy = dot(monomials, mul(M, cf));
    }
    else if ((logx >= log10(midPoint.x)) && (logx < log10(maxPoint.x)))
    {
        half knot_coord = (N_KNOTS_HIGH - 1) * (logx - log10(midPoint.x)) / (log10(maxPoint.x) - log10(midPoint.x));
        int j = knot_coord;
        half t = knot_coord - j;

        half3 cf = half3(coefsHigh[j], coefsHigh[j + 1], coefsHigh[j + 2]);
        half3 monomials = half3(t * t, t, 1.0);
        logy = dot(monomials, mul(M, cf));
    }
    else
    { //if (logIn >= log10(maxPoint.x)) {
        logy = logx * slopeHigh + (log10(maxPoint.y) - slopeHigh * log10(maxPoint.x));
    }

    return pow(10.0, logy);
}

half segmented_spline_c9_fwd(half x)
{
    const half coefsLow[10] = { -1.6989700043, -1.6989700043, -1.4779000000, -1.2291000000, -0.8648000000, -0.4480000000, 0.0051800000, 0.4511080334, 0.9113744414, 0.9113744414 }; // coefs for B-spline between minPoint and midPoint (units of log luminance)
    const half coefsHigh[10] = { 0.5154386965, 0.8470437783, 1.1358000000, 1.3802000000, 1.5197000000, 1.5985000000, 1.6467000000, 1.6746091357, 1.6878733390, 1.6878733390 }; // coefs for B-spline between midPoint and maxPoint (units of log luminance)
    const half2 minPoint = half2(segmented_spline_c5_fwd(0.18 * exp2(-6.5)), 0.02); // {luminance, luminance} linear extension below this
    const half2 midPoint = half2(segmented_spline_c5_fwd(0.18), 4.8); // {luminance, luminance}
    const half2 maxPoint = half2(segmented_spline_c5_fwd(0.18 * exp2(6.5)), 48.0); // {luminance, luminance} linear extension above this
    const half slopeLow = 0.0; // log-log slope of low linear extension
    const half slopeHigh = 0.04; // log-log slope of high linear extension

    const int N_KNOTS_LOW = 8;
    const int N_KNOTS_HIGH = 8;

    // Check for negatives or zero before taking the log. If negative or zero,
    // set to OCESMIN.
    half xCheck = x;
    if (xCheck <= 0.0) xCheck = 1e-4;

    half logx = log10(xCheck);
    half logy;

    if (logx <= log10(minPoint.x))
    {
        logy = logx * slopeLow + (log10(minPoint.y) - slopeLow * log10(minPoint.x));
    }
    else if ((logx > log10(minPoint.x)) && (logx < log10(midPoint.x)))
    {
        half knot_coord = (N_KNOTS_LOW - 1) * (logx - log10(minPoint.x)) / (log10(midPoint.x) - log10(minPoint.x));
        int j = knot_coord;
        half t = knot_coord - j;

        half3 cf = half3(coefsLow[j], coefsLow[j + 1], coefsLow[j + 2]);
        half3 monomials = half3(t * t, t, 1.0);
        logy = dot(monomials, mul(M, cf));
    }
    else if ((logx >= log10(midPoint.x)) && (logx < log10(maxPoint.x)))
    {
        half knot_coord = (N_KNOTS_HIGH - 1) * (logx - log10(midPoint.x)) / (log10(maxPoint.x) - log10(midPoint.x));
        int j = knot_coord;
        half t = knot_coord - j;

        half3 cf = half3(coefsHigh[j], coefsHigh[j + 1], coefsHigh[j + 2]);
        half3 monomials = half3(t * t, t, 1.0);
        logy = dot(monomials, mul(M, cf));
    }
    else
    { //if (logIn >= log10(maxPoint.x)) {
        logy = logx * slopeHigh + (log10(maxPoint.y) - slopeHigh * log10(maxPoint.x));
    }

    return pow(10.0, logy);
}

static const half RRT_GLOW_GAIN = 0.05;
static const half RRT_GLOW_MID = 0.08;

static const half RRT_RED_SCALE = 0.82;
static const half RRT_RED_PIVOT = 0.03;
static const half RRT_RED_HUE = 0.0;
static const half RRT_RED_WIDTH = 135.0;

static const half RRT_SAT_FACTOR = 0.96;

half3 RRT(half3 aces)
{
    // --- Glow module --- //
    half saturation = rgb_2_saturation(aces);
    half ycIn = rgb_2_yc(aces);
    half s = sigmoid_shaper((saturation - 0.4) / 0.2);
    half addedGlow = 1.0 + glow_fwd(ycIn, RRT_GLOW_GAIN * s, RRT_GLOW_MID);
    aces *= addedGlow;

    // --- Red modifier --- //
    half hue = rgb_2_hue(aces);
    half centeredHue = center_hue(hue, RRT_RED_HUE);
    half hueWeight;
    {
        //hueWeight = cubic_basis_shaper(centeredHue, RRT_RED_WIDTH);
        hueWeight = smoothstep(0.0, 1.0, 1.0 - abs(2.0 * centeredHue / RRT_RED_WIDTH));
        hueWeight *= hueWeight;
    }

    aces.r += hueWeight * saturation * (RRT_RED_PIVOT - aces.r) * (1.0 - RRT_RED_SCALE);

    // --- ACES to RGB rendering space --- //
    aces = clamp(aces, 0.0, HALF_MAX);  // avoids saturated negative colors from becoming positive in the matrix
    half3 rgbPre = mul(AP0_2_AP1_MAT, aces);
    rgbPre = clamp(rgbPre, 0, HALF_MAX);

    // --- Global desaturation --- //
    //rgbPre = mul(RRT_SAT_MAT, rgbPre);
    rgbPre = lerp(dot(rgbPre, AP1_RGB2Y).xxx, rgbPre, RRT_SAT_FACTOR.xxx);

    // --- Apply the tonescale independently in rendering-space RGB --- //
    half3 rgbPost;
    rgbPost.x = segmented_spline_c5_fwd(rgbPre.x);
    rgbPost.y = segmented_spline_c5_fwd(rgbPre.y);
    rgbPost.z = segmented_spline_c5_fwd(rgbPre.z);

    // --- RGB rendering space to OCES --- //
    half3 rgbOces = mul(AP1_2_AP0_MAT, rgbPost);

    return rgbOces;
}

//
// Output Device Transform
//
half3 Y_2_linCV(half3 Y, half Ymax, half Ymin)
{
    return (Y - Ymin) / (Ymax - Ymin);
}

half3 XYZ_2_xyY(half3 XYZ)
{
    half divisor = max(dot(XYZ, (1.0).xxx), 1e-4);
    return half3(XYZ.xy / divisor, XYZ.y);
}

half3 xyY_2_XYZ(half3 xyY)
{
    half m = xyY.z / max(xyY.y, 1e-4);
    half3 XYZ = half3(xyY.xz, (1.0 - xyY.x - xyY.y));
    XYZ.xz *= m;
    return XYZ;
}

static const half DIM_SURROUND_GAMMA = 0.9811;

half3 darkSurround_to_dimSurround(half3 linearCV)
{
    half3 XYZ = mul(AP1_2_XYZ_MAT, linearCV);

    half3 xyY = XYZ_2_xyY(XYZ);
    xyY.z = clamp(xyY.z, 0.0, HALF_MAX);
    xyY.z = pow(xyY.z, DIM_SURROUND_GAMMA);
    XYZ = xyY_2_XYZ(xyY);

    return mul(XYZ_2_AP1_MAT, XYZ);
}

half moncurve_r(half y, half gamma, half offs)
{
    // Reverse monitor curve
    half x;
    const half yb = pow(offs * gamma / ((gamma - 1.0) * (1.0 + offs)), gamma);
    const half rs = pow((gamma - 1.0) / offs, gamma - 1.0) * pow((1.0 + offs) / gamma, gamma);
    if (y >= yb)
        x = (1.0 + offs) * pow(y, 1.0 / gamma) - offs;
    else
        x = y * rs;
    return x;
}

half bt1886_r(half L, half gamma, half Lw, half Lb)
{
    // The reference EOTF specified in Rec. ITU-R BT.1886
    // L = a(max[(V+b),0])^g
    half a = pow(pow(Lw, 1.0 / gamma) - pow(Lb, 1.0 / gamma), gamma);
    half b = pow(Lb, 1.0 / gamma) / (pow(Lw, 1.0 / gamma) - pow(Lb, 1.0 / gamma));
    half V = pow(max(L / a, 0.0), 1.0 / gamma) - b;
    return V;
}

half roll_white_fwd(
    half x,       // color value to adjust (white scaled to around 1.0)
    half new_wht, // white adjustment (e.g. 0.9 for 10% darkening)
    half width    // adjusted width (e.g. 0.25 for top quarter of the tone scale)
    )
{
    const half x0 = -1.0;
    const half x1 = x0 + width;
    const half y0 = -new_wht;
    const half y1 = x1;
    const half m1 = (x1 - x0);
    const half a = y0 - y1 + m1;
    const half b = 2.0 * (y1 - y0) - m1;
    const half c = y0;
    const half t = (-x - x0) / (x1 - x0);
    half o = 0.0;
    if (t < 0.0)
        o = -(t * b + c);
    else if (t > 1.0)
        o = x;
    else
        o = -((t * a + b) * t + c);
    return o;
}

half3 linear_to_sRGB(half3 x)
{
    return (x <= 0.0031308 ? (x * 12.9232102) : 1.055 * pow(x, 1.0 / 2.4) - 0.055);
}

half3 linear_to_bt1886(half3 x, half gamma, half Lw, half Lb)
{
    // Good enough approximation for now, may consider using the exact formula instead
    // TODO: Experiment
    return pow(max(x, 0.0), 1.0 / 2.4);

    // Correct implementation (Reference EOTF specified in Rec. ITU-R BT.1886) :
    // L = a(max[(V+b),0])^g
    half invgamma = 1.0 / gamma;
    half p_Lw = pow(Lw, invgamma);
    half p_Lb = pow(Lb, invgamma);
    half3 a = pow(p_Lw - p_Lb, gamma).xxx;
    half3 b = (p_Lb / p_Lw - p_Lb).xxx;
    half3 V = pow(max(x / a, 0.0), invgamma.xxx) - b;
    return V;
}

static const half CINEMA_WHITE = 48.0;
static const half CINEMA_BLACK = CINEMA_WHITE / 2400.0;
static const half ODT_SAT_FACTOR = 0.93;

// <ACEStransformID>ODT.Academy.RGBmonitor_100nits_dim.a1.0.3</ACEStransformID>
// <ACESuserName>ACES 1.0 Output - sRGB</ACESuserName>

//
// Output Device Transform - RGB computer monitor
//

//
// Summary :
//  This transform is intended for mapping OCES onto a desktop computer monitor
//  typical of those used in motion picture visual effects production. These
//  monitors may occasionally be referred to as "sRGB" displays, however, the
//  monitor for which this transform is designed does not exactly match the
//  specifications in IEC 61966-2-1:1999.
//
//  The assumed observer adapted white is D65, and the viewing environment is
//  that of a dim surround.
//
//  The monitor specified is intended to be more typical of those found in
//  visual effects production.
//
// Device Primaries :
//  Primaries are those specified in Rec. ITU-R BT.709
//  CIE 1931 chromaticities:  x         y         Y
//              Red:          0.64      0.33
//              Green:        0.3       0.6
//              Blue:         0.15      0.06
//              White:        0.3127    0.329     100 cd/m^2
//
// Display EOTF :
//  The reference electro-optical transfer function specified in
//  IEC 61966-2-1:1999.
//
// Signal Range:
//    This transform outputs full range code values.
//
// Assumed observer adapted white point:
//         CIE 1931 chromaticities:    x            y
//                                     0.3127       0.329
//
// Viewing Environment:
//   This ODT has a compensation for viewing environment variables more typical
//   of those associated with video mastering.
//
half3 ODT_RGBmonitor_100nits_dim(half3 oces)
{
    // OCES to RGB rendering space
    half3 rgbPre = mul(AP0_2_AP1_MAT, oces);

    // Apply the tonescale independently in rendering-space RGB
    half3 rgbPost;
    rgbPost.x = segmented_spline_c9_fwd(rgbPre.x);
    rgbPost.y = segmented_spline_c9_fwd(rgbPre.y);
    rgbPost.z = segmented_spline_c9_fwd(rgbPre.z);

    // Scale luminance to linear code value
    half3 linearCV = Y_2_linCV(rgbPost, CINEMA_WHITE, CINEMA_BLACK);

     // Apply gamma adjustment to compensate for dim surround
    linearCV = darkSurround_to_dimSurround(linearCV);

    // Apply desaturation to compensate for luminance difference
    //linearCV = mul(ODT_SAT_MAT, linearCV);
    linearCV = lerp(dot(linearCV, AP1_RGB2Y).xxx, linearCV, ODT_SAT_FACTOR.xxx);

    // Convert to display primary encoding
    // Rendering space RGB to XYZ
    half3 XYZ = mul(AP1_2_XYZ_MAT, linearCV);

    // Apply CAT from ACES white point to assumed observer adapted white point
    XYZ = mul(D60_2_D65_CAT, XYZ);

    // CIE XYZ to display primaries
    linearCV = mul(XYZ_2_REC709_MAT, XYZ);

    // Handle out-of-gamut values
    // Clip values < 0 or > 1 (i.e. projecting outside the display primaries)
    linearCV = saturate(linearCV);

    // TODO: Revisit when it is possible to deactivate Unity default framebuffer encoding
    // with sRGB opto-electrical transfer function (OETF).
    /*
    // Encode linear code values with transfer function
    half3 outputCV;
    // moncurve_r with gamma of 2.4 and offset of 0.055 matches the EOTF found in IEC 61966-2-1:1999 (sRGB)
    const half DISPGAMMA = 2.4;
    const half OFFSET = 0.055;
    outputCV.x = moncurve_r(linearCV.x, DISPGAMMA, OFFSET);
    outputCV.y = moncurve_r(linearCV.y, DISPGAMMA, OFFSET);
    outputCV.z = moncurve_r(linearCV.z, DISPGAMMA, OFFSET);

    outputCV = linear_to_sRGB(linearCV);
    */

    // Unity already draws to a sRGB target
    return linearCV;
}

// <ACEStransformID>ODT.Academy.RGBmonitor_D60sim_100nits_dim.a1.0.3</ACEStransformID>
// <ACESuserName>ACES 1.0 Output - sRGB (D60 sim.)</ACESuserName>

//
// Output Device Transform - RGB computer monitor (D60 simulation)
//

//
// Summary :
//  This transform is intended for mapping OCES onto a desktop computer monitor
//  typical of those used in motion picture visual effects production. These
//  monitors may occasionally be referred to as "sRGB" displays, however, the
//  monitor for which this transform is designed does not exactly match the
//  specifications in IEC 61966-2-1:1999.
//
//  The assumed observer adapted white is D60, and the viewing environment is
//  that of a dim surround.
//
//  The monitor specified is intended to be more typical of those found in
//  visual effects production.
//
// Device Primaries :
//  Primaries are those specified in Rec. ITU-R BT.709
//  CIE 1931 chromaticities:  x         y         Y
//              Red:          0.64      0.33
//              Green:        0.3       0.6
//              Blue:         0.15      0.06
//              White:        0.3127    0.329     100 cd/m^2
//
// Display EOTF :
//  The reference electro-optical transfer function specified in
//  IEC 61966-2-1:1999.
//
// Signal Range:
//    This transform outputs full range code values.
//
// Assumed observer adapted white point:
//         CIE 1931 chromaticities:    x            y
//                                     0.32168      0.33767
//
// Viewing Environment:
//   This ODT has a compensation for viewing environment variables more typical
//   of those associated with video mastering.
//
half3 ODT_RGBmonitor_D60sim_100nits_dim(half3 oces)
{
    // OCES to RGB rendering space
    half3 rgbPre = mul(AP0_2_AP1_MAT, oces);

    // Apply the tonescale independently in rendering-space RGB
    half3 rgbPost;
    rgbPost.x = segmented_spline_c9_fwd(rgbPre.x);
    rgbPost.y = segmented_spline_c9_fwd(rgbPre.y);
    rgbPost.z = segmented_spline_c9_fwd(rgbPre.z);

    // Scale luminance to linear code value
    half3 linearCV = Y_2_linCV(rgbPost, CINEMA_WHITE, CINEMA_BLACK);

    // --- Compensate for different white point being darker  --- //
    // This adjustment is to correct an issue that exists in ODTs where the device
    // is calibrated to a white chromaticity other than D60. In order to simulate
    // D60 on such devices, unequal code values are sent to the display to achieve
    // neutrals at D60. In order to produce D60 on a device calibrated to the DCI
    // white point (i.e. equal code values yield CIE x,y chromaticities of 0.314,
    // 0.351) the red channel is higher than green and blue to compensate for the
    // "greenish" DCI white. This is the correct behavior but it means that as
    // highlight increase, the red channel will hit the device maximum first and
    // clip, resulting in a chromaticity shift as the green and blue channels
    // continue to increase.
    // To avoid this clipping error, a slight scale factor is applied to allow the
    // ODTs to simulate D60 within the D65 calibration white point.

    // Scale and clamp white to avoid casted highlights due to D60 simulation
    const half SCALE = 0.955;
    linearCV = min(linearCV, 1.0) * SCALE;

    // Apply gamma adjustment to compensate for dim surround
    linearCV = darkSurround_to_dimSurround(linearCV);

    // Apply desaturation to compensate for luminance difference
    //linearCV = mul(ODT_SAT_MAT, linearCV);
    linearCV = lerp(dot(linearCV, AP1_RGB2Y).xxx, linearCV, ODT_SAT_FACTOR.xxx);

    // Convert to display primary encoding
    // Rendering space RGB to XYZ
    half3 XYZ = mul(AP1_2_XYZ_MAT, linearCV);

    // CIE XYZ to display primaries
    linearCV = mul(XYZ_2_REC709_MAT, XYZ);

    // Handle out-of-gamut values
    // Clip values < 0 or > 1 (i.e. projecting outside the display primaries)
    linearCV = saturate(linearCV);

    // TODO: Revisit when it is possible to deactivate Unity default framebuffer encoding
    // with sRGB opto-electrical transfer function (OETF).
    /*
    // Encode linear code values with transfer function
    half3 outputCV;
    // moncurve_r with gamma of 2.4 and offset of 0.055 matches the EOTF found in IEC 61966-2-1:1999 (sRGB)
    const half DISPGAMMA = 2.4;
    const half OFFSET = 0.055;
    outputCV.x = moncurve_r(linearCV.x, DISPGAMMA, OFFSET);
    outputCV.y = moncurve_r(linearCV.y, DISPGAMMA, OFFSET);
    outputCV.z = moncurve_r(linearCV.z, DISPGAMMA, OFFSET);

    outputCV = linear_to_sRGB(linearCV);
    */

    // Unity already draws to a sRGB target
    return linearCV;
}

// <ACEStransformID>ODT.Academy.Rec709_100nits_dim.a1.0.3</ACEStransformID>
// <ACESuserName>ACES 1.0 Output - Rec.709</ACESuserName>

//
// Output Device Transform - Rec709
//

//
// Summary :
//  This transform is intended for mapping OCES onto a Rec.709 broadcast monitor
//  that is calibrated to a D65 white point at 100 cd/m^2. The assumed observer
//  adapted white is D65, and the viewing environment is a dim surround.
//
//  A possible use case for this transform would be HDTV/video mastering.
//
// Device Primaries :
//  Primaries are those specified in Rec. ITU-R BT.709
//  CIE 1931 chromaticities:  x         y         Y
//              Red:          0.64      0.33
//              Green:        0.3       0.6
//              Blue:         0.15      0.06
//              White:        0.3127    0.329     100 cd/m^2
//
// Display EOTF :
//  The reference electro-optical transfer function specified in
//  Rec. ITU-R BT.1886.
//
// Signal Range:
//    By default, this transform outputs full range code values. If instead a
//    SMPTE "legal" signal is desired, there is a runtime flag to output
//    SMPTE legal signal. In ctlrender, this can be achieved by appending
//    '-param1 legalRange 1' after the '-ctl odt.ctl' string.
//
// Assumed observer adapted white point:
//         CIE 1931 chromaticities:    x            y
//                                     0.3127       0.329
//
// Viewing Environment:
//   This ODT has a compensation for viewing environment variables more typical
//   of those associated with video mastering.
//
half3 ODT_Rec709_100nits_dim(half3 oces)
{
    // OCES to RGB rendering space
    half3 rgbPre = mul(AP0_2_AP1_MAT, oces);

    // Apply the tonescale independently in rendering-space RGB
    half3 rgbPost;
    rgbPost.x = segmented_spline_c9_fwd(rgbPre.x);
    rgbPost.y = segmented_spline_c9_fwd(rgbPre.y);
    rgbPost.z = segmented_spline_c9_fwd(rgbPre.z);

    // Scale luminance to linear code value
    half3 linearCV = Y_2_linCV(rgbPost, CINEMA_WHITE, CINEMA_BLACK);

    // Apply gamma adjustment to compensate for dim surround
    linearCV = darkSurround_to_dimSurround(linearCV);

    // Apply desaturation to compensate for luminance difference
    //linearCV = mul(ODT_SAT_MAT, linearCV);
    linearCV = lerp(dot(linearCV, AP1_RGB2Y).xxx, linearCV, ODT_SAT_FACTOR.xxx);

    // Convert to display primary encoding
    // Rendering space RGB to XYZ
    half3 XYZ = mul(AP1_2_XYZ_MAT, linearCV);

    // Apply CAT from ACES white point to assumed observer adapted white point
    XYZ = mul(D60_2_D65_CAT, XYZ);

    // CIE XYZ to display primaries
    linearCV = mul(XYZ_2_REC709_MAT, XYZ);

    // Handle out-of-gamut values
    // Clip values < 0 or > 1 (i.e. projecting outside the display primaries)
    linearCV = saturate(linearCV);

    // Encode linear code values with transfer function
    const half DISPGAMMA = 2.4;
    const half L_W = 1.0;
    const half L_B = 0.0;
    half3 outputCV = linear_to_bt1886(linearCV, DISPGAMMA, L_W, L_B);

    // TODO: Implement support for legal range.

    // NOTE: Unity framebuffer encoding is encoded with sRGB opto-electrical transfer function (OETF)
    // by default which will result in double perceptual encoding, thus for now if one want to use
    // this ODT, he needs to decode its output with sRGB electro-optical transfer function (EOTF) to
    // compensate for Unity default behaviour.

    return outputCV;
}

// <ACEStransformID>ODT.Academy.Rec709_D60sim_100nits_dim.a1.0.3</ACEStransformID>
// <ACESuserName>ACES 1.0 Output - Rec.709 (D60 sim.)</ACESuserName>

//
// Output Device Transform - Rec709 (D60 simulation)
//

//
// Summary :
//  This transform is intended for mapping OCES onto a Rec.709 broadcast monitor
//  that is calibrated to a D65 white point at 100 cd/m^2. The assumed observer
//  adapted white is D60, and the viewing environment is a dim surround.
//
//  A possible use case for this transform would be cinema "soft-proofing".
//
// Device Primaries :
//  Primaries are those specified in Rec. ITU-R BT.709
//  CIE 1931 chromaticities:  x         y         Y
//              Red:          0.64      0.33
//              Green:        0.3       0.6
//              Blue:         0.15      0.06
//              White:        0.3127    0.329     100 cd/m^2
//
// Display EOTF :
//  The reference electro-optical transfer function specified in
//  Rec. ITU-R BT.1886.
//
// Signal Range:
//    By default, this transform outputs full range code values. If instead a
//    SMPTE "legal" signal is desired, there is a runtime flag to output
//    SMPTE legal signal. In ctlrender, this can be achieved by appending
//    '-param1 legalRange 1' after the '-ctl odt.ctl' string.
//
// Assumed observer adapted white point:
//         CIE 1931 chromaticities:    x            y
//                                     0.32168      0.33767
//
// Viewing Environment:
//   This ODT has a compensation for viewing environment variables more typical
//   of those associated with video mastering.
//
half3 ODT_Rec709_D60sim_100nits_dim(half3 oces)
{
    // OCES to RGB rendering space
    half3 rgbPre = mul(AP0_2_AP1_MAT, oces);

    // Apply the tonescale independently in rendering-space RGB
    half3 rgbPost;
    rgbPost.x = segmented_spline_c9_fwd(rgbPre.x);
    rgbPost.y = segmented_spline_c9_fwd(rgbPre.y);
    rgbPost.z = segmented_spline_c9_fwd(rgbPre.z);

    // Scale luminance to linear code value
    half3 linearCV = Y_2_linCV(rgbPost, CINEMA_WHITE, CINEMA_BLACK);

    // --- Compensate for different white point being darker  --- //
    // This adjustment is to correct an issue that exists in ODTs where the device
    // is calibrated to a white chromaticity other than D60. In order to simulate
    // D60 on such devices, unequal code values must be sent to the display to achieve
    // the chromaticities of D60. More specifically, in order to produce D60 on a device
    // calibrated to a D65 white point (i.e. equal code values yield CIE x,y
    // chromaticities of 0.3127, 0.329) the red channel must be slightly higher than
    // that of green and blue in order to compensate for the relatively more "blue-ish"
    // D65 white. This unequalness of color channels is the correct behavior but it
    // means that as neutral highlights increase, the red channel will hit the
    // device maximum first and clip, resulting in a small chromaticity shift as the
    // green and blue channels continue to increase to their maximums.
    // To avoid this clipping error, a slight scale factor is applied to allow the
    // ODTs to simulate D60 within the D65 calibration white point.

    // Scale and clamp white to avoid casted highlights due to D60 simulation
    const half SCALE = 0.955;
    linearCV = min(linearCV, 1.0) * SCALE;

    // Apply gamma adjustment to compensate for dim surround
    linearCV = darkSurround_to_dimSurround(linearCV);

    // Apply desaturation to compensate for luminance difference
    //linearCV = mul(ODT_SAT_MAT, linearCV);
    linearCV = lerp(dot(linearCV, AP1_RGB2Y).xxx, linearCV, ODT_SAT_FACTOR.xxx);

    // Convert to display primary encoding
    // Rendering space RGB to XYZ
    half3 XYZ = mul(AP1_2_XYZ_MAT, linearCV);

    // CIE XYZ to display primaries
    linearCV = mul(XYZ_2_REC709_MAT, XYZ);

    // Handle out-of-gamut values
    // Clip values < 0 or > 1 (i.e. projecting outside the display primaries)
    linearCV = saturate(linearCV);

    // Encode linear code values with transfer function
    const half DISPGAMMA = 2.4;
    const half L_W = 1.0;
    const half L_B = 0.0;
    half3 outputCV = linear_to_bt1886(linearCV, DISPGAMMA, L_W, L_B);

    // TODO: Implement support for legal range.

    // NOTE: Unity framebuffer encoding is encoded with sRGB opto-electrical transfer function (OETF)
    // by default which will result in double perceptual encoding, thus for now if one want to use
    // this ODT, he needs to decode its output with sRGB electro-optical transfer function (EOTF) to
    // compensate for Unity default behaviour.

    return outputCV;
}

// <ACEStransformID>ODT.Academy.Rec2020_100nits_dim.a1.0.3</ACEStransformID>
// <ACESuserName>ACES 1.0 Output - Rec.2020</ACESuserName>

//
// Output Device Transform - Rec2020
//

//
// Summary :
//  This transform is intended for mapping OCES onto a Rec.2020 broadcast
//  monitor that is calibrated to a D65 white point at 100 cd/m^2. The assumed
//  observer adapted white is D65, and the viewing environment is that of a dim
//  surround.
//
//  A possible use case for this transform would be UHDTV/video mastering.
//
// Device Primaries :
//  Primaries are those specified in Rec. ITU-R BT.2020
//  CIE 1931 chromaticities:  x         y         Y
//              Red:          0.708     0.292
//              Green:        0.17      0.797
//              Blue:         0.131     0.046
//              White:        0.3127    0.329     100 cd/m^2
//
// Display EOTF :
//  The reference electro-optical transfer function specified in
//  Rec. ITU-R BT.1886.
//
// Signal Range:
//    By default, this transform outputs full range code values. If instead a
//    SMPTE "legal" signal is desired, there is a runtime flag to output
//    SMPTE legal signal. In ctlrender, this can be achieved by appending
//    '-param1 legalRange 1' after the '-ctl odt.ctl' string.
//
// Assumed observer adapted white point:
//         CIE 1931 chromaticities:    x            y
//                                     0.3127       0.329
//
// Viewing Environment:
//   This ODT has a compensation for viewing environment variables more typical
//   of those associated with video mastering.
//

half3 ODT_Rec2020_100nits_dim(half3 oces)
{
    // OCES to RGB rendering space
    half3 rgbPre = mul(AP0_2_AP1_MAT, oces);

    // Apply the tonescale independently in rendering-space RGB
    half3 rgbPost;
    rgbPost.x = segmented_spline_c9_fwd(rgbPre.x);
    rgbPost.y = segmented_spline_c9_fwd(rgbPre.y);
    rgbPost.z = segmented_spline_c9_fwd(rgbPre.z);

    // Scale luminance to linear code value
    half3 linearCV = Y_2_linCV(rgbPost, CINEMA_WHITE, CINEMA_BLACK);

    // Apply gamma adjustment to compensate for dim surround
    linearCV = darkSurround_to_dimSurround(linearCV);

    // Apply desaturation to compensate for luminance difference
    //linearCV = mul(ODT_SAT_MAT, linearCV);
    linearCV = lerp(dot(linearCV, AP1_RGB2Y).xxx, linearCV, ODT_SAT_FACTOR.xxx);

    // Convert to display primary encoding
    // Rendering space RGB to XYZ
    half3 XYZ = mul(AP1_2_XYZ_MAT, linearCV);

    // Apply CAT from ACES white point to assumed observer adapted white point
    XYZ = mul(D60_2_D65_CAT, XYZ);

    // CIE XYZ to display primaries
    linearCV = mul(XYZ_2_REC2020_MAT, XYZ);

    // Handle out-of-gamut values
    // Clip values < 0 or > 1 (i.e. projecting outside the display primaries)
    linearCV = saturate(linearCV);

    // Encode linear code values with transfer function
    const half DISPGAMMA = 2.4;
    const half L_W = 1.0;
    const half L_B = 0.0;
    half3 outputCV = linear_to_bt1886(linearCV, DISPGAMMA, L_W, L_B);

    // TODO: Implement support for legal range.

    // NOTE: Unity framebuffer encoding is encoded with sRGB opto-electrical transfer function (OETF)
    // by default which will result in double perceptual encoding, thus for now if one want to use
    // this ODT, he needs to decode its output with sRGB electro-optical transfer function (EOTF) to
    // compensate for Unity default behaviour.

    return outputCV;
}

// <ACEStransformID>ODT.Academy.P3DCI_48nits.a1.0.3</ACEStransformID>
// <ACESuserName>ACES 1.0 Output - P3-DCI</ACESuserName>

//
// Output Device Transform - P3DCI (D60 Simulation)
//

//
// Summary :
//  This transform is intended for mapping OCES onto a P3 digital cinema
//  projector that is calibrated to a DCI white point at 48 cd/m^2. The assumed
//  observer adapted white is D60, and the viewing environment is that of a dark
//  theater.
//
// Device Primaries :
//  CIE 1931 chromaticities:  x         y         Y
//              Red:          0.68      0.32
//              Green:        0.265     0.69
//              Blue:         0.15      0.06
//              White:        0.314     0.351     48 cd/m^2
//
// Display EOTF :
//  Gamma: 2.6
//
// Assumed observer adapted white point:
//         CIE 1931 chromaticities:    x            y
//                                     0.32168      0.33767
//
// Viewing Environment:
//  Environment specified in SMPTE RP 431-2-2007
//
half3 ODT_P3DCI_48nits(half3 oces)
{
    // OCES to RGB rendering space
    half3 rgbPre = mul(AP0_2_AP1_MAT, oces);

    // Apply the tonescale independently in rendering-space RGB
    half3 rgbPost;
    rgbPost.x = segmented_spline_c9_fwd(rgbPre.x);
    rgbPost.y = segmented_spline_c9_fwd(rgbPre.y);
    rgbPost.z = segmented_spline_c9_fwd(rgbPre.z);

    // Scale luminance to linear code value
    half3 linearCV = Y_2_linCV(rgbPost, CINEMA_WHITE, CINEMA_BLACK);

    // --- Compensate for different white point being darker  --- //
    // This adjustment is to correct an issue that exists in ODTs where the device
    // is calibrated to a white chromaticity other than D60. In order to simulate
    // D60 on such devices, unequal code values are sent to the display to achieve
    // neutrals at D60. In order to produce D60 on a device calibrated to the DCI
    // white point (i.e. equal code values yield CIE x,y chromaticities of 0.314,
    // 0.351) the red channel is higher than green and blue to compensate for the
    // "greenish" DCI white. This is the correct behavior but it means that as
    // highlight increase, the red channel will hit the device maximum first and
    // clip, resulting in a chromaticity shift as the green and blue channels
    // continue to increase.
    // To avoid this clipping error, a slight scale factor is applied to allow the
    // ODTs to simulate D60 within the D65 calibration white point. However, the
    // magnitude of the scale factor required for the P3DCI ODT was considered too
    // large. Therefore, the scale factor was reduced and the additional required
    // compression was achieved via a reshaping of the highlight rolloff in
    // conjunction with the scale. The shape of this rolloff was determined
    // throught subjective experiments and deemed to best reproduce the
    // "character" of the highlights in the P3D60 ODT.

    // Roll off highlights to avoid need for as much scaling
    const half NEW_WHT = 0.918;
    const half ROLL_WIDTH = 0.5;
    linearCV.x = roll_white_fwd(linearCV.x, NEW_WHT, ROLL_WIDTH);
    linearCV.y = roll_white_fwd(linearCV.y, NEW_WHT, ROLL_WIDTH);
    linearCV.z = roll_white_fwd(linearCV.z, NEW_WHT, ROLL_WIDTH);

    // Scale and clamp white to avoid casted highlights due to D60 simulation
    const half SCALE = 0.96;
    linearCV = min(linearCV, NEW_WHT) * SCALE;

    // Convert to display primary encoding
    // Rendering space RGB to XYZ
    half3 XYZ = mul(AP1_2_XYZ_MAT, linearCV);

    // CIE XYZ to display primaries
    linearCV = mul(XYZ_2_DCIP3_MAT, XYZ);

    // Handle out-of-gamut values
    // Clip values < 0 or > 1 (i.e. projecting outside the display primaries)
    linearCV = saturate(linearCV);

    // Encode linear code values with transfer function
    const half DISPGAMMA = 2.6;
    half3 outputCV = pow(linearCV, 1.0 / DISPGAMMA);

    // NOTE: Unity framebuffer encoding is encoded with sRGB opto-electrical transfer function (OETF)
    // by default which will result in double perceptual encoding, thus for now if one want to use
    // this ODT, he needs to decode its output with sRGB electro-optical transfer function (EOTF) to
    // compensate for Unity default behaviour.

    return outputCV;
}

#endif // __ACES__

// File end: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/ACES.hlsl
//================================================================================================================================




//-----------------------------------------------------------------------------
// Gamma space - Assume positive values
//-----------------------------------------------------------------------------

// Gamma20
real Gamma20ToLinear(real c)
{
    return c * c;
}

real3 Gamma20ToLinear(real3 c)
{
    return c.rgb * c.rgb;
}

real4 Gamma20ToLinear(real4 c)
{
    return real4(Gamma20ToLinear(c.rgb), c.a);
}

real LinearToGamma20(real c)
{
    return sqrt(c);
}

real3 LinearToGamma20(real3 c)
{
    return sqrt(c.rgb);
}

real4 LinearToGamma20(real4 c)
{
    return real4(LinearToGamma20(c.rgb), c.a);
}

// Gamma22
real Gamma22ToLinear(real c)
{
    return PositivePow(c, 2.2);
}

real3 Gamma22ToLinear(real3 c)
{
    return PositivePow(c.rgb, real3(2.2, 2.2, 2.2));
}

real4 Gamma22ToLinear(real4 c)
{
    return real4(Gamma22ToLinear(c.rgb), c.a);
}

real LinearToGamma22(real c)
{
    return PositivePow(c, 0.454545454545455);
}

real3 LinearToGamma22(real3 c)
{
    return PositivePow(c.rgb, real3(0.454545454545455, 0.454545454545455, 0.454545454545455));
}

real4 LinearToGamma22(real4 c)
{
    return real4(LinearToGamma22(c.rgb), c.a);
}

// sRGB
real SRGBToLinear(real c)
{
    real linearRGBLo  = c / 12.92;
    real linearRGBHi  = PositivePow((c + 0.055) / 1.055, 2.4);
    real linearRGB    = (c <= 0.04045) ? linearRGBLo : linearRGBHi;
    return linearRGB;
}

real2 SRGBToLinear(real2 c)
{
    real2 linearRGBLo  = c / 12.92;
    real2 linearRGBHi  = PositivePow((c + 0.055) / 1.055, real2(2.4, 2.4));
    real2 linearRGB    = (c <= 0.04045) ? linearRGBLo : linearRGBHi;
    return linearRGB;
}

real3 SRGBToLinear(real3 c)
{
    real3 linearRGBLo  = c / 12.92;
    real3 linearRGBHi  = PositivePow((c + 0.055) / 1.055, real3(2.4, 2.4, 2.4));
    real3 linearRGB    = (c <= 0.04045) ? linearRGBLo : linearRGBHi;
    return linearRGB;
}

real4 SRGBToLinear(real4 c)
{
    return real4(SRGBToLinear(c.rgb), c.a);
}

real LinearToSRGB(real c)
{
    real sRGBLo = c * 12.92;
    real sRGBHi = (PositivePow(c, 1.0/2.4) * 1.055) - 0.055;
    real sRGB   = (c <= 0.0031308) ? sRGBLo : sRGBHi;
    return sRGB;
}

real2 LinearToSRGB(real2 c)
{
    real2 sRGBLo = c * 12.92;
    real2 sRGBHi = (PositivePow(c, real2(1.0/2.4, 1.0/2.4)) * 1.055) - 0.055;
    real2 sRGB   = (c <= 0.0031308) ? sRGBLo : sRGBHi;
    return sRGB;
}

real3 LinearToSRGB(real3 c)
{
    real3 sRGBLo = c * 12.92;
    real3 sRGBHi = (PositivePow(c, real3(1.0/2.4, 1.0/2.4, 1.0/2.4)) * 1.055) - 0.055;
    real3 sRGB   = (c <= 0.0031308) ? sRGBLo : sRGBHi;
    return sRGB;
}

real4 LinearToSRGB(real4 c)
{
    return real4(LinearToSRGB(c.rgb), c.a);
}

// TODO: Seb - To verify and refit!
// Ref: http://chilliant.blogspot.com.au/2012/08/srgb-approximations-for-hlsl.html?m=1
real FastSRGBToLinear(real c)
{
    return c * (c * (c * 0.305306011 + 0.682171111) + 0.012522878);
}

real2 FastSRGBToLinear(real2 c)
{
    return c * (c * (c * 0.305306011 + 0.682171111) + 0.012522878);
}

real3 FastSRGBToLinear(real3 c)
{
    return c * (c * (c * 0.305306011 + 0.682171111) + 0.012522878);
}

real4 FastSRGBToLinear(real4 c)
{
    return real4(FastSRGBToLinear(c.rgb), c.a);
}

real FastLinearToSRGB(real c)
{
    return saturate(1.055 * PositivePow(c, 0.416666667) - 0.055);
}

real2 FastLinearToSRGB(real2 c)
{
    return saturate(1.055 * PositivePow(c, 0.416666667) - 0.055);
}

real3 FastLinearToSRGB(real3 c)
{
    return saturate(1.055 * PositivePow(c, 0.416666667) - 0.055);
}

real4 FastLinearToSRGB(real4 c)
{
    return real4(FastLinearToSRGB(c.rgb), c.a);
}

//-----------------------------------------------------------------------------
// Color space
//-----------------------------------------------------------------------------

// Convert rgb to luminance
// with rgb in linear space with sRGB primaries and D65 white point
real Luminance(real3 linearRgb)
{
    return dot(linearRgb, real3(0.2126729, 0.7151522, 0.0721750));
}

real Luminance(real4 linearRgba)
{
    return Luminance(linearRgba.rgb);
}

real AcesLuminance(real3 linearRgb)
{
    return dot(linearRgb, AP1_RGB2Y);
}

real AcesLuminance(real4 linearRgba)
{
    return AcesLuminance(linearRgba.rgb);
}

// Scotopic luminance approximation - input is in XYZ space
// Note: the range of values returned is approximately [0;4]
// "A spatial postprocessing algorithm for images of night scenes"
// William B. Thompson, Peter Shirley, and James A. Ferwerda
real ScotopicLuminance(real3 xyzRgb)
{
    float X = xyzRgb.x;
    float Y = xyzRgb.y;
    float Z = xyzRgb.z;
    return Y * (1.33 * (1.0 + (Y + Z) / X) - 1.68);
}

real ScotopicLuminance(real4 xyzRgba)
{
    return ScotopicLuminance(xyzRgba.rgb);
}

// This function take a rgb color (best is to provide color in sRGB space)
// and return a YCoCg color in [0..1] space for 8bit (An offset is apply in the function)
// Ref: http://www.nvidia.com/object/real-time-ycocg-dxt-compression.html
#define YCOCG_CHROMA_BIAS (128.0 / 255.0)
real3 RGBToYCoCg(real3 rgb)
{
    real3 YCoCg;
    YCoCg.x = dot(rgb, real3(0.25, 0.5, 0.25));
    YCoCg.y = dot(rgb, real3(0.5, 0.0, -0.5)) + YCOCG_CHROMA_BIAS;
    YCoCg.z = dot(rgb, real3(-0.25, 0.5, -0.25)) + YCOCG_CHROMA_BIAS;

    return YCoCg;
}

real3 YCoCgToRGB(real3 YCoCg)
{
    real Y = YCoCg.x;
    real Co = YCoCg.y - YCOCG_CHROMA_BIAS;
    real Cg = YCoCg.z - YCOCG_CHROMA_BIAS;

    real3 rgb;
    rgb.r = Y + Co - Cg;
    rgb.g = Y + Cg;
    rgb.b = Y - Co - Cg;

    return rgb;
}

// Following function can be use to reconstruct chroma component for a checkboard YCoCg pattern
// Reference: The Compact YCoCg Frame Buffer
real YCoCgCheckBoardEdgeFilter(real centerLum, real2 a0, real2 a1, real2 a2, real2 a3)
{
    real4 lum = real4(a0.x, a1.x, a2.x, a3.x);
    // Optimize: real4 w = 1.0 - step(30.0 / 255.0, abs(lum - centerLum));
    real4 w = 1.0 - saturate((abs(lum.xxxx - centerLum) - 30.0 / 255.0) * HALF_MAX);
    real W = w.x + w.y + w.z + w.w;
    // handle the special case where all the weights are zero.
    return  (W == 0.0) ? a0.y : (w.x * a0.y + w.y* a1.y + w.z* a2.y + w.w * a3.y) / W;
}

// Converts linear RGB to LMS
real3 LinearToLMS(real3 x)
{
    const real3x3 LIN_2_LMS_MAT = {
        3.90405e-1, 5.49941e-1, 8.92632e-3,
        7.08416e-2, 9.63172e-1, 1.35775e-3,
        2.31082e-2, 1.28021e-1, 9.36245e-1
    };

    return mul(LIN_2_LMS_MAT, x);
}

real3 LMSToLinear(real3 x)
{
    const real3x3 LMS_2_LIN_MAT = {
        2.85847e+0, -1.62879e+0, -2.48910e-2,
        -2.10182e-1,  1.15820e+0,  3.24281e-4,
        -4.18120e-2, -1.18169e-1,  1.06867e+0
    };

    return mul(LMS_2_LIN_MAT, x);
}

// Hue, Saturation, Value
// Ranges:
//  Hue [0.0, 1.0]
//  Sat [0.0, 1.0]
//  Lum [0.0, HALF_MAX]
real3 RgbToHsv(real3 c)
{
    const real4 K = real4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    real4 p = lerp(real4(c.bg, K.wz), real4(c.gb, K.xy), step(c.b, c.g));
    real4 q = lerp(real4(p.xyw, c.r), real4(c.r, p.yzx), step(p.x, c.r));
    real d = q.x - min(q.w, q.y);
    const real e = 1.0e-4;
    return real3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

real3 HsvToRgb(real3 c)
{
    const real4 K = real4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    real3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
}

real RotateHue(real value, real low, real hi)
{
    return (value < low)
            ? value + hi
            : (value > hi)
                ? value - hi
                : value;
}

// Soft-light blending mode use for split-toning. Works in HDR as long as `blend` is [0;1] which is
// fine for our use case.
float3 SoftLight(float3 base, float3 blend)
{
    float3 r1 = 2.0 * base * blend + base * base * (1.0 - 2.0 * blend);
    float3 r2 = sqrt(base) * (2.0 * blend - 1.0) + 2.0 * base * (1.0 - blend);
    float3 t = step(0.5, blend);
    return r2 * t + (1.0 - t) * r1;
}

// SMPTE ST.2084 (PQ) transfer functions
// 1.0 = 100nits, 100.0 = 10knits
#define DEFAULT_MAX_PQ 100.0

struct ParamsPQ
{
    real N, M;
    real C1, C2, C3;
};

static const ParamsPQ PQ =
{
    2610.0 / 4096.0 / 4.0,   // N
    2523.0 / 4096.0 * 128.0, // M
    3424.0 / 4096.0,         // C1
    2413.0 / 4096.0 * 32.0,  // C2
    2392.0 / 4096.0 * 32.0,  // C3
};

real3 LinearToPQ(real3 x, real maxPQValue)
{
    x = PositivePow(x / maxPQValue, PQ.N);
    real3 nd = (PQ.C1 + PQ.C2 * x) / (1.0 + PQ.C3 * x);
    return PositivePow(nd, PQ.M);
}

real3 LinearToPQ(real3 x)
{
    return LinearToPQ(x, DEFAULT_MAX_PQ);
}

real3 PQToLinear(real3 x, real maxPQValue)
{
    x = PositivePow(x, rcp(PQ.M));
    real3 nd = max(x - PQ.C1, 0.0) / (PQ.C2 - (PQ.C3 * x));
    return PositivePow(nd, rcp(PQ.N)) * maxPQValue;
}

real3 PQToLinear(real3 x)
{
    return PQToLinear(x, DEFAULT_MAX_PQ);
}

// Alexa LogC converters (El 1000)
// See http://www.vocas.nl/webfm_send/964
// Max range is ~58.85666

// Set to 1 to use more precise but more expensive log/linear conversions. I haven't found a proper
// use case for the high precision version yet so I'm leaving this to 0.
#define USE_PRECISE_LOGC 0

struct ParamsLogC
{
    real cut;
    real a, b, c, d, e, f;
};

static const ParamsLogC LogC =
{
    0.011361, // cut
    5.555556, // a
    0.047996, // b
    0.244161, // c
    0.386036, // d
    5.301883, // e
    0.092819  // f
};

real LinearToLogC_Precise(real x)
{
    real o;
    if (x > LogC.cut)
        o = LogC.c * log10(LogC.a * x + LogC.b) + LogC.d;
    else
        o = LogC.e * x + LogC.f;
    return o;
}

real3 LinearToLogC(real3 x)
{
#if USE_PRECISE_LOGC
    return real3(
        LinearToLogC_Precise(x.x),
        LinearToLogC_Precise(x.y),
        LinearToLogC_Precise(x.z)
    );
#else
    return LogC.c * log10(LogC.a * x + LogC.b) + LogC.d;
#endif
}

real LogCToLinear_Precise(real x)
{
    real o;
    if (x > LogC.e * LogC.cut + LogC.f)
        o = (pow(10.0, (x - LogC.d) / LogC.c) - LogC.b) / LogC.a;
    else
        o = (x - LogC.f) / LogC.e;
    return o;
}

real3 LogCToLinear(real3 x)
{
#if USE_PRECISE_LOGC
    return real3(
        LogCToLinear_Precise(x.x),
        LogCToLinear_Precise(x.y),
        LogCToLinear_Precise(x.z)
    );
#else
    return (pow(10.0, (x - LogC.d) / LogC.c) - LogC.b) / LogC.a;
#endif
}

//-----------------------------------------------------------------------------
// Utilities
//-----------------------------------------------------------------------------

real3 Desaturate(real3 value, real saturation)
{
    // Saturation = Colorfulness / Brightness.
    // https://munsell.com/color-blog/difference-chroma-saturation/
    real  mean = Avg3(value.r, value.g, value.b);
    real3 dev  = value - mean;

    return mean + dev * saturation;
}

// Fast reversible tonemapper
// http://gpuopen.com/optimized-reversible-tonemapper-for-resolve/
real FastTonemapPerChannel(real c)
{
    return c * rcp(c + 1.0);
}

real2 FastTonemapPerChannel(real2 c)
{
    return c * rcp(c + 1.0);
}

real3 FastTonemap(real3 c)
{
    return c * rcp(Max3(c.r, c.g, c.b) + 1.0);
}

real4 FastTonemap(real4 c)
{
    return real4(FastTonemap(c.rgb), c.a);
}

real3 FastTonemap(real3 c, real w)
{
    return c * (w * rcp(Max3(c.r, c.g, c.b) + 1.0));
}

real4 FastTonemap(real4 c, real w)
{
    return real4(FastTonemap(c.rgb, w), c.a);
}

real FastTonemapPerChannelInvert(real c)
{
    return c * rcp(1.0 - c);
}

real2 FastTonemapPerChannelInvert(real2 c)
{
    return c * rcp(1.0 - c);
}

real3 FastTonemapInvert(real3 c)
{
    return c * rcp(1.0 - Max3(c.r, c.g, c.b));
}

real4 FastTonemapInvert(real4 c)
{
    return real4(FastTonemapInvert(c.rgb), c.a);
}

#ifndef SHADER_API_GLES
// 3D LUT grading
// scaleOffset = (1 / lut_size, lut_size - 1)
real3 ApplyLut3D(TEXTURE3D_PARAM(tex, samplerTex), float3 uvw, float2 scaleOffset)
{
    uvw.xyz = uvw.xyz * scaleOffset.yyy * scaleOffset.xxx + scaleOffset.xxx * 0.5;
    return SAMPLE_TEXTURE3D_LOD(tex, samplerTex, uvw, 0.0).rgb;
}
#endif

// 2D LUT grading
// scaleOffset = (1 / lut_width, 1 / lut_height, lut_height - 1)
real3 ApplyLut2D(TEXTURE2D_PARAM(tex, samplerTex), float3 uvw, float3 scaleOffset)
{
    // Strip format where `height = sqrt(width)`
    uvw.z *= scaleOffset.z;
    float shift = floor(uvw.z);
    uvw.xy = uvw.xy * scaleOffset.z * scaleOffset.xy + scaleOffset.xy * 0.5;
    uvw.x += shift * scaleOffset.y;
    uvw.xyz = lerp(
        SAMPLE_TEXTURE2D_LOD(tex, samplerTex, uvw.xy, 0.0).rgb,
        SAMPLE_TEXTURE2D_LOD(tex, samplerTex, uvw.xy + float2(scaleOffset.y, 0.0), 0.0).rgb,
        uvw.z - shift
    );
    return uvw;
}

// Returns the default value for a given position on a 2D strip-format color lookup table
// params = (lut_height, 0.5 / lut_width, 0.5 / lut_height, lut_height / lut_height - 1)
real3 GetLutStripValue(float2 uv, float4 params)
{
    uv -= params.yz;
    real3 color;
    color.r = frac(uv.x * params.x);
    color.b = uv.x - color.r / params.x;
    color.g = uv.y;
    return color * params.w;
}

// Neutral tonemapping (Hable/Hejl/Frostbite)
// Input is linear RGB
#if defined(SHADER_API_SWITCH) // We need more accuracy on Nintendo Switch to avoid NaN on extremely high values.
float3 NeutralCurve(float3 x, real a, real b, real c, real d, real e, real f)
#else
real3 NeutralCurve(real3 x, real a, real b, real c, real d, real e, real f)
#endif
{
    return ((x * (a * x + c * b) + d * e) / (x * (a * x + b) + d * f)) - e / f;
}

real3 NeutralTonemap(real3 x)
{
    // Tonemap
    const real a = 0.2;
    const real b = 0.29;
    const real c = 0.24;
    const real d = 0.272;
    const real e = 0.02;
    const real f = 0.3;
    const real whiteLevel = 5.3;
    const real whiteClip = 1.0;

    real3 whiteScale = (1.0).xxx / NeutralCurve(whiteLevel, a, b, c, d, e, f);
    x = NeutralCurve(x * whiteScale, a, b, c, d, e, f);
    x *= whiteScale;

    // Post-curve white point adjustment
    x /= whiteClip.xxx;

    return x;
}

// Raw, unoptimized version of John Hable's artist-friendly tone curve
// Input is linear RGB
real EvalCustomSegment(real x, real4 segmentA, real2 segmentB)
{
    const real kOffsetX = segmentA.x;
    const real kOffsetY = segmentA.y;
    const real kScaleX  = segmentA.z;
    const real kScaleY  = segmentA.w;
    const real kLnA     = segmentB.x;
    const real kB       = segmentB.y;

    real x0 = (x - kOffsetX) * kScaleX;
    real y0 = (x0 > 0.0) ? exp(kLnA + kB * log(x0)) : 0.0;
    return y0 * kScaleY + kOffsetY;
}

real EvalCustomCurve(real x, real3 curve, real4 toeSegmentA, real2 toeSegmentB, real4 midSegmentA, real2 midSegmentB, real4 shoSegmentA, real2 shoSegmentB)
{
    real4 segmentA;
    real2 segmentB;

    if (x < curve.y)
    {
        segmentA = toeSegmentA;
        segmentB = toeSegmentB;
    }
    else if (x < curve.z)
    {
        segmentA = midSegmentA;
        segmentB = midSegmentB;
    }
    else
    {
        segmentA = shoSegmentA;
        segmentB = shoSegmentB;
    }

    return EvalCustomSegment(x, segmentA, segmentB);
}

// curve: x: inverseWhitePoint, y: x0, z: x1
real3 CustomTonemap(real3 x, real3 curve, real4 toeSegmentA, real2 toeSegmentB, real4 midSegmentA, real2 midSegmentB, real4 shoSegmentA, real2 shoSegmentB)
{
    real3 normX = x * curve.x;
    real3 ret;
    ret.x = EvalCustomCurve(normX.x, curve, toeSegmentA, toeSegmentB, midSegmentA, midSegmentB, shoSegmentA, shoSegmentB);
    ret.y = EvalCustomCurve(normX.y, curve, toeSegmentA, toeSegmentB, midSegmentA, midSegmentB, shoSegmentA, shoSegmentB);
    ret.z = EvalCustomCurve(normX.z, curve, toeSegmentA, toeSegmentB, midSegmentA, midSegmentB, shoSegmentA, shoSegmentB);
    return ret;
}

// Filmic tonemapping (ACES fitting, unless TONEMAPPING_USE_FULL_ACES is set to 1)
// Input is ACES2065-1 (AP0 w/ linear encoding)
#define TONEMAPPING_USE_FULL_ACES 0

float3 AcesTonemap(float3 aces)
{
#if TONEMAPPING_USE_FULL_ACES

    float3 oces = RRT(aces);
    float3 odt = ODT_RGBmonitor_100nits_dim(oces);
    return odt;

#else

    // --- Glow module --- //
    float saturation = rgb_2_saturation(aces);
    float ycIn = rgb_2_yc(aces);
    float s = sigmoid_shaper((saturation - 0.4) / 0.2);
    float addedGlow = 1.0 + glow_fwd(ycIn, RRT_GLOW_GAIN * s, RRT_GLOW_MID);
    aces *= addedGlow;

    // --- Red modifier --- //
    float hue = rgb_2_hue(aces);
    float centeredHue = center_hue(hue, RRT_RED_HUE);
    float hueWeight;
    {
        //hueWeight = cubic_basis_shaper(centeredHue, RRT_RED_WIDTH);
        hueWeight = smoothstep(0.0, 1.0, 1.0 - abs(2.0 * centeredHue / RRT_RED_WIDTH));
        hueWeight *= hueWeight;
    }

    aces.r += hueWeight * saturation * (RRT_RED_PIVOT - aces.r) * (1.0 - RRT_RED_SCALE);

    // --- ACES to RGB rendering space --- //
    float3 acescg = max(0.0, ACES_to_ACEScg(aces));

    // --- Global desaturation --- //
    //acescg = mul(RRT_SAT_MAT, acescg);
    acescg = lerp(dot(acescg, AP1_RGB2Y).xxx, acescg, RRT_SAT_FACTOR.xxx);

    // Luminance fitting of *RRT.a1.0.3 + ODT.Academy.RGBmonitor_100nits_dim.a1.0.3*.
    // https://github.com/colour-science/colour-unity/blob/master/Assets/Colour/Notebooks/CIECAM02_Unity.ipynb
    // RMSE: 0.0012846272106
#if defined(SHADER_API_SWITCH) // Fix floating point overflow on extremely large values.
    const float a = 2.785085 * 0.01;
    const float b = 0.107772 * 0.01;
    const float c = 2.936045 * 0.01;
    const float d = 0.887122 * 0.01;
    const float e = 0.806889 * 0.01;
    float3 x = acescg;
   float3 rgbPost = ((a * x + b)) / ((c * x + d) + e/(x + FLT_MIN));
#else
    const float a = 2.785085;
    const float b = 0.107772;
    const float c = 2.936045;
    const float d = 0.887122;
    const float e = 0.806889;
    float3 x = acescg;
    float3 rgbPost = (x * (a * x + b)) / (x * (c * x + d) + e);
#endif

    // Scale luminance to linear code value
    // float3 linearCV = Y_2_linCV(rgbPost, CINEMA_WHITE, CINEMA_BLACK);

    // Apply gamma adjustment to compensate for dim surround
    float3 linearCV = darkSurround_to_dimSurround(rgbPost);

    // Apply desaturation to compensate for luminance difference
    //linearCV = mul(ODT_SAT_MAT, color);
    linearCV = lerp(dot(linearCV, AP1_RGB2Y).xxx, linearCV, ODT_SAT_FACTOR.xxx);

    // Convert to display primary encoding
    // Rendering space RGB to XYZ
    float3 XYZ = mul(AP1_2_XYZ_MAT, linearCV);

    // Apply CAT from ACES white point to assumed observer adapted white point
    XYZ = mul(D60_2_D65_CAT, XYZ);

    // CIE XYZ to display primaries
    linearCV = mul(XYZ_2_REC709_MAT, XYZ);

    return linearCV;

#endif
}

// RGBM encode/decode
static const float kRGBMRange = 8.0;

half4 EncodeRGBM(half3 color)
{
    color *= 1.0 / kRGBMRange;
    half m = max(max(color.x, color.y), max(color.z, 1e-5));
    m = ceil(m * 255) / 255;
    return half4(color / m, m);
}

half3 DecodeRGBM(half4 rgbm)
{
    return rgbm.xyz * rgbm.w * kRGBMRange;
}

#endif // UNITY_COLOR_INCLUDED

// File end: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/Color.hlsl
//================================================================================================================================




// Note: All NDF and diffuse term have a version with and without divide by PI.
// Version with divide by PI are use for direct lighting.
// Version without divide by PI are use for image based lighting where often the PI cancel during importance sampling

//-----------------------------------------------------------------------------
// Help for BSDF evaluation
//-----------------------------------------------------------------------------

// Cosine-weighted BSDF (a BSDF taking the projected solid angle into account).
// If some of the values are monochromatic, the compiler will optimize accordingly.
struct CBSDF
{
    float3 diffR; // Diffuse  reflection   (T -> MS -> T, same sides)
    float3 specR; // Specular reflection   (R, RR, TRT, etc)
    float3 diffT; // Diffuse  transmission (rough T or TT, opposite sides)
    float3 specT; // Specular transmission (T, TT, TRRT, etc)
};

//-----------------------------------------------------------------------------
// Fresnel term
//-----------------------------------------------------------------------------

real F_Schlick(real f0, real f90, real u)
{
    real x = 1.0 - u;
    real x2 = x * x;
    real x5 = x * x2 * x2;
    return (f90 - f0) * x5 + f0;                // sub mul mul mul sub mad
}

real F_Schlick(real f0, real u)
{
    return F_Schlick(f0, 1.0, u);               // sub mul mul mul sub mad
}

real3 F_Schlick(real3 f0, real f90, real u)
{
    real x = 1.0 - u;
    real x2 = x * x;
    real x5 = x * x2 * x2;
    return f0 * (1.0 - x5) + (f90 * x5);        // sub mul mul mul sub mul mad*3
}

real3 F_Schlick(real3 f0, real u)
{
    return F_Schlick(f0, 1.0, u);               // sub mul mul mul sub mad*3
}

// Does not handle TIR.
real F_Transm_Schlick(real f0, real f90, real u)
{
    real x = 1.0 - u;
    real x2 = x * x;
    real x5 = x * x2 * x2;
    return (1.0 - f90 * x5) - f0 * (1.0 - x5);  // sub mul mul mul mad sub mad
}

// Does not handle TIR.
real F_Transm_Schlick(real f0, real u)
{
    return F_Transm_Schlick(f0, 1.0, u);        // sub mul mul mad mad
}

// Does not handle TIR.
real3 F_Transm_Schlick(real3 f0, real f90, real u)
{
    real x = 1.0 - u;
    real x2 = x * x;
    real x5 = x * x2 * x2;
    return (1.0 - f90 * x5) - f0 * (1.0 - x5);  // sub mul mul mul mad sub mad*3
}

// Does not handle TIR.
real3 F_Transm_Schlick(real3 f0, real u)
{
    return F_Transm_Schlick(f0, 1.0, u);        // sub mul mul mad mad*3
}

// Ref: https://seblagarde.wordpress.com/2013/04/29/memo-on-fresnel-equations/
// Fresnel dielectric / dielectric
real F_FresnelDielectric(real ior, real u)
{
    real g = sqrt(Sq(ior) + Sq(u) - 1.0);

    // The "1.0 - saturate(1.0 - result)" formulation allows to recover form cases where g is undefined, for IORs < 1
    return 1.0 - saturate(1.0 - 0.5 * Sq((g - u) / (g + u)) * (1.0 + Sq(((g + u) * u - 1.0) / ((g - u) * u + 1.0))));
}

// Fresnel dieletric / conductor
// Note: etak2 = etak * etak (optimization for Artist Friendly Metallic Fresnel below)
// eta = eta_t / eta_i and etak = k_t / n_i
real3 F_FresnelConductor(real3 eta, real3 etak2, real cosTheta)
{
    real cosTheta2 = cosTheta * cosTheta;
    real sinTheta2 = 1.0 - cosTheta2;
    real3 eta2 = eta * eta;

    real3 t0 = eta2 - etak2 - sinTheta2;
    real3 a2plusb2 = sqrt(t0 * t0 + 4.0 * eta2 * etak2);
    real3 t1 = a2plusb2 + cosTheta2;
    real3 a = sqrt(0.5 * (a2plusb2 + t0));
    real3 t2 = 2.0 * a * cosTheta;
    real3 Rs = (t1 - t2) / (t1 + t2);

    real3 t3 = cosTheta2 * a2plusb2 + sinTheta2 * sinTheta2;
    real3 t4 = t2 * sinTheta2;
    real3 Rp = Rs * (t3 - t4) / (t3 + t4);

    return 0.5 * (Rp + Rs);
}

// Conversion FO/IOR

TEMPLATE_2_REAL(IorToFresnel0, transmittedIor, incidentIor, return Sq((transmittedIor - incidentIor) / (transmittedIor + incidentIor)) )
// ior is a value between 1.0 and 3.0. 1.0 is air interface
real IorToFresnel0(real transmittedIor)
{
    return IorToFresnel0(transmittedIor, 1.0);
}

// Assume air interface for top
// Note: We don't handle the case fresnel0 == 1
//real Fresnel0ToIor(real fresnel0)
//{
//    real sqrtF0 = sqrt(fresnel0);
//    return (1.0 + sqrtF0) / (1.0 - sqrtF0);
//}
TEMPLATE_1_REAL(Fresnel0ToIor, fresnel0, return ((1.0 + sqrt(fresnel0)) / (1.0 - sqrt(fresnel0))) )

// This function is a coarse approximation of computing fresnel0 for a different top than air (here clear coat of IOR 1.5) when we only have fresnel0 with air interface
// This function is equivalent to IorToFresnel0(Fresnel0ToIor(fresnel0), 1.5)
// mean
// real sqrtF0 = sqrt(fresnel0);
// return Sq(1.0 - 5.0 * sqrtF0) / Sq(5.0 - sqrtF0);
// Optimization: Fit of the function (3 mad) for range [0.04 (should return 0), 1 (should return 1)]
TEMPLATE_1_REAL(ConvertF0ForAirInterfaceToF0ForClearCoat15, fresnel0, return saturate(-0.0256868 + fresnel0 * (0.326846 + (0.978946 - 0.283835 * fresnel0) * fresnel0)))

// Artist Friendly Metallic Fresnel Ref: http://jcgt.org/published/0003/04/03/paper.pdf

real3 GetIorN(real3 f0, real3 edgeTint)
{
    real3 sqrtF0 = sqrt(f0);
    return lerp((1.0 - f0) / (1.0 + f0), (1.0 + sqrtF0) / (1.0 - sqrt(f0)), edgeTint);
}

real3 getIorK2(real3 f0, real3 n)
{
    real3 nf0 = Sq(n + 1.0) * f0 - Sq(f0 - 1.0);
    return nf0 / (1.0 - f0);
}

// same as regular refract except there is not the test for total internal reflection + the vector is flipped for processing
real3 CoatRefract(real3 X, real3 N, real ieta)
{
    real XdotN = saturate(dot(N, X));
    return ieta * X + (sqrt(1 + ieta * ieta * (XdotN * XdotN - 1)) - ieta * XdotN) * N;
}

//-----------------------------------------------------------------------------
// Specular BRDF
//-----------------------------------------------------------------------------

real D_GGXNoPI(real NdotH, real roughness)
{
    real a2 = Sq(roughness);
    real s = (NdotH * a2 - NdotH) * NdotH + 1.0;

    // If roughness is 0, returns (NdotH == 1 ? 1 : 0).
    // That is, it returns 1 for perfect mirror reflection, and 0 otherwise.
    return SafeDiv(a2, s * s);
}

real D_GGX(real NdotH, real roughness)
{
    return INV_PI * D_GGXNoPI(NdotH, roughness);
}

// Ref: Understanding the Masking-Shadowing Function in Microfacet-Based BRDFs, p. 19, 29.
// p. 84 (37/60)
real G_MaskingSmithGGX(real NdotV, real roughness)
{
    // G1(V, H)    = HeavisideStep(VdotH) / (1 + Lambda(V)).
    // Lambda(V)        = -0.5 + 0.5 * sqrt(1 + 1 / a^2).
    // a           = 1 / (roughness * tan(theta)).
    // 1 + Lambda(V)    = 0.5 + 0.5 * sqrt(1 + roughness^2 * tan^2(theta)).
    // tan^2(theta) = (1 - cos^2(theta)) / cos^2(theta) = 1 / cos^2(theta) - 1.
    // Assume that (VdotH > 0), e.i. (acos(LdotV) < Pi).

    return 1.0 / (0.5 + 0.5 * sqrt(1.0 + Sq(roughness) * (1.0 / Sq(NdotV) - 1.0)));
}

// Ref: Understanding the Masking-Shadowing Function in Microfacet-Based BRDFs, p. 12.
real D_GGX_Visible(real NdotH, real NdotV, real VdotH, real roughness)
{
    return D_GGX(NdotH, roughness) * G_MaskingSmithGGX(NdotV, roughness) * VdotH / NdotV;
}

// Precompute part of lambdaV
real GetSmithJointGGXPartLambdaV(real NdotV, real roughness)
{
    real a2 = Sq(roughness);
    return sqrt((-NdotV * a2 + NdotV) * NdotV + a2);
}

// Note: V = G / (4 * NdotL * NdotV)
// Ref: http://jcgt.org/published/0003/02/03/paper.pdf
real V_SmithJointGGX(real NdotL, real NdotV, real roughness, real partLambdaV)
{
    real a2 = Sq(roughness);

    // Original formulation:
    // lambda_v = (-1 + sqrt(a2 * (1 - NdotL2) / NdotL2 + 1)) * 0.5
    // lambda_l = (-1 + sqrt(a2 * (1 - NdotV2) / NdotV2 + 1)) * 0.5
    // G        = 1 / (1 + lambda_v + lambda_l);

    // Reorder code to be more optimal:
    real lambdaV = NdotL * partLambdaV;
    real lambdaL = NdotV * sqrt((-NdotL * a2 + NdotL) * NdotL + a2);

    // Simplify visibility term: (2.0 * NdotL * NdotV) /  ((4.0 * NdotL * NdotV) * (lambda_v + lambda_l))
    return 0.5 / (lambdaV + lambdaL);
}

real V_SmithJointGGX(real NdotL, real NdotV, real roughness)
{
    real partLambdaV = GetSmithJointGGXPartLambdaV(NdotV, roughness);
    return V_SmithJointGGX(NdotL, NdotV, roughness, partLambdaV);
}

// Inline D_GGX() * V_SmithJointGGX() together for better code generation.
real DV_SmithJointGGX(real NdotH, real NdotL, real NdotV, real roughness, real partLambdaV)
{
    real a2 = Sq(roughness);
    real s = (NdotH * a2 - NdotH) * NdotH + 1.0;

    real lambdaV = NdotL * partLambdaV;
    real lambdaL = NdotV * sqrt((-NdotL * a2 + NdotL) * NdotL + a2);

    real2 D = real2(a2, s * s);            // Fraction without the multiplier (1/Pi)
    real2 G = real2(1, lambdaV + lambdaL); // Fraction without the multiplier (1/2)

    // This function is only used for direct lighting.
    // If roughness is 0, the probability of hitting a punctual or directional light is also 0.
    // Therefore, we return 0. The most efficient way to do it is with a max().
    return INV_PI * 0.5 * (D.x * G.x) / max(D.y * G.y, REAL_MIN);
}

real DV_SmithJointGGX(real NdotH, real NdotL, real NdotV, real roughness)
{
    real partLambdaV = GetSmithJointGGXPartLambdaV(NdotV, roughness);
    return DV_SmithJointGGX(NdotH, NdotL, NdotV, roughness, partLambdaV);
}

// Precompute a part of LambdaV.
// Note on this linear approximation.
// Exact for roughness values of 0 and 1. Also, exact when the cosine is 0 or 1.
// Otherwise, the worst case relative error is around 10%.
// https://www.desmos.com/calculator/wtp8lnjutx
real GetSmithJointGGXPartLambdaVApprox(real NdotV, real roughness)
{
    real a = roughness;
    return NdotV * (1 - a) + a;
}

real V_SmithJointGGXApprox(real NdotL, real NdotV, real roughness, real partLambdaV)
{
    real a = roughness;

    real lambdaV = NdotL * partLambdaV;
    real lambdaL = NdotV * (NdotL * (1 - a) + a);

    return 0.5 / (lambdaV + lambdaL);
}

real V_SmithJointGGXApprox(real NdotL, real NdotV, real roughness)
{
    real partLambdaV = GetSmithJointGGXPartLambdaVApprox(NdotV, roughness);
    return V_SmithJointGGXApprox(NdotL, NdotV, roughness, partLambdaV);
}

// roughnessT -> roughness in tangent direction
// roughnessB -> roughness in bitangent direction
real D_GGXAnisoNoPI(real TdotH, real BdotH, real NdotH, real roughnessT, real roughnessB)
{
    real a2 = roughnessT * roughnessB;
    real3 v = real3(roughnessB * TdotH, roughnessT * BdotH, a2 * NdotH);
    real  s = dot(v, v);

    // If roughness is 0, returns (NdotH == 1 ? 1 : 0).
    // That is, it returns 1 for perfect mirror reflection, and 0 otherwise.
    return SafeDiv(a2 * a2 * a2, s * s);
}

real D_GGXAniso(real TdotH, real BdotH, real NdotH, real roughnessT, real roughnessB)
{
    return INV_PI * D_GGXAnisoNoPI(TdotH, BdotH, NdotH, roughnessT, roughnessB);
}

real GetSmithJointGGXAnisoPartLambdaV(real TdotV, real BdotV, real NdotV, real roughnessT, real roughnessB)
{
    return length(real3(roughnessT * TdotV, roughnessB * BdotV, NdotV));
}

// Note: V = G / (4 * NdotL * NdotV)
// Ref: https://cedec.cesa.or.jp/2015/session/ENG/14698.html The Rendering Materials of Far Cry 4
real V_SmithJointGGXAniso(real TdotV, real BdotV, real NdotV, real TdotL, real BdotL, real NdotL, real roughnessT, real roughnessB, real partLambdaV)
{
    real lambdaV = NdotL * partLambdaV;
    real lambdaL = NdotV * length(real3(roughnessT * TdotL, roughnessB * BdotL, NdotL));

    return 0.5 / (lambdaV + lambdaL);
}

real V_SmithJointGGXAniso(real TdotV, real BdotV, real NdotV, real TdotL, real BdotL, real NdotL, real roughnessT, real roughnessB)
{
    real partLambdaV = GetSmithJointGGXAnisoPartLambdaV(TdotV, BdotV, NdotV, roughnessT, roughnessB);
    return V_SmithJointGGXAniso(TdotV, BdotV, NdotV, TdotL, BdotL, NdotL, roughnessT, roughnessB, partLambdaV);
}

// Inline D_GGXAniso() * V_SmithJointGGXAniso() together for better code generation.
real DV_SmithJointGGXAniso(real TdotH, real BdotH, real NdotH, real NdotV,
                           real TdotL, real BdotL, real NdotL,
                           real roughnessT, real roughnessB, real partLambdaV)
{
    real a2 = roughnessT * roughnessB;
    real3 v = real3(roughnessB * TdotH, roughnessT * BdotH, a2 * NdotH);
    real  s = dot(v, v);

    real lambdaV = NdotL * partLambdaV;
    real lambdaL = NdotV * length(real3(roughnessT * TdotL, roughnessB * BdotL, NdotL));

    real2 D = real2(a2 * a2 * a2, s * s);  // Fraction without the multiplier (1/Pi)
    real2 G = real2(1, lambdaV + lambdaL); // Fraction without the multiplier (1/2)

    // This function is only used for direct lighting.
    // If roughness is 0, the probability of hitting a punctual or directional light is also 0.
    // Therefore, we return 0. The most efficient way to do it is with a max().
    return (INV_PI * 0.5) * (D.x * G.x) / max(D.y * G.y, REAL_MIN);
}

real DV_SmithJointGGXAniso(real TdotH, real BdotH, real NdotH,
                           real TdotV, real BdotV, real NdotV,
                           real TdotL, real BdotL, real NdotL,
                           real roughnessT, real roughnessB)
{
    real partLambdaV = GetSmithJointGGXAnisoPartLambdaV(TdotV, BdotV, NdotV, roughnessT, roughnessB);
    return DV_SmithJointGGXAniso(TdotH, BdotH, NdotH, NdotV,
                                 TdotL, BdotL, NdotL,
                                 roughnessT, roughnessB, partLambdaV);
}

// Get projected roughness for a certain normalized direction V in tangent space
// and an anisotropic roughness
// Ref: Understanding the Masking-Shadowing Function in Microfacet-Based BRDFs, Heitz 2014, pp. 86, 88 - 39/60, 41/60
float GetProjectedRoughness(float TdotV, float BdotV, float NdotV, float roughnessT, float roughnessB)
{
    float2 roughness = float2(roughnessT, roughnessB);
    float sinTheta2 = max((1 - Sq(NdotV)), FLT_MIN);
    // if sinTheta^2 = 0, NdotV = 1, TdotV = BdotV = 0 and roughness is arbitrary, no real azimuth
    // as there's a breakdown of the spherical parameterization, so we clamp under by FLT_MIN in any case
    // for safe division
    // Note:
    //       sin(thetaV)^2 * cos(phiV)^2 = (TdotV)^2
    //       sin(thetaV)^2 * sin(phiV)^2 = (BdotV)^2
    float2 vProj2 = Sq(float2(TdotV, BdotV)) * rcp(sinTheta2);
    //       vProj2 = (cos^2(phi), sin^2(phi))
    float projRoughness = sqrt(dot(vProj2, roughness*roughness));
    return projRoughness;
}

//-----------------------------------------------------------------------------
// Diffuse BRDF - diffuseColor is expected to be multiply by the caller
//-----------------------------------------------------------------------------

real LambertNoPI()
{
    return 1.0;
}

real Lambert()
{
    return INV_PI;
}

real DisneyDiffuseNoPI(real NdotV, real NdotL, real LdotV, real perceptualRoughness)
{
    // (2 * LdotH * LdotH) = 1 + LdotV
    // real fd90 = 0.5 + (2 * LdotH * LdotH) * perceptualRoughness;
    real fd90 = 0.5 + (perceptualRoughness + perceptualRoughness * LdotV);
    // Two schlick fresnel term
    real lightScatter = F_Schlick(1.0, fd90, NdotL);
    real viewScatter = F_Schlick(1.0, fd90, NdotV);

    // Normalize the BRDF for polar view angles of up to (Pi/4).
    // We use the worst case of (roughness = albedo = 1), and, for each view angle,
    // integrate (brdf * cos(theta_light)) over all light directions.
    // The resulting value is for (theta_view = 0), which is actually a little bit larger
    // than the value of the integral for (theta_view = Pi/4).
    // Hopefully, the compiler folds the constant together with (1/Pi).
    return rcp(1.03571) * (lightScatter * viewScatter);
}

real DisneyDiffuse(real NdotV, real NdotL, real LdotV, real perceptualRoughness)
{
    return INV_PI * DisneyDiffuseNoPI(NdotV, NdotL, LdotV, perceptualRoughness);
}

// Ref: Diffuse Lighting for GGX + Smith Microsurfaces, p. 113.
real3 DiffuseGGXNoPI(real3 albedo, real NdotV, real NdotL, real NdotH, real LdotV, real roughness)
{
    real facing = 0.5 + 0.5 * LdotV;              // (LdotH)^2
    real rough = facing * (0.9 - 0.4 * facing) * (0.5 / NdotH + 1);
    real transmitL = F_Transm_Schlick(0, NdotL);
    real transmitV = F_Transm_Schlick(0, NdotV);
    real smooth = transmitL * transmitV * 1.05;   // Normalize F_t over the hemisphere
    real single = lerp(smooth, rough, roughness); // Rescaled by PI
    real multiple = roughness * (0.1159 * PI);      // Rescaled by PI

    return single + albedo * multiple;
}

real3 DiffuseGGX(real3 albedo, real NdotV, real NdotL, real NdotH, real LdotV, real roughness)
{
    // Note that we could save 2 cycles by inlining the multiplication by INV_PI.
    return INV_PI * DiffuseGGXNoPI(albedo, NdotV, NdotL, NdotH, LdotV, roughness);
}

//-----------------------------------------------------------------------------
// Iridescence
//-----------------------------------------------------------------------------

// Ref: https://belcour.github.io/blog/research/2017/05/01/brdf-thin-film.html
// Evaluation XYZ sensitivity curves in Fourier space
real3 EvalSensitivity(real opd, real shift)
{
    // Use Gaussian fits, given by 3 parameters: val, pos and var
    real phase = 2.0 * PI * opd * 1e-6;
    real3 val = real3(5.4856e-13, 4.4201e-13, 5.2481e-13);
    real3 pos = real3(1.6810e+06, 1.7953e+06, 2.2084e+06);
    real3 var = real3(4.3278e+09, 9.3046e+09, 6.6121e+09);
    real3 xyz = val * sqrt(2.0 * PI * var) * cos(pos * phase + shift) * exp(-var * phase * phase);
    xyz.x += 9.7470e-14 * sqrt(2.0 * PI * 4.5282e+09) * cos(2.2399e+06 * phase + shift) * exp(-4.5282e+09 * phase * phase);
    xyz /= 1.0685e-7;

    // Convert to linear sRGb color space here.
    // EvalIridescence works in linear sRGB color space and does not switch...
    real3 srgb = mul(XYZ_2_REC709_MAT, xyz);
    return srgb;
}

// Evaluate the reflectance for a thin-film layer on top of a dielectric medum.
real3 EvalIridescence(real eta_1, real cosTheta1, real iridescenceThickness, real3 baseLayerFresnel0, real iorOverBaseLayer = 0.0)
{
    real3 I;

    // iridescenceThickness unit is micrometer for this equation here. Mean 0.5 is 500nm.
    real Dinc = 3.0 * iridescenceThickness;

    // Note: Unlike the code provide with the paper, here we use schlick approximation
    // Schlick is a very poor approximation when dealing with iridescence to the Fresnel
    // term and there is no "neutral" value in this unlike in the original paper.
    // We use Iridescence mask here to allow to have neutral value

    // Hack: In order to use only one parameter (DInc), we deduced the ior of iridescence from current Dinc iridescenceThickness
    // and we use mask instead to fade out the effect
    real eta_2 = lerp(2.0, 1.0, iridescenceThickness);
    // Following line from original code is not needed for us, it create a discontinuity
    // Force eta_2 -> eta_1 when Dinc -> 0.0
    // real eta_2 = lerp(eta_1, eta_2, smoothstep(0.0, 0.03, Dinc));
    // Evaluate the cosTheta on the base layer (Snell law)
    real sinTheta2Sq = Sq(eta_1 / eta_2) * (1.0 - Sq(cosTheta1));

    // Handle TIR:
    // (Also note that with just testing sinTheta2Sq > 1.0, (1.0 - sinTheta2Sq) can be negative, as emitted instructions
    // can eg be a mad giving a small negative for (1.0 - sinTheta2Sq), while sinTheta2Sq still testing equal to 1.0), so we actually
    // test the operand [cosTheta2Sq := (1.0 - sinTheta2Sq)] < 0 directly:)
    real cosTheta2Sq = (1.0 - sinTheta2Sq);
    // Or use this "artistic hack" to get more continuity even though wrong (no TIR, continue the effect by mirroring it):
    //   if( cosTheta2Sq < 0.0 ) => { sinTheta2Sq = 2 - sinTheta2Sq; => so cosTheta2Sq = sinTheta2Sq - 1 }
    // ie don't test and simply do
    //   real cosTheta2Sq = abs(1.0 - sinTheta2Sq);
    if (cosTheta2Sq < 0.0)
        I = real3(1.0, 1.0, 1.0);
    else
    {

        real cosTheta2 = sqrt(cosTheta2Sq);

        // First interface
        real R0 = IorToFresnel0(eta_2, eta_1);
        real R12 = F_Schlick(R0, cosTheta1);
        real R21 = R12;
        real T121 = 1.0 - R12;
        real phi12 = 0.0;
        real phi21 = PI - phi12;

        // Second interface
        // The f0 or the base should account for the new computed eta_2 on top.
        // This is optionally done if we are given the needed current ior over the base layer that is accounted for
        // in the baseLayerFresnel0 parameter:
        if (iorOverBaseLayer > 0.0)
        {
            // Fresnel0ToIor will give us a ratio of baseIor/topIor, hence we * iorOverBaseLayer to get the baseIor
            real3 baseIor = iorOverBaseLayer * Fresnel0ToIor(baseLayerFresnel0 + 0.0001); // guard against 1.0
            baseLayerFresnel0 = IorToFresnel0(baseIor, eta_2);
        }

        real3 R23 = F_Schlick(baseLayerFresnel0, cosTheta2);
        real  phi23 = 0.0;

        // Phase shift
        real OPD = Dinc * cosTheta2;
        real phi = phi21 + phi23;

        // Compound terms
        real3 R123 = clamp(R12 * R23, 1e-5, 0.9999);
        real3 r123 = sqrt(R123);
        real3 Rs = Sq(T121) * R23 / (real3(1.0, 1.0, 1.0) - R123);

        // Reflectance term for m = 0 (DC term amplitude)
        real3 C0 = R12 + Rs;
        I = C0;

        // Reflectance term for m > 0 (pairs of diracs)
        real3 Cm = Rs - T121;
        for (int m = 1; m <= 2; ++m)
        {
            Cm *= r123;
            real3 Sm = 2.0 * EvalSensitivity(m * OPD, m * phi);
            //vec3 SmP = 2.0 * evalSensitivity(m*OPD, m*phi2.y);
            I += Cm * Sm;
        }

        // Since out of gamut colors might be produced, negative color values are clamped to 0.
        I = max(I, float3(0.0, 0.0, 0.0));
    }

    return I;
}

//-----------------------------------------------------------------------------
// Fabric
//-----------------------------------------------------------------------------

// Ref: https://knarkowicz.wordpress.com/2018/01/04/cloth-shading/
real D_CharlieNoPI(real NdotH, real roughness)
{
    float invR = rcp(roughness);
    float cos2h = NdotH * NdotH;
    float sin2h = 1.0 - cos2h;
    // Note: We have sin^2 so multiply by 0.5 to cancel it
    return (2.0 + invR) * PositivePow(sin2h, invR * 0.5) / 2.0;
}

real D_Charlie(real NdotH, real roughness)
{
    return INV_PI * D_CharlieNoPI(NdotH, roughness);
}

real CharlieL(real x, real r)
{
    r = saturate(r);
    r = 1.0 - (1.0 - r) * (1.0 - r);

    float a = lerp(25.3245, 21.5473, r);
    float b = lerp(3.32435, 3.82987, r);
    float c = lerp(0.16801, 0.19823, r);
    float d = lerp(-1.27393, -1.97760, r);
    float e = lerp(-4.85967, -4.32054, r);

    return a / (1. + b * PositivePow(x, c)) + d * x + e;
}

// Note: This version don't include the softening of the paper: Production Friendly Microfacet Sheen BRDF
real V_Charlie(real NdotL, real NdotV, real roughness)
{
    real lambdaV = NdotV < 0.5 ? exp(CharlieL(NdotV, roughness)) : exp(2.0 * CharlieL(0.5, roughness) - CharlieL(1.0 - NdotV, roughness));
    real lambdaL = NdotL < 0.5 ? exp(CharlieL(NdotL, roughness)) : exp(2.0 * CharlieL(0.5, roughness) - CharlieL(1.0 - NdotL, roughness));

    return 1.0 / ((1.0 + lambdaV + lambdaL) * (4.0 * NdotV * NdotL));
}

// We use V_Ashikhmin instead of V_Charlie in practice for game due to the cost of V_Charlie
real V_Ashikhmin(real NdotL, real NdotV)
{
    // Use soft visibility term introduce in: Crafting a Next-Gen Material Pipeline for The Order : 1886
    return 1.0 / (4.0 * (NdotL + NdotV - NdotL * NdotV));
}

// A diffuse term use with fabric done by tech artist - empirical
real FabricLambertNoPI(real roughness)
{
    return lerp(1.0, 0.5, roughness);
}

real FabricLambert(real roughness)
{
    return INV_PI * FabricLambertNoPI(roughness);
}

real G_CookTorrance(real NdotH, real NdotV, real NdotL, real HdotV)
{
    return min(1.0, 2.0 * NdotH * min(NdotV, NdotL) / HdotV);
}

//-----------------------------------------------------------------------------
// Hair
//-----------------------------------------------------------------------------

//http://web.engr.oregonstate.edu/~mjb/cs519/Projects/Papers/HairRendering.pdf
real3 ShiftTangent(real3 T, real3 N, real shift)
{
    return normalize(T + N * shift);
}

// Note: this is Blinn-Phong, the original paper uses Phong.
real3 D_KajiyaKay(real3 T, real3 H, real specularExponent)
{
    real TdotH = dot(T, H);
    real sinTHSq = saturate(1.0 - TdotH * TdotH);

    real dirAttn = saturate(TdotH + 1.0); // Evgenii: this seems like a hack? Do we really need this?

                                           // Note: Kajiya-Kay is not energy conserving.
                                           // We attempt at least some energy conservation by approximately normalizing Blinn-Phong NDF.
                                           // We use the formulation with the NdotL.
                                           // See http://www.thetenthplanet.de/archives/255.
    real n = specularExponent;
    real norm = (n + 2) * rcp(2 * PI);

    return dirAttn * norm * PositivePow(sinTHSq, 0.5 * n);
}
#endif // UNITY_BSDF_INCLUDED

// File end: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/BSDF.hlsl
//================================================================================================================================



//================================================================================================================================
// File start: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/Sampling/Sampling.hlsl


#ifndef UNITY_SAMPLING_INCLUDED
#define UNITY_SAMPLING_INCLUDED

//-----------------------------------------------------------------------------
// Sample generator
//-----------------------------------------------------------------------------

//================================================================================================================================
// File start: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/Sampling/Fibonacci.hlsl


#ifndef UNITY_FIBONACCI_INCLUDED
#define UNITY_FIBONACCI_INCLUDED

// Computes a point using the Fibonacci sequence of length N.
// Input: Fib[N - 1], Fib[N - 2], and the index 'i' of the point.
// Ref: Efficient Quadrature Rules for Illumination Integrals
real2 Fibonacci2dSeq(real fibN1, real fibN2, uint i)
{
    // 3 cycles on GCN if 'fibN1' and 'fibN2' are known at compile time.
    // N.b.: According to Swinbank and Pusser [SP06], the uniformity of the distribution
    // can be slightly improved by introducing an offset of 1/N to the Z (or R) coordinates.
    return real2(i / fibN1 + (0.5 / fibN1), frac(i * (fibN2 / fibN1)));
}

#define GOLDEN_RATIO 1.61803
#define GOLDEN_ANGLE 2.39996

// Replaces the Fibonacci sequence in Fibonacci2dSeq() with the Golden ratio.
real2 Golden2dSeq(uint i, real n)
{
    // GoldenAngle = 2 * Pi * (1 - 1 / GoldenRatio).
    // We can drop the "1 -" part since all it does is reverse the orientation.
    return real2(i / n + (0.5 / n), frac(i * rcp(GOLDEN_RATIO)));
}

static const uint k_FibonacciSeq[] = {
    0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, 1597, 2584, 4181
};

static const real2 k_Fibonacci2dSeq21[] = {
    real2(0.02380952, 0.00000000),
    real2(0.07142857, 0.61904764),
    real2(0.11904762, 0.23809528),
    real2(0.16666667, 0.85714293),
    real2(0.21428572, 0.47619057),
    real2(0.26190478, 0.09523821),
    real2(0.30952382, 0.71428585),
    real2(0.35714287, 0.33333349),
    real2(0.40476191, 0.95238113),
    real2(0.45238096, 0.57142878),
    real2(0.50000000, 0.19047642),
    real2(0.54761904, 0.80952406),
    real2(0.59523809, 0.42857170),
    real2(0.64285713, 0.04761887),
    real2(0.69047618, 0.66666698),
    real2(0.73809522, 0.28571510),
    real2(0.78571427, 0.90476227),
    real2(0.83333331, 0.52380943),
    real2(0.88095236, 0.14285755),
    real2(0.92857140, 0.76190567),
    real2(0.97619045, 0.38095284)
};

static const real2 k_Fibonacci2dSeq34[] = {
    real2(0.01470588, 0.00000000),
    real2(0.04411765, 0.61764705),
    real2(0.07352941, 0.23529410),
    real2(0.10294118, 0.85294116),
    real2(0.13235295, 0.47058821),
    real2(0.16176471, 0.08823538),
    real2(0.19117647, 0.70588231),
    real2(0.22058824, 0.32352924),
    real2(0.25000000, 0.94117641),
    real2(0.27941176, 0.55882359),
    real2(0.30882353, 0.17647076),
    real2(0.33823529, 0.79411745),
    real2(0.36764705, 0.41176462),
    real2(0.39705881, 0.02941132),
    real2(0.42647058, 0.64705849),
    real2(0.45588234, 0.26470566),
    real2(0.48529410, 0.88235283),
    real2(0.51470590, 0.50000000),
    real2(0.54411763, 0.11764717),
    real2(0.57352942, 0.73529434),
    real2(0.60294116, 0.35294151),
    real2(0.63235295, 0.97058773),
    real2(0.66176468, 0.58823490),
    real2(0.69117647, 0.20588207),
    real2(0.72058821, 0.82352924),
    real2(0.75000000, 0.44117641),
    real2(0.77941179, 0.05882263),
    real2(0.80882353, 0.67646980),
    real2(0.83823532, 0.29411697),
    real2(0.86764705, 0.91176414),
    real2(0.89705884, 0.52941132),
    real2(0.92647058, 0.14705849),
    real2(0.95588237, 0.76470566),
    real2(0.98529410, 0.38235283)
};

static const real2 k_Fibonacci2dSeq55[] = {
    real2(0.00909091, 0.00000000),
    real2(0.02727273, 0.61818182),
    real2(0.04545455, 0.23636365),
    real2(0.06363636, 0.85454547),
    real2(0.08181818, 0.47272730),
    real2(0.10000000, 0.09090900),
    real2(0.11818182, 0.70909095),
    real2(0.13636364, 0.32727289),
    real2(0.15454546, 0.94545460),
    real2(0.17272727, 0.56363630),
    real2(0.19090909, 0.18181801),
    real2(0.20909090, 0.80000019),
    real2(0.22727273, 0.41818190),
    real2(0.24545455, 0.03636360),
    real2(0.26363635, 0.65454578),
    real2(0.28181818, 0.27272701),
    real2(0.30000001, 0.89090919),
    real2(0.31818181, 0.50909138),
    real2(0.33636364, 0.12727261),
    real2(0.35454544, 0.74545479),
    real2(0.37272727, 0.36363602),
    real2(0.39090911, 0.98181820),
    real2(0.40909091, 0.60000038),
    real2(0.42727274, 0.21818161),
    real2(0.44545454, 0.83636379),
    real2(0.46363637, 0.45454597),
    real2(0.48181817, 0.07272720),
    real2(0.50000000, 0.69090843),
    real2(0.51818180, 0.30909157),
    real2(0.53636366, 0.92727280),
    real2(0.55454546, 0.54545403),
    real2(0.57272726, 0.16363716),
    real2(0.59090906, 0.78181839),
    real2(0.60909092, 0.39999962),
    real2(0.62727273, 0.01818275),
    real2(0.64545453, 0.63636398),
    real2(0.66363639, 0.25454521),
    real2(0.68181819, 0.87272835),
    real2(0.69999999, 0.49090958),
    real2(0.71818179, 0.10909081),
    real2(0.73636365, 0.72727203),
    real2(0.75454545, 0.34545517),
    real2(0.77272725, 0.96363640),
    real2(0.79090911, 0.58181763),
    real2(0.80909091, 0.20000076),
    real2(0.82727271, 0.81818199),
    real2(0.84545457, 0.43636322),
    real2(0.86363637, 0.05454636),
    real2(0.88181818, 0.67272758),
    real2(0.89999998, 0.29090881),
    real2(0.91818184, 0.90909195),
    real2(0.93636364, 0.52727318),
    real2(0.95454544, 0.14545441),
    real2(0.97272730, 0.76363754),
    real2(0.99090910, 0.38181686)
};

static const real2 k_Fibonacci2dSeq89[] = {
    real2(0.00561798, 0.00000000),
    real2(0.01685393, 0.61797750),
    real2(0.02808989, 0.23595500),
    real2(0.03932584, 0.85393250),
    real2(0.05056180, 0.47191000),
    real2(0.06179775, 0.08988762),
    real2(0.07303371, 0.70786500),
    real2(0.08426967, 0.32584238),
    real2(0.09550562, 0.94382000),
    real2(0.10674157, 0.56179762),
    real2(0.11797753, 0.17977524),
    real2(0.12921348, 0.79775238),
    real2(0.14044943, 0.41573000),
    real2(0.15168539, 0.03370762),
    real2(0.16292135, 0.65168476),
    real2(0.17415731, 0.26966286),
    real2(0.18539326, 0.88764000),
    real2(0.19662921, 0.50561714),
    real2(0.20786516, 0.12359524),
    real2(0.21910113, 0.74157238),
    real2(0.23033708, 0.35955048),
    real2(0.24157304, 0.97752762),
    real2(0.25280899, 0.59550476),
    real2(0.26404494, 0.21348286),
    real2(0.27528089, 0.83146000),
    real2(0.28651685, 0.44943714),
    real2(0.29775280, 0.06741524),
    real2(0.30898875, 0.68539238),
    real2(0.32022473, 0.30336952),
    real2(0.33146068, 0.92134666),
    real2(0.34269664, 0.53932571),
    real2(0.35393259, 0.15730286),
    real2(0.36516854, 0.77528000),
    real2(0.37640449, 0.39325714),
    real2(0.38764045, 0.01123428),
    real2(0.39887640, 0.62921333),
    real2(0.41011235, 0.24719048),
    real2(0.42134830, 0.86516762),
    real2(0.43258426, 0.48314476),
    real2(0.44382024, 0.10112190),
    real2(0.45505619, 0.71910095),
    real2(0.46629214, 0.33707809),
    real2(0.47752810, 0.95505524),
    real2(0.48876405, 0.57303238),
    real2(0.50000000, 0.19100952),
    real2(0.51123595, 0.80898666),
    real2(0.52247190, 0.42696571),
    real2(0.53370786, 0.04494286),
    real2(0.54494381, 0.66292000),
    real2(0.55617976, 0.28089714),
    real2(0.56741571, 0.89887428),
    real2(0.57865167, 0.51685333),
    real2(0.58988762, 0.13483047),
    real2(0.60112357, 0.75280762),
    real2(0.61235952, 0.37078476),
    real2(0.62359548, 0.98876190),
    real2(0.63483149, 0.60673904),
    real2(0.64606744, 0.22471619),
    real2(0.65730339, 0.84269333),
    real2(0.66853935, 0.46067429),
    real2(0.67977530, 0.07865143),
    real2(0.69101125, 0.69662857),
    real2(0.70224720, 0.31460571),
    real2(0.71348315, 0.93258286),
    real2(0.72471911, 0.55056000),
    real2(0.73595506, 0.16853714),
    real2(0.74719101, 0.78651428),
    real2(0.75842696, 0.40449142),
    real2(0.76966292, 0.02246857),
    real2(0.78089887, 0.64044571),
    real2(0.79213482, 0.25842667),
    real2(0.80337077, 0.87640381),
    real2(0.81460673, 0.49438095),
    real2(0.82584268, 0.11235809),
    real2(0.83707863, 0.73033524),
    real2(0.84831458, 0.34831238),
    real2(0.85955054, 0.96628952),
    real2(0.87078649, 0.58426666),
    real2(0.88202250, 0.20224380),
    real2(0.89325845, 0.82022095),
    real2(0.90449440, 0.43820190),
    real2(0.91573036, 0.05617905),
    real2(0.92696631, 0.67415619),
    real2(0.93820226, 0.29213333),
    real2(0.94943821, 0.91011047),
    real2(0.96067417, 0.52808762),
    real2(0.97191012, 0.14606476),
    real2(0.98314607, 0.76404190),
    real2(0.99438202, 0.38201904)
};

// Loads elements from one of the precomputed tables for sample counts of 21, 34, 55, and 89.
// Computes sample positions at runtime otherwise.
// Sample count must be a Fibonacci number (see 'k_FibonacciSeq').
real2 Fibonacci2d(uint i, uint sampleCount)
{
    switch (sampleCount)
    {
        case 21: return k_Fibonacci2dSeq21[i];
        case 34: return k_Fibonacci2dSeq34[i];
        case 55: return k_Fibonacci2dSeq55[i];
        case 89: return k_Fibonacci2dSeq89[i];
        default:
        {
            uint fibN1 = sampleCount;
            uint fibN2 = sampleCount;

            // These are all constants, so this loop will be optimized away.
            for (uint j = 1; j < 20; j++)
            {
                if (k_FibonacciSeq[j] == fibN1)
                {
                    fibN2 = k_FibonacciSeq[j - 1];
                }
            }

            return Fibonacci2dSeq(fibN1, fibN2, i);
        }
    }
}

// Returns the radius as the X coordinate, and the angle as the Y coordinate.
real2 SampleDiskFibonacci(uint i, uint sampleCount)
{
    real2 f = Fibonacci2d(i, sampleCount);
    return real2(sqrt(f.x), TWO_PI * f.y);
}

// Returns the zenith as the X coordinate, and the azimuthal angle as the Y coordinate.
real2 SampleHemisphereFibonacci(uint i, uint sampleCount)
{
    real2 f = Fibonacci2d(i, sampleCount);
    return real2(1 - f.x, TWO_PI * f.y);
}

// Returns the zenith as the X coordinate, and the azimuthal angle as the Y coordinate.
real2 SampleSphereFibonacci(uint i, uint sampleCount)
{
    real2 f = Fibonacci2d(i, sampleCount);
    return real2(1 - 2 * f.x, TWO_PI * f.y);
}

#endif // UNITY_FIBONACCI_INCLUDED

// File end: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/Sampling/Fibonacci.hlsl
//================================================================================================================================



//================================================================================================================================
// File start: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/Sampling/Hammersley.hlsl


#ifndef UNITY_HAMMERSLEY_INCLUDED
#define UNITY_HAMMERSLEY_INCLUDED

// Ref: http://holger.dammertz.org/stuff/notes_HammersleyOnHemisphere.html
uint ReverseBits32(uint bits)
{
#if (SHADER_TARGET >= 45)
    return reversebits(bits);
#else
    bits = (bits << 16) | (bits >> 16);
    bits = ((bits & 0x00ff00ff) << 8) | ((bits & 0xff00ff00) >> 8);
    bits = ((bits & 0x0f0f0f0f) << 4) | ((bits & 0xf0f0f0f0) >> 4);
    bits = ((bits & 0x33333333) << 2) | ((bits & 0xcccccccc) >> 2);
    bits = ((bits & 0x55555555) << 1) | ((bits & 0xaaaaaaaa) >> 1);
    return bits;
#endif
}

real VanDerCorputBase2(uint i)
{
    return ReverseBits32(i) * rcp(4294967296.0); // 2^-32
}

real2 Hammersley2dSeq(uint i, uint sequenceLength)
{
    return real2(real(i) / real(sequenceLength), VanDerCorputBase2(i));
}

static const real2 k_Hammersley2dSeq16[] = {
    real2(0.00000000, 0.00000000),
    real2(0.06250000, 0.50000000),
    real2(0.12500000, 0.25000000),
    real2(0.18750000, 0.75000000),
    real2(0.25000000, 0.12500000),
    real2(0.31250000, 0.62500000),
    real2(0.37500000, 0.37500000),
    real2(0.43750000, 0.87500000),
    real2(0.50000000, 0.06250000),
    real2(0.56250000, 0.56250000),
    real2(0.62500000, 0.31250000),
    real2(0.68750000, 0.81250000),
    real2(0.75000000, 0.18750000),
    real2(0.81250000, 0.68750000),
    real2(0.87500000, 0.43750000),
    real2(0.93750000, 0.93750000)
};

static const real2 k_Hammersley2dSeq32[] = {
    real2(0.00000000, 0.00000000),
    real2(0.03125000, 0.50000000),
    real2(0.06250000, 0.25000000),
    real2(0.09375000, 0.75000000),
    real2(0.12500000, 0.12500000),
    real2(0.15625000, 0.62500000),
    real2(0.18750000, 0.37500000),
    real2(0.21875000, 0.87500000),
    real2(0.25000000, 0.06250000),
    real2(0.28125000, 0.56250000),
    real2(0.31250000, 0.31250000),
    real2(0.34375000, 0.81250000),
    real2(0.37500000, 0.18750000),
    real2(0.40625000, 0.68750000),
    real2(0.43750000, 0.43750000),
    real2(0.46875000, 0.93750000),
    real2(0.50000000, 0.03125000),
    real2(0.53125000, 0.53125000),
    real2(0.56250000, 0.28125000),
    real2(0.59375000, 0.78125000),
    real2(0.62500000, 0.15625000),
    real2(0.65625000, 0.65625000),
    real2(0.68750000, 0.40625000),
    real2(0.71875000, 0.90625000),
    real2(0.75000000, 0.09375000),
    real2(0.78125000, 0.59375000),
    real2(0.81250000, 0.34375000),
    real2(0.84375000, 0.84375000),
    real2(0.87500000, 0.21875000),
    real2(0.90625000, 0.71875000),
    real2(0.93750000, 0.46875000),
    real2(0.96875000, 0.96875000)
};

static const real2 k_Hammersley2dSeq64[] = {
    real2(0.00000000, 0.00000000),
    real2(0.01562500, 0.50000000),
    real2(0.03125000, 0.25000000),
    real2(0.04687500, 0.75000000),
    real2(0.06250000, 0.12500000),
    real2(0.07812500, 0.62500000),
    real2(0.09375000, 0.37500000),
    real2(0.10937500, 0.87500000),
    real2(0.12500000, 0.06250000),
    real2(0.14062500, 0.56250000),
    real2(0.15625000, 0.31250000),
    real2(0.17187500, 0.81250000),
    real2(0.18750000, 0.18750000),
    real2(0.20312500, 0.68750000),
    real2(0.21875000, 0.43750000),
    real2(0.23437500, 0.93750000),
    real2(0.25000000, 0.03125000),
    real2(0.26562500, 0.53125000),
    real2(0.28125000, 0.28125000),
    real2(0.29687500, 0.78125000),
    real2(0.31250000, 0.15625000),
    real2(0.32812500, 0.65625000),
    real2(0.34375000, 0.40625000),
    real2(0.35937500, 0.90625000),
    real2(0.37500000, 0.09375000),
    real2(0.39062500, 0.59375000),
    real2(0.40625000, 0.34375000),
    real2(0.42187500, 0.84375000),
    real2(0.43750000, 0.21875000),
    real2(0.45312500, 0.71875000),
    real2(0.46875000, 0.46875000),
    real2(0.48437500, 0.96875000),
    real2(0.50000000, 0.01562500),
    real2(0.51562500, 0.51562500),
    real2(0.53125000, 0.26562500),
    real2(0.54687500, 0.76562500),
    real2(0.56250000, 0.14062500),
    real2(0.57812500, 0.64062500),
    real2(0.59375000, 0.39062500),
    real2(0.60937500, 0.89062500),
    real2(0.62500000, 0.07812500),
    real2(0.64062500, 0.57812500),
    real2(0.65625000, 0.32812500),
    real2(0.67187500, 0.82812500),
    real2(0.68750000, 0.20312500),
    real2(0.70312500, 0.70312500),
    real2(0.71875000, 0.45312500),
    real2(0.73437500, 0.95312500),
    real2(0.75000000, 0.04687500),
    real2(0.76562500, 0.54687500),
    real2(0.78125000, 0.29687500),
    real2(0.79687500, 0.79687500),
    real2(0.81250000, 0.17187500),
    real2(0.82812500, 0.67187500),
    real2(0.84375000, 0.42187500),
    real2(0.85937500, 0.92187500),
    real2(0.87500000, 0.10937500),
    real2(0.89062500, 0.60937500),
    real2(0.90625000, 0.35937500),
    real2(0.92187500, 0.85937500),
    real2(0.93750000, 0.23437500),
    real2(0.95312500, 0.73437500),
    real2(0.96875000, 0.48437500),
    real2(0.98437500, 0.98437500)
};

static const real2 k_Hammersley2dSeq256[] = {
    real2(0.00000000, 0.00000000),
    real2(0.00390625, 0.50000000),
    real2(0.00781250, 0.25000000),
    real2(0.01171875, 0.75000000),
    real2(0.01562500, 0.12500000),
    real2(0.01953125, 0.62500000),
    real2(0.02343750, 0.37500000),
    real2(0.02734375, 0.87500000),
    real2(0.03125000, 0.06250000),
    real2(0.03515625, 0.56250000),
    real2(0.03906250, 0.31250000),
    real2(0.04296875, 0.81250000),
    real2(0.04687500, 0.18750000),
    real2(0.05078125, 0.68750000),
    real2(0.05468750, 0.43750000),
    real2(0.05859375, 0.93750000),
    real2(0.06250000, 0.03125000),
    real2(0.06640625, 0.53125000),
    real2(0.07031250, 0.28125000),
    real2(0.07421875, 0.78125000),
    real2(0.07812500, 0.15625000),
    real2(0.08203125, 0.65625000),
    real2(0.08593750, 0.40625000),
    real2(0.08984375, 0.90625000),
    real2(0.09375000, 0.09375000),
    real2(0.09765625, 0.59375000),
    real2(0.10156250, 0.34375000),
    real2(0.10546875, 0.84375000),
    real2(0.10937500, 0.21875000),
    real2(0.11328125, 0.71875000),
    real2(0.11718750, 0.46875000),
    real2(0.12109375, 0.96875000),
    real2(0.12500000, 0.01562500),
    real2(0.12890625, 0.51562500),
    real2(0.13281250, 0.26562500),
    real2(0.13671875, 0.76562500),
    real2(0.14062500, 0.14062500),
    real2(0.14453125, 0.64062500),
    real2(0.14843750, 0.39062500),
    real2(0.15234375, 0.89062500),
    real2(0.15625000, 0.07812500),
    real2(0.16015625, 0.57812500),
    real2(0.16406250, 0.32812500),
    real2(0.16796875, 0.82812500),
    real2(0.17187500, 0.20312500),
    real2(0.17578125, 0.70312500),
    real2(0.17968750, 0.45312500),
    real2(0.18359375, 0.95312500),
    real2(0.18750000, 0.04687500),
    real2(0.19140625, 0.54687500),
    real2(0.19531250, 0.29687500),
    real2(0.19921875, 0.79687500),
    real2(0.20312500, 0.17187500),
    real2(0.20703125, 0.67187500),
    real2(0.21093750, 0.42187500),
    real2(0.21484375, 0.92187500),
    real2(0.21875000, 0.10937500),
    real2(0.22265625, 0.60937500),
    real2(0.22656250, 0.35937500),
    real2(0.23046875, 0.85937500),
    real2(0.23437500, 0.23437500),
    real2(0.23828125, 0.73437500),
    real2(0.24218750, 0.48437500),
    real2(0.24609375, 0.98437500),
    real2(0.25000000, 0.00781250),
    real2(0.25390625, 0.50781250),
    real2(0.25781250, 0.25781250),
    real2(0.26171875, 0.75781250),
    real2(0.26562500, 0.13281250),
    real2(0.26953125, 0.63281250),
    real2(0.27343750, 0.38281250),
    real2(0.27734375, 0.88281250),
    real2(0.28125000, 0.07031250),
    real2(0.28515625, 0.57031250),
    real2(0.28906250, 0.32031250),
    real2(0.29296875, 0.82031250),
    real2(0.29687500, 0.19531250),
    real2(0.30078125, 0.69531250),
    real2(0.30468750, 0.44531250),
    real2(0.30859375, 0.94531250),
    real2(0.31250000, 0.03906250),
    real2(0.31640625, 0.53906250),
    real2(0.32031250, 0.28906250),
    real2(0.32421875, 0.78906250),
    real2(0.32812500, 0.16406250),
    real2(0.33203125, 0.66406250),
    real2(0.33593750, 0.41406250),
    real2(0.33984375, 0.91406250),
    real2(0.34375000, 0.10156250),
    real2(0.34765625, 0.60156250),
    real2(0.35156250, 0.35156250),
    real2(0.35546875, 0.85156250),
    real2(0.35937500, 0.22656250),
    real2(0.36328125, 0.72656250),
    real2(0.36718750, 0.47656250),
    real2(0.37109375, 0.97656250),
    real2(0.37500000, 0.02343750),
    real2(0.37890625, 0.52343750),
    real2(0.38281250, 0.27343750),
    real2(0.38671875, 0.77343750),
    real2(0.39062500, 0.14843750),
    real2(0.39453125, 0.64843750),
    real2(0.39843750, 0.39843750),
    real2(0.40234375, 0.89843750),
    real2(0.40625000, 0.08593750),
    real2(0.41015625, 0.58593750),
    real2(0.41406250, 0.33593750),
    real2(0.41796875, 0.83593750),
    real2(0.42187500, 0.21093750),
    real2(0.42578125, 0.71093750),
    real2(0.42968750, 0.46093750),
    real2(0.43359375, 0.96093750),
    real2(0.43750000, 0.05468750),
    real2(0.44140625, 0.55468750),
    real2(0.44531250, 0.30468750),
    real2(0.44921875, 0.80468750),
    real2(0.45312500, 0.17968750),
    real2(0.45703125, 0.67968750),
    real2(0.46093750, 0.42968750),
    real2(0.46484375, 0.92968750),
    real2(0.46875000, 0.11718750),
    real2(0.47265625, 0.61718750),
    real2(0.47656250, 0.36718750),
    real2(0.48046875, 0.86718750),
    real2(0.48437500, 0.24218750),
    real2(0.48828125, 0.74218750),
    real2(0.49218750, 0.49218750),
    real2(0.49609375, 0.99218750),
    real2(0.50000000, 0.00390625),
    real2(0.50390625, 0.50390625),
    real2(0.50781250, 0.25390625),
    real2(0.51171875, 0.75390625),
    real2(0.51562500, 0.12890625),
    real2(0.51953125, 0.62890625),
    real2(0.52343750, 0.37890625),
    real2(0.52734375, 0.87890625),
    real2(0.53125000, 0.06640625),
    real2(0.53515625, 0.56640625),
    real2(0.53906250, 0.31640625),
    real2(0.54296875, 0.81640625),
    real2(0.54687500, 0.19140625),
    real2(0.55078125, 0.69140625),
    real2(0.55468750, 0.44140625),
    real2(0.55859375, 0.94140625),
    real2(0.56250000, 0.03515625),
    real2(0.56640625, 0.53515625),
    real2(0.57031250, 0.28515625),
    real2(0.57421875, 0.78515625),
    real2(0.57812500, 0.16015625),
    real2(0.58203125, 0.66015625),
    real2(0.58593750, 0.41015625),
    real2(0.58984375, 0.91015625),
    real2(0.59375000, 0.09765625),
    real2(0.59765625, 0.59765625),
    real2(0.60156250, 0.34765625),
    real2(0.60546875, 0.84765625),
    real2(0.60937500, 0.22265625),
    real2(0.61328125, 0.72265625),
    real2(0.61718750, 0.47265625),
    real2(0.62109375, 0.97265625),
    real2(0.62500000, 0.01953125),
    real2(0.62890625, 0.51953125),
    real2(0.63281250, 0.26953125),
    real2(0.63671875, 0.76953125),
    real2(0.64062500, 0.14453125),
    real2(0.64453125, 0.64453125),
    real2(0.64843750, 0.39453125),
    real2(0.65234375, 0.89453125),
    real2(0.65625000, 0.08203125),
    real2(0.66015625, 0.58203125),
    real2(0.66406250, 0.33203125),
    real2(0.66796875, 0.83203125),
    real2(0.67187500, 0.20703125),
    real2(0.67578125, 0.70703125),
    real2(0.67968750, 0.45703125),
    real2(0.68359375, 0.95703125),
    real2(0.68750000, 0.05078125),
    real2(0.69140625, 0.55078125),
    real2(0.69531250, 0.30078125),
    real2(0.69921875, 0.80078125),
    real2(0.70312500, 0.17578125),
    real2(0.70703125, 0.67578125),
    real2(0.71093750, 0.42578125),
    real2(0.71484375, 0.92578125),
    real2(0.71875000, 0.11328125),
    real2(0.72265625, 0.61328125),
    real2(0.72656250, 0.36328125),
    real2(0.73046875, 0.86328125),
    real2(0.73437500, 0.23828125),
    real2(0.73828125, 0.73828125),
    real2(0.74218750, 0.48828125),
    real2(0.74609375, 0.98828125),
    real2(0.75000000, 0.01171875),
    real2(0.75390625, 0.51171875),
    real2(0.75781250, 0.26171875),
    real2(0.76171875, 0.76171875),
    real2(0.76562500, 0.13671875),
    real2(0.76953125, 0.63671875),
    real2(0.77343750, 0.38671875),
    real2(0.77734375, 0.88671875),
    real2(0.78125000, 0.07421875),
    real2(0.78515625, 0.57421875),
    real2(0.78906250, 0.32421875),
    real2(0.79296875, 0.82421875),
    real2(0.79687500, 0.19921875),
    real2(0.80078125, 0.69921875),
    real2(0.80468750, 0.44921875),
    real2(0.80859375, 0.94921875),
    real2(0.81250000, 0.04296875),
    real2(0.81640625, 0.54296875),
    real2(0.82031250, 0.29296875),
    real2(0.82421875, 0.79296875),
    real2(0.82812500, 0.16796875),
    real2(0.83203125, 0.66796875),
    real2(0.83593750, 0.41796875),
    real2(0.83984375, 0.91796875),
    real2(0.84375000, 0.10546875),
    real2(0.84765625, 0.60546875),
    real2(0.85156250, 0.35546875),
    real2(0.85546875, 0.85546875),
    real2(0.85937500, 0.23046875),
    real2(0.86328125, 0.73046875),
    real2(0.86718750, 0.48046875),
    real2(0.87109375, 0.98046875),
    real2(0.87500000, 0.02734375),
    real2(0.87890625, 0.52734375),
    real2(0.88281250, 0.27734375),
    real2(0.88671875, 0.77734375),
    real2(0.89062500, 0.15234375),
    real2(0.89453125, 0.65234375),
    real2(0.89843750, 0.40234375),
    real2(0.90234375, 0.90234375),
    real2(0.90625000, 0.08984375),
    real2(0.91015625, 0.58984375),
    real2(0.91406250, 0.33984375),
    real2(0.91796875, 0.83984375),
    real2(0.92187500, 0.21484375),
    real2(0.92578125, 0.71484375),
    real2(0.92968750, 0.46484375),
    real2(0.93359375, 0.96484375),
    real2(0.93750000, 0.05859375),
    real2(0.94140625, 0.55859375),
    real2(0.94531250, 0.30859375),
    real2(0.94921875, 0.80859375),
    real2(0.95312500, 0.18359375),
    real2(0.95703125, 0.68359375),
    real2(0.96093750, 0.43359375),
    real2(0.96484375, 0.93359375),
    real2(0.96875000, 0.12109375),
    real2(0.97265625, 0.62109375),
    real2(0.97656250, 0.37109375),
    real2(0.98046875, 0.87109375),
    real2(0.98437500, 0.24609375),
    real2(0.98828125, 0.74609375),
    real2(0.99218750, 0.49609375),
    real2(0.99609375, 0.99609375)
};

// Loads elements from one of the precomputed tables for sample counts of 16, 32, 64, 256.
// Computes sample positions at runtime otherwise.
real2 Hammersley2d(uint i, uint sampleCount)
{
    switch (sampleCount)
    {
        case 16:  return k_Hammersley2dSeq16[i];
        case 32:  return k_Hammersley2dSeq32[i];
        case 64:  return k_Hammersley2dSeq64[i];
        case 256: return k_Hammersley2dSeq256[i];
        default:  return Hammersley2dSeq(i, sampleCount);
    }
}

#endif // UNITY_HAMMERSLEY_INCLUDED

// File end: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/Sampling/Hammersley.hlsl
//================================================================================================================================




//-----------------------------------------------------------------------------
// Coordinate system conversion
//-----------------------------------------------------------------------------

// Transforms the unit vector from the spherical to the Cartesian (right-handed, Z up) coordinate.
real3 SphericalToCartesian(real cosPhi, real sinPhi, real cosTheta)
{
    real sinTheta = SinFromCos(cosTheta);

    return real3(real2(cosPhi, sinPhi) * sinTheta, cosTheta);
}

real3 SphericalToCartesian(real phi, real cosTheta)
{
    real sinPhi, cosPhi;
    sincos(phi, sinPhi, cosPhi);

    return SphericalToCartesian(cosPhi, sinPhi, cosTheta);
}

// Converts Cartesian coordinates given in the right-handed coordinate system
// with Z pointing upwards (OpenGL style) to the coordinates in the left-handed
// coordinate system with Y pointing up and Z facing forward (DirectX style).
real3 TransformGLtoDX(real3 v)
{
    return v.xzy;
}

// Performs conversion from equiareal map coordinates to Cartesian (DirectX cubemap) ones.
real3 ConvertEquiarealToCubemap(real u, real v)
{
    real phi      = TWO_PI - TWO_PI * u;
    real cosTheta = 1.0 - 2.0 * v;

    return TransformGLtoDX(SphericalToCartesian(phi, cosTheta));
}

// Convert a texel position into normalized position [-1..1]x[-1..1]
real2 CubemapTexelToNVC(uint2 unPositionTXS, uint cubemapSize)
{
    return 2.0 * real2(unPositionTXS) / real(max(cubemapSize - 1, 1)) - 1.0;
}

// Map cubemap face to world vector basis
static const real3 CUBEMAP_FACE_BASIS_MAPPING[6][3] =
{
    //XPOS face
    {
        real3(0.0, 0.0, -1.0),
        real3(0.0, -1.0, 0.0),
        real3(1.0, 0.0, 0.0)
    },
    //XNEG face
    {
        real3(0.0, 0.0, 1.0),
        real3(0.0, -1.0, 0.0),
        real3(-1.0, 0.0, 0.0)
    },
    //YPOS face
    {
        real3(1.0, 0.0, 0.0),
        real3(0.0, 0.0, 1.0),
        real3(0.0, 1.0, 0.0)
    },
    //YNEG face
    {
        real3(1.0, 0.0, 0.0),
        real3(0.0, 0.0, -1.0),
        real3(0.0, -1.0, 0.0)
    },
    //ZPOS face
    {
        real3(1.0, 0.0, 0.0),
        real3(0.0, -1.0, 0.0),
        real3(0.0, 0.0, 1.0)
    },
    //ZNEG face
    {
        real3(-1.0, 0.0, 0.0),
        real3(0.0, -1.0, 0.0),
        real3(0.0, 0.0, -1.0)
    }
};

// Convert a normalized cubemap face position into a direction
real3 CubemapTexelToDirection(real2 positionNVC, uint faceId)
{
    real3 dir = CUBEMAP_FACE_BASIS_MAPPING[faceId][0] * positionNVC.x
               + CUBEMAP_FACE_BASIS_MAPPING[faceId][1] * positionNVC.y
               + CUBEMAP_FACE_BASIS_MAPPING[faceId][2];

    return normalize(dir);
}

//-----------------------------------------------------------------------------
// Sampling function
// Reference : http://www.cs.virginia.edu/~jdl/bib/globillum/mis/shirley96.pdf + PBRT
//-----------------------------------------------------------------------------

// Performs uniform sampling of the unit disk.
// Ref: PBRT v3, p. 777.
real2 SampleDiskUniform(real u1, real u2)
{
    real r   = sqrt(u1);
    real phi = TWO_PI * u2;

    real sinPhi, cosPhi;
    sincos(phi, sinPhi, cosPhi);

    return r * real2(cosPhi, sinPhi);
}

real3 SampleConeUniform(real u1, real u2, real cos_theta)
{
    float r0 = cos_theta + u1 * (1.0f - cos_theta);
    float r = sqrt(max(0.0, 1.0 - r0 * r0));
    float phi = TWO_PI * u2;
    return float3(r * cos(phi), r * sin(phi), r0);
}

real3 SampleSphereUniform(real u1, real u2)
{
    real phi      = TWO_PI * u2;
    real cosTheta = 1.0 - 2.0 * u1;

    return SphericalToCartesian(phi, cosTheta);
}

// Performs cosine-weighted sampling of the hemisphere.
// Ref: PBRT v3, p. 780.
real3 SampleHemisphereCosine(real u1, real u2)
{
    real3 localL;

    // Since we don't really care about the area distortion,
    // we substitute uniform disk sampling for the concentric one.
    localL.xy = SampleDiskUniform(u1, u2);

    // Project the point from the disk onto the hemisphere.
    localL.z = sqrt(1.0 - u1);

    return localL;
}

// Cosine-weighted sampling without the tangent frame.
// Ref: http://www.amietia.com/lambertnotangent.html
real3 SampleHemisphereCosine(real u1, real u2, real3 normal)
{
    real3 pointOnSphere = SampleSphereUniform(u1, u2);
    return normalize(normal + pointOnSphere);
}

real3 SampleHemisphereUniform(real u1, real u2)
{
    real phi      = TWO_PI * u2;
    real cosTheta = 1.0 - u1;

    return SphericalToCartesian(phi, cosTheta);
}

void SampleSphere(real2   u,
                  real4x4 localToWorld,
                  real    radius,
              out real    lightPdf,
              out real3   P,
              out real3   Ns)
{
    real u1 = u.x;
    real u2 = u.y;

    Ns = SampleSphereUniform(u1, u2);

    // Transform from unit sphere to world space
    P = radius * Ns + localToWorld[3].xyz;

    // pdf is inverse of area
    lightPdf = 1.0 / (FOUR_PI * radius * radius);
}

void SampleHemisphere(real2   u,
                      real4x4 localToWorld,
                      real    radius,
                  out real    lightPdf,
                  out real3   P,
                  out real3   Ns)
{
    real u1 = u.x;
    real u2 = u.y;

    // Random point at hemisphere surface
    Ns = -SampleHemisphereUniform(u1, u2); // We want the y down hemisphere
    P = radius * Ns;

    // Transform to world space
    P = mul(real4(P, 1.0), localToWorld).xyz;
    Ns = mul(Ns, (real3x3)(localToWorld));

    // pdf is inverse of area
    lightPdf = 1.0 / (TWO_PI * radius * radius);
}

// Note: The cylinder has no end caps (i.e. no disk on the side)
void SampleCylinder(real2   u,
                    real4x4 localToWorld,
                    real    radius,
                    real    width,
                out real    lightPdf,
                out real3   P,
                out real3   Ns)
{
    real u1 = u.x;
    real u2 = u.y;

    // Random point at cylinder surface
    real t = (u1 - 0.5) * width;
    real theta = 2.0 * PI * u2;
    real cosTheta = cos(theta);
    real sinTheta = sin(theta);

    // Cylinder are align on the right axis
    P = real3(t, radius * cosTheta, radius * sinTheta);
    Ns = normalize(real3(0.0, cosTheta, sinTheta));

    // Transform to world space
    P = mul(real4(P, 1.0), localToWorld).xyz;
    Ns = mul(Ns, (real3x3)(localToWorld));

    // pdf is inverse of area
    lightPdf = 1.0 / (TWO_PI * radius * width);
}

void SampleRectangle(real2   u,
                     real4x4 localToWorld,
                     real    width,
                     real    height,
                 out real    lightPdf,
                 out real3   P,
                 out real3   Ns)
{
    // Random point at rectangle surface
    P = real3((u.x - 0.5) * width, (u.y - 0.5) * height, 0);
    Ns = real3(0, 0, -1); // Light down (-Z)

    // Transform to world space
    P = mul(real4(P, 1.0), localToWorld).xyz;
    Ns = mul(Ns, (real3x3)(localToWorld));

    // pdf is inverse of area
    lightPdf = 1.0 / (width * height);
}

void SampleDisk(real2   u,
                real4x4 localToWorld,
                real    radius,
            out real    lightPdf,
            out real3   P,
            out real3   Ns)
{
    // Random point at disk surface
    P  = real3(radius * SampleDiskUniform(u.x, u.y), 0);
    Ns = real3(0.0, 0.0, -1.0); // Light down (-Z)

    // Transform to world space
    P = mul(real4(P, 1.0), localToWorld).xyz;
    Ns = mul(Ns, (real3x3)(localToWorld));

    // pdf is inverse of area
    lightPdf = 1.0 / (PI * radius * radius);
}

// Solid angle cone sampling.
// Takes the cosine of the aperture as an input.
void SampleCone(real2 u, real cosHalfAngle,
                out real3 dir, out real rcpPdf)
{
    real cosTheta = lerp(1, cosHalfAngle, u.x);
    real phi      = TWO_PI * u.y;

    dir    = SphericalToCartesian(phi, cosTheta);
    rcpPdf = TWO_PI * (1 - cosHalfAngle);
}

#endif // UNITY_SAMPLING_INCLUDED

// File end: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/Sampling/Sampling.hlsl
//================================================================================================================================




#ifndef UNITY_SPECCUBE_LOD_STEPS
    // This is actuall the last mip index, we generate 7 mips of convolution
    #define UNITY_SPECCUBE_LOD_STEPS 6
#endif

//-----------------------------------------------------------------------------
// Util image based lighting
//-----------------------------------------------------------------------------

// The *approximated* version of the non-linear remapping. It works by
// approximating the cone of the specular lobe, and then computing the MIP map level
// which (approximately) covers the footprint of the lobe with a single texel.
// Improves the perceptual roughness distribution.
real PerceptualRoughnessToMipmapLevel(real perceptualRoughness, uint mipMapCount)
{
    perceptualRoughness = perceptualRoughness * (1.7 - 0.7 * perceptualRoughness);

    return perceptualRoughness * mipMapCount;
}

real PerceptualRoughnessToMipmapLevel(real perceptualRoughness)
{
    return PerceptualRoughnessToMipmapLevel(perceptualRoughness, UNITY_SPECCUBE_LOD_STEPS);
}

// Mapping for convolved Texture2D, this is an empirical remapping to match GGX version of cubemap convolution
real PlanarPerceptualRoughnessToMipmapLevel(real perceptualRoughness, uint mipMapcount)
{
    return PositivePow(perceptualRoughness, 0.8) * uint(max(mipMapcount - 1, 0));
}

// The *accurate* version of the non-linear remapping. It works by
// approximating the cone of the specular lobe, and then computing the MIP map level
// which (approximately) covers the footprint of the lobe with a single texel.
// Improves the perceptual roughness distribution and adds reflection (contact) hardening.
// TODO: optimize!
real PerceptualRoughnessToMipmapLevel(real perceptualRoughness, real NdotR)
{
    real m = PerceptualRoughnessToRoughness(perceptualRoughness);

    // Remap to spec power. See eq. 21 in --> https://dl.dropboxusercontent.com/u/55891920/papers/mm_brdf.pdf
    real n = (2.0 / max(REAL_EPS, m * m)) - 2.0;

    // Remap from n_dot_h formulation to n_dot_r. See section "Pre-convolved Cube Maps vs Path Tracers" --> https://s3.amazonaws.com/docs.knaldtech.com/knald/1.0.0/lys_power_drops.html
    n /= (4.0 * max(NdotR, REAL_EPS));

    // remap back to square root of real roughness (0.25 include both the sqrt root of the conversion and sqrt for going from roughness to perceptualRoughness)
    perceptualRoughness = pow(2.0 / (n + 2.0), 0.25);

    return perceptualRoughness * UNITY_SPECCUBE_LOD_STEPS;
}

// The inverse of the *approximated* version of perceptualRoughnessToMipmapLevel().
real MipmapLevelToPerceptualRoughness(real mipmapLevel)
{
    real perceptualRoughness = saturate(mipmapLevel / UNITY_SPECCUBE_LOD_STEPS);

    return saturate(1.7 / 1.4 - sqrt(2.89 / 1.96 - (2.8 / 1.96) * perceptualRoughness));
}

//-----------------------------------------------------------------------------
// Anisotropic image based lighting
//-----------------------------------------------------------------------------

// T is the fiber axis (hair strand direction, root to tip).
float3 ComputeViewFacingNormal(float3 V, float3 T)
{
    return Orthonormalize(V, T);
}

// Fake anisotropy by distorting the normal (non-negative anisotropy values only).
// The grain direction (e.g. hair or brush direction) is assumed to be orthogonal to N.
// Anisotropic ratio (0->no isotropic; 1->full anisotropy in tangent direction)
real3 GetAnisotropicModifiedNormal(real3 grainDir, real3 N, real3 V, real anisotropy)
{
    real3 grainNormal = ComputeViewFacingNormal(V, grainDir);
    return normalize(lerp(N, grainNormal, anisotropy));
}

// For GGX aniso and IBL we have done an empirical (eye balled) approximation compare to the reference.
// We use a single fetch, and we stretch the normal to use based on various criteria.
// result are far away from the reference but better than nothing
// Anisotropic ratio (0->no isotropic; 1->full anisotropy in tangent direction) - positive use bitangentWS - negative use tangentWS
// Note: returned iblPerceptualRoughness shouldn't be use for sampling FGD texture in a pre-integration
void GetGGXAnisotropicModifiedNormalAndRoughness(real3 bitangentWS, real3 tangentWS, real3 N, real3 V, real anisotropy, real perceptualRoughness, out real3 iblN, out real iblPerceptualRoughness)
{
    // For positive anisotropy values: tangent = highlight stretch (anisotropy) direction, bitangent = grain (brush) direction.
    float3 grainDirWS = (anisotropy >= 0.0) ? bitangentWS : tangentWS;
    // Reduce stretching depends on the perceptual roughness
    float stretch = abs(anisotropy) * saturate(1.5 * sqrt(perceptualRoughness));
    // NOTE: If we follow the theory we should use the modified normal for the different calculation implying a normal (like NdotV)
    // However modified normal is just a hack. The goal is just to stretch a cubemap, no accuracy here. Let's save performance instead.
    iblN = GetAnisotropicModifiedNormal(grainDirWS, N, V, stretch);
    iblPerceptualRoughness = perceptualRoughness * saturate(1.2 - abs(anisotropy));
}

// Ref: "Moving Frostbite to PBR", p. 69.
real3 GetSpecularDominantDir(real3 N, real3 R, real perceptualRoughness, real NdotV)
{
    real p = perceptualRoughness;
    real a = 1.0 - p * p;
    real s = sqrt(a);

#ifdef USE_FB_DSD
    // This is the original formulation.
    real lerpFactor = (s + p * p) * a;
#else
    // TODO: tweak this further to achieve a closer match to the reference.
    real lerpFactor = (s + p * p) * saturate(a * a + lerp(0.0, a, NdotV * NdotV));
#endif

    // The result is not normalized as we fetch in a cubemap
    return lerp(N, R, lerpFactor);
}

// ----------------------------------------------------------------------------
// Importance sampling BSDF functions
// ----------------------------------------------------------------------------

void SampleGGXDir(real2   u,
                  real3   V,
                  real3x3 localToWorld,
                  real    roughness,
              out real3   L,
              out real    NdotL,
              out real    NdotH,
              out real    VdotH,
                  bool    VeqN = false)
{
    // GGX NDF sampling
    real cosTheta = sqrt(SafeDiv(1.0 - u.x, 1.0 + (roughness * roughness - 1.0) * u.x));
    real phi      = TWO_PI * u.y;

    real3 localH = SphericalToCartesian(phi, cosTheta);

    NdotH = cosTheta;

    real3 localV;

    if (VeqN)
    {
        // localV == localN
        localV = real3(0.0, 0.0, 1.0);
        VdotH  = NdotH;
    }
    else
    {
        localV = mul(V, transpose(localToWorld));
        VdotH  = saturate(dot(localV, localH));
    }

    // Compute { localL = reflect(-localV, localH) }
    real3 localL = -localV + 2.0 * VdotH * localH;
    NdotL = localL.z;

    L = mul(localL, localToWorld);
}

// Ref: "A Simpler and Exact Sampling Routine for the GGX Distribution of Visible Normals".
void SampleVisibleAnisoGGXDir(real2 u,
                              real3 V,
                              real3x3 localToWorld,
                              real roughnessT,
                              real roughnessB,
                          out real3 L,
                          out real  NdotL,
                          out real  NdotH,
                          out real  VdotH,
                              bool  VeqN = false)
{
    real3 localV = mul(V, transpose(localToWorld));

    // Construct an orthonormal basis around the stretched view direction
    real3x3 viewToLocal;
    if (VeqN)
    {
        viewToLocal = k_identity3x3;
    }
    else
    {
        // TODO: this code is tacky. We should make it cleaner
        viewToLocal[2] = normalize(real3(roughnessT * localV.x, roughnessB * localV.y, localV.z));
        viewToLocal[0] = (viewToLocal[2].z < 0.9999) ? normalize(cross(real3(0, 0, 1), viewToLocal[2])) : real3(1, 0, 0);
        viewToLocal[1] = cross(viewToLocal[2], viewToLocal[0]);
    }

    // Compute a sample point with polar coordinates (r, phi)
    real r   = sqrt(u.x);
    real phi = 2.0 * PI * u.y;
    real t1  = r * cos(phi);
    real t2  = r * sin(phi);
    float s  = 0.5 * (1.0 + viewToLocal[2].z);
    t2 = (1.0 - s) * sqrt(1.0 - t1 * t1) + s * t2;

    // Reproject onto hemisphere
    real3 localH = t1 * viewToLocal[0] + t2 * viewToLocal[1] + sqrt(max(0.0, 1.0 - t1 * t1 - t2 * t2)) * viewToLocal[2];

    // Transform the normal back to the ellipsoid configuration
    localH = normalize(real3(roughnessT * localH.x, roughnessB * localH.y, max(0.0, localH.z)));

    NdotH = localH.z;
    VdotH = saturate(dot(localV, localH));

    // Compute the reflection direction
    real3 localL = 2.0 * VdotH * localH - localV;
    NdotL = localL.z;

    L = mul(localL, localToWorld);
}

void SampleVisibleGGXDir(real2 u,
                         real3 V,
                         real3x3 localToWorld,
                         real roughness,
                     out real3 L,
                     out real  NdotL,
                     out real  NdotH,
                     out real  VdotH,
                         bool  VeqN = false)
{
    SampleVisibleAnisoGGXDir(u, V, localToWorld, roughness, roughness, L, NdotL, NdotH, VdotH, VeqN);
}

// ref: http://blog.selfshadow.com/publications/s2012-shading-course/burley/s2012_pbs_disney_brdf_notes_v3.pdf p26
void SampleAnisoGGXDir(real2 u,
                       real3 V,
                       real3 N,
                       real3 tangentX,
                       real3 tangentY,
                       real  roughnessT,
                       real  roughnessB,
                   out real3 H,
                   out real3 L)
{
    // AnisoGGX NDF sampling
    H = sqrt(u.x / (1.0 - u.x)) * (roughnessT * cos(TWO_PI * u.y) * tangentX + roughnessB * sin(TWO_PI * u.y) * tangentY) + N;
    H = normalize(H);

    // Convert sample from half angle to incident angle
    L = 2.0 * saturate(dot(V, H)) * H - V;
}

// weightOverPdf return the weight (without the diffuseAlbedo term) over pdf. diffuseAlbedo term must be apply by the caller.
void ImportanceSampleLambert(real2   u,
                             real3x3 localToWorld,
                         out real3   L,
                         out real    NdotL,
                         out real    weightOverPdf)
{
#if 0
    real3 localL = SampleHemisphereCosine(u.x, u.y);

    NdotL = localL.z;

    L = mul(localL, localToWorld);
#else
    real3 N = localToWorld[2];

    L     = SampleHemisphereCosine(u.x, u.y, N);
    NdotL = saturate(dot(N, L));
#endif

    // Importance sampling weight for each sample
    // pdf = N.L / PI
    // weight = fr * (N.L) with fr = diffuseAlbedo / PI
    // weight over pdf is:
    // weightOverPdf = (diffuseAlbedo / PI) * (N.L) / (N.L / PI)
    // weightOverPdf = diffuseAlbedo
    // diffuseAlbedo is apply outside the function

    weightOverPdf = 1.0;
}

// weightOverPdf return the weight (without the Fresnel term) over pdf. Fresnel term must be apply by the caller.
void ImportanceSampleGGX(real2   u,
                         real3   V,
                         real3x3 localToWorld,
                         real    roughness,
                         real    NdotV,
                     out real3   L,
                     out real    VdotH,
                     out real    NdotL,
                     out real    weightOverPdf)
{
    real NdotH;
    SampleGGXDir(u, V, localToWorld, roughness, L, NdotL, NdotH, VdotH);

    // Importance sampling weight for each sample
    // pdf = D(H) * (N.H) / (4 * (L.H))
    // weight = fr * (N.L) with fr = F(H) * G(V, L) * D(H) / (4 * (N.L) * (N.V))
    // weight over pdf is:
    // weightOverPdf = F(H) * G(V, L) * (L.H) / ((N.H) * (N.V))
    // weightOverPdf = F(H) * 4 * (N.L) * V(V, L) * (L.H) / (N.H) with V(V, L) = G(V, L) / (4 * (N.L) * (N.V))
    // Remind (L.H) == (V.H)
    // F is apply outside the function

    real Vis = V_SmithJointGGX(NdotL, NdotV, roughness);
    weightOverPdf = 4.0 * Vis * NdotL * VdotH / NdotH;
}

// weightOverPdf return the weight (without the Fresnel term) over pdf. Fresnel term must be apply by the caller.
void ImportanceSampleAnisoGGX(real2   u,
                              real3   V,
                              real3x3 localToWorld,
                              real    roughnessT,
                              real    roughnessB,
                              real    NdotV,
                          out real3   L,
                          out real    VdotH,
                          out real    NdotL,
                          out real    weightOverPdf)
{
    real3 tangentX = localToWorld[0];
    real3 tangentY = localToWorld[1];
    real3 N        = localToWorld[2];

    real3 H;
    SampleAnisoGGXDir(u, V, N, tangentX, tangentY, roughnessT, roughnessB, H, L);

    real NdotH = saturate(dot(N, H));
    // Note: since L and V are symmetric around H, LdotH == VdotH
    VdotH = saturate(dot(V, H));
    NdotL = saturate(dot(N, L));

    // Importance sampling weight for each sample
    // pdf = D(H) * (N.H) / (4 * (L.H))
    // weight = fr * (N.L) with fr = F(H) * G(V, L) * D(H) / (4 * (N.L) * (N.V))
    // weight over pdf is:
    // weightOverPdf = F(H) * G(V, L) * (L.H) / ((N.H) * (N.V))
    // weightOverPdf = F(H) * 4 * (N.L) * V(V, L) * (L.H) / (N.H) with V(V, L) = G(V, L) / (4 * (N.L) * (N.V))
    // Remind (L.H) == (V.H)
    // F is apply outside the function

    // For anisotropy we must not saturate these values
    real TdotV = dot(tangentX, V);
    real BdotV = dot(tangentY, V);
    real TdotL = dot(tangentX, L);
    real BdotL = dot(tangentY, L);

    real Vis = V_SmithJointGGXAniso(TdotV, BdotV, NdotV, TdotL, BdotL, NdotL, roughnessT, roughnessB);
    weightOverPdf = 4.0 * Vis * NdotL * VdotH / NdotH;
}

// ----------------------------------------------------------------------------
// Pre-integration
// ----------------------------------------------------------------------------

#if !defined SHADER_API_GLES
// Ref: Listing 18 in "Moving Frostbite to PBR" + https://knarkowicz.wordpress.com/2014/12/27/analytical-dfg-term-for-ibl/
real4 IntegrateGGXAndDisneyDiffuseFGD(real NdotV, real roughness, uint sampleCount = 4096)
{
    // Note that our LUT covers the full [0, 1] range.
    // Therefore, we don't really want to clamp NdotV here (else the lerp slope is wrong).
    // However, if NdotV is 0, the integral is 0, so that's not what we want, either.
    // Our runtime NdotV bias is quite large, so we use a smaller one here instead.
    NdotV     = max(NdotV, REAL_EPS);
    real3 V   = real3(sqrt(1 - NdotV * NdotV), 0, NdotV);
    real4 acc = real4(0.0, 0.0, 0.0, 0.0);

    real3x3 localToWorld = k_identity3x3;

    for (uint i = 0; i < sampleCount; ++i)
    {
        real2 u = Hammersley2d(i, sampleCount);

        real VdotH;
        real NdotL;
        real weightOverPdf;

        real3 L; // Unused
        ImportanceSampleGGX(u, V, localToWorld, roughness, NdotV,
                            L, VdotH, NdotL, weightOverPdf);

        if (NdotL > 0.0)
        {
            // Integral{BSDF * <N,L> dw} =
            // Integral{(F0 + (1 - F0) * (1 - <V,H>)^5) * (BSDF / F) * <N,L> dw} =
            // (1 - F0) * Integral{(1 - <V,H>)^5 * (BSDF / F) * <N,L> dw} + F0 * Integral{(BSDF / F) * <N,L> dw}=
            // (1 - F0) * x + F0 * y = lerp(x, y, F0)

            acc.x += weightOverPdf * pow(1 - VdotH, 5);
            acc.y += weightOverPdf;
        }

        // for Disney we still use a Cosine importance sampling, true Disney importance sampling imply a look up table
        ImportanceSampleLambert(u, localToWorld, L, NdotL, weightOverPdf);

        if (NdotL > 0.0)
        {
            real LdotV = dot(L, V);
            real disneyDiffuse = DisneyDiffuseNoPI(NdotV, NdotL, LdotV, RoughnessToPerceptualRoughness(roughness));

            acc.z += disneyDiffuse * weightOverPdf;
        }
    }

    acc /= sampleCount;

    // Remap from the [0.5, 1.5] to the [0, 1] range.
    acc.z -= 0.5;

    return acc;
}
#else
// Not supported due to lack of random library in GLES 2
#define IntegrateGGXAndDisneyDiffuseFGD ERROR_ON_UNSUPPORTED_FUNCTION(IntegrateGGXAndDisneyDiffuseFGD)
#endif

uint GetIBLRuntimeFilterSampleCount(uint mipLevel)
{
    uint sampleCount = 0;

    switch (mipLevel)
    {
        case 1: sampleCount = 21; break;
        case 2: sampleCount = 34; break;
#if defined(SHADER_API_MOBILE) || defined(SHADER_API_SWITCH)
        case 3: sampleCount = 34; break;
        case 4: sampleCount = 34; break;
        case 5: sampleCount = 34; break;
        case 6: sampleCount = 34; break; // UNITY_SPECCUBE_LOD_STEPS
#else
        case 3: sampleCount = 55; break;
        case 4: sampleCount = 89; break;
        case 5: sampleCount = 89; break;
        case 6: sampleCount = 89; break; // UNITY_SPECCUBE_LOD_STEPS
#endif
    }

    return sampleCount;
}

// Ref: Listing 19 in "Moving Frostbite to PBR"
real4 IntegrateLD(TEXTURECUBE_PARAM(tex, sampl),
                   TEXTURE2D(ggxIblSamples),
                   real3 V,
                   real3 N,
                   real roughness,
                   real index,      // Current MIP level minus one
                   real invOmegaP,
                   uint sampleCount, // Must be a Fibonacci number
                   bool prefilter,
                   bool usePrecomputedSamples)
{
    real3x3 localToWorld = GetLocalFrame(N);

#ifndef USE_KARIS_APPROXIMATION
    real NdotV       = 1; // N == V
    real partLambdaV = GetSmithJointGGXPartLambdaV(NdotV, roughness);
#endif

    real3 lightInt = real3(0.0, 0.0, 0.0);
    real  cbsdfInt = 0.0;

    for (uint i = 0; i < sampleCount; ++i)
    {
        real3 L;
        real  NdotL, NdotH, LdotH;

        if (usePrecomputedSamples)
        {
            // Performance warning: using a texture LUT will generate a vector load,
            // which increases both the VGPR pressure and the workload of the
            // texture unit. A better solution here is to load from a Constant, Raw
            // or Structured buffer, or perhaps even declare all the constants in an
            // HLSL header to allow the compiler to inline everything.
            real3 localL = LOAD_TEXTURE2D(ggxIblSamples, uint2(i, index)).xyz;

            L     = mul(localL, localToWorld);
            NdotL = localL.z;
            LdotH = sqrt(0.5 + 0.5 * NdotL);
        }
        else
        {
            real2 u = Fibonacci2d(i, sampleCount);

            // Note: if (N == V), all of the microsurface normals are visible.
            SampleGGXDir(u, V, localToWorld, roughness, L, NdotL, NdotH, LdotH, true);

            if (NdotL <= 0) continue; // Note that some samples will have 0 contribution
        }

        real mipLevel;

        if (!prefilter) // BRDF importance sampling
        {
            mipLevel = 0;
        }
        else // Prefiltered BRDF importance sampling
        {
            // Use lower MIP-map levels for fetching samples with low probabilities
            // in order to reduce the variance.
            // Ref: http://http.developer.nvidia.com/GPUGems3/gpugems3_ch20.html
            //
            // - OmegaS: Solid angle associated with the sample
            // - OmegaP: Solid angle associated with the texel of the cubemap

            real omegaS;

            if (usePrecomputedSamples)
            {
                omegaS = LOAD_TEXTURE2D(ggxIblSamples, uint2(i, index)).w;
            }
            else
            {
                // real PDF = D * NdotH * Jacobian, where Jacobian = 1 / (4 * LdotH).
                // Since (N == V), NdotH == LdotH.
                real pdf = 0.25 * D_GGX(NdotH, roughness);
                // TODO: improve the accuracy of the sample's solid angle fit for GGX.
                omegaS    = rcp(sampleCount) * rcp(pdf);
            }

            // 'invOmegaP' is precomputed on CPU and provided as a parameter to the function.
            // real omegaP = FOUR_PI / (6.0 * cubemapWidth * cubemapWidth);
            const real mipBias = roughness;
            mipLevel = 0.5 * log2(omegaS * invOmegaP) + mipBias;
        }

        // TODO: use a Gaussian-like filter to generate the MIP pyramid.
        real3 val = SAMPLE_TEXTURECUBE_LOD(tex, sampl, L, mipLevel).rgb;

        // The goal of this function is to use Monte-Carlo integration to find
        // X = Integral{Radiance(L) * CBSDF(L, N, V) dL} / Integral{CBSDF(L, N, V) dL}.
        // Note: Integral{CBSDF(L, N, V) dL} is given by the FDG texture.
        // CBSDF  = F * D * G * NdotL / (4 * NdotL * NdotV) = F * D * G / (4 * NdotV).
        // PDF    = D * NdotH / (4 * LdotH).
        // Weight = CBSDF / PDF = F * G * LdotH / (NdotV * NdotH).
        // Since we perform filtering with the assumption that (V == N),
        // (LdotH == NdotH) && (NdotV == 1) && (Weight == F * G).
        // Therefore, after the Monte Carlo expansion of the integrals,
        // X = Sum(Radiance(L) * Weight) / Sum(Weight) = Sum(Radiance(L) * F * G) / Sum(F * G).

    #ifndef USE_KARIS_APPROXIMATION
        // The choice of the Fresnel factor does not appear to affect the result.
        real F = 1; // F_Schlick(F0, LdotH);
        real G = V_SmithJointGGX(NdotL, NdotV, roughness, partLambdaV) * NdotL * NdotV; // 4 cancels out

        lightInt += F * G * val;
        cbsdfInt += F * G;
    #else
        // Use the approximation from "Real Shading in Unreal Engine 4": Weight ~ NdotL.
        lightInt += NdotL * val;
        cbsdfInt += NdotL;
    #endif
    }

    return real4(lightInt / cbsdfInt, 1.0);
}

real4 IntegrateLDCharlie(TEXTURECUBE_PARAM(tex, sampl),
                   real3 V,
                   real3 N,
                   real roughness,
                   uint sampleCount,
                   real invOmegaP,
                   bool prefilter)
{
    // Local frame for the local to world sample transformation
    real3x3 localToWorld = GetLocalFrame(N);
    float NdotV = 1;

    // Cumulative values
    real3 lightInt = real3(0.0, 0.0, 0.0);
    real  cbsdfInt = 0.0;

    for (uint i = 0; i < sampleCount; ++i)
    {
        // Generate a new random number
        real2 u = Hammersley2d(i, sampleCount);

        // Generate the matching direction with a cosine importance sampling
        float3 localL = SampleHemisphereCosine(u.x, u.y);

        // Convert it to world space
        real3 L = mul(localL, localToWorld);
        float NdotL = saturate(dot(N, L));

        // Are we in the hemisphere?
        if (NdotL <= 0) continue; // Note that some samples will have 0 contribution

        // The goal of this function is to use Monte-Carlo integration to find
        // X = Integral{Radiance(L) * CBSDF(L, N, V) dL} / Integral{CBSDF(L, N, V) dL}.
        // Note: Integral{CBSDF(L, N, V) dL} is given by the FDG texture.
        // CBSDF  = F * D * V * NdotL.
        // PDF    =  1.0 / NdotL
        // Weight = CBSDF / PDF = F * D * V
        // Since we perform filtering with the assumption that (V == N),
        // (LdotH == NdotH) && (NdotV == 1) && (Weight ==  F * D * V)
        // Therefore, after the Monte Carlo expansion of the integrals,
        // X = Sum(Radiance(L) * Weight) / Sum(Weight) = Sum(Radiance(L) * F * D * V) / Sum(F * D * V).

        // We are in the supposition that N == V
        float LdotV, NdotH, LdotH, invLenLV;
        GetBSDFAngle(V, L, NdotL, NdotV, LdotV, NdotH, LdotH, invLenLV);

        // BRDF data
        real F = 1;
        real D = D_Charlie(NdotH, roughness);
        real Vis = V_Charlie(NdotL, NdotV, roughness);

        real mipLevel = 0;
        if (prefilter) // Prefiltered BRDF importance sampling
        {
            // Use lower MIP-map levels for fetching samples with low probabilities
            // in order to reduce the variance.
            // Ref: http://http.developer.nvidia.com/GPUGems3/gpugems3_ch20.html
            //
            // - OmegaS: Solid angle associated with the sample
            // - OmegaP: Solid angle associated with the texel of the cubemap

            real omegaS;

            // real PDF = 1.0f / NdotL
            // Since (N == V), NdotH == LdotH.
            real pdf = 1.0 /  NdotL;
            // TODO: improve the accuracy of the sample's solid angle fit for GGX.
            omegaS    = rcp(sampleCount) * rcp(pdf);

            // 'invOmegaP' is precomputed on CPU and provided as a parameter to the function.
            // real omegaP = FOUR_PI / (6.0 * cubemapWidth * cubemapWidth);
            const real mipBias = roughness;
            mipLevel = 0.5 * log2(omegaS * invOmegaP) + mipBias;
        }

        // TODO: use a Gaussian-like filter to generate the MIP pyramid.
        real3 val = SAMPLE_TEXTURECUBE_LOD(tex, sampl, L, mipLevel).rgb;

        // Use the approximation from "Real Shading in Unreal Engine 4": Weight ~ NdotL.
        lightInt +=  val * F * D * Vis;
        cbsdfInt += F * D * Vis;
    }

    return real4(lightInt / cbsdfInt, 1.0);
}


// Searches the row 'j' containing 'n' elements of 'haystack' and
// returns the index of the first element greater or equal to 'needle'.
uint BinarySearchRow(uint j, real needle, TEXTURE2D(haystack), uint n)
{
    uint  i = n - 1;
    real v = LOAD_TEXTURE2D(haystack, uint2(i, j)).r;

    if (needle < v)
    {
        i = 0;

        for (uint b = 1 << firstbithigh(n - 1); b != 0; b >>= 1)
        {
            uint p = i | b;
            v = LOAD_TEXTURE2D(haystack, uint2(p, j)).r;
            if (v <= needle) { i = p; } // Move to the right.
        }
    }

    return i;
}

#if !defined SHADER_API_GLES
real4 IntegrateLD_MIS(TEXTURECUBE_PARAM(envMap, sampler_envMap),
                       TEXTURE2D(marginalRowDensities),
                       TEXTURE2D(conditionalDensities),
                       real3 V,
                       real3 N,
                       real roughness,
                       real invOmegaP,
                       uint width,
                       uint height,
                       uint sampleCount,
                       bool prefilter)
{
    real3x3 localToWorld = GetLocalFrame(N);

    real3 lightInt = real3(0.0, 0.0, 0.0);
    real  cbsdfInt = 0.0;

/*
    // Dedicate 50% of samples to light sampling at 1.0 roughness.
    // Only perform BSDF sampling when roughness is below 0.5.
    const int lightSampleCount = lerp(0, sampleCount / 2, saturate(2.0 * roughness - 1.0));
    const int bsdfSampleCount  = sampleCount - lightSampleCount;
*/

    // The value of the integral of intensity values of the environment map (as a 2D step function).
    real envMapInt2dStep = LOAD_TEXTURE2D(marginalRowDensities, uint2(height, 0)).r;
    // Since we are using equiareal mapping, we need to divide by the area of the sphere.
    real envMapIntSphere = envMapInt2dStep * INV_FOUR_PI;

    // Perform light importance sampling.
    for (uint i = 0; i < sampleCount; i++)
    {
        real2 s = Hammersley2d(i, sampleCount);

        // Sample a row from the marginal distribution.
        uint y = BinarySearchRow(0, s.x, marginalRowDensities, height - 1);

        // Sample a column from the conditional distribution.
        uint x = BinarySearchRow(y, s.y, conditionalDensities, width - 1);

        // Compute the coordinates of the sample.
        // Note: we take the sample in between two texels, and also apply the half-texel offset.
        // We could compute fractional coordinates at the cost of 4 extra texel samples.
        real  u = saturate((real)x / width  + 1.0 / width);
        real  v = saturate((real)y / height + 1.0 / height);
        real3 L = ConvertEquiarealToCubemap(u, v);

        real NdotL = saturate(dot(N, L));

        if (NdotL > 0.0)
        {
            real3 val = SAMPLE_TEXTURECUBE_LOD(envMap, sampler_envMap, L, 0).rgb;
            real  pdf = (val.r + val.g + val.b) / envMapIntSphere;

            if (pdf > 0.0)
            {
                // (N == V) && (acos(VdotL) == 2 * acos(NdotH)).
                real NdotH = sqrt(NdotL * 0.5 + 0.5);

                // *********************************************************************************
                // Our goal is to use Monte-Carlo integration with importance sampling to evaluate
                // X(V)   = Integral{Radiance(L) * CBSDF(L, N, V) dL} / Integral{CBSDF(L, N, V) dL}.
                // CBSDF  = F * D * G * NdotL / (4 * NdotL * NdotV) = F * D * G / (4 * NdotV).
                // Weight = CBSDF / PDF.
                // We use two approximations of Brian Karis from "Real Shading in Unreal Engine 4":
                // (F * G ~ NdotL) && (NdotV == 1).
                // Weight = D * NdotL / (4 * PDF).
                // *********************************************************************************

                real weight = D_GGX(NdotH, roughness) * NdotL / (4.0 * pdf);

                lightInt += weight * val;
                cbsdfInt += weight;
            }
        }
    }

    // Prevent NaNs arising from the division of 0 by 0.
    cbsdfInt = max(cbsdfInt, REAL_EPS);

    return real4(lightInt / cbsdfInt, 1.0);
}
#else
// Not supported due to lack of random library in GLES 2
#define IntegrateLD_MIS ERROR_ON_UNSUPPORTED_FUNCTION(IntegrateLD_MIS)
#endif

// Little helper to share code between sphere and box reflection probe.
// This function will fade the mask of a reflection volume based on normal orientation compare to direction define by the center of the reflection volume.
float InfluenceFadeNormalWeight(float3 normal, float3 centerToPos)
{
    // Start weight from 0.6f (1 fully transparent) to 0.2f (fully opaque).
    return saturate((-1.0f / 0.4f) * dot(normal, centerToPos) + (0.6f / 0.4f));
}

#endif // UNITY_IMAGE_BASED_LIGHTING_INCLUDED

// File end: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/ImageBasedLighting.hlsl
//================================================================================================================================



//================================================================================================================================
// File start: com.unity.render-pipelines.universal@7.3.1/ShaderLibrary/Core.hlsl


#ifndef UNIVERSAL_PIPELINE_CORE_INCLUDED
#define UNIVERSAL_PIPELINE_CORE_INCLUDED

//================================================================================================================================
// File start: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/Packing.hlsl


#ifndef UNITY_PACKING_INCLUDED
#define UNITY_PACKING_INCLUDED

//-----------------------------------------------------------------------------
// Normal packing
//-----------------------------------------------------------------------------

real3 PackNormalMaxComponent(real3 n)
{
    return (n / Max3(abs(n.x), abs(n.y), abs(n.z))) * 0.5 + 0.5;
}

real3 UnpackNormalMaxComponent(real3 n)
{
    return normalize(n * 2.0 - 1.0);
}

// Ref: http://www.vis.uni-stuttgart.de/~engelhts/paper/vmvOctaMaps.pdf
// Encode with Oct, this function work with any size of output
// return real between [-1, 1]
real2 PackNormalOctRectEncode(real3 n)
{
    // Perform planar projection.
    real3 p = n * rcp(dot(abs(n), 1.0));
    real  x = p.x, y = p.y, z = p.z;

    // Unfold the octahedron.
    // Also correct the aspect ratio from 2:1 to 1:1.
    real r = saturate(0.5 - 0.5 * x + 0.5 * y);
    real g = x + y;

    // Negative hemisphere on the left, positive on the right.
    return real2(CopySign(r, z), g);
}

real3 UnpackNormalOctRectEncode(real2 f)
{
    real r = f.r, g = f.g;

    // Solve for {x, y, z} given {r, g}.
    real x = 0.5 + 0.5 * g - abs(r);
    real y = g - x;
    real z = max(1.0 - abs(x) - abs(y), REAL_EPS); // EPS is absolutely crucial for anisotropy

    real3 p = real3(x, y, CopySign(z, r));

    return normalize(p);
}

// Ref: http://jcgt.org/published/0003/02/01/paper.pdf
// Encode with Oct, this function work with any size of output
// return float between [-1, 1]
float2 PackNormalOctQuadEncode(float3 n)
{
    //float l1norm    = dot(abs(n), 1.0);
    //float2 res0     = n.xy * (1.0 / l1norm);

    //float2 val      = 1.0 - abs(res0.yx);
    //return (n.zz < float2(0.0, 0.0) ? (res0 >= 0.0 ? val : -val) : res0);

    // Optimized version of above code:
    n *= rcp(dot(abs(n), 1.0));
    float t = saturate(-n.z);
    return n.xy + (n.xy >= 0.0 ? t : -t);
}

float3 UnpackNormalOctQuadEncode(float2 f)
{
    float3 n = float3(f.x, f.y, 1.0 - abs(f.x) - abs(f.y));

    //float2 val = 1.0 - abs(n.yx);
    //n.xy = (n.zz < float2(0.0, 0.0) ? (n.xy >= 0.0 ? val : -val) : n.xy);

    // Optimized version of above code:
    float t = max(-n.z, 0.0);
    n.xy += n.xy >= 0.0 ? -t.xx : t.xx;

    return normalize(n);
}

real2 PackNormalHemiOctEncode(real3 n)
{
    real l1norm = dot(abs(n), 1.0);
    real2 res = n.xy * (1.0 / l1norm);

    return real2(res.x + res.y, res.x - res.y);
}

real3 UnpackNormalHemiOctEncode(real2 f)
{
    real2 val = real2(f.x + f.y, f.x - f.y) * 0.5;
    real3 n = real3(val, 1.0 - dot(abs(val), 1.0));

    return normalize(n);
}

// Tetrahedral encoding - Looks like Tetra encoding 10:10 + 2 is similar to oct 11:11, as oct is cheaper prefer it
// To generate the basisNormal below we use these 4 vertex of a regular tetrahedron
// v0 = float3(1.0, 0.0, -1.0 / sqrt(2.0));
// v1 = float3(-1.0, 0.0, -1.0 / sqrt(2.0));
// v2 = float3(0.0, 1.0, 1.0 / sqrt(2.0));
// v3 = float3(0.0, -1.0, 1.0 / sqrt(2.0));
// Then we normalize the average of each face's vertices
// normalize(v0 + v1 + v2), etc...
static const real3 tetraBasisNormal[4] =
{
    real3(0., 0.816497, -0.57735),
    real3(-0.816497, 0., 0.57735),
    real3(0.816497, 0., 0.57735),
    real3(0., -0.816497, -0.57735)
};

// Then to get the local matrix (with z axis rotate to basisNormal) use GetLocalFrame(basisNormal[xxx])
static const real3x3 tetraBasisArray[4] =
{
    real3x3(-1., 0., 0.,0., 0.57735, 0.816497,0., 0.816497, -0.57735),
    real3x3(0., -1., 0.,0.57735, 0., 0.816497,-0.816497, 0., 0.57735),
    real3x3(0., 1., 0.,-0.57735, 0., 0.816497,0.816497, 0., 0.57735),
    real3x3(1., 0., 0.,0., -0.57735, 0.816497,0., -0.816497, -0.57735)
};

// Return [-1..1] vector2 oriented in plane of the faceIndex of a regular tetrahedron
real2 PackNormalTetraEncode(float3 n, out uint faceIndex)
{
    // Retrieve the tetrahedra's face for the normal direction
    // It is the one with the greatest dot value with face normal
    real dot0 = dot(n, tetraBasisNormal[0]);
    real dot1 = dot(n, tetraBasisNormal[1]);
    real dot2 = dot(n, tetraBasisNormal[2]);
    real dot3 = dot(n, tetraBasisNormal[3]);

    real maxi0 = max(dot0, dot1);
    real maxi1 = max(dot2, dot3);
    real maxi = max(maxi0, maxi1);

    // Get the index from the greatest dot
    if (maxi == dot0)
        faceIndex = 0;
    else if (maxi == dot1)
        faceIndex = 1;
    else if (maxi == dot2)
        faceIndex = 2;
    else //(maxi == dot3)
        faceIndex = 3;

    // Rotate n into this local basis
    n = mul(tetraBasisArray[faceIndex], n);

    // Project n onto the local plane
    return n.xy;
}

// Assume f [-1..1]
real3 UnpackNormalTetraEncode(real2 f, uint faceIndex)
{
    // Recover n from local plane
    real3 n = real3(f.xy, sqrt(1.0 - dot(f.xy, f.xy)));
    // Inverse of transform PackNormalTetraEncode (just swap order in mul as we have a rotation)
    return mul(n, tetraBasisArray[faceIndex]);
}

// Unpack from normal map
real3 UnpackNormalRGB(real4 packedNormal, real scale = 1.0)
{
    real3 normal;
    normal.xyz = packedNormal.rgb * 2.0 - 1.0;
    normal.xy *= scale;
    return normal;
}

real3 UnpackNormalRGBNoScale(real4 packedNormal)
{
    return packedNormal.rgb * 2.0 - 1.0;
}

real3 UnpackNormalAG(real4 packedNormal, real scale = 1.0)
{
    real3 normal;
    normal.xy = packedNormal.ag * 2.0 - 1.0;
    normal.xy *= scale;
    normal.z = sqrt(1.0 - saturate(dot(normal.xy, normal.xy)));
    return normal;
}

// Unpack normal as DXT5nm (1, y, 0, x) or BC5 (x, y, 0, 1)
real3 UnpackNormalmapRGorAG(real4 packedNormal, real scale = 1.0)
{
    // Convert to (?, y, 0, x)
    packedNormal.a *= packedNormal.r;
    return UnpackNormalAG(packedNormal, scale);
}

real3 UnpackNormal(real4 packedNormal)
{
#if defined(UNITY_NO_DXT5nm)
    return UnpackNormalRGBNoScale(packedNormal);
#else
    // Compiler will optimize the scale away
    return UnpackNormalmapRGorAG(packedNormal, 1.0);
#endif
}

real3 UnpackNormalScale(real4 packedNormal, real bumpScale)
{
#if defined(UNITY_NO_DXT5nm)
    return UnpackNormalRGB(packedNormal, bumpScale);
#else
    return UnpackNormalmapRGorAG(packedNormal, bumpScale);
#endif
}

//-----------------------------------------------------------------------------
// HDR packing
//-----------------------------------------------------------------------------

// HDR Packing not defined in GLES2
#if !defined(SHADER_API_GLES)

// Ref: http://realtimecollisiondetection.net/blog/?p=15
real4 PackToLogLuv(real3 vRGB)
{
    // M matrix, for encoding
    const real3x3 M = real3x3(
        0.2209, 0.3390, 0.4184,
        0.1138, 0.6780, 0.7319,
        0.0102, 0.1130, 0.2969);

    real4 vResult;
    real3 Xp_Y_XYZp = mul(vRGB, M);
    Xp_Y_XYZp = max(Xp_Y_XYZp, real3(1e-6, 1e-6, 1e-6));
    vResult.xy = Xp_Y_XYZp.xy / Xp_Y_XYZp.z;
    real Le = 2.0 * log2(Xp_Y_XYZp.y) + 127.0;
    vResult.w = frac(Le);
    vResult.z = (Le - (floor(vResult.w * 255.0)) / 255.0) / 255.0;
    return vResult;
}

real3 UnpackFromLogLuv(real4 vLogLuv)
{
    // Inverse M matrix, for decoding
    const real3x3 InverseM = real3x3(
        6.0014, -2.7008, -1.7996,
        -1.3320, 3.1029, -5.7721,
        0.3008, -1.0882, 5.6268);

    real Le = vLogLuv.z * 255.0 + vLogLuv.w;
    real3 Xp_Y_XYZp;
    Xp_Y_XYZp.y = exp2((Le - 127.0) / 2.0);
    Xp_Y_XYZp.z = Xp_Y_XYZp.y / vLogLuv.y;
    Xp_Y_XYZp.x = vLogLuv.x * Xp_Y_XYZp.z;
    real3 vRGB = mul(Xp_Y_XYZp, InverseM);
    return max(vRGB, real3(0.0, 0.0, 0.0));
}

// The standard 32-bit HDR color format
uint PackToR11G11B10f(float3 rgb)
{
    uint r = (f32tof16(rgb.x) << 17) & 0xFFE00000;
    uint g = (f32tof16(rgb.y) << 6) & 0x001FFC00;
    uint b = (f32tof16(rgb.z) >> 5) & 0x000003FF;
    return r | g | b;
}

float3 UnpackFromR11G11B10f(uint rgb)
{
    float r = f16tof32((rgb >> 17) & 0x7FF0);
    float g = f16tof32((rgb >> 6) & 0x7FF0);
    float b = f16tof32((rgb << 5) & 0x7FE0);
    return float3(r, g, b);
}

#endif // SHADER_API_GLES

//-----------------------------------------------------------------------------
// Quaternion packing
//-----------------------------------------------------------------------------

// Ref: https://cedec.cesa.or.jp/2015/session/ENG/14698.html The Rendering Materials of Far Cry 4

/*
// This is GCN intrinsic
uint FindBiggestComponent(real4 q)
{
    uint xyzIndex = CubeMapFaceID(q.x, q.y, q.z) * 0.5f;
    uint wIndex = 3;

    bool wBiggest = abs(q.w) > max3(abs(q.x), qbs(q.y), qbs(q.z));

    return wBiggest ? wIndex : xyzIndex;
}

// Pack a quaternion into a 10:10:10:2
real4  PackQuat(real4 quat)
{
    uint index = FindBiggestComponent(quat);

    if (index == 0) quat = quat.yzwx;
    if (index == 1) quat = quat.xzwy;
    if (index == 2) quat = quat.xywz;

    real4 packedQuat;
    packedQuat.xyz = quat.xyz * FastSign(quat.w) * sqrt(0.5) + 0.5;
    packedQuat.w = index / 3.0;

    return packedQuat;
}
*/

// Unpack a quaternion from a 10:10:10:2
real4 UnpackQuat(real4 packedQuat)
{
    uint index = (uint)(packedQuat.w * 3.0);

    real4 quat;
    quat.xyz = packedQuat.xyz * sqrt(2.0) - (1.0 / sqrt(2.0));
    quat.w = sqrt(1.0 - saturate(dot(quat.xyz, quat.xyz)));

    if (index == 0) quat = quat.wxyz;
    if (index == 1) quat = quat.xwyz;
    if (index == 2) quat = quat.xywz;

    return quat;
}

// Integer and Float packing not defined in GLES2
#if !defined(SHADER_API_GLES)

//-----------------------------------------------------------------------------
// Integer packing
//-----------------------------------------------------------------------------

// Packs an integer stored using at most 'numBits' into a [0..1] real.
real PackInt(uint i, uint numBits)
{
    uint maxInt = (1u << numBits) - 1u;
    return saturate(i * rcp(maxInt));
}

// Unpacks a [0..1] real into an integer of size 'numBits'.
uint UnpackInt(real f, uint numBits)
{
    uint maxInt = (1u << numBits) - 1u;
    return (uint)(f * maxInt + 0.5); // Round instead of truncating
}

// Packs a [0..255] integer into a [0..1] real.
real PackByte(uint i)
{
    return PackInt(i, 8);
}

// Unpacks a [0..1] real into a [0..255] integer.
uint UnpackByte(real f)
{
    return UnpackInt(f, 8);
}

// Packs a [0..65535] integer into a [0..1] real.
real PackShort(uint i)
{
    return PackInt(i, 16);
}

// Unpacks a [0..1] real into a [0..65535] integer.
uint UnpackShort(real f)
{
    return UnpackInt(f, 16);
}

// Packs 8 lowermost bits of a [0..65535] integer into a [0..1] real.
real PackShortLo(uint i)
{
    uint lo = BitFieldExtract(i, 0u, 8u);
    return PackInt(lo, 8);
}

// Packs 8 uppermost bits of a [0..65535] integer into a [0..1] real.
real PackShortHi(uint i)
{
    uint hi = BitFieldExtract(i, 8u, 8u);
    return PackInt(hi, 8);
}

real Pack2Byte(real2 inputs)
{
    real2 temp = inputs * real2(255.0, 255.0);
    temp.x *= 256.0;
    temp = round(temp);
    real combined = temp.x + temp.y;
    return combined * (1.0 / 65535.0);
}

real2 Unpack2Byte(real inputs)
{
    real temp = round(inputs * 65535.0);
    real ipart;
    real fpart = modf(temp / 256.0, ipart);
    real2 result = real2(ipart, round(256.0 * fpart));
    return result * (1.0 / real2(255.0, 255.0));
}

// Encode a real in [0..1] and an int in [0..maxi - 1] as a real [0..1] to be store in log2(precision) bit
// maxi must be a power of two and define the number of bit dedicated 0..1 to the int part (log2(maxi))
// Example: precision is 256.0, maxi is 2, i is [0..1] encode on 1 bit. f is [0..1] encode on 7 bit.
// Example: precision is 256.0, maxi is 4, i is [0..3] encode on 2 bit. f is [0..1] encode on 6 bit.
// Example: precision is 256.0, maxi is 8, i is [0..7] encode on 3 bit. f is [0..1] encode on 5 bit.
// ...
// Example: precision is 1024.0, maxi is 8, i is [0..7] encode on 3 bit. f is [0..1] encode on 7 bit.
//...
real PackFloatInt(real f, uint i, real maxi, real precision)
{
    // Constant
    real precisionMinusOne = precision - 1.0;
    real t1 = ((precision / maxi) - 1.0) / precisionMinusOne;
    real t2 = (precision / maxi) / precisionMinusOne;

    return t1 * f + t2 * real(i);
}

void UnpackFloatInt(real val, real maxi, real precision, out real f, out uint i)
{
    // Constant
    real precisionMinusOne = precision - 1.0;
    real t1 = ((precision / maxi) - 1.0) / precisionMinusOne;
    real t2 = (precision / maxi) / precisionMinusOne;

    // extract integer part
    i = int((val / t2) + rcp(precisionMinusOne)); // + rcp(precisionMinusOne) to deal with precision issue (can't use round() as val contain the floating number
    // Now that we have i, solve formula in PackFloatInt for f
    //f = (val - t2 * real(i)) / t1 => convert in mads form
    f = saturate((-t2 * real(i) + val) / t1); // Saturate in case of precision issue
}

// Define various variante for ease of read
real PackFloatInt8bit(real f, uint i, real maxi)
{
    return PackFloatInt(f, i, maxi, 256.0);
}

void UnpackFloatInt8bit(real val, real maxi, out real f, out uint i)
{
    UnpackFloatInt(val, maxi, 256.0, f, i);
}

real PackFloatInt10bit(real f, uint i, real maxi)
{
    return PackFloatInt(f, i, maxi, 1024.0);
}

void UnpackFloatInt10bit(real val, real maxi, out real f, out uint i)
{
    UnpackFloatInt(val, maxi, 1024.0, f, i);
}

real PackFloatInt16bit(real f, uint i, real maxi)
{
    return PackFloatInt(f, i, maxi, 65536.0);
}

void UnpackFloatInt16bit(real val, real maxi, out real f, out uint i)
{
    UnpackFloatInt(val, maxi, 65536.0, f, i);
}

//-----------------------------------------------------------------------------
// Float packing
//-----------------------------------------------------------------------------

// src must be between 0.0 and 1.0
uint PackFloatToUInt(real src, uint offset, uint numBits)
{
    return UnpackInt(src, numBits) << offset;
}

real UnpackUIntToFloat(uint src, uint offset, uint numBits)
{
    uint maxInt = (1u << numBits) - 1u;
    return real(BitFieldExtract(src, offset, numBits)) * rcp(maxInt);
}

uint PackToR10G10B10A2(real4 rgba)
{
    return (PackFloatToUInt(rgba.x, 0,  10) |
            PackFloatToUInt(rgba.y, 10, 10) |
            PackFloatToUInt(rgba.z, 20, 10) |
            PackFloatToUInt(rgba.w, 30, 2));
}

real4 UnpackFromR10G10B10A2(uint rgba)
{
    real4 output;
    output.x = UnpackUIntToFloat(rgba, 0,  10);
    output.y = UnpackUIntToFloat(rgba, 10, 10);
    output.z = UnpackUIntToFloat(rgba, 20, 10);
    output.w = UnpackUIntToFloat(rgba, 30, 2);
    return output;
}

// Both the input and the output are in the [0, 1] range.
real2 PackFloatToR8G8(real f)
{
    uint i = UnpackShort(f);
    return real2(PackShortLo(i), PackShortHi(i));
}

// Both the input and the output are in the [0, 1] range.
real UnpackFloatFromR8G8(real2 f)
{
    uint lo = UnpackByte(f.x);
    uint hi = UnpackByte(f.y);
    uint cb = (hi << 8) + lo;
    return PackShort(cb);
}

// Pack float2 (each of 12 bit) in 888
float3 PackFloat2To888(float2 f)
{
    uint2 i = (uint2)(f * 4095.5);
    uint2 hi = i >> 8;
    uint2 lo = i & 255;
    // 8 bit in lo, 4 bit in hi
    uint3 cb = uint3(lo, hi.x | (hi.y << 4));

    return cb / 255.0;
}

// Unpack 2 float of 12bit packed into a 888
float2 Unpack888ToFloat2(float3 x)
{
    uint3 i = (uint3)(x * 255.0);
    // 8 bit in lo, 4 bit in hi
    uint hi = i.z >> 4;
    uint lo = i.z & 15;
    uint2 cb = i.xy | uint2(lo << 8, hi << 8);

    return cb / 4095.0;
}
#endif // SHADER_API_GLES

#endif // UNITY_PACKING_INCLUDED

// File end: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/Packing.hlsl
//================================================================================================================================



//================================================================================================================================
// File start: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/Version.hlsl


#define SHADER_LIBRARY_VERSION_MAJOR 7
#define SHADER_LIBRARY_VERSION_MINOR 3

#define VERSION_GREATER_EQUAL(major, minor) ((SHADER_LIBRARY_VERSION_MAJOR > major) || ((SHADER_LIBRARY_VERSION_MAJOR == major) && (SHADER_LIBRARY_VERSION_MINOR >= minor)))
#define VERSION_LOWER(major, minor) ((SHADER_LIBRARY_VERSION_MAJOR < major) || ((SHADER_LIBRARY_VERSION_MAJOR == major) && (SHADER_LIBRARY_VERSION_MINOR < minor)))
#define VERSION_EQUAL(major, minor) ((SHADER_LIBRARY_VERSION_MAJOR == major) && (SHADER_LIBRARY_VERSION_MINOR == minor))


// File end: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/Version.hlsl
//================================================================================================================================



//================================================================================================================================
// File start: com.unity.render-pipelines.universal@7.3.1/ShaderLibrary/Input.hlsl


#ifndef UNIVERSAL_INPUT_INCLUDED
#define UNIVERSAL_INPUT_INCLUDED

#define MAX_VISIBLE_LIGHTS_SSBO 256
#define MAX_VISIBLE_LIGHTS_UBO  32

//================================================================================================================================
// File start: com.unity.render-pipelines.universal@7.3.1/ShaderLibrary/ShaderTypes.cs.hlsl


//
// This file was automatically generated. Please don't edit by hand.
//

#ifndef SHADERTYPES_CS_HLSL
#define SHADERTYPES_CS_HLSL
// Generated from UnityEngine.Rendering.Universal.ShaderInput+LightData
// PackingRules = Exact
struct LightData
{
    float4 position;
    float4 color;
    float4 attenuation;
    float4 spotDirection;
    float4 occlusionProbeChannels;
};

// Generated from UnityEngine.Rendering.Universal.ShaderInput+ShadowData
// PackingRules = Exact
struct ShadowData
{
    float4x4 worldToShadowMatrix;
    float4 shadowParams;
};


#endif

// File end: com.unity.render-pipelines.universal@7.3.1/ShaderLibrary/ShaderTypes.cs.hlsl
//================================================================================================================================




// There are some performance issues by using SSBO in mobile.
// Also some GPUs don't supports SSBO in vertex shader.
#if !defined(SHADER_API_MOBILE) && (defined(SHADER_API_METAL) || defined(SHADER_API_VULKAN) || defined(SHADER_API_PS4) || defined(SHADER_API_XBOXONE))
    #define USE_STRUCTURED_BUFFER_FOR_LIGHT_DATA 0
    #define MAX_VISIBLE_LIGHTS MAX_VISIBLE_LIGHTS_SSBO
// We don't use SSBO in D3D because we can't figure out without adding shader variants if platforms is D3D10.
// We don't use SSBO on Nintendo Switch as UBO path is faster.
// However here we use same limits as SSBO path. 
#elif defined(SHADER_API_D3D11) || defined(SHADER_API_SWITCH)
    #define MAX_VISIBLE_LIGHTS MAX_VISIBLE_LIGHTS_SSBO
    #define USE_STRUCTURED_BUFFER_FOR_LIGHT_DATA 0
// We use less limits for mobile as some mobile GPUs have small SP cache for constants
// Using more than 32 might cause spilling to main memory.
#else
    #define MAX_VISIBLE_LIGHTS MAX_VISIBLE_LIGHTS_UBO
    #define USE_STRUCTURED_BUFFER_FOR_LIGHT_DATA 0
#endif

struct InputData
{
    float3  positionWS;
    half3   normalWS;
    half3   viewDirectionWS;
    float4  shadowCoord;
    half    fogCoord;
    half3   vertexLighting;
    half3   bakedGI;
};

///////////////////////////////////////////////////////////////////////////////
//                      Constant Buffers                                     //
///////////////////////////////////////////////////////////////////////////////

half4 _GlossyEnvironmentColor;
half4 _SubtractiveShadowColor;

float4x4 _InvCameraViewProj;
float4 _ScaledScreenParams;

float4 _MainLightPosition;
half4 _MainLightColor;

half4 _AdditionalLightsCount;
#if USE_STRUCTURED_BUFFER_FOR_LIGHT_DATA
StructuredBuffer<LightData> _AdditionalLightsBuffer;
StructuredBuffer<int> _AdditionalLightsIndices;
#else
float4 _AdditionalLightsPosition[MAX_VISIBLE_LIGHTS];
half4 _AdditionalLightsColor[MAX_VISIBLE_LIGHTS];
half4 _AdditionalLightsAttenuation[MAX_VISIBLE_LIGHTS];
half4 _AdditionalLightsSpotDir[MAX_VISIBLE_LIGHTS];
half4 _AdditionalLightsOcclusionProbes[MAX_VISIBLE_LIGHTS];
#endif

#define UNITY_MATRIX_M     unity_ObjectToWorld
#define UNITY_MATRIX_I_M   unity_WorldToObject
#define UNITY_MATRIX_V     unity_MatrixV
#define UNITY_MATRIX_I_V   unity_MatrixInvV
#define UNITY_MATRIX_P     OptimizeProjectionMatrix(glstate_matrix_projection)
#define UNITY_MATRIX_I_P   ERROR_UNITY_MATRIX_I_P_IS_NOT_DEFINED
#define UNITY_MATRIX_VP    unity_MatrixVP
#define UNITY_MATRIX_I_VP  _InvCameraViewProj
#define UNITY_MATRIX_MV    mul(UNITY_MATRIX_V, UNITY_MATRIX_M)
#define UNITY_MATRIX_T_MV  transpose(UNITY_MATRIX_MV)
#define UNITY_MATRIX_IT_MV transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V))
#define UNITY_MATRIX_MVP   mul(UNITY_MATRIX_VP, UNITY_MATRIX_M)

//================================================================================================================================
// File start: com.unity.render-pipelines.universal@7.3.1/ShaderLibrary/UnityInput.hlsl


// UNITY_SHADER_NO_UPGRADE

#ifndef UNIVERSAL_SHADER_VARIABLES_INCLUDED
#define UNIVERSAL_SHADER_VARIABLES_INCLUDED

#if defined(STEREO_INSTANCING_ON) && (defined(SHADER_API_D3D11) || defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE) || defined(SHADER_API_PSSL) || defined(SHADER_API_VULKAN))
#define UNITY_STEREO_INSTANCING_ENABLED
#endif

#if defined(STEREO_MULTIVIEW_ON) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE) || defined(SHADER_API_VULKAN)) && !(defined(SHADER_API_SWITCH))
    #define UNITY_STEREO_MULTIVIEW_ENABLED
#endif

#if defined(UNITY_SINGLE_PASS_STEREO) || defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
#define USING_STEREO_MATRICES
#endif

#if defined(USING_STEREO_MATRICES)
#define glstate_matrix_projection unity_StereoMatrixP[unity_StereoEyeIndex]
#define unity_MatrixV unity_StereoMatrixV[unity_StereoEyeIndex]
#define unity_MatrixInvV unity_StereoMatrixInvV[unity_StereoEyeIndex]
#define unity_MatrixVP unity_StereoMatrixVP[unity_StereoEyeIndex]

#define unity_CameraProjection unity_StereoCameraProjection[unity_StereoEyeIndex]
#define unity_CameraInvProjection unity_StereoCameraInvProjection[unity_StereoEyeIndex]
#define unity_WorldToCamera unity_StereoWorldToCamera[unity_StereoEyeIndex]
#define unity_CameraToWorld unity_StereoCameraToWorld[unity_StereoEyeIndex]
#define _WorldSpaceCameraPos unity_StereoWorldSpaceCameraPos[unity_StereoEyeIndex]
#endif

#define UNITY_LIGHTMODEL_AMBIENT (glstate_lightmodel_ambient * 2)

// ----------------------------------------------------------------------------

// Time (t = time since current level load) values from Unity
float4 _Time; // (t/20, t, t*2, t*3)
float4 _SinTime; // sin(t/8), sin(t/4), sin(t/2), sin(t)
float4 _CosTime; // cos(t/8), cos(t/4), cos(t/2), cos(t)
float4 unity_DeltaTime; // dt, 1/dt, smoothdt, 1/smoothdt
float4 _TimeParameters; // t, sin(t), cos(t)

#if !defined(USING_STEREO_MATRICES)
float3 _WorldSpaceCameraPos;
#endif

// x = 1 or -1 (-1 if projection is flipped)
// y = near plane
// z = far plane
// w = 1/far plane
float4 _ProjectionParams;

// x = width
// y = height
// z = 1 + 1.0/width
// w = 1 + 1.0/height
float4 _ScreenParams;

// Values used to linearize the Z buffer (http://www.humus.name/temp/Linearize%20depth.txt)
// x = 1-far/near
// y = far/near
// z = x/far
// w = y/far
// or in case of a reversed depth buffer (UNITY_REVERSED_Z is 1)
// x = -1+far/near
// y = 1
// z = x/far
// w = 1/far
float4 _ZBufferParams;

// x = orthographic camera's width
// y = orthographic camera's height
// z = unused
// w = 1.0 if camera is ortho, 0.0 if perspective
float4 unity_OrthoParams;

float4 unity_CameraWorldClipPlanes[6];

#if !defined(USING_STEREO_MATRICES)
// Projection matrices of the camera. Note that this might be different from projection matrix
// that is set right now, e.g. while rendering shadows the matrices below are still the projection
// of original camera.
float4x4 unity_CameraProjection;
float4x4 unity_CameraInvProjection;
float4x4 unity_WorldToCamera;
float4x4 unity_CameraToWorld;
#endif

// ----------------------------------------------------------------------------

// Block Layout should be respected due to SRP Batcher
CBUFFER_START(UnityPerDraw)
// Space block Feature
float4x4 unity_ObjectToWorld;
float4x4 unity_WorldToObject;
float4 unity_LODFade; // x is the fade value ranging within [0,1]. y is x quantized into 16 levels
real4 unity_WorldTransformParams; // w is usually 1.0, or -1.0 for odd-negative scale transforms

// Light Indices block feature
// These are set internally by the engine upon request by RendererConfiguration.
real4 unity_LightData;
real4 unity_LightIndices[2];

float4 unity_ProbesOcclusion;

// Reflection Probe 0 block feature
// HDR environment map decode instructions
real4 unity_SpecCube0_HDR;

// Lightmap block feature
float4 unity_LightmapST;
float4 unity_DynamicLightmapST;

// SH block feature
real4 unity_SHAr;
real4 unity_SHAg;
real4 unity_SHAb;
real4 unity_SHBr;
real4 unity_SHBg;
real4 unity_SHBb;
real4 unity_SHC;
CBUFFER_END

#if defined(UNITY_STEREO_MULTIVIEW_ENABLED) || ((defined(UNITY_SINGLE_PASS_STEREO) || defined(UNITY_STEREO_INSTANCING_ENABLED)) && (defined(SHADER_API_GLCORE) || defined(SHADER_API_GLES3) || defined(SHADER_API_METAL) || defined(SHADER_API_VULKAN)))
    #define GLOBAL_CBUFFER_START(name)    cbuffer name {
    #define GLOBAL_CBUFFER_END            }
#else
    #define GLOBAL_CBUFFER_START(name)    CBUFFER_START(name)
    #define GLOBAL_CBUFFER_END            CBUFFER_END
#endif

#if defined(USING_STEREO_MATRICES)
GLOBAL_CBUFFER_START(UnityStereoGlobals)
float4x4 unity_StereoMatrixP[2];
float4x4 unity_StereoMatrixV[2];
float4x4 unity_StereoMatrixInvV[2];
float4x4 unity_StereoMatrixVP[2];

float4x4 unity_StereoCameraProjection[2];
float4x4 unity_StereoCameraInvProjection[2];
float4x4 unity_StereoWorldToCamera[2];
float4x4 unity_StereoCameraToWorld[2];

float3 unity_StereoWorldSpaceCameraPos[2];
float4 unity_StereoScaleOffset[2];
GLOBAL_CBUFFER_END
#endif

#if defined(USING_STEREO_MATRICES) && defined(UNITY_STEREO_MULTIVIEW_ENABLED)
GLOBAL_CBUFFER_START(UnityStereoEyeIndices)
    float4 unity_StereoEyeIndices[2];
GLOBAL_CBUFFER_END
#endif

#if defined(UNITY_STEREO_MULTIVIEW_ENABLED) && defined(SHADER_STAGE_VERTEX)
// OVR_multiview
// In order to convey this info over the DX compiler, we wrap it into a cbuffer.
#if !defined(UNITY_DECLARE_MULTIVIEW)
#define UNITY_DECLARE_MULTIVIEW(number_of_views) GLOBAL_CBUFFER_START(OVR_multiview) uint gl_ViewID; uint numViews_##number_of_views; GLOBAL_CBUFFER_END
#define UNITY_VIEWID gl_ViewID
#endif
#endif

#if defined(UNITY_STEREO_MULTIVIEW_ENABLED) && defined(SHADER_STAGE_VERTEX)
#define unity_StereoEyeIndex UNITY_VIEWID
UNITY_DECLARE_MULTIVIEW(2);
#elif defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
static uint unity_StereoEyeIndex;
#elif defined(UNITY_SINGLE_PASS_STEREO)
GLOBAL_CBUFFER_START(UnityStereoEyeIndex)
int unity_StereoEyeIndex;
GLOBAL_CBUFFER_END
#endif

float4x4 glstate_matrix_transpose_modelview0;

// ----------------------------------------------------------------------------

real4 glstate_lightmodel_ambient;
real4 unity_AmbientSky;
real4 unity_AmbientEquator;
real4 unity_AmbientGround;
real4 unity_IndirectSpecColor;
float4 unity_FogParams;
real4  unity_FogColor;

#if !defined(USING_STEREO_MATRICES)
float4x4 glstate_matrix_projection;
float4x4 unity_MatrixV;
float4x4 unity_MatrixInvV;
float4x4 unity_MatrixVP;
float4 unity_StereoScaleOffset;
int unity_StereoEyeIndex;
#endif

real4 unity_ShadowColor;

// ----------------------------------------------------------------------------

// Unity specific
TEXTURECUBE(unity_SpecCube0);
SAMPLER(samplerunity_SpecCube0);

// Main lightmap
TEXTURE2D(unity_Lightmap);
SAMPLER(samplerunity_Lightmap);
// Dual or directional lightmap (always used with unity_Lightmap, so can share sampler)
TEXTURE2D(unity_LightmapInd);

// We can have shadowMask only if we have lightmap, so no sampler
TEXTURE2D(unity_ShadowMask);

// ----------------------------------------------------------------------------

// TODO: all affine matrices should be 3x4.
// TODO: sort these vars by the frequency of use (descending), and put commonly used vars together.
// Note: please use UNITY_MATRIX_X macros instead of referencing matrix variables directly.
float4x4 _PrevViewProjMatrix;
float4x4 _ViewProjMatrix;
float4x4 _NonJitteredViewProjMatrix;
float4x4 _ViewMatrix;
float4x4 _ProjMatrix;
float4x4 _InvViewProjMatrix;
float4x4 _InvViewMatrix;
float4x4 _InvProjMatrix;
float4   _InvProjParam;
float4   _ScreenSize;       // {w, h, 1/w, 1/h}
float4   _FrustumPlanes[6]; // {(a, b, c) = N, d = -dot(N, P)} [L, R, T, B, N, F]

float4x4 OptimizeProjectionMatrix(float4x4 M)
{
    // Matrix format (x = non-constant value).
    // Orthographic Perspective  Combined(OR)
    // | x 0 0 x |  | x 0 x 0 |  | x 0 x x |
    // | 0 x 0 x |  | 0 x x 0 |  | 0 x x x |
    // | x x x x |  | x x x x |  | x x x x | <- oblique projection row
    // | 0 0 0 1 |  | 0 0 x 0 |  | 0 0 x x |
    // Notice that some values are always 0.
    // We can avoid loading and doing math with constants.
    M._21_41 = 0;
    M._12_42 = 0;
    return M;
}

#endif // UNIVERSAL_SHADER_VARIABLES_INCLUDED

// File end: com.unity.render-pipelines.universal@7.3.1/ShaderLibrary/UnityInput.hlsl
//================================================================================================================================



//================================================================================================================================
// File start: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/UnityInstancing.hlsl


#ifndef UNITY_INSTANCING_INCLUDED
#define UNITY_INSTANCING_INCLUDED

#if SHADER_TARGET >= 35 && (defined(SHADER_API_D3D11) || defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE) || defined(SHADER_API_XBOXONE) || defined(SHADER_API_PSSL) || defined(SHADER_API_VULKAN) || defined(SHADER_API_METAL))
    #define UNITY_SUPPORT_INSTANCING
#endif

#if defined(SHADER_API_SWITCH)
    #define UNITY_SUPPORT_INSTANCING
#endif

#if defined(SHADER_API_D3D11) || defined(SHADER_API_GLCORE) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN)
    #define UNITY_SUPPORT_STEREO_INSTANCING
#endif

// These platforms support dynamically adjusting the instancing CB size according to the current batch.
#if defined(SHADER_API_D3D11) || defined(SHADER_API_GLCORE) || defined(SHADER_API_GLES3) || defined(SHADER_API_METAL) || defined(SHADER_API_PSSL) || defined(SHADER_API_VULKAN) || defined(SHADER_API_SWITCH)
    #define UNITY_INSTANCING_SUPPORT_FLEXIBLE_ARRAY_SIZE
#endif

#if defined(SHADER_TARGET_SURFACE_ANALYSIS) && defined(UNITY_SUPPORT_INSTANCING)
    #undef UNITY_SUPPORT_INSTANCING
#endif

////////////////////////////////////////////////////////
// instancing paths
// - UNITY_INSTANCING_ENABLED               Defined if instancing path is taken.
// - UNITY_PROCEDURAL_INSTANCING_ENABLED    Defined if procedural instancing path is taken.
// - UNITY_STEREO_INSTANCING_ENABLED        Defined if stereo instancing path is taken.
// - UNITY_ANY_INSTANCING_ENABLED           Defined if any instancing path is taken
#if defined(UNITY_SUPPORT_INSTANCING) && defined(INSTANCING_ON)
    #define UNITY_INSTANCING_ENABLED
#endif
#if defined(UNITY_SUPPORT_INSTANCING) && defined(PROCEDURAL_INSTANCING_ON)
    #define UNITY_PROCEDURAL_INSTANCING_ENABLED
#endif
#if defined(UNITY_SUPPORT_STEREO_INSTANCING) && defined(STEREO_INSTANCING_ON)
    #define UNITY_STEREO_INSTANCING_ENABLED
#endif

#if defined(UNITY_INSTANCING_ENABLED) || defined(UNITY_PROCEDURAL_INSTANCING_ENABLED) || defined(UNITY_STEREO_INSTANCING_ENABLED)
    #define UNITY_ANY_INSTANCING_ENABLED 1
#else
    #define UNITY_ANY_INSTANCING_ENABLED 0
#endif

#if defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE) || defined(SHADER_API_METAL) || defined(SHADER_API_VULKAN)
    // These platforms have constant buffers disabled normally, but not here (see CBUFFER_START/CBUFFER_END in HLSLSupport.cginc).
    #define UNITY_INSTANCING_CBUFFER_SCOPE_BEGIN(name)  cbuffer name {
    #define UNITY_INSTANCING_CBUFFER_SCOPE_END          }
#else
    #define UNITY_INSTANCING_CBUFFER_SCOPE_BEGIN(name)  CBUFFER_START(name)
    #define UNITY_INSTANCING_CBUFFER_SCOPE_END          CBUFFER_END
#endif

////////////////////////////////////////////////////////
// basic instancing setups
// - UNITY_VERTEX_INPUT_INSTANCE_ID     Declare instance ID field in vertex shader input / output struct.
// - UNITY_GET_INSTANCE_ID              (Internal) Get the instance ID from input struct.
#if defined(UNITY_INSTANCING_ENABLED) || defined(UNITY_PROCEDURAL_INSTANCING_ENABLED) || defined(UNITY_STEREO_INSTANCING_ENABLED)

    // A global instance ID variable that functions can directly access.
    static uint unity_InstanceID;

    // Don't make UnityDrawCallInfo an actual CB on GL
    #if !defined(SHADER_API_GLES3) && !defined(SHADER_API_GLCORE)
        UNITY_INSTANCING_CBUFFER_SCOPE_BEGIN(UnityDrawCallInfo)
    #endif
            int unity_BaseInstanceID;
            int unity_InstanceCount;
    #if !defined(SHADER_API_GLES3) && !defined(SHADER_API_GLCORE)
        UNITY_INSTANCING_CBUFFER_SCOPE_END
    #endif

    #ifdef SHADER_API_PSSL
        #define DEFAULT_UNITY_VERTEX_INPUT_INSTANCE_ID uint instanceID;
        #define UNITY_GET_INSTANCE_ID(input)    _GETINSTANCEID(input)
    #else
        #define DEFAULT_UNITY_VERTEX_INPUT_INSTANCE_ID uint instanceID : SV_InstanceID;
        #define UNITY_GET_INSTANCE_ID(input)    input.instanceID
    #endif

#else
    #define DEFAULT_UNITY_VERTEX_INPUT_INSTANCE_ID
#endif // UNITY_INSTANCING_ENABLED || UNITY_PROCEDURAL_INSTANCING_ENABLED || UNITY_STEREO_INSTANCING_ENABLED

#if !defined(UNITY_VERTEX_INPUT_INSTANCE_ID)
#   define UNITY_VERTEX_INPUT_INSTANCE_ID DEFAULT_UNITY_VERTEX_INPUT_INSTANCE_ID
#endif

////////////////////////////////////////////////////////
// basic stereo instancing setups
// - UNITY_VERTEX_OUTPUT_STEREO             Declare stereo target eye field in vertex shader output struct.
// - UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO  Assign the stereo target eye.
// - UNITY_TRANSFER_VERTEX_OUTPUT_STEREO    Copy stero target from input struct to output struct. Used in vertex shader.
// - UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
#ifdef UNITY_STEREO_INSTANCING_ENABLED
#if defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)
    #define DEFAULT_UNITY_VERTEX_OUTPUT_STEREO                          uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex; uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
    #define DEFAULT_UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output)       output.stereoTargetEyeIndexAsRTArrayIdx = unity_StereoEyeIndex; output.stereoTargetEyeIndexAsBlendIdx0 = unity_StereoEyeIndex;
    #define DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(input, output)  output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
    #define DEFAULT_UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)     unity_StereoEyeIndex = input.stereoTargetEyeIndexAsBlendIdx0;
#elif defined(SHADER_API_PSSL) && defined(TESSELLATION_ON)
    // Use of SV_RenderTargetArrayIndex is a little more complicated if we have tessellation stages involved
    // This will add an extra instructions which we might be able to optimize away in some stages if we are careful.
    #if defined(SHADER_STAGE_VERTEX)
        #define DEFAULT_UNITY_VERTEX_OUTPUT_STEREO                          uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #define DEFAULT_UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output)       output.stereoTargetEyeIndexAsBlendIdx0 = unity_StereoEyeIndex;
        #define DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(input, output)  output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #define DEFAULT_UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)     unity_StereoEyeIndex = input.stereoTargetEyeIndexAsBlendIdx0;        
    #else
        #define DEFAULT_UNITY_VERTEX_OUTPUT_STEREO                          uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex; uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #define DEFAULT_UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output)       output.stereoTargetEyeIndexAsRTArrayIdx = unity_StereoEyeIndex; output.stereoTargetEyeIndexAsBlendIdx0 = unity_StereoEyeIndex;
        #define DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(input, output)  output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #define DEFAULT_UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)     unity_StereoEyeIndex = input.stereoTargetEyeIndexAsBlendIdx0;                
    #endif
#else
    #define DEFAULT_UNITY_VERTEX_OUTPUT_STEREO                          uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
    #define DEFAULT_UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output)       output.stereoTargetEyeIndexAsRTArrayIdx = unity_StereoEyeIndex
    #define DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(input, output)  output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
    #define DEFAULT_UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)     unity_StereoEyeIndex = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif

#elif defined(UNITY_STEREO_MULTIVIEW_ENABLED)
    #define DEFAULT_UNITY_VERTEX_OUTPUT_STEREO float stereoTargetEyeIndexAsBlendIdx0 : BLENDWEIGHT0;
    // HACK: Workaround for Mali shader compiler issues with directly using GL_ViewID_OVR (GL_OVR_multiview). This array just contains the values 0 and 1.
    #define DEFAULT_UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output) output.stereoTargetEyeIndexAsBlendIdx0 = unity_StereoEyeIndices[unity_StereoEyeIndex].x;
    #define DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(input, output) output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
    #if defined(SHADER_STAGE_VERTEX)
        #define DEFAULT_UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
    #else
        #define DEFAULT_UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input) unity_StereoEyeIndex = (uint) input.stereoTargetEyeIndexAsBlendIdx0;
    #endif
#else
    #define DEFAULT_UNITY_VERTEX_OUTPUT_STEREO
    #define DEFAULT_UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output)
    #define DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(input, output)
    #define DEFAULT_UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
#endif


#if !defined(UNITY_VERTEX_OUTPUT_STEREO)
#   define UNITY_VERTEX_OUTPUT_STEREO                           DEFAULT_UNITY_VERTEX_OUTPUT_STEREO
#endif
#if !defined(UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO)
#   define UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output)        DEFAULT_UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output)
#endif
#if !defined(UNITY_TRANSFER_VERTEX_OUTPUT_STEREO)
#   define UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(input, output)   DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(input, output)
#endif
#if !defined(UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX)
#   define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)      DEFAULT_UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
#endif

////////////////////////////////////////////////////////
// - UNITY_SETUP_INSTANCE_ID        Should be used at the very beginning of the vertex shader / fragment shader,
//                                  so that succeeding code can have access to the global unity_InstanceID.
//                                  Also procedural function is called to setup instance data.
// - UNITY_TRANSFER_INSTANCE_ID     Copy instance ID from input struct to output struct. Used in vertex shader.

#if defined(UNITY_INSTANCING_ENABLED) || defined(UNITY_PROCEDURAL_INSTANCING_ENABLED) || defined(UNITY_STEREO_INSTANCING_ENABLED)
    void UnitySetupInstanceID(uint inputInstanceID)
    {
        #ifdef UNITY_STEREO_INSTANCING_ENABLED
            #if !defined(SHADEROPTIONS_XR_MAX_VIEWS) || SHADEROPTIONS_XR_MAX_VIEWS <= 2
                #if defined(SHADER_API_GLES3)
                    // We must calculate the stereo eye index differently for GLES3
                    // because otherwise,  the unity shader compiler will emit a bitfieldInsert function.
                    // bitfieldInsert requires support for glsl version 400 or later.  Therefore the
                    // generated glsl code will fail to compile on lower end devices.  By changing the
                    // way we calculate the stereo eye index,  we can help the shader compiler to avoid
                    // emitting the bitfieldInsert function and thereby increase the number of devices we
                    // can run stereo instancing on.
                    unity_StereoEyeIndex = round(fmod(inputInstanceID, 2.0));
                    unity_InstanceID = unity_BaseInstanceID + (inputInstanceID >> 1);
                #else
                    // stereo eye index is automatically figured out from the instance ID
                    unity_StereoEyeIndex = inputInstanceID & 0x01;
                    unity_InstanceID = unity_BaseInstanceID + (inputInstanceID >> 1);
                #endif
            #else
                unity_StereoEyeIndex = inputInstanceID % _XRViewCount;
                unity_InstanceID = unity_BaseInstanceID + (inputInstanceID / _XRViewCount);
            #endif
        #else
            unity_InstanceID = inputInstanceID + unity_BaseInstanceID;
        #endif
    }

    #ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
        #ifndef UNITY_INSTANCING_PROCEDURAL_FUNC
            #error "UNITY_INSTANCING_PROCEDURAL_FUNC must be defined."
        #else
            void UNITY_INSTANCING_PROCEDURAL_FUNC(); // forward declaration of the procedural function
            #define DEFAULT_UNITY_SETUP_INSTANCE_ID(input)      { UnitySetupInstanceID(UNITY_GET_INSTANCE_ID(input)); UNITY_INSTANCING_PROCEDURAL_FUNC();}
        #endif
    #else
        #define DEFAULT_UNITY_SETUP_INSTANCE_ID(input)          { UnitySetupInstanceID(UNITY_GET_INSTANCE_ID(input));}
    #endif
    #define UNITY_TRANSFER_INSTANCE_ID(input, output)   output.instanceID = UNITY_GET_INSTANCE_ID(input)
#else
    #define DEFAULT_UNITY_SETUP_INSTANCE_ID(input)
    #define UNITY_TRANSFER_INSTANCE_ID(input, output)
#endif

#if !defined(UNITY_SETUP_INSTANCE_ID)
#   define UNITY_SETUP_INSTANCE_ID(input) DEFAULT_UNITY_SETUP_INSTANCE_ID(input)
#endif

////////////////////////////////////////////////////////
// instanced property arrays
#if defined(UNITY_INSTANCING_ENABLED)

    #ifdef UNITY_FORCE_MAX_INSTANCE_COUNT
        #define UNITY_INSTANCED_ARRAY_SIZE  UNITY_FORCE_MAX_INSTANCE_COUNT
    #elif defined(UNITY_INSTANCING_SUPPORT_FLEXIBLE_ARRAY_SIZE)
        #define UNITY_INSTANCED_ARRAY_SIZE  2 // minimum array size that ensures dynamic indexing
    #elif defined(UNITY_MAX_INSTANCE_COUNT)
        #define UNITY_INSTANCED_ARRAY_SIZE  UNITY_MAX_INSTANCE_COUNT
    #else
        #if (defined(SHADER_API_VULKAN) && defined(SHADER_API_MOBILE)) || defined(SHADER_API_SWITCH)
            #define UNITY_INSTANCED_ARRAY_SIZE  250
        #else
            #define UNITY_INSTANCED_ARRAY_SIZE  500
        #endif
    #endif

    #define UNITY_INSTANCING_BUFFER_START(buf)      UNITY_INSTANCING_CBUFFER_SCOPE_BEGIN(UnityInstancing_##buf) struct {
    #define UNITY_INSTANCING_BUFFER_END(arr)        } arr##Array[UNITY_INSTANCED_ARRAY_SIZE]; UNITY_INSTANCING_CBUFFER_SCOPE_END
    #define UNITY_DEFINE_INSTANCED_PROP(type, var)  type var;
    #define UNITY_ACCESS_INSTANCED_PROP(arr, var)   arr##Array[unity_InstanceID].var

    // Put worldToObject array to a separate CB if UNITY_ASSUME_UNIFORM_SCALING is defined. Most of the time it will not be used.
    #ifdef UNITY_ASSUME_UNIFORM_SCALING
        #define UNITY_WORLDTOOBJECTARRAY_CB 1
    #else
        #define UNITY_WORLDTOOBJECTARRAY_CB 0
    #endif

    #if defined(UNITY_INSTANCED_LOD_FADE) && (defined(LOD_FADE_PERCENTAGE) || defined(LOD_FADE_CROSSFADE))
        #define UNITY_USE_LODFADE_ARRAY
    #endif

    #if defined(UNITY_INSTANCED_RENDERING_LAYER)
        #define UNITY_USE_RENDERINGLAYER_ARRAY
    #endif

    #ifdef UNITY_INSTANCED_LIGHTMAPSTS
        #ifdef LIGHTMAP_ON
            #define UNITY_USE_LIGHTMAPST_ARRAY
        #endif
        #ifdef DYNAMICLIGHTMAP_ON
            #define UNITY_USE_DYNAMICLIGHTMAPST_ARRAY
        #endif
    #endif

    #if defined(UNITY_INSTANCED_SH) && !defined(LIGHTMAP_ON)
        #if !defined(DYNAMICLIGHTMAP_ON)
            #define UNITY_USE_SHCOEFFS_ARRAYS
        #endif
        #if defined(SHADOWS_SHADOWMASK)
            #define UNITY_USE_PROBESOCCLUSION_ARRAY
        #endif
    #endif

    UNITY_INSTANCING_BUFFER_START(PerDraw0)
        #ifndef UNITY_DONT_INSTANCE_OBJECT_MATRICES
            UNITY_DEFINE_INSTANCED_PROP(float4x4, unity_ObjectToWorldArray)
            #if UNITY_WORLDTOOBJECTARRAY_CB == 0
                UNITY_DEFINE_INSTANCED_PROP(float4x4, unity_WorldToObjectArray)
            #endif
        #endif
        #if defined(UNITY_USE_LODFADE_ARRAY) && defined(UNITY_INSTANCING_SUPPORT_FLEXIBLE_ARRAY_SIZE)
            UNITY_DEFINE_INSTANCED_PROP(float2, unity_LODFadeArray)
            #define unity_LODFade UNITY_ACCESS_INSTANCED_PROP(unity_Builtins0, unity_LODFadeArray).xyxx
        #endif
        #if defined(UNITY_USE_RENDERINGLAYER_ARRAY) && defined(UNITY_INSTANCING_SUPPORT_FLEXIBLE_ARRAY_SIZE)
            UNITY_DEFINE_INSTANCED_PROP(float, unity_RenderingLayerArray)
            #define unity_RenderingLayer UNITY_ACCESS_INSTANCED_PROP(unity_Builtins0, unity_RenderingLayerArray).xxxx
        #endif
        #if defined(SHADER_GRAPH_GENERATED)
                DOTS_CUSTOM_ADDITIONAL_MATERIAL_VARS
        #endif
    UNITY_INSTANCING_BUFFER_END(unity_Builtins0)

    UNITY_INSTANCING_BUFFER_START(PerDraw1)
        #if !defined(UNITY_DONT_INSTANCE_OBJECT_MATRICES) && UNITY_WORLDTOOBJECTARRAY_CB == 1
            UNITY_DEFINE_INSTANCED_PROP(float4x4, unity_WorldToObjectArray)
        #endif
        #if defined(UNITY_USE_LODFADE_ARRAY) && !defined(UNITY_INSTANCING_SUPPORT_FLEXIBLE_ARRAY_SIZE)
            UNITY_DEFINE_INSTANCED_PROP(float2, unity_LODFadeArray)
            #define unity_LODFade UNITY_ACCESS_INSTANCED_PROP(unity_Builtins1, unity_LODFadeArray).xyxx
        #endif
        #if defined(UNITY_USE_RENDERINGLAYER_ARRAY) && !defined(UNITY_INSTANCING_SUPPORT_FLEXIBLE_ARRAY_SIZE)
            UNITY_DEFINE_INSTANCED_PROP(float, unity_RenderingLayerArray)
            #define unity_RenderingLayer UNITY_ACCESS_INSTANCED_PROP(unity_Builtins1, unity_RenderingLayerArray).xxxx
        #endif
    UNITY_INSTANCING_BUFFER_END(unity_Builtins1)

    UNITY_INSTANCING_BUFFER_START(PerDraw2)
        #ifdef UNITY_USE_LIGHTMAPST_ARRAY
            UNITY_DEFINE_INSTANCED_PROP(float4, unity_LightmapSTArray)
            #define unity_LightmapST UNITY_ACCESS_INSTANCED_PROP(unity_Builtins2, unity_LightmapSTArray)
        #endif
        #ifdef UNITY_USE_DYNAMICLIGHTMAPST_ARRAY
            UNITY_DEFINE_INSTANCED_PROP(float4, unity_DynamicLightmapSTArray)
            #define unity_DynamicLightmapST UNITY_ACCESS_INSTANCED_PROP(unity_Builtins2, unity_DynamicLightmapSTArray)
        #endif
        #ifdef UNITY_USE_SHCOEFFS_ARRAYS
            UNITY_DEFINE_INSTANCED_PROP(half4, unity_SHArArray)
            UNITY_DEFINE_INSTANCED_PROP(half4, unity_SHAgArray)
            UNITY_DEFINE_INSTANCED_PROP(half4, unity_SHAbArray)
            UNITY_DEFINE_INSTANCED_PROP(half4, unity_SHBrArray)
            UNITY_DEFINE_INSTANCED_PROP(half4, unity_SHBgArray)
            UNITY_DEFINE_INSTANCED_PROP(half4, unity_SHBbArray)
            UNITY_DEFINE_INSTANCED_PROP(half4, unity_SHCArray)
            #define unity_SHAr UNITY_ACCESS_INSTANCED_PROP(unity_Builtins2, unity_SHArArray)
            #define unity_SHAg UNITY_ACCESS_INSTANCED_PROP(unity_Builtins2, unity_SHAgArray)
            #define unity_SHAb UNITY_ACCESS_INSTANCED_PROP(unity_Builtins2, unity_SHAbArray)
            #define unity_SHBr UNITY_ACCESS_INSTANCED_PROP(unity_Builtins2, unity_SHBrArray)
            #define unity_SHBg UNITY_ACCESS_INSTANCED_PROP(unity_Builtins2, unity_SHBgArray)
            #define unity_SHBb UNITY_ACCESS_INSTANCED_PROP(unity_Builtins2, unity_SHBbArray)
            #define unity_SHC  UNITY_ACCESS_INSTANCED_PROP(unity_Builtins2, unity_SHCArray)
        #endif
        #ifdef UNITY_USE_PROBESOCCLUSION_ARRAY
            UNITY_DEFINE_INSTANCED_PROP(half4, unity_ProbesOcclusionArray)
            #define unity_ProbesOcclusion UNITY_ACCESS_INSTANCED_PROP(unity_Builtins2, unity_ProbesOcclusionArray)
        #endif
    UNITY_INSTANCING_BUFFER_END(unity_Builtins2)

    #ifndef UNITY_DONT_INSTANCE_OBJECT_MATRICES
        #undef UNITY_MATRIX_M
        #undef UNITY_MATRIX_I_M
        #define MERGE_UNITY_BUILTINS_INDEX(X) unity_Builtins##X
        #define CALL_MERGE_UNITY_BUILTINS_INDEX(X)  MERGE_UNITY_BUILTINS_INDEX(X)
        #ifdef MODIFY_MATRIX_FOR_CAMERA_RELATIVE_RENDERING
            #define UNITY_MATRIX_M      ApplyCameraTranslationToMatrix(UNITY_ACCESS_INSTANCED_PROP(unity_Builtins0, unity_ObjectToWorldArray))
            #define UNITY_MATRIX_I_M    ApplyCameraTranslationToInverseMatrix(UNITY_ACCESS_INSTANCED_PROP(CALL_MERGE_UNITY_BUILTINS_INDEX(UNITY_WORLDTOOBJECTARRAY_CB), unity_WorldToObjectArray))
        #else
            #define UNITY_MATRIX_M      UNITY_ACCESS_INSTANCED_PROP(unity_Builtins0, unity_ObjectToWorldArray)
            #define UNITY_MATRIX_I_M    UNITY_ACCESS_INSTANCED_PROP(CALL_MERGE_UNITY_BUILTINS_INDEX(UNITY_WORLDTOOBJECTARRAY_CB), unity_WorldToObjectArray)
        #endif
    #endif

#else // UNITY_INSTANCING_ENABLED

    // in procedural mode we don't need cbuffer, and properties are not uniforms
    #ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
        #define UNITY_INSTANCING_BUFFER_START(buf)
        #define UNITY_INSTANCING_BUFFER_END(arr)
        #define UNITY_DEFINE_INSTANCED_PROP(type, var)      static type var;
    #else
        #define UNITY_INSTANCING_BUFFER_START(buf)          CBUFFER_START(buf)
        #define UNITY_INSTANCING_BUFFER_END(arr)            CBUFFER_END
        #define UNITY_DEFINE_INSTANCED_PROP(type, var)      type var;
    #endif

    #define UNITY_ACCESS_INSTANCED_PROP(arr, var)           var

#endif // UNITY_INSTANCING_ENABLED

#endif // UNITY_INSTANCING_INCLUDED

// File end: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/UnityInstancing.hlsl
//================================================================================================================================



//================================================================================================================================
// File start: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/SpaceTransforms.hlsl


#ifndef UNITY_SPACE_TRANSFORMS_INCLUDED
#define UNITY_SPACE_TRANSFORMS_INCLUDED

// Return the PreTranslated ObjectToWorld Matrix (i.e matrix with _WorldSpaceCameraPos apply to it if we use camera relative rendering)
float4x4 GetObjectToWorldMatrix()
{
    return UNITY_MATRIX_M;
}

float4x4 GetWorldToObjectMatrix()
{
    return UNITY_MATRIX_I_M;
}

float4x4 GetWorldToViewMatrix()
{
    return UNITY_MATRIX_V;
}

// Transform to homogenous clip space
float4x4 GetWorldToHClipMatrix()
{
    return UNITY_MATRIX_VP;
}

// Transform to homogenous clip space
float4x4 GetViewToHClipMatrix()
{
    return UNITY_MATRIX_P;
}

// This function always return the absolute position in WS
float3 GetAbsolutePositionWS(float3 positionRWS)
{
#if (SHADEROPTIONS_CAMERA_RELATIVE_RENDERING != 0)
    positionRWS += _WorldSpaceCameraPos;
#endif
    return positionRWS;
}

// This function return the camera relative position in WS
float3 GetCameraRelativePositionWS(float3 positionWS)
{
#if (SHADEROPTIONS_CAMERA_RELATIVE_RENDERING != 0)
    positionWS -= _WorldSpaceCameraPos;
#endif
    return positionWS;
}

real GetOddNegativeScale()
{
    return unity_WorldTransformParams.w;
}

float3 TransformObjectToWorld(float3 positionOS)
{
    return mul(GetObjectToWorldMatrix(), float4(positionOS, 1.0)).xyz;
}

float3 TransformWorldToObject(float3 positionWS)
{
    return mul(GetWorldToObjectMatrix(), float4(positionWS, 1.0)).xyz;
}

float3 TransformWorldToView(float3 positionWS)
{
    return mul(GetWorldToViewMatrix(), float4(positionWS, 1.0)).xyz;
}

// Transforms position from object space to homogenous space
float4 TransformObjectToHClip(float3 positionOS)
{
    // More efficient than computing M*VP matrix product
    return mul(GetWorldToHClipMatrix(), mul(GetObjectToWorldMatrix(), float4(positionOS, 1.0)));
}

// Tranforms position from world space to homogenous space
float4 TransformWorldToHClip(float3 positionWS)
{
    return mul(GetWorldToHClipMatrix(), float4(positionWS, 1.0));
}

// Tranforms position from view space to homogenous space
float4 TransformWViewToHClip(float3 positionVS)
{
    return mul(GetViewToHClipMatrix(), float4(positionVS, 1.0));
}

real3 TransformObjectToWorldDir(real3 dirOS)
{
    // Normalize to support uniform scaling
    return SafeNormalize(mul((real3x3)GetObjectToWorldMatrix(), dirOS));
}

real3 TransformWorldToObjectDir(real3 dirWS)
{
    // Normalize to support uniform scaling
    return normalize(mul((real3x3)GetWorldToObjectMatrix(), dirWS));
}

real3 TransformWorldToViewDir(real3 dirWS)
{
    return mul((real3x3)GetWorldToViewMatrix(), dirWS).xyz;
}

// Tranforms vector from world space to homogenous space
real3 TransformWorldToHClipDir(real3 directionWS)
{
    return mul((real3x3)GetWorldToHClipMatrix(), directionWS);
}

// Transforms normal from object to world space
float3 TransformObjectToWorldNormal(float3 normalOS)
{
#ifdef UNITY_ASSUME_UNIFORM_SCALING
    return TransformObjectToWorldDir(normalOS);
#else
    // Normal need to be multiply by inverse transpose
    return SafeNormalize(mul(normalOS, (float3x3)GetWorldToObjectMatrix()));
#endif
}

// Transforms normal from world to object space
float3 TransformWorldToObjectNormal(float3 normalWS)
{
#ifdef UNITY_ASSUME_UNIFORM_SCALING
    return TransformWorldToObjectDir(normalWS);
#else
    // Normal need to be multiply by inverse transpose
    return SafeNormalize(mul(normalWS, (float3x3)GetObjectToWorldMatrix()));
#endif
}

real3x3 CreateTangentToWorld(real3 normal, real3 tangent, real flipSign)
{
    // For odd-negative scale transforms we need to flip the sign
    real sgn = flipSign * GetOddNegativeScale();
    real3 bitangent = cross(normal, tangent) * sgn;

    return real3x3(tangent, bitangent, normal);
}

real3 TransformTangentToWorld(real3 dirTS, real3x3 tangentToWorld)
{
    // Note matrix is in row major convention with left multiplication as it is build on the fly
    return mul(dirTS, tangentToWorld);
}

real3 TransformWorldToTangent(real3 dirWS, real3x3 tangentToWorld)
{
    // Note matrix is in row major convention with left multiplication as it is build on the fly
    float3 row0 = tangentToWorld[0];
	float3 row1 = tangentToWorld[1];
	float3 row2 = tangentToWorld[2];

	// these are the columns of the inverse matrix but scaled by the determinant
	float3 col0 = cross(row1, row2);
	float3 col1 = cross(row2, row0);
	float3 col2 = cross(row0, row1);

	float determinant = dot(row0, col0);
	float sgn = determinant<0.0 ? (-1.0) : 1.0;

	// inverse transposed but scaled by determinant
	real3x3 matTBN_I_T = real3x3(col0, col1, col2);

	// remove transpose part by using matrix as the first arg in mul()
	// this makes it the exact inverse of what TransformTangentToWorld() does.
	return SafeNormalize( sgn * mul(matTBN_I_T, dirWS) );
}

real3 TransformTangentToObject(real3 dirTS, real3x3 tangentToWorld)
{
    // Note matrix is in row major convention with left multiplication as it is build on the fly
	real3 normalWS = TransformTangentToWorld(dirTS, tangentToWorld);
	return TransformWorldToObjectNormal(normalWS);
}

real3 TransformObjectToTangent(real3 dirOS, real3x3 tangentToWorld)
{
    // Note matrix is in row major convention with left multiplication as it is build on the fly
	float3 normalWS = TransformObjectToWorldNormal(dirOS);
	return TransformWorldToTangent(normalWS, tangentToWorld);
}

#endif

// File end: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/SpaceTransforms.hlsl
//================================================================================================================================




#endif

// File end: com.unity.render-pipelines.universal@7.3.1/ShaderLibrary/Input.hlsl
//================================================================================================================================




#if !defined(SHADER_HINT_NICE_QUALITY)
#if defined(SHADER_API_MOBILE) || defined(SHADER_API_SWITCH)
#define SHADER_HINT_NICE_QUALITY 0
#else
#define SHADER_HINT_NICE_QUALITY 1
#endif
#endif

// Shader Quality Tiers in Universal. 
// SRP doesn't use Graphics Settings Quality Tiers.
// We should expose shader quality tiers in the pipeline asset.
// Meanwhile, it's forced to be:
// High Quality: Non-mobile platforms or shader explicit defined SHADER_HINT_NICE_QUALITY
// Medium: Mobile aside from GLES2
// Low: GLES2 
#if SHADER_HINT_NICE_QUALITY
#define SHADER_QUALITY_HIGH
#elif defined(SHADER_API_GLES)
#define SHADER_QUALITY_LOW
#else
#define SHADER_QUALITY_MEDIUM
#endif

#ifndef BUMP_SCALE_NOT_SUPPORTED
#define BUMP_SCALE_NOT_SUPPORTED !SHADER_HINT_NICE_QUALITY
#endif

struct VertexPositionInputs
{
    float3 positionWS; // World space position
    float3 positionVS; // View space position
    float4 positionCS; // Homogeneous clip space position
    float4 positionNDC;// Homogeneous normalized device coordinates
};

struct VertexNormalInputs
{
    real3 tangentWS;
    real3 bitangentWS;
    float3 normalWS;
};

VertexPositionInputs GetVertexPositionInputs(float3 positionOS)
{
    VertexPositionInputs input;
    input.positionWS = TransformObjectToWorld(positionOS);
    input.positionVS = TransformWorldToView(input.positionWS);
    input.positionCS = TransformWorldToHClip(input.positionWS);
    
    float4 ndc = input.positionCS * 0.5f;
    input.positionNDC.xy = float2(ndc.x, ndc.y * _ProjectionParams.x) + ndc.w;
    input.positionNDC.zw = input.positionCS.zw;
        
    return input;
}

VertexNormalInputs GetVertexNormalInputs(float3 normalOS)
{
    VertexNormalInputs tbn;
    tbn.tangentWS = real3(1.0, 0.0, 0.0);
    tbn.bitangentWS = real3(0.0, 1.0, 0.0);
    tbn.normalWS = TransformObjectToWorldNormal(normalOS);
    return tbn;
}

VertexNormalInputs GetVertexNormalInputs(float3 normalOS, float4 tangentOS)
{
    VertexNormalInputs tbn;

    // mikkts space compliant. only normalize when extracting normal at frag.
    real sign = tangentOS.w * GetOddNegativeScale();
    tbn.normalWS = TransformObjectToWorldNormal(normalOS);
    tbn.tangentWS = TransformObjectToWorldDir(tangentOS.xyz);
    tbn.bitangentWS = cross(tbn.normalWS, tbn.tangentWS) * sign;
    return tbn;
}

#if UNITY_REVERSED_Z
    #if SHADER_API_OPENGL || SHADER_API_GLES || SHADER_API_GLES3
        //GL with reversed z => z clip range is [near, -far] -> should remap in theory but dont do it in practice to save some perf (range is close enough)
        #define UNITY_Z_0_FAR_FROM_CLIPSPACE(coord) max(-(coord), 0)
    #else
        //D3d with reversed Z => z clip range is [near, 0] -> remapping to [0, far]
        //max is required to protect ourselves from near plane not being correct/meaningfull in case of oblique matrices.
        #define UNITY_Z_0_FAR_FROM_CLIPSPACE(coord) max(((1.0-(coord)/_ProjectionParams.y)*_ProjectionParams.z),0)
    #endif
#elif UNITY_UV_STARTS_AT_TOP
    //D3d without reversed z => z clip range is [0, far] -> nothing to do
    #define UNITY_Z_0_FAR_FROM_CLIPSPACE(coord) (coord)
#else
    //Opengl => z clip range is [-near, far] -> should remap in theory but dont do it in practice to save some perf (range is close enough)
    #define UNITY_Z_0_FAR_FROM_CLIPSPACE(coord) (coord)
#endif

float3 GetCameraPositionWS()
{
    return _WorldSpaceCameraPos;
}

float4 GetScaledScreenParams()
{
    return _ScaledScreenParams;
}

void AlphaDiscard(real alpha, real cutoff, real offset = 0.0h)
{
#ifdef _ALPHATEST_ON
    clip(alpha - cutoff + offset);
#endif
}

// A word on normalization of normals:
// For better quality normals should be normalized before and after
// interpolation. 
// 1) In vertex, skinning or blend shapes might vary significantly the lenght of normal. 
// 2) In fragment, because even outputting unit-length normals interpolation can make it non-unit.
// 3) In fragment when using normal map, because mikktspace sets up non orthonormal basis. 
// However we will try to balance performance vs quality here as also let users configure that as 
// shader quality tiers. 
// Low Quality Tier: Normalize either per-vertex or per-pixel depending if normalmap is sampled.
// Medium Quality Tier: Always normalize per-vertex. Normalize per-pixel only if using normal map
// High Quality Tier: Normalize in both vertex and pixel shaders.
real3 NormalizeNormalPerVertex(real3 normalWS)
{
#if defined(SHADER_QUALITY_LOW) && defined(_NORMALMAP)
    return normalWS;
#else
    return normalize(normalWS);
#endif
}

real3 NormalizeNormalPerPixel(real3 normalWS)
{ 
#if defined(SHADER_QUALITY_HIGH) || defined(_NORMALMAP)
    return normalize(normalWS);
#else
    return normalWS;
#endif
}

// TODO: A similar function should be already available in SRP lib on master. Use that instead
float4 ComputeScreenPos(float4 positionCS)
{
    float4 o = positionCS * 0.5f;
    o.xy = float2(o.x, o.y * _ProjectionParams.x) + o.w;
    o.zw = positionCS.zw;
    return o;
}

real ComputeFogFactor(float z)
{
    float clipZ_01 = UNITY_Z_0_FAR_FROM_CLIPSPACE(z);

#if defined(FOG_LINEAR)
    // factor = (end-z)/(end-start) = z * (-1/(end-start)) + (end/(end-start))
    float fogFactor = saturate(clipZ_01 * unity_FogParams.z + unity_FogParams.w);
    return real(fogFactor);
#elif defined(FOG_EXP) || defined(FOG_EXP2)
    // factor = exp(-(density*z)^2)
    // -density * z computed at vertex
    return real(unity_FogParams.x * clipZ_01);
#else
    return 0.0h;
#endif
}

real ComputeFogIntensity(real fogFactor)
{
    real fogIntensity = 0.0h;
#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
#if defined(FOG_EXP)
    // factor = exp(-density*z)
    // fogFactor = density*z compute at vertex
    fogIntensity = saturate(exp2(-fogFactor));
#elif defined(FOG_EXP2)
    // factor = exp(-(density*z)^2)
    // fogFactor = density*z compute at vertex
    fogIntensity = saturate(exp2(-fogFactor * fogFactor));
#elif defined(FOG_LINEAR)
    fogIntensity = fogFactor;
#endif
#endif
    return fogIntensity;
}

half3 MixFogColor(real3 fragColor, real3 fogColor, real fogFactor)
{
#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
    real fogIntensity = ComputeFogIntensity(fogFactor);
    fragColor = lerp(fogColor, fragColor, fogIntensity);
#endif
    return fragColor;
}

half3 MixFog(real3 fragColor, real fogFactor)
{
    return MixFogColor(fragColor, unity_FogColor.rgb, fogFactor);
}

// Stereo-related bits
#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)

    #define SLICE_ARRAY_INDEX   unity_StereoEyeIndex

    #define TEXTURE2D_X                 TEXTURE2D_ARRAY
    #define TEXTURE2D_X_PARAM           TEXTURE2D_ARRAY_PARAM
    #define TEXTURE2D_X_ARGS            TEXTURE2D_ARRAY_ARGS
    #define TEXTURE2D_X_HALF            TEXTURE2D_ARRAY_HALF
    #define TEXTURE2D_X_FLOAT           TEXTURE2D_ARRAY_FLOAT

    #define LOAD_TEXTURE2D_X(textureName, unCoord2)                         LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, SLICE_ARRAY_INDEX)
    #define LOAD_TEXTURE2D_X_LOD(textureName, unCoord2, lod)                LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, SLICE_ARRAY_INDEX, lod)    
    #define SAMPLE_TEXTURE2D_X(textureName, samplerName, coord2)            SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, SLICE_ARRAY_INDEX)
    #define SAMPLE_TEXTURE2D_X_LOD(textureName, samplerName, coord2, lod)   SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, SLICE_ARRAY_INDEX, lod)
    #define GATHER_TEXTURE2D_X(textureName, samplerName, coord2)            GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, SLICE_ARRAY_INDEX)
    #define GATHER_RED_TEXTURE2D_X(textureName, samplerName, coord2)        GATHER_RED_TEXTURE2D(textureName, samplerName, float3(coord2, SLICE_ARRAY_INDEX))
    #define GATHER_GREEN_TEXTURE2D_X(textureName, samplerName, coord2)      GATHER_GREEN_TEXTURE2D(textureName, samplerName, float3(coord2, SLICE_ARRAY_INDEX))
    #define GATHER_BLUE_TEXTURE2D_X(textureName, samplerName, coord2)       GATHER_BLUE_TEXTURE2D(textureName, samplerName, float3(coord2, SLICE_ARRAY_INDEX))

#else

    #define SLICE_ARRAY_INDEX       0

    #define TEXTURE2D_X                 TEXTURE2D
    #define TEXTURE2D_X_PARAM           TEXTURE2D_PARAM
    #define TEXTURE2D_X_ARGS            TEXTURE2D_ARGS
    #define TEXTURE2D_X_HALF            TEXTURE2D_HALF
    #define TEXTURE2D_X_FLOAT           TEXTURE2D_FLOAT

    #define LOAD_TEXTURE2D_X            LOAD_TEXTURE2D
    #define LOAD_TEXTURE2D_X_LOD        LOAD_TEXTURE2D_LOD
    #define SAMPLE_TEXTURE2D_X          SAMPLE_TEXTURE2D
    #define SAMPLE_TEXTURE2D_X_LOD      SAMPLE_TEXTURE2D_LOD
    #define GATHER_TEXTURE2D_X          GATHER_TEXTURE2D
    #define GATHER_RED_TEXTURE2D_X      GATHER_RED_TEXTURE2D
    #define GATHER_GREEN_TEXTURE2D_X    GATHER_GREEN_TEXTURE2D
    #define GATHER_BLUE_TEXTURE2D_X     GATHER_BLUE_TEXTURE2D

#endif

#if defined(UNITY_SINGLE_PASS_STEREO)
float2 TransformStereoScreenSpaceTex(float2 uv, float w)
{
    // TODO: RVS support can be added here, if Universal decides to support it
    float4 scaleOffset = unity_StereoScaleOffset[unity_StereoEyeIndex];
    return uv.xy * scaleOffset.xy + scaleOffset.zw * w;
}

float2 UnityStereoTransformScreenSpaceTex(float2 uv)
{
    return TransformStereoScreenSpaceTex(saturate(uv), 1.0);
}

#else

#define UnityStereoTransformScreenSpaceTex(uv) uv

#endif // defined(UNITY_SINGLE_PASS_STEREO)

//================================================================================================================================
// File start: com.unity.render-pipelines.universal@7.3.1/ShaderLibrary/Deprecated.hlsl


#ifndef UNIVERSAL_DEPRECATED_INCLUDED
#define UNIVERSAL_DEPRECATED_INCLUDED

// Stereo-related bits
#define SCREENSPACE_TEXTURE         TEXTURE2D_X
#define SCREENSPACE_TEXTURE_FLOAT   TEXTURE2D_X_FLOAT
#define SCREENSPACE_TEXTURE_HALF    TEXTURE2D_X_HALF

#endif // UNIVERSAL_DEPRECATED_INCLUDED

// File end: com.unity.render-pipelines.universal@7.3.1/ShaderLibrary/Deprecated.hlsl
//================================================================================================================================




#endif

// File end: com.unity.render-pipelines.universal@7.3.1/ShaderLibrary/Core.hlsl
//================================================================================================================================



//================================================================================================================================
// File start: com.unity.render-pipelines.universal@7.3.1/ShaderLibrary/Shadows.hlsl


#ifndef UNIVERSAL_SHADOWS_INCLUDED
#define UNIVERSAL_SHADOWS_INCLUDED

//================================================================================================================================
// File start: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/Shadow/ShadowSamplingTent.hlsl


// ------------------------------------------------------------------
//  PCF Filtering Tent Functions
// ------------------------------------------------------------------

// Assuming a isoceles right angled triangle of height "triangleHeight" (as drawn below).
// This function return the area of the triangle above the first texel.
//
// |\      <-- 45 degree slop isosceles right angled triangle
// | \
// ----    <-- length of this side is "triangleHeight"
// _ _ _ _ <-- texels
real SampleShadow_GetTriangleTexelArea(real triangleHeight)
{
    return triangleHeight - 0.5;
}

// Assuming a isoceles triangle of 1.5 texels height and 3 texels wide lying on 4 texels.
// This function return the area of the triangle above each of those texels.
//    |    <-- offset from -0.5 to 0.5, 0 meaning triangle is exactly in the center
//   / \   <-- 45 degree slop isosceles triangle (ie tent projected in 2D)
//  /   \
// _ _ _ _ <-- texels
// X Y Z W <-- result indices (in computedArea.xyzw and computedAreaUncut.xyzw)
void SampleShadow_GetTexelAreas_Tent_3x3(real offset, out real4 computedArea, out real4 computedAreaUncut)
{
    // Compute the exterior areas
    real offset01SquaredHalved = (offset + 0.5) * (offset + 0.5) * 0.5;
    computedAreaUncut.x = computedArea.x = offset01SquaredHalved - offset;
    computedAreaUncut.w = computedArea.w = offset01SquaredHalved;

    // Compute the middle areas
    // For Y : We find the area in Y of as if the left section of the isoceles triangle would
    // intersect the axis between Y and Z (ie where offset = 0).
    computedAreaUncut.y = SampleShadow_GetTriangleTexelArea(1.5 - offset);
    // This area is superior to the one we are looking for if (offset < 0) thus we need to
    // subtract the area of the triangle defined by (0,1.5-offset), (0,1.5+offset), (-offset,1.5).
    real clampedOffsetLeft = min(offset,0);
    real areaOfSmallLeftTriangle = clampedOffsetLeft * clampedOffsetLeft;
    computedArea.y = computedAreaUncut.y - areaOfSmallLeftTriangle;

    // We do the same for the Z but with the right part of the isoceles triangle
    computedAreaUncut.z = SampleShadow_GetTriangleTexelArea(1.5 + offset);
    real clampedOffsetRight = max(offset,0);
    real areaOfSmallRightTriangle = clampedOffsetRight * clampedOffsetRight;
    computedArea.z = computedAreaUncut.z - areaOfSmallRightTriangle;
}

// Assuming a isoceles triangle of 1.5 texels height and 3 texels wide lying on 4 texels.
// This function return the weight of each texels area relative to the full triangle area.
void SampleShadow_GetTexelWeights_Tent_3x3(real offset, out real4 computedWeight)
{
    real4 dummy;
    SampleShadow_GetTexelAreas_Tent_3x3(offset, computedWeight, dummy);
    computedWeight *= 0.44444;//0.44 == 1/(the triangle area)
}

// Assuming a isoceles triangle of 2.5 texel height and 5 texels wide lying on 6 texels.
// This function return the weight of each texels area relative to the full triangle area.
//  /       \
// _ _ _ _ _ _ <-- texels
// 0 1 2 3 4 5 <-- computed area indices (in texelsWeights[])
void SampleShadow_GetTexelWeights_Tent_5x5(real offset, out real3 texelsWeightsA, out real3 texelsWeightsB)
{
    // See _UnityInternalGetAreaPerTexel_3TexelTriangleFilter for details.
    real4 computedArea_From3texelTriangle;
    real4 computedAreaUncut_From3texelTriangle;
    SampleShadow_GetTexelAreas_Tent_3x3(offset, computedArea_From3texelTriangle, computedAreaUncut_From3texelTriangle);

    // Triangle slope is 45 degree thus we can almost reuse the result of the 3 texel wide computation.
    // the 5 texel wide triangle can be seen as the 3 texel wide one but shifted up by one unit/texel.
    // 0.16 is 1/(the triangle area)
    texelsWeightsA.x = 0.16 * (computedArea_From3texelTriangle.x);
    texelsWeightsA.y = 0.16 * (computedAreaUncut_From3texelTriangle.y);
    texelsWeightsA.z = 0.16 * (computedArea_From3texelTriangle.y + 1);
    texelsWeightsB.x = 0.16 * (computedArea_From3texelTriangle.z + 1);
    texelsWeightsB.y = 0.16 * (computedAreaUncut_From3texelTriangle.z);
    texelsWeightsB.z = 0.16 * (computedArea_From3texelTriangle.w);
}

// Assuming a isoceles triangle of 3.5 texel height and 7 texels wide lying on 8 texels.
// This function return the weight of each texels area relative to the full triangle area.
//  /           \
// _ _ _ _ _ _ _ _ <-- texels
// 0 1 2 3 4 5 6 7 <-- computed area indices (in texelsWeights[])
void SampleShadow_GetTexelWeights_Tent_7x7(real offset, out real4 texelsWeightsA, out real4 texelsWeightsB)
{
    // See _UnityInternalGetAreaPerTexel_3TexelTriangleFilter for details.
    real4 computedArea_From3texelTriangle;
    real4 computedAreaUncut_From3texelTriangle;
    SampleShadow_GetTexelAreas_Tent_3x3(offset, computedArea_From3texelTriangle, computedAreaUncut_From3texelTriangle);

    // Triangle slope is 45 degree thus we can almost reuse the result of the 3 texel wide computation.
    // the 7 texel wide triangle can be seen as the 3 texel wide one but shifted up by two unit/texel.
    // 0.081632 is 1/(the triangle area)
    texelsWeightsA.x = 0.081632 * (computedArea_From3texelTriangle.x);
    texelsWeightsA.y = 0.081632 * (computedAreaUncut_From3texelTriangle.y);
    texelsWeightsA.z = 0.081632 * (computedAreaUncut_From3texelTriangle.y + 1);
    texelsWeightsA.w = 0.081632 * (computedArea_From3texelTriangle.y + 2);
    texelsWeightsB.x = 0.081632 * (computedArea_From3texelTriangle.z + 2);
    texelsWeightsB.y = 0.081632 * (computedAreaUncut_From3texelTriangle.z + 1);
    texelsWeightsB.z = 0.081632 * (computedAreaUncut_From3texelTriangle.z);
    texelsWeightsB.w = 0.081632 * (computedArea_From3texelTriangle.w);
}

// 3x3 Tent filter (45 degree sloped triangles in U and V)
void SampleShadow_ComputeSamples_Tent_3x3(real4 shadowMapTexture_TexelSize, real2 coord, out real fetchesWeights[4], out real2 fetchesUV[4])
{
    // tent base is 3x3 base thus covering from 9 to 12 texels, thus we need 4 bilinear PCF fetches
    real2 tentCenterInTexelSpace = coord.xy * shadowMapTexture_TexelSize.zw;
    real2 centerOfFetchesInTexelSpace = floor(tentCenterInTexelSpace + 0.5);
    real2 offsetFromTentCenterToCenterOfFetches = tentCenterInTexelSpace - centerOfFetchesInTexelSpace;

    // find the weight of each texel based
    real4 texelsWeightsU, texelsWeightsV;
    SampleShadow_GetTexelWeights_Tent_3x3(offsetFromTentCenterToCenterOfFetches.x, texelsWeightsU);
    SampleShadow_GetTexelWeights_Tent_3x3(offsetFromTentCenterToCenterOfFetches.y, texelsWeightsV);

    // each fetch will cover a group of 2x2 texels, the weight of each group is the sum of the weights of the texels
    real2 fetchesWeightsU = texelsWeightsU.xz + texelsWeightsU.yw;
    real2 fetchesWeightsV = texelsWeightsV.xz + texelsWeightsV.yw;

    // move the PCF bilinear fetches to respect texels weights
    real2 fetchesOffsetsU = texelsWeightsU.yw / fetchesWeightsU.xy + real2(-1.5,0.5);
    real2 fetchesOffsetsV = texelsWeightsV.yw / fetchesWeightsV.xy + real2(-1.5,0.5);
    fetchesOffsetsU *= shadowMapTexture_TexelSize.xx;
    fetchesOffsetsV *= shadowMapTexture_TexelSize.yy;

    real2 bilinearFetchOrigin = centerOfFetchesInTexelSpace * shadowMapTexture_TexelSize.xy;
    fetchesUV[0] = bilinearFetchOrigin + real2(fetchesOffsetsU.x, fetchesOffsetsV.x);
    fetchesUV[1] = bilinearFetchOrigin + real2(fetchesOffsetsU.y, fetchesOffsetsV.x);
    fetchesUV[2] = bilinearFetchOrigin + real2(fetchesOffsetsU.x, fetchesOffsetsV.y);
    fetchesUV[3] = bilinearFetchOrigin + real2(fetchesOffsetsU.y, fetchesOffsetsV.y);

    fetchesWeights[0] = fetchesWeightsU.x * fetchesWeightsV.x;
    fetchesWeights[1] = fetchesWeightsU.y * fetchesWeightsV.x;
    fetchesWeights[2] = fetchesWeightsU.x * fetchesWeightsV.y;
    fetchesWeights[3] = fetchesWeightsU.y * fetchesWeightsV.y;
}

// 5x5 Tent filter (45 degree sloped triangles in U and V)
void SampleShadow_ComputeSamples_Tent_5x5(real4 shadowMapTexture_TexelSize, real2 coord, out real fetchesWeights[9], out real2 fetchesUV[9])
{
    // tent base is 5x5 base thus covering from 25 to 36 texels, thus we need 9 bilinear PCF fetches
    real2 tentCenterInTexelSpace = coord.xy * shadowMapTexture_TexelSize.zw;
    real2 centerOfFetchesInTexelSpace = floor(tentCenterInTexelSpace + 0.5);
    real2 offsetFromTentCenterToCenterOfFetches = tentCenterInTexelSpace - centerOfFetchesInTexelSpace;

    // find the weight of each texel based on the area of a 45 degree slop tent above each of them.
    real3 texelsWeightsU_A, texelsWeightsU_B;
    real3 texelsWeightsV_A, texelsWeightsV_B;
    SampleShadow_GetTexelWeights_Tent_5x5(offsetFromTentCenterToCenterOfFetches.x, texelsWeightsU_A, texelsWeightsU_B);
    SampleShadow_GetTexelWeights_Tent_5x5(offsetFromTentCenterToCenterOfFetches.y, texelsWeightsV_A, texelsWeightsV_B);

    // each fetch will cover a group of 2x2 texels, the weight of each group is the sum of the weights of the texels
    real3 fetchesWeightsU = real3(texelsWeightsU_A.xz, texelsWeightsU_B.y) + real3(texelsWeightsU_A.y, texelsWeightsU_B.xz);
    real3 fetchesWeightsV = real3(texelsWeightsV_A.xz, texelsWeightsV_B.y) + real3(texelsWeightsV_A.y, texelsWeightsV_B.xz);

    // move the PCF bilinear fetches to respect texels weights
    real3 fetchesOffsetsU = real3(texelsWeightsU_A.y, texelsWeightsU_B.xz) / fetchesWeightsU.xyz + real3(-2.5,-0.5,1.5);
    real3 fetchesOffsetsV = real3(texelsWeightsV_A.y, texelsWeightsV_B.xz) / fetchesWeightsV.xyz + real3(-2.5,-0.5,1.5);
    fetchesOffsetsU *= shadowMapTexture_TexelSize.xxx;
    fetchesOffsetsV *= shadowMapTexture_TexelSize.yyy;

    real2 bilinearFetchOrigin = centerOfFetchesInTexelSpace * shadowMapTexture_TexelSize.xy;
    fetchesUV[0] = bilinearFetchOrigin + real2(fetchesOffsetsU.x, fetchesOffsetsV.x);
    fetchesUV[1] = bilinearFetchOrigin + real2(fetchesOffsetsU.y, fetchesOffsetsV.x);
    fetchesUV[2] = bilinearFetchOrigin + real2(fetchesOffsetsU.z, fetchesOffsetsV.x);
    fetchesUV[3] = bilinearFetchOrigin + real2(fetchesOffsetsU.x, fetchesOffsetsV.y);
    fetchesUV[4] = bilinearFetchOrigin + real2(fetchesOffsetsU.y, fetchesOffsetsV.y);
    fetchesUV[5] = bilinearFetchOrigin + real2(fetchesOffsetsU.z, fetchesOffsetsV.y);
    fetchesUV[6] = bilinearFetchOrigin + real2(fetchesOffsetsU.x, fetchesOffsetsV.z);
    fetchesUV[7] = bilinearFetchOrigin + real2(fetchesOffsetsU.y, fetchesOffsetsV.z);
    fetchesUV[8] = bilinearFetchOrigin + real2(fetchesOffsetsU.z, fetchesOffsetsV.z);

    fetchesWeights[0] = fetchesWeightsU.x * fetchesWeightsV.x;
    fetchesWeights[1] = fetchesWeightsU.y * fetchesWeightsV.x;
    fetchesWeights[2] = fetchesWeightsU.z * fetchesWeightsV.x;
    fetchesWeights[3] = fetchesWeightsU.x * fetchesWeightsV.y;
    fetchesWeights[4] = fetchesWeightsU.y * fetchesWeightsV.y;
    fetchesWeights[5] = fetchesWeightsU.z * fetchesWeightsV.y;
    fetchesWeights[6] = fetchesWeightsU.x * fetchesWeightsV.z;
    fetchesWeights[7] = fetchesWeightsU.y * fetchesWeightsV.z;
    fetchesWeights[8] = fetchesWeightsU.z * fetchesWeightsV.z;
}

// 7x7 Tent filter (45 degree sloped triangles in U and V)
void SampleShadow_ComputeSamples_Tent_7x7(real4 shadowMapTexture_TexelSize, real2 coord, out real fetchesWeights[16], out real2 fetchesUV[16])
{
    // tent base is 7x7 base thus covering from 49 to 64 texels, thus we need 16 bilinear PCF fetches
    real2 tentCenterInTexelSpace = coord.xy * shadowMapTexture_TexelSize.zw;
    real2 centerOfFetchesInTexelSpace = floor(tentCenterInTexelSpace + 0.5);
    real2 offsetFromTentCenterToCenterOfFetches = tentCenterInTexelSpace - centerOfFetchesInTexelSpace;

    // find the weight of each texel based on the area of a 45 degree slop tent above each of them.
    real4 texelsWeightsU_A, texelsWeightsU_B;
    real4 texelsWeightsV_A, texelsWeightsV_B;
    SampleShadow_GetTexelWeights_Tent_7x7(offsetFromTentCenterToCenterOfFetches.x, texelsWeightsU_A, texelsWeightsU_B);
    SampleShadow_GetTexelWeights_Tent_7x7(offsetFromTentCenterToCenterOfFetches.y, texelsWeightsV_A, texelsWeightsV_B);

    // each fetch will cover a group of 2x2 texels, the weight of each group is the sum of the weights of the texels
    real4 fetchesWeightsU = real4(texelsWeightsU_A.xz, texelsWeightsU_B.xz) + real4(texelsWeightsU_A.yw, texelsWeightsU_B.yw);
    real4 fetchesWeightsV = real4(texelsWeightsV_A.xz, texelsWeightsV_B.xz) + real4(texelsWeightsV_A.yw, texelsWeightsV_B.yw);

    // move the PCF bilinear fetches to respect texels weights
    real4 fetchesOffsetsU = real4(texelsWeightsU_A.yw, texelsWeightsU_B.yw) / fetchesWeightsU.xyzw + real4(-3.5,-1.5,0.5,2.5);
    real4 fetchesOffsetsV = real4(texelsWeightsV_A.yw, texelsWeightsV_B.yw) / fetchesWeightsV.xyzw + real4(-3.5,-1.5,0.5,2.5);
    fetchesOffsetsU *= shadowMapTexture_TexelSize.xxxx;
    fetchesOffsetsV *= shadowMapTexture_TexelSize.yyyy;

    real2 bilinearFetchOrigin = centerOfFetchesInTexelSpace * shadowMapTexture_TexelSize.xy;
    fetchesUV[0]  = bilinearFetchOrigin + real2(fetchesOffsetsU.x, fetchesOffsetsV.x);
    fetchesUV[1]  = bilinearFetchOrigin + real2(fetchesOffsetsU.y, fetchesOffsetsV.x);
    fetchesUV[2]  = bilinearFetchOrigin + real2(fetchesOffsetsU.z, fetchesOffsetsV.x);
    fetchesUV[3]  = bilinearFetchOrigin + real2(fetchesOffsetsU.w, fetchesOffsetsV.x);
    fetchesUV[4]  = bilinearFetchOrigin + real2(fetchesOffsetsU.x, fetchesOffsetsV.y);
    fetchesUV[5]  = bilinearFetchOrigin + real2(fetchesOffsetsU.y, fetchesOffsetsV.y);
    fetchesUV[6]  = bilinearFetchOrigin + real2(fetchesOffsetsU.z, fetchesOffsetsV.y);
    fetchesUV[7]  = bilinearFetchOrigin + real2(fetchesOffsetsU.w, fetchesOffsetsV.y);
    fetchesUV[8]  = bilinearFetchOrigin + real2(fetchesOffsetsU.x, fetchesOffsetsV.z);
    fetchesUV[9]  = bilinearFetchOrigin + real2(fetchesOffsetsU.y, fetchesOffsetsV.z);
    fetchesUV[10] = bilinearFetchOrigin + real2(fetchesOffsetsU.z, fetchesOffsetsV.z);
    fetchesUV[11] = bilinearFetchOrigin + real2(fetchesOffsetsU.w, fetchesOffsetsV.z);
    fetchesUV[12] = bilinearFetchOrigin + real2(fetchesOffsetsU.x, fetchesOffsetsV.w);
    fetchesUV[13] = bilinearFetchOrigin + real2(fetchesOffsetsU.y, fetchesOffsetsV.w);
    fetchesUV[14] = bilinearFetchOrigin + real2(fetchesOffsetsU.z, fetchesOffsetsV.w);
    fetchesUV[15] = bilinearFetchOrigin + real2(fetchesOffsetsU.w, fetchesOffsetsV.w);

    fetchesWeights[0]  = fetchesWeightsU.x * fetchesWeightsV.x;
    fetchesWeights[1]  = fetchesWeightsU.y * fetchesWeightsV.x;
    fetchesWeights[2]  = fetchesWeightsU.z * fetchesWeightsV.x;
    fetchesWeights[3]  = fetchesWeightsU.w * fetchesWeightsV.x;
    fetchesWeights[4]  = fetchesWeightsU.x * fetchesWeightsV.y;
    fetchesWeights[5]  = fetchesWeightsU.y * fetchesWeightsV.y;
    fetchesWeights[6]  = fetchesWeightsU.z * fetchesWeightsV.y;
    fetchesWeights[7]  = fetchesWeightsU.w * fetchesWeightsV.y;
    fetchesWeights[8]  = fetchesWeightsU.x * fetchesWeightsV.z;
    fetchesWeights[9]  = fetchesWeightsU.y * fetchesWeightsV.z;
    fetchesWeights[10] = fetchesWeightsU.z * fetchesWeightsV.z;
    fetchesWeights[11] = fetchesWeightsU.w * fetchesWeightsV.z;
    fetchesWeights[12] = fetchesWeightsU.x * fetchesWeightsV.w;
    fetchesWeights[13] = fetchesWeightsU.y * fetchesWeightsV.w;
    fetchesWeights[14] = fetchesWeightsU.z * fetchesWeightsV.w;
    fetchesWeights[15] = fetchesWeightsU.w * fetchesWeightsV.w;
}

// File end: com.unity.render-pipelines.core@7.3.1/ShaderLibrary/Shadow/ShadowSamplingTent.hlsl
//================================================================================================================================



//================================================================================================================================
// WARNING: File not found: Core.hlsl
//================================================================================================================================


#define SHADOWS_SCREEN 0
#define MAX_SHADOW_CASCADES 4

#if !defined(_RECEIVE_SHADOWS_OFF)
    #if defined(_MAIN_LIGHT_SHADOWS)
        #define MAIN_LIGHT_CALCULATE_SHADOWS

        #if !defined(_MAIN_LIGHT_SHADOWS_CASCADE)
            #define REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
        #endif
    #endif

    #if defined(_ADDITIONAL_LIGHT_SHADOWS)
        #define ADDITIONAL_LIGHT_CALCULATE_SHADOWS
    #endif
#endif

#if defined(_ADDITIONAL_LIGHTS) || defined(_MAIN_LIGHT_SHADOWS_CASCADE)
    #define REQUIRES_WORLD_SPACE_POS_INTERPOLATOR
#endif

SCREENSPACE_TEXTURE(_ScreenSpaceShadowmapTexture);
SAMPLER(sampler_ScreenSpaceShadowmapTexture);

TEXTURE2D_SHADOW(_MainLightShadowmapTexture);
SAMPLER_CMP(sampler_MainLightShadowmapTexture);

TEXTURE2D_SHADOW(_AdditionalLightsShadowmapTexture);
SAMPLER_CMP(sampler_AdditionalLightsShadowmapTexture);

// Last cascade is initialized with a no-op matrix. It always transforms
// shadow coord to half3(0, 0, NEAR_PLANE). We use this trick to avoid
// branching since ComputeCascadeIndex can return cascade index = MAX_SHADOW_CASCADES
float4x4    _MainLightWorldToShadow[MAX_SHADOW_CASCADES + 1];
float4      _CascadeShadowSplitSpheres0;
float4      _CascadeShadowSplitSpheres1;
float4      _CascadeShadowSplitSpheres2;
float4      _CascadeShadowSplitSpheres3;
float4      _CascadeShadowSplitSphereRadii;
half4       _MainLightShadowOffset0;
half4       _MainLightShadowOffset1;
half4       _MainLightShadowOffset2;
half4       _MainLightShadowOffset3;
half4       _MainLightShadowParams;  // (x: shadowStrength, y: 1.0 if soft shadows, 0.0 otherwise)
float4      _MainLightShadowmapSize; // (xy: 1/width and 1/height, zw: width and height)

#if USE_STRUCTURED_BUFFER_FOR_LIGHT_DATA
StructuredBuffer<ShadowData> _AdditionalShadowsBuffer;
StructuredBuffer<int> _AdditionalShadowsIndices;
#else
float4x4    _AdditionalLightsWorldToShadow[MAX_VISIBLE_LIGHTS];
half4       _AdditionalShadowParams[MAX_VISIBLE_LIGHTS];
#endif
half4       _AdditionalShadowOffset0;
half4       _AdditionalShadowOffset1;
half4       _AdditionalShadowOffset2;
half4       _AdditionalShadowOffset3;
float4      _AdditionalShadowmapSize; // (xy: 1/width and 1/height, zw: width and height)

float4 _ShadowBias; // x: depth bias, y: normal bias

#define BEYOND_SHADOW_FAR(shadowCoord) shadowCoord.z <= 0.0 || shadowCoord.z >= 1.0

struct ShadowSamplingData
{
    half4 shadowOffset0;
    half4 shadowOffset1;
    half4 shadowOffset2;
    half4 shadowOffset3;
    float4 shadowmapSize;
};

ShadowSamplingData GetMainLightShadowSamplingData()
{
    ShadowSamplingData shadowSamplingData;
    shadowSamplingData.shadowOffset0 = _MainLightShadowOffset0;
    shadowSamplingData.shadowOffset1 = _MainLightShadowOffset1;
    shadowSamplingData.shadowOffset2 = _MainLightShadowOffset2;
    shadowSamplingData.shadowOffset3 = _MainLightShadowOffset3;
    shadowSamplingData.shadowmapSize = _MainLightShadowmapSize;
    return shadowSamplingData;
}

ShadowSamplingData GetAdditionalLightShadowSamplingData()
{
    ShadowSamplingData shadowSamplingData;
    shadowSamplingData.shadowOffset0 = _AdditionalShadowOffset0;
    shadowSamplingData.shadowOffset1 = _AdditionalShadowOffset1;
    shadowSamplingData.shadowOffset2 = _AdditionalShadowOffset2;
    shadowSamplingData.shadowOffset3 = _AdditionalShadowOffset3;
    shadowSamplingData.shadowmapSize = _AdditionalShadowmapSize;
    return shadowSamplingData;
}

// ShadowParams
// x: ShadowStrength
// y: 1.0 if shadow is soft, 0.0 otherwise
half4 GetMainLightShadowParams()
{
    return _MainLightShadowParams;
}


// ShadowParams
// x: ShadowStrength
// y: 1.0 if shadow is soft, 0.0 otherwise
half4 GetAdditionalLightShadowParams(int lightIndex)
{
#if USE_STRUCTURED_BUFFER_FOR_LIGHT_DATA
    return _AdditionalShadowsBuffer[lightIndex].shadowParams;
#else
    return _AdditionalShadowParams[lightIndex];
#endif
}

half SampleScreenSpaceShadowmap(float4 shadowCoord)
{
    shadowCoord.xy /= shadowCoord.w;

    // The stereo transform has to happen after the manual perspective divide
    shadowCoord.xy = UnityStereoTransformScreenSpaceTex(shadowCoord.xy);

#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
    half attenuation = SAMPLE_TEXTURE2D_ARRAY(_ScreenSpaceShadowmapTexture, sampler_ScreenSpaceShadowmapTexture, shadowCoord.xy, unity_StereoEyeIndex).x;
#else
    half attenuation = SAMPLE_TEXTURE2D(_ScreenSpaceShadowmapTexture, sampler_ScreenSpaceShadowmapTexture, shadowCoord.xy).x;
#endif

    return attenuation;
}

real SampleShadowmapFiltered(TEXTURE2D_SHADOW_PARAM(ShadowMap, sampler_ShadowMap), float4 shadowCoord, ShadowSamplingData samplingData)
{
    real attenuation;

#if defined(SHADER_API_MOBILE) || defined(SHADER_API_SWITCH)
    // 4-tap hardware comparison
    real4 attenuation4;
    attenuation4.x = SAMPLE_TEXTURE2D_SHADOW(ShadowMap, sampler_ShadowMap, shadowCoord.xyz + samplingData.shadowOffset0.xyz);
    attenuation4.y = SAMPLE_TEXTURE2D_SHADOW(ShadowMap, sampler_ShadowMap, shadowCoord.xyz + samplingData.shadowOffset1.xyz);
    attenuation4.z = SAMPLE_TEXTURE2D_SHADOW(ShadowMap, sampler_ShadowMap, shadowCoord.xyz + samplingData.shadowOffset2.xyz);
    attenuation4.w = SAMPLE_TEXTURE2D_SHADOW(ShadowMap, sampler_ShadowMap, shadowCoord.xyz + samplingData.shadowOffset3.xyz);
    attenuation = dot(attenuation4, 0.25);
#else
    float fetchesWeights[9];
    float2 fetchesUV[9];
    SampleShadow_ComputeSamples_Tent_5x5(samplingData.shadowmapSize, shadowCoord.xy, fetchesWeights, fetchesUV);

    attenuation = fetchesWeights[0] * SAMPLE_TEXTURE2D_SHADOW(ShadowMap, sampler_ShadowMap, float3(fetchesUV[0].xy, shadowCoord.z));
    attenuation += fetchesWeights[1] * SAMPLE_TEXTURE2D_SHADOW(ShadowMap, sampler_ShadowMap, float3(fetchesUV[1].xy, shadowCoord.z));
    attenuation += fetchesWeights[2] * SAMPLE_TEXTURE2D_SHADOW(ShadowMap, sampler_ShadowMap, float3(fetchesUV[2].xy, shadowCoord.z));
    attenuation += fetchesWeights[3] * SAMPLE_TEXTURE2D_SHADOW(ShadowMap, sampler_ShadowMap, float3(fetchesUV[3].xy, shadowCoord.z));
    attenuation += fetchesWeights[4] * SAMPLE_TEXTURE2D_SHADOW(ShadowMap, sampler_ShadowMap, float3(fetchesUV[4].xy, shadowCoord.z));
    attenuation += fetchesWeights[5] * SAMPLE_TEXTURE2D_SHADOW(ShadowMap, sampler_ShadowMap, float3(fetchesUV[5].xy, shadowCoord.z));
    attenuation += fetchesWeights[6] * SAMPLE_TEXTURE2D_SHADOW(ShadowMap, sampler_ShadowMap, float3(fetchesUV[6].xy, shadowCoord.z));
    attenuation += fetchesWeights[7] * SAMPLE_TEXTURE2D_SHADOW(ShadowMap, sampler_ShadowMap, float3(fetchesUV[7].xy, shadowCoord.z));
    attenuation += fetchesWeights[8] * SAMPLE_TEXTURE2D_SHADOW(ShadowMap, sampler_ShadowMap, float3(fetchesUV[8].xy, shadowCoord.z));
#endif

    return attenuation;
}

real SampleShadowmap(TEXTURE2D_SHADOW_PARAM(ShadowMap, sampler_ShadowMap), float4 shadowCoord, ShadowSamplingData samplingData, half4 shadowParams, bool isPerspectiveProjection = true)
{
    // Compiler will optimize this branch away as long as isPerspectiveProjection is known at compile time
    if (isPerspectiveProjection)
        shadowCoord.xyz /= shadowCoord.w;

    real attenuation;
    real shadowStrength = shadowParams.x;

    // TODO: We could branch on if this light has soft shadows (shadowParams.y) to save perf on some platforms.
#ifdef _SHADOWS_SOFT
    attenuation = SampleShadowmapFiltered(TEXTURE2D_SHADOW_ARGS(ShadowMap, sampler_ShadowMap), shadowCoord, samplingData);
#else
    // 1-tap hardware comparison
    attenuation = SAMPLE_TEXTURE2D_SHADOW(ShadowMap, sampler_ShadowMap, shadowCoord.xyz);
#endif

    attenuation = LerpWhiteTo(attenuation, shadowStrength);

    // Shadow coords that fall out of the light frustum volume must always return attenuation 1.0
    // TODO: We could use branch here to save some perf on some platforms.
    return BEYOND_SHADOW_FAR(shadowCoord) ? 1.0 : attenuation;
}

half ComputeCascadeIndex(float3 positionWS)
{
    float3 fromCenter0 = positionWS - _CascadeShadowSplitSpheres0.xyz;
    float3 fromCenter1 = positionWS - _CascadeShadowSplitSpheres1.xyz;
    float3 fromCenter2 = positionWS - _CascadeShadowSplitSpheres2.xyz;
    float3 fromCenter3 = positionWS - _CascadeShadowSplitSpheres3.xyz;
    float4 distances2 = float4(dot(fromCenter0, fromCenter0), dot(fromCenter1, fromCenter1), dot(fromCenter2, fromCenter2), dot(fromCenter3, fromCenter3));

    half4 weights = half4(distances2 < _CascadeShadowSplitSphereRadii);
    weights.yzw = saturate(weights.yzw - weights.xyz);

    return 4 - dot(weights, half4(4, 3, 2, 1));
}

float4 TransformWorldToShadowCoord(float3 positionWS)
{
#ifdef _MAIN_LIGHT_SHADOWS_CASCADE
    half cascadeIndex = ComputeCascadeIndex(positionWS);
#else
    half cascadeIndex = 0;
#endif

    return mul(_MainLightWorldToShadow[cascadeIndex], float4(positionWS, 1.0));
}

half MainLightRealtimeShadow(float4 shadowCoord)
{
#if !defined(MAIN_LIGHT_CALCULATE_SHADOWS)
    return 1.0h;
#endif

    ShadowSamplingData shadowSamplingData = GetMainLightShadowSamplingData();
    half4 shadowParams = GetMainLightShadowParams();
    return SampleShadowmap(TEXTURE2D_ARGS(_MainLightShadowmapTexture, sampler_MainLightShadowmapTexture), shadowCoord, shadowSamplingData, shadowParams, false);
}

half AdditionalLightRealtimeShadow(int lightIndex, float3 positionWS)
{
#if !defined(ADDITIONAL_LIGHT_CALCULATE_SHADOWS)
    return 1.0h;
#endif

    ShadowSamplingData shadowSamplingData = GetAdditionalLightShadowSamplingData();

#if USE_STRUCTURED_BUFFER_FOR_LIGHT_DATA
    lightIndex = _AdditionalShadowsIndices[lightIndex];

    // We have to branch here as otherwise we would sample buffer with lightIndex == -1.
    // However this should be ok for platforms that store light in SSBO.
    UNITY_BRANCH
    if (lightIndex < 0)
        return 1.0;

    float4 shadowCoord = mul(_AdditionalShadowsBuffer[lightIndex].worldToShadowMatrix, float4(positionWS, 1.0));
#else
    float4 shadowCoord = mul(_AdditionalLightsWorldToShadow[lightIndex], float4(positionWS, 1.0));
#endif

    half4 shadowParams = GetAdditionalLightShadowParams(lightIndex);
    return SampleShadowmap(TEXTURE2D_ARGS(_AdditionalLightsShadowmapTexture, sampler_AdditionalLightsShadowmapTexture), shadowCoord, shadowSamplingData, shadowParams, true);
}

float4 GetShadowCoord(VertexPositionInputs vertexInput)
{
    return TransformWorldToShadowCoord(vertexInput.positionWS);
}

float3 ApplyShadowBias(float3 positionWS, float3 normalWS, float3 lightDirection)
{
    float invNdotL = 1.0 - saturate(dot(lightDirection, normalWS));
    float scale = invNdotL * _ShadowBias.y;

    // normal bias is negative since we want to apply an inset normal offset
    positionWS = lightDirection * _ShadowBias.xxx + positionWS;
    positionWS = normalWS * scale.xxx + positionWS;
    return positionWS;
}

///////////////////////////////////////////////////////////////////////////////
// Deprecated                                                                 /
///////////////////////////////////////////////////////////////////////////////

// Renamed -> _MainLightShadowParams
#define _MainLightShadowData _MainLightShadowParams

// Deprecated: Use GetMainLightShadowParams instead.
half GetMainLightShadowStrength()
{
    return _MainLightShadowData.x;
}

// Deprecated: Use GetAdditionalLightShadowParams instead.
half GetAdditionalLightShadowStrenth(int lightIndex)
{
#if USE_STRUCTURED_BUFFER_FOR_LIGHT_DATA
    return _AdditionalShadowsBuffer[lightIndex].shadowParams.x;
#else
    return _AdditionalShadowParams[lightIndex].x;
#endif
}

// Deprecated: Use SampleShadowmap that takes shadowParams instead of strength.
real SampleShadowmap(float4 shadowCoord, TEXTURE2D_SHADOW_PARAM(ShadowMap, sampler_ShadowMap), ShadowSamplingData samplingData, half shadowStrength, bool isPerspectiveProjection = true)
{
    half4 shadowParams = half4(shadowStrength, 1.0, 0.0, 0.0);
    return SampleShadowmap(TEXTURE2D_SHADOW_ARGS(ShadowMap, sampler_ShadowMap), shadowCoord, samplingData, shadowParams, isPerspectiveProjection);
}

#endif

// File end: com.unity.render-pipelines.universal@7.3.1/ShaderLibrary/Shadows.hlsl
//================================================================================================================================




// If lightmap is not defined than we evaluate GI (ambient + probes) from SH
// We might do it fully or partially in vertex to save shader ALU
#if !defined(LIGHTMAP_ON)
// TODO: Controls things like these by exposing SHADER_QUALITY levels (low, medium, high)
    #if defined(SHADER_API_GLES) || !defined(_NORMALMAP)
        // Evaluates SH fully in vertex
        #define EVALUATE_SH_VERTEX
    #elif !SHADER_HINT_NICE_QUALITY
        // Evaluates L2 SH in vertex and L0L1 in pixel
        #define EVALUATE_SH_MIXED
    #endif
        // Otherwise evaluate SH fully per-pixel
#endif


#ifdef LIGHTMAP_ON
    #define DECLARE_LIGHTMAP_OR_SH(lmName, shName, index) float2 lmName : TEXCOORD##index
    #define OUTPUT_LIGHTMAP_UV(lightmapUV, lightmapScaleOffset, OUT) OUT.xy = lightmapUV.xy * lightmapScaleOffset.xy + lightmapScaleOffset.zw;
    #define OUTPUT_SH(normalWS, OUT)
#else
    #define DECLARE_LIGHTMAP_OR_SH(lmName, shName, index) half3 shName : TEXCOORD##index
    #define OUTPUT_LIGHTMAP_UV(lightmapUV, lightmapScaleOffset, OUT)
    #define OUTPUT_SH(normalWS, OUT) OUT.xyz = SampleSHVertex(normalWS)
#endif

///////////////////////////////////////////////////////////////////////////////
//                          Light Helpers                                    //
///////////////////////////////////////////////////////////////////////////////

// Abstraction over Light shading data.
struct Light
{
    half3   direction;
    half3   color;
    half    distanceAttenuation;
    half    shadowAttenuation;
};

///////////////////////////////////////////////////////////////////////////////
//                        Attenuation Functions                               /
///////////////////////////////////////////////////////////////////////////////

// Matches Unity Vanila attenuation
// Attenuation smoothly decreases to light range.
float DistanceAttenuation(float distanceSqr, half2 distanceAttenuation)
{
    // We use a shared distance attenuation for additional directional and puctual lights
    // for directional lights attenuation will be 1
    float lightAtten = rcp(distanceSqr);

#if SHADER_HINT_NICE_QUALITY
    // Use the smoothing factor also used in the Unity lightmapper.
    half factor = distanceSqr * distanceAttenuation.x;
    half smoothFactor = saturate(1.0h - factor * factor);
    smoothFactor = smoothFactor * smoothFactor;
#else
    // We need to smoothly fade attenuation to light range. We start fading linearly at 80% of light range
    // Therefore:
    // fadeDistance = (0.8 * 0.8 * lightRangeSq)
    // smoothFactor = (lightRangeSqr - distanceSqr) / (lightRangeSqr - fadeDistance)
    // We can rewrite that to fit a MAD by doing
    // distanceSqr * (1.0 / (fadeDistanceSqr - lightRangeSqr)) + (-lightRangeSqr / (fadeDistanceSqr - lightRangeSqr)
    // distanceSqr *        distanceAttenuation.y            +             distanceAttenuation.z
    half smoothFactor = saturate(distanceSqr * distanceAttenuation.x + distanceAttenuation.y);
#endif

    return lightAtten * smoothFactor;
}

half AngleAttenuation(half3 spotDirection, half3 lightDirection, half2 spotAttenuation)
{
    // Spot Attenuation with a linear falloff can be defined as
    // (SdotL - cosOuterAngle) / (cosInnerAngle - cosOuterAngle)
    // This can be rewritten as
    // invAngleRange = 1.0 / (cosInnerAngle - cosOuterAngle)
    // SdotL * invAngleRange + (-cosOuterAngle * invAngleRange)
    // SdotL * spotAttenuation.x + spotAttenuation.y

    // If we precompute the terms in a MAD instruction
    half SdotL = dot(spotDirection, lightDirection);
    half atten = saturate(SdotL * spotAttenuation.x + spotAttenuation.y);
    return atten * atten;
}

///////////////////////////////////////////////////////////////////////////////
//                      Light Abstraction                                    //
///////////////////////////////////////////////////////////////////////////////

Light GetMainLight()
{
    Light light;
    light.direction = _MainLightPosition.xyz;
    // unity_LightData.z is 1 when not culled by the culling mask, otherwise 0.
    light.distanceAttenuation = unity_LightData.z;
#if defined(LIGHTMAP_ON) || defined(_MIXED_LIGHTING_SUBTRACTIVE)
    // unity_ProbesOcclusion.x is the mixed light probe occlusion data
    light.distanceAttenuation *= unity_ProbesOcclusion.x;
#endif
    light.shadowAttenuation = 1.0;
    light.color = _MainLightColor.rgb;

    return light;
}

Light GetMainLight(float4 shadowCoord)
{
    Light light = GetMainLight();
    light.shadowAttenuation = MainLightRealtimeShadow(shadowCoord);
    return light;
}

// Fills a light struct given a perObjectLightIndex
Light GetAdditionalPerObjectLight(int perObjectLightIndex, float3 positionWS)
{
    // Abstraction over Light input constants
#if USE_STRUCTURED_BUFFER_FOR_LIGHT_DATA
    float4 lightPositionWS = _AdditionalLightsBuffer[perObjectLightIndex].position;
    half3 color = _AdditionalLightsBuffer[perObjectLightIndex].color.rgb;
    half4 distanceAndSpotAttenuation = _AdditionalLightsBuffer[perObjectLightIndex].attenuation;
    half4 spotDirection = _AdditionalLightsBuffer[perObjectLightIndex].spotDirection;
    half4 lightOcclusionProbeInfo = _AdditionalLightsBuffer[perObjectLightIndex].occlusionProbeChannels;
#else
    float4 lightPositionWS = _AdditionalLightsPosition[perObjectLightIndex];
    half3 color = _AdditionalLightsColor[perObjectLightIndex].rgb;
    half4 distanceAndSpotAttenuation = _AdditionalLightsAttenuation[perObjectLightIndex];
    half4 spotDirection = _AdditionalLightsSpotDir[perObjectLightIndex];
    half4 lightOcclusionProbeInfo = _AdditionalLightsOcclusionProbes[perObjectLightIndex];
#endif

    // Directional lights store direction in lightPosition.xyz and have .w set to 0.0.
    // This way the following code will work for both directional and punctual lights.
    float3 lightVector = lightPositionWS.xyz - positionWS * lightPositionWS.w;
    float distanceSqr = max(dot(lightVector, lightVector), HALF_MIN);

    half3 lightDirection = half3(lightVector * rsqrt(distanceSqr));
    half attenuation = DistanceAttenuation(distanceSqr, distanceAndSpotAttenuation.xy) * AngleAttenuation(spotDirection.xyz, lightDirection, distanceAndSpotAttenuation.zw);

    Light light;
    light.direction = lightDirection;
    light.distanceAttenuation = attenuation;
    light.shadowAttenuation = AdditionalLightRealtimeShadow(perObjectLightIndex, positionWS);
    light.color = color;

    // In case we're using light probes, we can sample the attenuation from the `unity_ProbesOcclusion`
#if defined(LIGHTMAP_ON) || defined(_MIXED_LIGHTING_SUBTRACTIVE)
    // First find the probe channel from the light.
    // Then sample `unity_ProbesOcclusion` for the baked occlusion.
    // If the light is not baked, the channel is -1, and we need to apply no occlusion.

    // probeChannel is the index in 'unity_ProbesOcclusion' that holds the proper occlusion value.
    int probeChannel = lightOcclusionProbeInfo.x;

    // lightProbeContribution is set to 0 if we are indeed using a probe, otherwise set to 1.
    half lightProbeContribution = lightOcclusionProbeInfo.y;

    half probeOcclusionValue = unity_ProbesOcclusion[probeChannel];
    light.distanceAttenuation *= max(probeOcclusionValue, lightProbeContribution);
#endif

    return light;
}

uint GetPerObjectLightIndexOffset()
{
#if USE_STRUCTURED_BUFFER_FOR_LIGHT_DATA
    return unity_LightData.x;
#else
    return 0;
#endif
}

// Returns a per-object index given a loop index.
// This abstract the underlying data implementation for storing lights/light indices
int GetPerObjectLightIndex(uint index)
{
/////////////////////////////////////////////////////////////////////////////////////////////
// Structured Buffer Path                                                                   /
//                                                                                          /
// Lights and light indices are stored in StructuredBuffer. We can just index them.         /
// Currently all non-mobile platforms take this path :(                                     /
// There are limitation in mobile GPUs to use SSBO (performance / no vertex shader support) /
/////////////////////////////////////////////////////////////////////////////////////////////
#if USE_STRUCTURED_BUFFER_FOR_LIGHT_DATA
    uint offset = unity_LightData.x;
    return _AdditionalLightsIndices[offset + index];

/////////////////////////////////////////////////////////////////////////////////////////////
// UBO path                                                                                 /
//                                                                                          /
// We store 8 light indices in float4 unity_LightIndices[2];                                /
// Due to memory alignment unity doesn't support int[] or float[]                           /
// Even trying to reinterpret cast the unity_LightIndices to float[] won't work             /
// it will cast to float4[] and create extra register pressure. :(                          /
/////////////////////////////////////////////////////////////////////////////////////////////
#elif !defined(SHADER_API_GLES)
    // since index is uint shader compiler will implement
    // div & mod as bitfield ops (shift and mask).
    
    // TODO: Can we index a float4? Currently compiler is
    // replacing unity_LightIndicesX[i] with a dp4 with identity matrix.
    // u_xlat16_40 = dot(unity_LightIndices[int(u_xlatu13)], ImmCB_0_0_0[u_xlati1]);
    // This increases both arithmetic and register pressure.
    return unity_LightIndices[index / 4][index % 4];
#else
    // Fallback to GLES2. No bitfield magic here :(.
    // We limit to 4 indices per object and only sample unity_4LightIndices0.
    // Conditional moves are branch free even on mali-400
    // small arithmetic cost but no extra register pressure from ImmCB_0_0_0 matrix.
    half2 lightIndex2 = (index < 2.0h) ? unity_LightIndices[0].xy : unity_LightIndices[0].zw;
    half i_rem = (index < 2.0h) ? index : index - 2.0h;
    return (i_rem < 1.0h) ? lightIndex2.x : lightIndex2.y;
#endif
}

// Fills a light struct given a loop i index. This will convert the i
// index to a perObjectLightIndex
Light GetAdditionalLight(uint i, float3 positionWS)
{
    int perObjectLightIndex = GetPerObjectLightIndex(i);
    return GetAdditionalPerObjectLight(perObjectLightIndex, positionWS);
}

int GetAdditionalLightsCount()
{
    // TODO: we need to expose in SRP api an ability for the pipeline cap the amount of lights
    // in the culling. This way we could do the loop branch with an uniform
    // This would be helpful to support baking exceeding lights in SH as well
    return min(_AdditionalLightsCount.x, unity_LightData.y);
}

///////////////////////////////////////////////////////////////////////////////
//                         BRDF Functions                                    //
///////////////////////////////////////////////////////////////////////////////

#define kDieletricSpec half4(0.04, 0.04, 0.04, 1.0 - 0.04) // standard dielectric reflectivity coef at incident angle (= 4%)

struct BRDFData
{
    half3 diffuse;
    half3 specular;
    half perceptualRoughness;
    half roughness;
    half roughness2;
    half grazingTerm;

    // We save some light invariant BRDF terms so we don't have to recompute
    // them in the light loop. Take a look at DirectBRDF function for detailed explaination.
    half normalizationTerm;     // roughness * 4.0 + 2.0
    half roughness2MinusOne;    // roughness^2 - 1.0
};

half ReflectivitySpecular(half3 specular)
{
#if defined(SHADER_API_GLES)
    return specular.r; // Red channel - because most metals are either monocrhome or with redish/yellowish tint
#else
    return max(max(specular.r, specular.g), specular.b);
#endif
}

half OneMinusReflectivityMetallic(half metallic)
{
    // We'll need oneMinusReflectivity, so
    //   1-reflectivity = 1-lerp(dielectricSpec, 1, metallic) = lerp(1-dielectricSpec, 0, metallic)
    // store (1-dielectricSpec) in kDieletricSpec.a, then
    //   1-reflectivity = lerp(alpha, 0, metallic) = alpha + metallic*(0 - alpha) =
    //                  = alpha - metallic * alpha
    half oneMinusDielectricSpec = kDieletricSpec.a;
    return oneMinusDielectricSpec - metallic * oneMinusDielectricSpec;
}

inline void InitializeBRDFData(half3 albedo, half metallic, half3 specular, half smoothness, half alpha, out BRDFData outBRDFData)
{
#ifdef _SPECULAR_SETUP
    half reflectivity = ReflectivitySpecular(specular);
    half oneMinusReflectivity = 1.0 - reflectivity;

    outBRDFData.diffuse = albedo * (half3(1.0h, 1.0h, 1.0h) - specular);
    outBRDFData.specular = specular;
#else

    half oneMinusReflectivity = OneMinusReflectivityMetallic(metallic);
    half reflectivity = 1.0 - oneMinusReflectivity;

    outBRDFData.diffuse = albedo * oneMinusReflectivity;
    outBRDFData.specular = lerp(kDieletricSpec.rgb, albedo, metallic);
#endif

    outBRDFData.grazingTerm = saturate(smoothness + reflectivity);
    outBRDFData.perceptualRoughness = PerceptualSmoothnessToPerceptualRoughness(smoothness);
    outBRDFData.roughness = max(PerceptualRoughnessToRoughness(outBRDFData.perceptualRoughness), HALF_MIN);
    outBRDFData.roughness2 = outBRDFData.roughness * outBRDFData.roughness;

    outBRDFData.normalizationTerm = outBRDFData.roughness * 4.0h + 2.0h;
    outBRDFData.roughness2MinusOne = outBRDFData.roughness2 - 1.0h;

#ifdef _ALPHAPREMULTIPLY_ON
    outBRDFData.diffuse *= alpha;
    alpha = alpha * oneMinusReflectivity + reflectivity;
#endif
}

half3 EnvironmentBRDF(BRDFData brdfData, half3 indirectDiffuse, half3 indirectSpecular, half fresnelTerm)
{
    half3 c = indirectDiffuse * brdfData.diffuse;
    float surfaceReduction = 1.0 / (brdfData.roughness2 + 1.0);
    c += surfaceReduction * indirectSpecular * lerp(brdfData.specular, brdfData.grazingTerm, fresnelTerm);
    return c;
}

// Based on Minimalist CookTorrance BRDF
// Implementation is slightly different from original derivation: http://www.thetenthplanet.de/archives/255
//
// * NDF [Modified] GGX
// * Modified Kelemen and Szirmay-Kalos for Visibility term
// * Fresnel approximated with 1/LdotH
half3 DirectBDRF(BRDFData brdfData, half3 normalWS, half3 lightDirectionWS, half3 viewDirectionWS)
{
#ifndef _SPECULARHIGHLIGHTS_OFF
    float3 halfDir = SafeNormalize(float3(lightDirectionWS) + float3(viewDirectionWS));

    float NoH = saturate(dot(normalWS, halfDir));
    half LoH = saturate(dot(lightDirectionWS, halfDir));

    // GGX Distribution multiplied by combined approximation of Visibility and Fresnel
    // BRDFspec = (D * V * F) / 4.0
    // D = roughness^2 / ( NoH^2 * (roughness^2 - 1) + 1 )^2
    // V * F = 1.0 / ( LoH^2 * (roughness + 0.5) )
    // See "Optimizing PBR for Mobile" from Siggraph 2015 moving mobile graphics course
    // https://community.arm.com/events/1155

    // Final BRDFspec = roughness^2 / ( NoH^2 * (roughness^2 - 1) + 1 )^2 * (LoH^2 * (roughness + 0.5) * 4.0)
    // We further optimize a few light invariant terms
    // brdfData.normalizationTerm = (roughness + 0.5) * 4.0 rewritten as roughness * 4.0 + 2.0 to a fit a MAD.
    float d = NoH * NoH * brdfData.roughness2MinusOne + 1.00001f;

    half LoH2 = LoH * LoH;
    half specularTerm = brdfData.roughness2 / ((d * d) * max(0.1h, LoH2) * brdfData.normalizationTerm);

    // On platforms where half actually means something, the denominator has a risk of overflow
    // clamp below was added specifically to "fix" that, but dx compiler (we convert bytecode to metal/gles)
    // sees that specularTerm have only non-negative terms, so it skips max(0,..) in clamp (leaving only min(100,...))
#if defined (SHADER_API_MOBILE) || defined (SHADER_API_SWITCH)
    specularTerm = specularTerm - HALF_MIN;
    specularTerm = clamp(specularTerm, 0.0, 100.0); // Prevent FP16 overflow on mobiles
#endif

    half3 color = specularTerm * brdfData.specular + brdfData.diffuse;
    return color;
#else
    return brdfData.diffuse;
#endif
}

///////////////////////////////////////////////////////////////////////////////
//                      Global Illumination                                  //
///////////////////////////////////////////////////////////////////////////////

// Samples SH L0, L1 and L2 terms
half3 SampleSH(half3 normalWS)
{
    // LPPV is not supported in Ligthweight Pipeline
    real4 SHCoefficients[7];
    SHCoefficients[0] = unity_SHAr;
    SHCoefficients[1] = unity_SHAg;
    SHCoefficients[2] = unity_SHAb;
    SHCoefficients[3] = unity_SHBr;
    SHCoefficients[4] = unity_SHBg;
    SHCoefficients[5] = unity_SHBb;
    SHCoefficients[6] = unity_SHC;

    return max(half3(0, 0, 0), SampleSH9(SHCoefficients, normalWS));
}

// SH Vertex Evaluation. Depending on target SH sampling might be
// done completely per vertex or mixed with L2 term per vertex and L0, L1
// per pixel. See SampleSHPixel
half3 SampleSHVertex(half3 normalWS)
{
#if defined(EVALUATE_SH_VERTEX)
    return max(half3(0, 0, 0), SampleSH(normalWS));
#elif defined(EVALUATE_SH_MIXED)
    // no max since this is only L2 contribution
    return SHEvalLinearL2(normalWS, unity_SHBr, unity_SHBg, unity_SHBb, unity_SHC);
#endif

    // Fully per-pixel. Nothing to compute.
    return half3(0.0, 0.0, 0.0);
}

// SH Pixel Evaluation. Depending on target SH sampling might be done
// mixed or fully in pixel. See SampleSHVertex
half3 SampleSHPixel(half3 L2Term, half3 normalWS)
{
#if defined(EVALUATE_SH_VERTEX)
    return L2Term;
#elif defined(EVALUATE_SH_MIXED)
    half3 L0L1Term = SHEvalLinearL0L1(normalWS, unity_SHAr, unity_SHAg, unity_SHAb);
    return max(half3(0, 0, 0), L2Term + L0L1Term);
#endif

    // Default: Evaluate SH fully per-pixel
    return SampleSH(normalWS);
}

// Sample baked lightmap. Non-Direction and Directional if available.
// Realtime GI is not supported.
half3 SampleLightmap(float2 lightmapUV, half3 normalWS)
{
#ifdef UNITY_LIGHTMAP_FULL_HDR
    bool encodedLightmap = false;
#else
    bool encodedLightmap = true;
#endif

    half4 decodeInstructions = half4(LIGHTMAP_HDR_MULTIPLIER, LIGHTMAP_HDR_EXPONENT, 0.0h, 0.0h);

    // The shader library sample lightmap functions transform the lightmap uv coords to apply bias and scale.
    // However, universal pipeline already transformed those coords in vertex. We pass half4(1, 1, 0, 0) and
    // the compiler will optimize the transform away.
    half4 transformCoords = half4(1, 1, 0, 0);

#ifdef DIRLIGHTMAP_COMBINED
    return SampleDirectionalLightmap(TEXTURE2D_ARGS(unity_Lightmap, samplerunity_Lightmap),
        TEXTURE2D_ARGS(unity_LightmapInd, samplerunity_Lightmap),
        lightmapUV, transformCoords, normalWS, encodedLightmap, decodeInstructions);
#elif defined(LIGHTMAP_ON)
    return SampleSingleLightmap(TEXTURE2D_ARGS(unity_Lightmap, samplerunity_Lightmap), lightmapUV, transformCoords, encodedLightmap, decodeInstructions);
#else
    return half3(0.0, 0.0, 0.0);
#endif
}

// We either sample GI from baked lightmap or from probes.
// If lightmap: sampleData.xy = lightmapUV
// If probe: sampleData.xyz = L2 SH terms
#ifdef LIGHTMAP_ON
#define SAMPLE_GI(lmName, shName, normalWSName) SampleLightmap(lmName, normalWSName)
#else
#define SAMPLE_GI(lmName, shName, normalWSName) SampleSHPixel(shName, normalWSName)
#endif

half3 GlossyEnvironmentReflection(half3 reflectVector, half perceptualRoughness, half occlusion)
{
#if !defined(_ENVIRONMENTREFLECTIONS_OFF)
    half mip = PerceptualRoughnessToMipmapLevel(perceptualRoughness);
    half4 encodedIrradiance = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflectVector, mip);

#if !defined(UNITY_USE_NATIVE_HDR)
    half3 irradiance = DecodeHDREnvironment(encodedIrradiance, unity_SpecCube0_HDR);
#else
    half3 irradiance = encodedIrradiance.rbg;
#endif

    return irradiance * occlusion;
#endif // GLOSSY_REFLECTIONS

    return _GlossyEnvironmentColor.rgb * occlusion;
}

half3 SubtractDirectMainLightFromLightmap(Light mainLight, half3 normalWS, half3 bakedGI)
{
    // Let's try to make realtime shadows work on a surface, which already contains
    // baked lighting and shadowing from the main sun light.
    // Summary:
    // 1) Calculate possible value in the shadow by subtracting estimated light contribution from the places occluded by realtime shadow:
    //      a) preserves other baked lights and light bounces
    //      b) eliminates shadows on the geometry facing away from the light
    // 2) Clamp against user defined ShadowColor.
    // 3) Pick original lightmap value, if it is the darkest one.


    // 1) Gives good estimate of illumination as if light would've been shadowed during the bake.
    // We only subtract the main direction light. This is accounted in the contribution term below.
    half shadowStrength = GetMainLightShadowStrength();
    half contributionTerm = saturate(dot(mainLight.direction, normalWS));
    half3 lambert = mainLight.color * contributionTerm;
    half3 estimatedLightContributionMaskedByInverseOfShadow = lambert * (1.0 - mainLight.shadowAttenuation);
    half3 subtractedLightmap = bakedGI - estimatedLightContributionMaskedByInverseOfShadow;

    // 2) Allows user to define overall ambient of the scene and control situation when realtime shadow becomes too dark.
    half3 realtimeShadow = max(subtractedLightmap, _SubtractiveShadowColor.xyz);
    realtimeShadow = lerp(bakedGI, realtimeShadow, shadowStrength);

    // 3) Pick darkest color
    return min(bakedGI, realtimeShadow);
}

half3 GlobalIllumination(BRDFData brdfData, half3 bakedGI, half occlusion, half3 normalWS, half3 viewDirectionWS)
{
    half3 reflectVector = reflect(-viewDirectionWS, normalWS);
    half fresnelTerm = Pow4(1.0 - saturate(dot(normalWS, viewDirectionWS)));

    half3 indirectDiffuse = bakedGI * occlusion;
    half3 indirectSpecular = GlossyEnvironmentReflection(reflectVector, brdfData.perceptualRoughness, occlusion);

    return EnvironmentBRDF(brdfData, indirectDiffuse, indirectSpecular, fresnelTerm);
}

void MixRealtimeAndBakedGI(inout Light light, half3 normalWS, inout half3 bakedGI, half4 shadowMask)
{
#if defined(_MIXED_LIGHTING_SUBTRACTIVE) && defined(LIGHTMAP_ON)
    bakedGI = SubtractDirectMainLightFromLightmap(light, normalWS, bakedGI);
#endif
}

///////////////////////////////////////////////////////////////////////////////
//                      Lighting Functions                                   //
///////////////////////////////////////////////////////////////////////////////
half3 LightingLambert(half3 lightColor, half3 lightDir, half3 normal)
{
    half NdotL = saturate(dot(normal, lightDir));
    return lightColor * NdotL;
}

half3 LightingSpecular(half3 lightColor, half3 lightDir, half3 normal, half3 viewDir, half4 specular, half smoothness)
{
    float3 halfVec = SafeNormalize(float3(lightDir) + float3(viewDir));
    half NdotH = saturate(dot(normal, halfVec));
    half modifier = pow(NdotH, smoothness);
    half3 specularReflection = specular.rgb * modifier;
    return lightColor * specularReflection;
}

half3 LightingPhysicallyBased(BRDFData brdfData, half3 lightColor, half3 lightDirectionWS, half lightAttenuation, half3 normalWS, half3 viewDirectionWS)
{
    half NdotL = saturate(dot(normalWS, lightDirectionWS));
    half3 radiance = lightColor * (lightAttenuation * NdotL);
    return DirectBDRF(brdfData, normalWS, lightDirectionWS, viewDirectionWS) * radiance;
}

half3 LightingPhysicallyBased(BRDFData brdfData, Light light, half3 normalWS, half3 viewDirectionWS)
{
    return LightingPhysicallyBased(brdfData, light.color, light.direction, light.distanceAttenuation * light.shadowAttenuation, normalWS, viewDirectionWS);
}

half3 VertexLighting(float3 positionWS, half3 normalWS)
{
    half3 vertexLightColor = half3(0.0, 0.0, 0.0);

#ifdef _ADDITIONAL_LIGHTS_VERTEX
    uint lightsCount = GetAdditionalLightsCount();
    for (uint lightIndex = 0u; lightIndex < lightsCount; ++lightIndex)
    {
        Light light = GetAdditionalLight(lightIndex, positionWS);
        half3 lightColor = light.color * light.distanceAttenuation;
        vertexLightColor += LightingLambert(lightColor, light.direction, normalWS);
    }
#endif

    return vertexLightColor;
}

///////////////////////////////////////////////////////////////////////////////
//                      Fragment Functions                                   //
//       Used by ShaderGraph and others builtin renderers                    //
///////////////////////////////////////////////////////////////////////////////
half4 UniversalFragmentPBR(InputData inputData, half3 albedo, half metallic, half3 specular,
    half smoothness, half occlusion, half3 emission, half alpha)
{
    BRDFData brdfData;
    InitializeBRDFData(albedo, metallic, specular, smoothness, alpha, brdfData);
    
    Light mainLight = GetMainLight(inputData.shadowCoord);
    MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI, half4(0, 0, 0, 0));

    half3 color = GlobalIllumination(brdfData, inputData.bakedGI, occlusion, inputData.normalWS, inputData.viewDirectionWS);
    color += LightingPhysicallyBased(brdfData, mainLight, inputData.normalWS, inputData.viewDirectionWS);

#ifdef _ADDITIONAL_LIGHTS
    uint pixelLightCount = GetAdditionalLightsCount();
    for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
    {
        Light light = GetAdditionalLight(lightIndex, inputData.positionWS);
        color += LightingPhysicallyBased(brdfData, light, inputData.normalWS, inputData.viewDirectionWS);
    }
#endif

#ifdef _ADDITIONAL_LIGHTS_VERTEX
    color += inputData.vertexLighting * brdfData.diffuse;
#endif

    color += emission;
    return half4(color, alpha);
}

half4 UniversalFragmentBlinnPhong(InputData inputData, half3 diffuse, half4 specularGloss, half smoothness, half3 emission, half alpha)
{
    Light mainLight = GetMainLight(inputData.shadowCoord);
    MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI, half4(0, 0, 0, 0));

    half3 attenuatedLightColor = mainLight.color * (mainLight.distanceAttenuation * mainLight.shadowAttenuation);
    half3 diffuseColor = inputData.bakedGI + LightingLambert(attenuatedLightColor, mainLight.direction, inputData.normalWS);
    half3 specularColor = LightingSpecular(attenuatedLightColor, mainLight.direction, inputData.normalWS, inputData.viewDirectionWS, specularGloss, smoothness);

#ifdef _ADDITIONAL_LIGHTS
    uint pixelLightCount = GetAdditionalLightsCount();
    for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
    {
        Light light = GetAdditionalLight(lightIndex, inputData.positionWS);
        half3 attenuatedLightColor = light.color * (light.distanceAttenuation * light.shadowAttenuation);
        diffuseColor += LightingLambert(attenuatedLightColor, light.direction, inputData.normalWS);
        specularColor += LightingSpecular(attenuatedLightColor, light.direction, inputData.normalWS, inputData.viewDirectionWS, specularGloss, smoothness);
    }
#endif

#ifdef _ADDITIONAL_LIGHTS_VERTEX
    diffuseColor += inputData.vertexLighting;
#endif

    half3 finalColor = diffuseColor * diffuse + emission;

#if defined(_SPECGLOSSMAP) || defined(_SPECULAR_COLOR)
    finalColor += specularColor;
#endif

    return half4(finalColor, alpha);
}

//LWRP -> Universal Backwards Compatibility
half4 LightweightFragmentPBR(InputData inputData, half3 albedo, half metallic, half3 specular,
    half smoothness, half occlusion, half3 emission, half alpha)
{
    return UniversalFragmentPBR(inputData, albedo, metallic, specular, smoothness, occlusion, emission, alpha);
}

half4 LightweightFragmentBlinnPhong(InputData inputData, half3 diffuse, half4 specularGloss, half smoothness, half3 emission, half alpha)
{
    return UniversalFragmentBlinnPhong(inputData, diffuse, specularGloss, smoothness, emission, alpha);
}
#endif

// File end: com.unity.render-pipelines.universal@7.3.1/ShaderLibrary/Lighting.hlsl
//================================================================================================================================


