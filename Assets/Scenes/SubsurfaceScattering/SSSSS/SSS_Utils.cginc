#ifndef SSS_UTILS_INCLUDED
#define SSS_UTILS_INCLUDED
//-----------------------------------------------------------------------------
// Helper functions 
//-----------------------------------------------------------------------------

float RoughnessToPerceptualRoughness_local(float roughness)
{
    return sqrt(roughness);
}

float RoughnessToPerceptualSmoothness_local(float roughness)
{
    return 1.0 - sqrt(roughness);
}

float PerceptualSmoothnessToRoughness_local(float perceptualSmoothness)
{
    return (1.0 - perceptualSmoothness) * (1.0 - perceptualSmoothness);
}

float PerceptualSmoothnessToPerceptualRoughness_local(float perceptualSmoothness)
{
    return (1.0 - perceptualSmoothness);
}

float PerceptualRoughnessToPerceptualSmoothness_local(float perceptualRoughness)
{
    return (1.0 - perceptualRoughness);
}

// Return modified perceptualSmoothness based on provided variance (get from GeometricNormalVariance + TextureNormalVariance)
float NormalFiltering(float perceptualSmoothness, float variance, float threshold)
{
    float roughness = PerceptualSmoothnessToRoughness_local(perceptualSmoothness);
    // Ref: Geometry into Shading - http://graphics.pixar.com/library/BumpRoughness/paper.pdf - equation (3)
    float squaredRoughness = saturate(roughness * roughness + min(2.0 * variance, threshold * threshold)); // threshold can be floatly low, square the value for easier control

    return RoughnessToPerceptualSmoothness_local(sqrt(squaredRoughness));
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

//SSS method from GDC 2011 conference by Colin Barre-Bresebois & Marc Bouchard and modified by Xiexe
float3 getSubsurfaceScatteringLight (float3 lightColor, float3 lightDirection, float3 normalDirection, float3 viewDirection, 
    float attenuation, float3 thickness, float3 indirectLight, float3 subsurfaceColour)
{
    float3 vLTLight = lightDirection + normalDirection * _SSSDist; // Distortion
    float3 fLTDot = pow(saturate(dot(viewDirection, -vLTLight)), _SSSPow) 
        * _SSSIntensity * 1.0/UNITY_PI; 
    
    return lerp(1, attenuation, float(any(_WorldSpaceLightPos0.xyz))) 
                * (fLTDot + _SSSAmbient) * thickness
                * (lightColor + indirectLight) * subsurfaceColour;
                
}

inline float3 BlendNormalsPD(float3 n1, float3 n2) {
    return normalize(float3(n1.xy*n2.z + n2.xy*n1.z, n1.z*n2.z));
}

// Based on NormalInTangentSpace from UnityStandardInput
inline float3 NormalInTangentSpace(float2 texcoords, float2 texcoords2, half mask)
{
    //float3 normalTangent = UnpackNormal(tex2D(_BumpMap,TRANSFORM_TEX(texcoords.xy, _MainTex)));
    //float3 normalTangent = UnpackNormal(tex2D(_BumpMap,texcoords.xy));
    half3 normalTangent = UnpackScaleNormal(tex2D (_BumpMap, texcoords.xy), _BumpScale);

    half3 detailNormalTangent = UnpackScaleNormal(tex2D (_DetailBumpMap, TRANSFORM_TEX(texcoords2.xy, _DetailBumpMap)), _DetailBumpMapScale);
    #if _DETAIL_LERP
        normalTangent = lerp(
            normalTangent,
            detailNormalTangent,
            mask);
    #else
        normalTangent = lerp(
            normalTangent,
            BlendNormalsPD(normalTangent, detailNormalTangent),
            mask);
    #endif

    return normalTangent;
}

// "R2" dithering

// Triangle Wave
float T(float z) {
    return z >= 0.5 ? 2.-2.*z : 2.*z;
}

// R dither mask
float intensity(float2 pixel) {
    const float a1 = 0.75487766624669276;
    const float a2 = 0.569840290998;
    return frac(a1 * float(pixel.x) + a2 * float(pixel.y));
}

// Get the maximum SH contribution
// synqark's Arktoon shader's shading method
half3 GetSHLength ()
{
    half3 x, x1;
    x.r = length(unity_SHAr);
    x.g = length(unity_SHAg);
    x.b = length(unity_SHAb);
    x1.r = length(unity_SHBr);
    x1.g = length(unity_SHBg);
    x1.b = length(unity_SHBb);
    return x + x1;
}

half3 min3(float a, float b, float c) {
    return min(min(a, b), c);
}

half3 min3(float3 a) {
    return min(min(a.x, a.y), a.z);
}

half3 max3(float a, float b, float c) {
    return max(max(a, b), c);
}

half3 max3(float3 a) {
    return max(max(a.x, a.y), a.z);
}

half3 GetSHAvg ()
{
    return float3(unity_SHAr.w,unity_SHAg.w,unity_SHAb.w);
}

//-----------------------------------------------------------------------------
// Better GI functions
//-----------------------------------------------------------------------------

/* http://www.geomerics.com/wp-content/uploads/2015/08/CEDEC_Geomerics_ReconstructingDiffuseLighting1.pdf */
float shEvaluateDiffuseL1Geomerics_local(float L0, float3 L1, float3 n)
{
    // average energy
    float R0 = L0;

    // avg direction of incoming light
    float3 R1 = 0.5f * L1;

    // directional brightness
    float lenR1 = length(R1);

    // linear angle between normal and direction 0-1
    //float q = 0.5f * (1.0f + dot(R1 / lenR1, n));
    //float q = dot(R1 / lenR1, n) * 0.5 + 0.5;
    float q = dot(normalize(R1), n) * 0.5 + 0.5;
    q = saturate(q); // Thanks to ScruffyRuffles for the bug identity.

    // power for q
    // lerps from 1 (linear) to 3 (cubic) based on directionality
    float p = 1.0f + 2.0f * lenR1 / R0;

    // dynamic range constant
    // should vary between 4 (highly directional) and 0 (ambient)
    float a = (1.0f - lenR1 / R0) / (1.0f + lenR1 / R0);

    return R0 * (a + (1.0f - a) * (p + 1.0f) * pow(q, p));
}

// From https://github.com/lukis101/VRCUnityStuffs/tree/master/SH
// SH Convolution Functions
// Code adapted from https://blog.selfshadow.com/2012/01/07/righting-wrap-part-2/
///////////////////////////

float3 GeneralWrapSH(float fA) // original unoptimized
{
    // Normalization factor for our model.
    float norm = 0.5 * (2 + fA) / (1 + fA);
    float4 t = float4(2 * (fA + 1), fA + 2, fA + 3, fA + 4);
    return norm * float3(t.x / t.y, 2 * t.x / (t.y * t.z),
        t.x * (fA * fA - t.x + 5) / (t.y * t.z * t.w));
}
float3 GeneralWrapSHOpt(float fA)
{
    const float4 t0 = float4(-0.047771, -0.129310, 0.214438, 0.279310);
    const float4 t1 = float4( 1.000000,  0.666667, 0.250000, 0.000000);

    float3 r;
    r.xyz = saturate(t0.xxy * fA + t0.yzw);
    r.xyz = -r * fA + t1.xyz;
    return r;
}

float3 GreenWrapSHOpt(float fW)
{
    const float4 t0 = float4(0.0, 1.0 / 4.0, -1.0 / 3.0, -1.0 / 2.0);
    const float4 t1 = float4(1.0, 2.0 / 3.0,  1.0 / 4.0,  0.0);

    float3 r;
    r.xyz = t0.xxy * fW + t0.xzw;
    r.xyz = r.xyz * fW + t1.xyz;
    return r;
}

float3 ShadeSH9_wrapped(float3 normal, float3 conv)
{
    float3 x0, x1, x2;
    conv *= float3(1, 1.5, 4); // Undo pre-applied cosine convolution
    //conv *= _Bands.xyz; // debugging

    // Constant (L0)
    // Band 0 has constant part from 6th kernel (band 1) pre-applied, but ignore for performance
    x0 = float3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w);

    // Linear (L1) polynomial terms
    x1.r = (dot(unity_SHAr.xyz, normal));
    x1.g = (dot(unity_SHAg.xyz, normal));
    x1.b = (dot(unity_SHAb.xyz, normal));

    // 4 of the quadratic (L2) polynomials
    float4 vB = normal.xyzz * normal.yzzx;
    x2.r = dot(unity_SHBr, vB);
    x2.g = dot(unity_SHBg, vB);
    x2.b = dot(unity_SHBb, vB);

    // Final (5th) quadratic (L2) polynomial
    float vC = normal.x * normal.x - normal.y * normal.y;
    x2 += unity_SHC.rgb * vC;

    return x0 * conv.x + x1 * conv.y + x2 * conv.z;
}

