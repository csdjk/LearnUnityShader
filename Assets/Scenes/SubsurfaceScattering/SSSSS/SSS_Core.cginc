#ifndef SSS_CORE_INCLUDED
#define SSS_CORE_INCLUDED
//-----------------------------------------------------------------------------
// BRDF functions 
//-----------------------------------------------------------------------------

// See UnityStandardBRDF for more info

UNITY_DECLARE_TEX2D(_BRDFTex);

half4 UNITY_BRDF_PBS_SSSS (half3 diffColor, half3 specColor, half oneMinusReflectivity, half smoothness, half thickness,
    float3 normal, float3 viewDir,
    UnityLight light, UnityIndirect gi)
{
    float perceptualRoughness = SmoothnessToPerceptualRoughness (smoothness);
    float3 halfDir = Unity_SafeNormalize (float3(light.dir) + viewDir);

// NdotV should not be negative for visible pixels, but it can happen due to perspective projection and normal mapping
// In this case normal should be modified to become valid (i.e facing camera) and not cause weird artifacts.
// but this operation adds few ALU and users may not want it. Alternative is to simply take the abs of NdotV (less correct but works too).
// Following define allow to control this. Set it to 0 if ALU is critical on your platform.
// This correction is interesting for GGX with SmithJoint visibility function because artifacts are more visible in this case due to highlight edge of rough surface
// Edit: Disable this code by default for now as it is not compatible with two sided lighting used in SpeedTree.
#define UNITY_HANDLE_CORRECTLY_NEGATIVE_NDOTV 0

#if UNITY_HANDLE_CORRECTLY_NEGATIVE_NDOTV
    // The amount we shift the normal toward the view vector is defined by the dot product.
    half shiftAmount = dot(normal, viewDir);
    normal = shiftAmount < 0.0f ? normal + viewDir * (-shiftAmount + 1e-5f) : normal;
    // A re-normalization should be applied here but as the shift is small we don't do it to save ALU.
    //normal = normalize(normal);

    float nv = saturate(dot(normal, viewDir)); // TODO: this saturate should no be necessary here
#else
    half nv = abs(dot(normal, viewDir));    // This abs allow to limit artifact
#endif

    float nl = saturate(dot(normal, light.dir));
    float nh = saturate(dot(normal, halfDir));

    half lv = saturate(dot(light.dir, viewDir));
    half lh = saturate(dot(light.dir, halfDir));

    // Diffuse term
    half3 diffuseTerm = DisneyDiffuse(nv, nl, lh, perceptualRoughness) * nl;

    #if defined(_METALLICGLOSSMAP) // Scattering 
    //  Skin Lighting
    float2 brdfUV;
    // Half-Lambert lighting value based on blurred normals.
    brdfUV.x = nl * 0.5 + 0.5;
    // Curvature amount. Multiplied by light's luminosity so brighter light = more scattering.
    // Pleae note: gi.light.color already contains light attenuation
    brdfUV.y = thickness * dot(light.color, fixed3(0.22, 0.707, 0.071));
    half3 brdf = UNITY_SAMPLE_TEX2D ( _BRDFTex, brdfUV ).rgb;
    #else
    float wrappedDiffuse = pow(saturate((diffuseTerm + _WrappingFactor) /
     (1.0f + _WrappingFactor)), _WrappingPowerFactor) * (_WrappingPowerFactor + 1) / (2 * (1 + _WrappingFactor));
    half3 brdf = wrappedDiffuse;
    #endif

    // Specular term
    // HACK: theoretically we should divide diffuseTerm by Pi and not multiply specularTerm!
    // BUT 1) that will make shader look significantly darker than Legacy ones
    // and 2) on engine side "Non-important" lights have to be divided by Pi too in cases when they are injected into ambient SH
    float roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
#if UNITY_BRDF_GGX
    // GGX with roughtness to 0 would mean no specular at all, using max(roughness, 0.002) here to match HDrenderloop roughtness remapping.
    roughness = max(roughness, 0.002);
    float V = SmithJointGGXVisibilityTerm (nl, nv, roughness);
    float D = GGXTerm (nh, roughness);
#else
    // Legacy
    half V = SmithBeckmannVisibilityTerm (nl, nv, roughness);
    half D = NDFBlinnPhongNormalizedTerm (nh, PerceptualRoughnessToSpecPower(perceptualRoughness));
#endif

    float specularTerm = V*D * UNITY_PI; // Torrance-Sparrow model, Fresnel is applied later

#   ifdef UNITY_COLORSPACE_GAMMA
        specularTerm = sqrt(max(1e-4h, specularTerm));
#   endif

    // specularTerm * nl can be NaN on Metal in some cases, use max() to make sure it's a sane value
    specularTerm = max(0, specularTerm * nl);
#if defined(_SPECULARHIGHLIGHTS_OFF)
    specularTerm = 0.0;
#endif

    // surfaceReduction = Int D(NdotH) * NdotH * Id(NdotL>0) dH = 1/(roughness^2+1)
    half surfaceReduction;
#   ifdef UNITY_COLORSPACE_GAMMA
        surfaceReduction = 1.0-0.28*roughness*perceptualRoughness;      // 1-0.28*x^3 as approximation for (1/(x^4+1))^(1/2.2) on the domain [0;1]
#   else
        surfaceReduction = 1.0 / (roughness*roughness + 1.0);           // fade \in [0.5;1]
#   endif

    const float epsilon = 1.192092896e-07; // Smallest positive number, such that 1.0 + epsilon != 1.0

    // SH brdf term
    #if defined(_METALLICGLOSSMAP) // Scattering 
    float3 shLength = GetSHLength();
    float3 giBase = saturate(gi.diffuse / shLength);
    float giBaseL = dot(giBase, 1.0/3.0) + epsilon;
    giBase /= giBaseL;

    brdfUV.x = giBaseL * 0.5 + 0.5;
    brdfUV.y = thickness * dot(shLength, fixed3(0.22, 0.707, 0.071));
    half3 brdfSH = UNITY_SAMPLE_TEX2D ( _BRDFTex, brdfUV ).rgb;
    gi.diffuse = max(0, shLength * giBase * lerp(giBaseL, brdfSH, thickness));
    #endif

    // To provide true Lambert lighting, we need to be able to kill specular completely.
    specularTerm *= any(specColor) ? 1.0 : 0.0;

    half grazingTerm = saturate(smoothness + (1-oneMinusReflectivity));
    half3 color =   diffColor * (gi.diffuse + light.color * lerp(diffuseTerm, brdf, thickness))
                    + specularTerm * light.color * FresnelTerm (specColor, lh)
                    + surfaceReduction * gi.specular * FresnelLerp (specColor, grazingTerm, nv);

    return half4(color, 1);
}

