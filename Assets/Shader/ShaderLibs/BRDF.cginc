#ifndef LCL_BRDF_INCLUDED
#define LCL_BRDF_INCLUDED

struct BxDFContext
{
    float NdotV;
    float NdotL;
    float VdotL;
    float NdotH;
    float VdotH;
    float TdotV;
    float TdotL;
    float TdotH;
    float BdotV;
    float BdotL;
    float BdotH;
};


void Init(inout BxDFContext Context, half3 N, half3 V, half3 L)
{
    Context.NdotL = dot(N, L);
    Context.NdotV = dot(N, V);
    Context.VdotL = dot(V, L);
    float InvLenH = rsqrt(2 + 2 * Context.VdotL);
    Context.NdotH = saturate((Context.NdotL + Context.NdotV) * InvLenH);
    Context.VdotH = saturate(InvLenH + InvLenH * Context.VdotL);

    Context.TdotV = 0.0f;
    Context.TdotL = 0.0f;
    Context.TdotH = 0.0f;
    Context.BdotV = 0.0f;
    Context.BdotL = 0.0f;
    Context.BdotH = 0.0f;
}

void Init(inout BxDFContext Context, half3 N, half3 V, half3 L, half3 T, half3 B)
{
    Context.NdotL = dot(N, L);
    Context.NdotV = dot(N, V);
    Context.VdotL = dot(V, L);
    float InvLenH = rsqrt(2 + 2 * Context.VdotL);
    Context.NdotH = saturate((Context.NdotL + Context.NdotV) * InvLenH);
    Context.VdotH = saturate(InvLenH + InvLenH * Context.VdotL);
    //NdotL = saturate( NdotL );
    //NdotV = saturate( abs( NdotV ) + 1e-5 );

    Context.TdotV = dot(T, V);
    Context.TdotL = dot(T, L);
    Context.TdotH = (Context.TdotL + Context.TdotV) * InvLenH;
    Context.BdotV = dot(B, V);
    Context.BdotL = dot(B, L);
    Context.BdotH = (Context.BdotL + Context.BdotV) * InvLenH;
}


float Square(float x)
{
    return x * x;
}

float2 Square(float2 x)
{
    return x * x;
}

float3 Square(float3 x)
{
    return x * x;
}

float4 Square(float4 x)
{
    return x * x;
}

// ================================== 各向异性BRDF ==================================
void GetAnisotropicRoughness(float Roughness, float Anisotropy, out float ax, out float ay)
{
    // Anisotropic parameters: ax and ay are the roughness along the tangent and bitangent
    // Kulla 2017, "Revisiting Physically Based Shading at Imageworks"
    ax = max(Roughness * (1.0 + Anisotropy), 0.001f);
    ay = max(Roughness * (1.0 - Anisotropy), 0.001f);
}


void ConvertAnisotropyToRoughness(float roughness, float anisotropy, out float roughnessT, out float roughnessB)
{
    // (0 <= anisotropy <= 1), therefore (0 <= anisoAspect <= 1)
    // The 0.9 factor limits the aspect ratio to 10:1.
    float anisoAspect = sqrt(1.0 - 0.9 * anisotropy);
    roughnessT = roughness / anisoAspect; // Distort along tangent (rougher)
    roughnessB = roughness * anisoAspect; // Straighten along bitangent (smoother)

}
//Clamp roughness
float ClampRoughnessForAnalyticalLights(float roughness)
{
    return max(roughness, 0.000001);
}

// Anisotropic GGX
// [Burley 2012, "Physically-Based Shading at Disney"]
inline float D_GGXAniso(float ax, float ay, float NoH, float ToH, float BoH)
{
    // NdotH, TdotH, BdotH
    // The two formulations are mathematically equivalent
    #if 1
        float a2 = ax * ay;
        float3 V = float3(ay * ToH, ax * BoH, a2 * NoH);
        float S = dot(V, V);
        return (1.0f / UNITY_PI) * a2 * Square(a2 / S);
    #else
        float d = ToH * ToH / (ax * ax) + BoH * BoH / (ay * ay) + NoH * NoH;
        return 1.0f / (UNITY_PI * ax * ay * d * d);
    #endif
}

// Anisotropic GGX
// From HDRenderPipeline
inline float D_GGXAnisotropic(float TdotH, float BdotH, float NdotH, float roughnessT, float roughnessB)
{
    float f = TdotH * TdotH / (roughnessT * roughnessT) + BdotH * BdotH / (roughnessB * roughnessB) + NdotH * NdotH;
    return 1.0 / (roughnessT * roughnessB * f * f);
}