float3 ShadeSH9_wrappedCorrect(float3 normal, float3 conv)
{
    const float3 cosconv_inv = float3(1, 1.5, 4); // Inverse of the pre-applied cosine convolution
    float3 x0, x1, x2;
    conv *= cosconv_inv; // Undo pre-applied cosine convolution
    //conv *= _Bands.xyz; // debugging

    // Constant (L0)
    x0 = float3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w);
    // Remove the constant part from L2 and add it back with correct convolution
    float3 otherband = float3(unity_SHBr.z, unity_SHBg.z, unity_SHBb.z) / 3.0;
    x0 = (x0 + otherband) * conv.x - otherband * conv.z;

    // Linear (L1) polynomial terms
    x1.r = (dot(unity_SHAr.xyz, normal));
    x1.g = (dot(unity_SHAg.xyz, normal));
    x1.b = (dot(unity_SHAb.xyz, normal));

    // 4 of the quadratic (L2) polynomials
    float4 vB = normal.xyzz * normal.yzzx;
    x2.r = dot(unity_SHBr, vB);
    x2.g = dot(unity_SHBg, vB);
    x2.b = dot(unity_SHBb, vB);

    // Final (5th) quadratic (L2) polynomial
    float vC = normal.x * normal.x - normal.y * normal.y;
    x2 += unity_SHC.rgb * vC;

    return x0 + x1 * conv.y + x2 * conv.z;
}