//-----------------------------------------------------------------------------
// Surface functions 
//-----------------------------------------------------------------------------

struct SurfaceOutputStandardSSSS
{
    fixed3 Albedo;      // base (diffuse or specular) color
    float3 Normal;      // tangent space normal, if written
    half3 Emission;
    half Metallic;      // 0=non-metal, 1=metal
    // Smoothness is the user facing name, it should be perceptual smoothness but user should not have to deal with it.
    // Everywhere in the code you meet smoothness it is perceptual smoothness
    half Smoothness;    // 0=rough, 1=smooth
    half Occlusion;     // occlusion (default 1)
    fixed Alpha;        // alpha for transparencies
    fixed Thickness;
};


struct SurfaceOutputStandardSpecularSSSS
{
    fixed3 Albedo;      // diffuse color
    fixed3 Specular;    // specular color
    float3 Normal;      // tangent space normal, if written
    half3 Emission;
    half Smoothness;    // 0=rough, 1=smooth
    half Occlusion;     // occlusion (default 1)
    fixed Alpha;        // alpha for transparencies
    fixed Thickness;
};

inline half4 LightingStandardSSSS (SurfaceOutputStandardSSSS s, UnityGIInput data, UnityGI gi)
{
    s.Normal = normalize(s.Normal);

    half oneMinusReflectivity;
    half3 specColor;
    s.Albedo = DiffuseAndSpecularFromMetallic (s.Albedo, s.Metallic, /*out*/ specColor, /*out*/ oneMinusReflectivity);

    // shader relies on pre-multiply alpha-blend (_SrcBlend = One, _DstBlend = OneMinusSrcAlpha)
    // this is necessary to handle transparency in physically correct way - only diffuse component gets affected by alpha
    half outputAlpha;
    s.Albedo = PreMultiplyAlpha (s.Albedo, s.Alpha, oneMinusReflectivity, /*out*/ outputAlpha); 

    half4 c = UNITY_BRDF_PBS_SSSS (s.Albedo, specColor, oneMinusReflectivity, s.Smoothness, s.Thickness, s.Normal, data.worldViewDir, gi.light, gi.indirect);


#if defined(UNITY_PASS_FORWARDBASE) && defined(VERTEXLIGHT_ON)
    // energy conservation
    UnityLight light = gi.light;
    UnityIndirect nullGi = gi.indirect;

    nullGi.diffuse = 0;
    nullGi.specular = 0;

    for(int num = 0; num < 4 && any(unity_LightColor[num].rgb > 0); num++)
        {
        UnityLight light;
        float3 lightPos = float3(unity_4LightPosX0[num], unity_4LightPosY0[num], unity_4LightPosZ0[num]);
        light.dir = lightPos - data.worldPos;
        
        float lengthSq = dot(light.dir, light.dir);
        float atten2 = saturate(1 - (lengthSq * unity_4LightAtten0[num] / 25));

        if (atten2 > 0)
            {
            light.dir *= min(1e30, rsqrt(lengthSq));
            float atten = 1.0 / (1.0 + (lengthSq * unity_4LightAtten0[num]));
            //atten = unityPointAttenuation(lengthSq, unity_4LightAtten0[num]);
            atten = min(atten, atten2 * atten2);
                        
            light.color = unity_LightColor[num].rgb * atten;
            
            c += UNITY_BRDF_PBS_SSSS (s.Albedo, specColor, 
                oneMinusReflectivity, s.Smoothness, 
                s.Thickness, s.Normal, 
                data.worldViewDir, light, nullGi); 
            }
        };
#endif

    c.a = outputAlpha;
    return c;
}