// Heitz 2014, "Understanding the Masking-Shadowing Function in Microfacet-Based BRDFs"
float Vis_SmithJointAniso(float at, float ab, float ToV, float BoV,
float ToL, float BoL, float NoV, float NoL)
{
    // lambdaV can be pre-computed for all the lights, it should be moved out of this function
    float lambdaV = NoL * length(float3(at * ToV, ab * BoV, NoL));
    float lambdaL = NoV * length(float3(at * ToL, ab * BoL, NoV));
    // rcp : 计算一个快速的、近似的、每个分量的倒数
    float v = 0.5 * rcp(lambdaV + lambdaL);
    return saturate(v);
}

float V_SmithJointGGXAnisotropic(float TdotV, float BdotV, float NdotV, float TdotL, float BdotL, float NdotL, float roughnessT, float roughnessB)
{
    float aT = roughnessT;
    float aT2 = aT * aT;
    float aB = roughnessB;
    float aB2 = aB * aB;
    float lambdaV = NdotL * sqrt(aT2 * TdotV * TdotV + aB2 * BdotV * BdotV + NdotV * NdotV);
    float lambdaL = NdotV * sqrt(aT2 * TdotL * TdotL + aB2 * BdotL * BdotL + NdotL * NdotL);
    return 0.5 / (lambdaV + lambdaL);
}


float3 Diffuse_Lambert( float3 DiffuseColor )
{
	return DiffuseColor * UNITY_INV_PI;
}
// inline float APP_DisneyDiffuse(half NdotV, half NdotL, half LdotH, half roughness)
// {
//     half fd90 = 0.5 + 2 * LdotH * LdotH * roughness;
//     // Two schlick fresnel term
//     half lightScatter = (1 + (fd90 - 1) * Pow5(1 - NdotL));
//     half viewScatter = (1 + (fd90 - 1) * Pow5(1 - NdotV));
//     return lightScatter * viewScatter;
// }

// [Burley 2012, "Physically-Based Shading at Disney"]
float3 Diffuse_Burley(float3 DiffuseColor, float Roughness, float NoV, float NoL, float VoH)
{
    float FD90 = 0.5 + 2 * VoH * VoH * Roughness;
    float FdV = 1 + (FD90 - 1) * Pow5(1 - NoV);
    float FdL = 1 + (FD90 - 1) * Pow5(1 - NoL);
    return DiffuseColor * FdV * FdL;
}

// GGX / Trowbridge-Reitz
// [Walter et al. 2007, "Microfacet models for refraction through rough surfaces"]
inline float D_GGX(float NdotH, float roughness)
{
    float a2 = roughness * roughness;
    float NdotH2 = NdotH * NdotH;
    float denom = (NdotH2 * (a2 - 1.0) + 1.0);
    denom = UNITY_PI * denom * denom;
    denom = max(denom, 0.0000001); //防止分母为0
    return a2 / denom;
}


// Appoximation of joint Smith term for GGX
// [Heitz 2014, "Understanding the Masking-Shadowing Function in Microfacet-Based BRDFs"]
float Vis_SmithJointApprox(float roughness, float NoV, float NoL)
{
    float a = roughness;
    float Vis_SmithV = NoL * (NoV * (1 - a) + a);
    float Vis_SmithL = NoV * (NoL * (1 - a) + a);
    return 0.5 * rcp(Vis_SmithV + Vis_SmithL);
}



// F 菲涅尔函数
inline float3 F_FrenelSchlick(float HdotV, float3 F0)
{
    return F0 + (1 - F0) * pow(1 - HdotV, 5.0);
}

inline float3 Fresnel_UE4(float HdotV, float3 F0)
{
    return F0 + (1 - F0) * pow(2, (-5.55473 * HdotV - 6.98316) * HdotV);
}

// 计算菲涅耳效应时纳入表面粗糙度(roughness)
float3 FresnelSchlickRoughness(float NdotV, float3 F0, float roughness)
{
    float3 oneMinusRoughness = 1.0 - roughness;
    return F0 + (max(oneMinusRoughness, F0) - F0) * pow(1.0 - NdotV, 5.0);
}

// G 几何遮蔽函数
float GeometrySchlickGGX(float NdotV, float roughness)
{
    float a = (roughness + 1.0) / 2;
    float k = a * a / 4;
    float nom = NdotV;
    float denom = NdotV * (1.0 - k) + k;
    denom = max(denom, 0.0000001); //防止分母为0
    return nom / denom;
}
float G_GeometrySmith(float NdotV, float NdotL, float roughness)
{
    NdotV = max(NdotV, 0.0);
    NdotL = max(NdotL, 0.0);
    float ggx1 = GeometrySchlickGGX(NdotV, roughness);
    float ggx2 = GeometrySchlickGGX(NdotL, roughness);
    return ggx1 * ggx2;
}