float PositivePow(float base, float power)
{
    return pow(abs(base), power);
}

bool isReflectionProbeActive()
{
#ifndef SHADER_TARGET_SURFACE_ANALYSIS // Required to use GetDimensions
    float height, width;
    unity_SpecCube0.GetDimensions(width, height);
    return !(height * width < 32);
#endif
    return 1;
}

// Ref: Moving Frostbite to PBR - Gotanda siggraph 2011
// Return specular occlusion based on ambient occlusion (usually get from SSAO) and view/roughness info
float GetSpecularOcclusionFromAmbientOcclusion(float NdotV, float ambientOcclusion, float roughness)
{
    return saturate(PositivePow(NdotV + ambientOcclusion, exp2(-16.0 * roughness - 1.0)) - 1.0 + ambientOcclusion);
}

inline UnityGI UnityGlobalIllumination_Geom (UnityGIInput data, half occlusion, half3 normalWorld, Unity_GlossyEnvironmentData glossIn,
    half thickness = 0.5)
{
    UnityGI o_gi = UnityGI_Base(data, occlusion, normalWorld);
    #if UNITY_SHOULD_SAMPLE_SH
        #if 0
            o_gi.indirect.diffuse = ShadeSHPerPixel(normalWorld, data.ambient, data.worldPos);
        #endif

        #if 0 
            float3 L0 = float3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w);
            float3 nonLinearSH = float3(0,0,0); 
            nonLinearSH.r = shEvaluateDiffuseL1Geomerics_local(L0.r, unity_SHAr.xyz, normalWorld);
            nonLinearSH.g = shEvaluateDiffuseL1Geomerics_local(L0.g, unity_SHAg.xyz, normalWorld);
            nonLinearSH.b = shEvaluateDiffuseL1Geomerics_local(L0.b, unity_SHAb.xyz, normalWorld);
            nonLinearSH = max(nonLinearSH, 0);
            nonLinearSH += SHEvalLinearL2(half4(normal, 1.0));
            o_gi.indirect.diffuse += nonLinearSH * occlusion;
        #endif

        #if 1
            float shWrap = thickness;
            float3 sh_conv = GeneralWrapSH(shWrap);
            o_gi.indirect.diffuse = ShadeSH9_wrappedCorrect(normalWorld, sh_conv);
        #endif
    #endif

    #if 0
    half NdotV = abs(dot(normalWorld, data.worldViewDir));
    float specOcclusion = GetSpecularOcclusionFromAmbientOcclusion(NdotV, occlusion, glossIn.roughness);
    #else
    float specOcclusion = occlusion;
    #endif
    

    if (isReflectionProbeActive())
    {
        o_gi.indirect.specular = UnityGI_IndirectSpecular(data, specOcclusion, glossIn);
    } else 
    {
        // Use light probes for the indirect specular lighting.
        o_gi.indirect.specular = o_gi.indirect.diffuse;
    }
    return o_gi;
}