inline half4 LightingStandardSSSS_Deferred (SurfaceOutputStandardSSSS s, float3 viewDir, UnityGI gi, out half4 outGBuffer0, out half4 outGBuffer1, out half4 outGBuffer2)
{
    half oneMinusReflectivity;
    half3 specColor;
    s.Albedo = DiffuseAndSpecularFromMetallic (s.Albedo, s.Metallic, /*out*/ specColor, /*out*/ oneMinusReflectivity);

    half4 c = UNITY_BRDF_PBS_SSSS (s.Albedo, specColor, oneMinusReflectivity, s.Smoothness, s.Thickness, s.Normal, viewDir, gi.light, gi.indirect);

    UnityStandardData data;
    data.diffuseColor   = s.Albedo;
    data.occlusion      = s.Occlusion;
    data.specularColor  = specColor;
    data.smoothness     = s.Smoothness;
    data.normalWorld    = s.Normal;

    UnityStandardDataToGbuffer(data, outGBuffer0, outGBuffer1, outGBuffer2);

    half4 emission = half4(s.Emission + c.rgb, 1);
    return emission;
}

inline void LightingStandardSSSS_GI (
    SurfaceOutputStandardSSSS s,
    UnityGIInput data,
    inout UnityGI gi)
{
#if defined(UNITY_PASS_DEFERRED) && UNITY_ENABLE_REFLECTION_BUFFERS
    gi = UnityGlobalIllumination_Geom(data, s.Occlusion, s.Normal);
#else
    Unity_GlossyEnvironmentData g = UnityGlossyEnvironmentSetup(s.Smoothness, data.worldViewDir, s.Normal, lerp(unity_ColorSpaceDielectricSpec.rgb, s.Albedo, s.Metallic));
    gi = UnityGlobalIllumination_Geom(data, s.Occlusion, s.Normal, g);
#endif
}