float3 SpecularGGX(float Roughness, float Anisotropy, float3 SpecularColor, BxDFContext Context, float3 F0, float Atten)
{
    float roughnessT, roughnessB;
    ConvertAnisotropyToRoughness(Roughness, Anisotropy, roughnessT, roughnessB);
    roughnessT = ClampRoughnessForAnalyticalLights(roughnessT);
    roughnessB = ClampRoughnessForAnalyticalLights(roughnessB);
    float D = D_GGXAnisotropic(Context.TdotH, Context.BdotH, Context.NdotH, roughnessT, roughnessB);
    float Vis = V_SmithJointGGXAnisotropic(Context.TdotV, Context.BdotV, abs(Context.NdotV), Context.TdotL, Context.BdotL, saturate(Context.NdotL), roughnessT, roughnessB);

    // UE4 Anisotropic
    // float ax, ay;
    // GetAnisotropicRoughness(Roughness, Anisotropy, ax, ay);
    // float3 Vis = Vis_SmithJointAniso(ax, ay, Context.TdotL, Context.BdotV, Context.TdotL, Context.BdotL, Context.NdotV, saturate(Context.NdotL));
    // float3 D = D_GGXAniso(ax, ay, Context.NdotH, Context.TdotH, Context.BdotH) * Atten;

    float3 F = F_FrenelSchlick(Context.VdotH, F0);
    // float3 F = F_Schlick(SpecularColor, Context.VoH);
    return (D * Vis) * F;
}
float3 SpecularGGX(float Roughness, float3 SpecularColor, BxDFContext Context, float3 F0, float Atten)
{
    float D = D_GGX(Context.NdotH, Roughness);
    float Vis = Vis_SmithJointApprox(Roughness, Context.NdotV, saturate(Context.NdotL));
    float3 F = F_FrenelSchlick(Context.VdotH, F0);
    // float3 F = F_Schlick(SpecularColor, Context.VoH);
    return (D * Vis) * F;
}


//UE4 Black Ops II modify version
float2 EnvBRDFApprox(float Roughness, float NoV)
{
    const float4 c0 = {
        - 1, -0.0275, -0.572, 0.022
    };
    const float4 c1 = {
        1, 0.0425, 1.04, -0.04
    };
    float4 r = Roughness * c0 + c1;
    float a004 = min(r.x * r.x, exp2(-9.28 * NoV)) * r.x + r.y;
    float2 AB = float2(-1.04, 1.04) * a004 + r.zw;
    return AB;
}



// ================================== Spherical Gaussian SSS (球面高斯 次表面散射) ==================================
struct FSphericalGaussian
{
    // float3 Axis;
    float Sharpness;
    float Amplitude;
};

FSphericalGaussian MakeNormalizedSG(half spharpness)
{
    FSphericalGaussian SG;
    // SG.Axis = L;
    SG.Sharpness = spharpness;
    SG.Amplitude = SG.Sharpness / ((2 * UNITY_PI) * (1 - exp(-2 * SG.Sharpness)));
    return SG;
}

float DotCosineLobe(FSphericalGaussian G, float NdotL)
{
    // const float muDotN = dot(G.Axis, N);
    const float muDotN = NdotL;
    const float c0 = 0.36;
    const float c1 = 0.25 / c0;
    float eml = exp(-G.Sharpness);
    float em2l = eml * eml;
    float rl = rcp(G.Sharpness);
    float scale = 1.0f + 2.0f * em2l - rl;
    float bias = (eml - em2l) * rl - em2l;

    float x = sqrt(1.0 - scale);
    float x0 = c0 * muDotN;
    float x1 = c1 * x;
    float n = x0 + x1;
    // float y = (abs(x0) <= x1)? n * n / x : saturate(muDotN);
    float y1 = n * n / x;
    float y2 = saturate(muDotN);
    float y = lerp(y2,y1,  step(abs(x0), x1));
    return scale * y + bias;
}

half3 SGDiffuseLighting(float NdotL, half3 scatterAmt,float scatterPower)
{
    FSphericalGaussian redKernel = MakeNormalizedSG(1 / max(scatterAmt.x, 0.00001f));
    FSphericalGaussian greenKernel = MakeNormalizedSG(1 / max(scatterAmt.y, 0.00001f));
    FSphericalGaussian blueKernel = MakeNormalizedSG(1 / max(scatterAmt.z, 0.00001f));
    half3 diffuse = half3(DotCosineLobe(redKernel, NdotL), DotCosineLobe(greenKernel, NdotL), DotCosineLobe(blueKernel, NdotL));

    diffuse *= scatterPower;
    // tone mapping
    half3 x = max(0, (diffuse - 0.004f));
    diffuse = (x * (6.2 * x + 0.5)) / (x * (6.2 * x + 1.7) + 0.06);
    return diffuse;
}

#endif