half3 BetterSH9 (half4 normal) {
    float3 indirect;
    float3 L0 = float3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w);
    indirect.r = shEvaluateDiffuseL1Geomerics_local(L0.r, unity_SHAr.xyz, normal);
    indirect.g = shEvaluateDiffuseL1Geomerics_local(L0.g, unity_SHAg.xyz, normal);
    indirect.b = shEvaluateDiffuseL1Geomerics_local(L0.b, unity_SHAb.xyz, normal);
    indirect = max(0, indirect);
    return indirect;

}


// Ref: Horizon Occlusion for Normal Mapped Reflections: http://marmosetco.tumblr.com/post/81245981087
float GetHorizonOcclusion(float3 V, float3 normalWS, float3 vertexNormal, float horizonFade)
{
    float3 R = reflect(-V, normalWS);
    float specularOcclusion = saturate(1.0 + horizonFade * dot(R, vertexNormal));
    // smooth it
    return specularOcclusion * specularOcclusion;
}

// ref: Practical floattime Strategies for Accurate Indirect Occlusion
// Update ambient occlusion to colored ambient occlusion based on statitics of how light is bouncing in an object and with the albedo of the object
float3 GTAOMultiBounce(float visibility, float3 albedo)
{
    float3 a =  2.0404 * albedo - 0.3324;
    float3 b = -4.7951 * albedo + 0.6417;
    float3 c =  2.7552 * albedo + 0.6903;

    float x = visibility;
    return max(x, ((x * a + b) * x + c) * x);
}

// Ref: The Technical Art of Uncharted 4 - Brinck and Maximov 2016
float ComputeMicroShadowing(float AO, float NdotL, float opacity)
{
    float aperture = 2.0 * AO * AO;
    float microshadow = saturate(NdotL + aperture - 1.0);
    return lerp(1.0, microshadow, opacity);
}

// Invoke with finalcolor:ApplyDitherAlpha
// Must be defined after surf in file.
void ApplyDitherAlpha(Input IN, SurfaceOutputCustomLightingCustom o, inout fixed4 color) {
    float2 pos = (IN.screenPos.xy*_ScreenParams)/IN.screenPos.w;
    pos += _SinTime.x%4;
    float alpha = o.Alpha;

    #if !(defined(_ALPHATEST_ON) || defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON))
        alpha = 1.0;
    #else
        alpha = ((alpha - _Cutout) / max(fwidth(alpha), 0.0001) + 0.5);
        clip(alpha - 1.0/255.0 );
    #endif

    //float mask = (T(intensity(pos)));
    //alpha = saturate(alpha + alpha * mask); 

    color.a = alpha;
}

float unityPointAttenuation(float lengthSq, float range)
{
    // Based on https://geom.io/bakery/wiki/index.php?title=Point_Light_Attenuation
    return 1/(pow((lengthSq/range)*5, 2.0)+1);

}

#endif // SSS_UTILS_INCLUDED