inline half4 LightingStandardSSSSSpecular (SurfaceOutputStandardSpecularSSSS s, UnityGIInput data, UnityGI gi)
{
    s.Normal = normalize(s.Normal);

    // energy conservation
    half oneMinusReflectivity;
    s.Albedo = EnergyConservationBetweenDiffuseAndSpecular (s.Albedo, s.Specular, /*out*/ oneMinusReflectivity);

    // shader relies on pre-multiply alpha-blend (_SrcBlend = One, _DstBlend = OneMinusSrcAlpha)
    // this is necessary to handle transparency in physically correct way - only diffuse component gets affected by alpha
    half outputAlpha;
    s.Albedo = PreMultiplyAlpha (s.Albedo, s.Alpha, oneMinusReflectivity, /*out*/ outputAlpha);

    half4 c = UNITY_BRDF_PBS_SSSS (s.Albedo, s.Specular, oneMinusReflectivity, s.Smoothness, s.Thickness, s.Normal, data.worldViewDir, gi.light, gi.indirect);

#if defined(UNITY_PASS_FORWARDBASE) && defined(VERTEXLIGHT_ON)
    // energy conservation
    UnityLight light = gi.light;
    UnityIndirect nullGi = gi.indirect;

    nullGi.diffuse = 0;
    nullGi.specular = 0;

    for(int num = 0; num < 4 && any(unity_LightColor[num].rgb > 0); num++)
        {
        UnityLight light;
        float3 lightPos = float3(unity_4LightPosX0[num], unity_4LightPosY0[num], unity_4LightPosZ0[num]);
        light.dir = lightPos - data.worldPos;
        
        float lengthSq = dot(light.dir, light.dir);
        float atten2 = saturate(1 - (lengthSq * unity_4LightAtten0[num] / 25));

        if (atten2 > 0)
            {
            light.dir *= min(1e30, rsqrt(lengthSq));
            float atten = 1.0 / (1.0 + (lengthSq * unity_4LightAtten0[num]));
            //atten = unityPointAttenuation(lengthSq, unity_4LightAtten0[num]);
            atten = min(atten, atten2 * atten2);
                        
            light.color = unity_LightColor[num].rgb * atten;
            
            c += UNITY_BRDF_PBS_SSSS (s.Albedo, s.Specular, 
                oneMinusReflectivity, s.Smoothness, 
                s.Thickness, s.Normal, 
                data.worldViewDir, light, nullGi); 
            }
        };
#endif

    c.a = outputAlpha;
    return c;
}

inline half4 LightingStandardSSSSSpecular_Deferred (SurfaceOutputStandardSpecularSSSS s, float3 viewDir, UnityGI gi, out half4 outGBuffer0, out half4 outGBuffer1, out half4 outGBuffer2)
{
    // energy conservation
    half oneMinusReflectivity;
    s.Albedo = EnergyConservationBetweenDiffuseAndSpecular (s.Albedo, s.Specular, /*out*/ oneMinusReflectivity);

    half4 c = UNITY_BRDF_PBS_SSSS (s.Albedo, s.Specular, oneMinusReflectivity, s.Smoothness, s.Thickness, s.Normal, viewDir, gi.light, gi.indirect);

    UnityStandardData data;
    data.diffuseColor   = s.Albedo;
    data.occlusion      = s.Occlusion;
    data.specularColor  = s.Specular;
    data.smoothness     = s.Smoothness;
    data.normalWorld    = s.Normal;

    UnityStandardDataToGbuffer(data, outGBuffer0, outGBuffer1, outGBuffer2);

    half4 emission = half4(s.Emission + c.rgb, 1);
    return emission;
}

inline void LightingStandardSSSSSpecular_GI (
    SurfaceOutputStandardSpecularSSSS s,
    UnityGIInput data,
    inout UnityGI gi)
{
#if defined(UNITY_PASS_DEFERRED) && UNITY_ENABLE_REFLECTION_BUFFERS
    gi = UnityGlobalIllumination_Geom(data, s.Occlusion, s.Normal);
#else
    Unity_GlossyEnvironmentData g = UnityGlossyEnvironmentSetup(s.Smoothness, data.worldViewDir, s.Normal, s.Specular);
    gi = UnityGlobalIllumination_Geom(data, s.Occlusion, s.Normal, g);
#endif
}

#endif // SSS_CORE_INCLUDED