#ifndef LCL_LIGHTING_INCLUDED
#define LCL_LIGHTING_INCLUDED

#include "Lighting.cginc"
#include "AutoLight.cginc"
#include "BRDF.cginc"
// ---------------- Properties ----------------

sampler2D _MainTex;
float4 _MainTex_ST;

half4 _DiffuseColor;
half3 _SpecularColor;

sampler2D _NormalTex;
half _NormalScale;

// R - Roughness , G - Metallic , B - Emission, A - AO
sampler2D _MaskTex;

half _Roughness;
half _Metallic;
half _OcclusionPower;

// sampler2D _EmissionTex;
half3 _EmissionColor;


half3 _RimColor;
float _RimWidth;
float _RimIntensity;
float _RimSmoothness;

//Anisotropy
float _Anisotropy;

// SSS
#if defined(SSS_ON)
    half3 _ScatterAmt;
    float _ScatterPower;
#endif


struct VertexInput
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float4 tangent : TANGENT;
    float4 texcoord : TEXCOORD0;
};

struct Varyings
{
    float4 position : SV_POSITION;
    float2 uv_MainTex : TEXCOORD0;
    float3 worldNormal : TEXCOORD1;
    float3 worldPos : TEXCOORD2;
    float3 worldView : TEXCOORD3;
    UNITY_SHADOW_COORDS(4)
    float3x3 tbnMtrix : float3x3;
};


struct LcLSurfaceData
{
    half3 Albedo;
    float3 Normal;
    half3 Emission;
    half Roughness;
    half Metallic;
    half Scatter;
    half Occlusion;
    half Alpha;
    half3 SpecularColor;

    #if defined(ANISO_ON)
        float3 Binormal;
        float3 Tangent;
        half Anisotropy;
    #endif
};


struct LcLInputData
{
    UnityLight light;

    float3 worldPos;
    half3 worldView;
    half atten;
    half3 ambient;
    
    float4 probeHDR[1];

    half3 NdotV;
    float3 F0;
    float Roughness;
    half3 ReflUVW;
    float F90;
};

inline half3 StylizedFresnel(half NdotV, half rimWidth, float rimIntensity, half smoothness)
{
    half revertNdotV = 1 - NdotV;
    float threshold = 1 - rimWidth;
    float3 rim = smoothstep(threshold - smoothness, threshold + smoothness, revertNdotV) * rimIntensity;
    return rim * _RimColor;
}


Varyings LitPassVertex(VertexInput v)
{
    Varyings o;
    UNITY_INITIALIZE_OUTPUT(Varyings, o);

    o.position = UnityObjectToClipPos(v.vertex);
    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
    o.uv_MainTex = TRANSFORM_TEX(v.texcoord, _MainTex);

    float3 worldNormal = normalize(mul(v.normal, (float3x3) unity_WorldToObject));
    float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
    float3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;
    o.tbnMtrix = float3x3(worldTangent, worldBinormal, worldNormal);
    o.worldNormal = worldNormal;

    o.worldView = normalize(UnityWorldSpaceViewDir(o.worldPos));
    return o;
};


LcLSurfaceData InitSurfaceData(Varyings IN)
{
    LcLSurfaceData o;
    UNITY_INITIALIZE_OUTPUT(LcLSurfaceData, o);

    // Albedo
    half4 albedo = tex2D(_MainTex, IN.uv_MainTex) * _DiffuseColor;
    o.Albedo = albedo.rgb;
    o.Alpha = albedo.a;

    // Normal
    float4 tangentNormal = float4(0.5, 0.5, 1, 1);
    #ifdef _NORMALMAP
        tangentNormal = tex2D(_NormalTex, IN.uv_MainTex);
    #endif

    float3 normalWS = UnpackNormal(tangentNormal);
    normalWS.xy *= _NormalScale;
    o.Normal = normalize(half3(mul(normalWS, IN.tbnMtrix)));
    

    half4 mask = tex2D(_MaskTex, IN.uv_MainTex);
    o.Roughness = mask.r * _Roughness;
    o.Metallic = mask.g * _Metallic;
    o.Occlusion = LerpOneTo(mask.a, _OcclusionPower);

    o.SpecularColor = _SpecularColor;


    #if defined(ANISO_ON)
        o.Anisotropy = _Anisotropy;
        o.Tangent = IN.tbnMtrix[0];
        o.Binormal = IN.tbnMtrix[1];
    #endif

    // Emission
    #ifdef EMISSION_ON
        o.Emission = _EmissionColor * mask.b;
    #endif
    return o;
}

UnityLight AppMainLight()
{
    UnityLight l;

    l.color = _LightColor0.rgb;
    l.dir = _WorldSpaceLightPos0.xyz;
    return l;
}

inline LcLInputData InitInputData(Varyings i, LcLSurfaceData s)
{
    LcLInputData d;
    d.light = AppMainLight();

    d.worldPos = i.worldPos;
    d.worldView = i.worldView;
    d.ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
    d.probeHDR[0] = unity_SpecCube0_HDR;
    d.atten = SHADOW_ATTENUATION(i);

    //
    d.NdotV = dot(i.worldNormal, i.worldView);
    d.F0 = lerp(0.04, s.Albedo, s.Metallic);
    d.Roughness = max(PerceptualRoughnessToRoughness(s.Roughness), 0.002);
    d.ReflUVW = reflect(-i.worldView, i.worldNormal);
    return d;
}


// ----------------------------- 全局光照 ---------------------------------------------
inline UnityGI LcLFragmentGI(LcLSurfaceData s, LcLInputData giInput)
{
    UnityGI gi;
    ResetUnityGI(gi);
    gi.light = giInput.light;

    float NdotV = saturate(giInput.NdotV);
    half3 albedo = s.Albedo;
    float metallic = s.Metallic;
    half roughness = giInput.Roughness;
    float3 F0 = giInput.F0;
    // half ao = s.Occlusion;
    
    // 系数
    float3 ks_indirect = FresnelSchlickRoughness(NdotV, F0, roughness);
    float3 kd_indirect = 1.0 - ks_indirect;
    kd_indirect *= (1 - metallic);

    // ---------------Diffuse---------------
    // 球谐函数
    float3 irradianceSH = ShadeSH9(float4(s.Normal, 1));
    float3 diffuseIndirect = kd_indirect * irradianceSH * albedo;

    // diffuseIndirect /= UNITY_PI;

    // ---------------Specular---------------
    // ApproximateSpecularIBL
    // 积分拆分成两部分：Li*NdotL 和 DFG/(4*NdotL*NdotV)

    // 1.Li*NdotL
    // 预过滤环境贴图方式
    half mip = perceptualRoughnessToMipmapLevel(roughness);
    half4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, giInput.ReflUVW, mip);
    float3 prefilteredColor = DecodeHDR(rgbm, unity_SpecCube0_HDR);

    // rgbm = texCUBE(_ReflectionMap, giInput.ReflUVW);
    // float3 prefilteredColor = DecodeHDR(rgbm, unity_SpecCube0_HDR);

    //2.DFG/(4*NdotL*NdotV)：
    //数值拟合方式计算：
    float2 envBRDF = EnvBRDFApprox(roughness, NdotV);

    // 结合两部分
    float3 specularIndirect = prefilteredColor * (ks_indirect * envBRDF.x + envBRDF.y);
    gi.indirect.diffuse = diffuseIndirect;
    gi.indirect.specular = specularIndirect;
    return gi;
}

half4 LcLFragmentPBR(LcLSurfaceData s, LcLInputData giInput, UnityGI gi)
{
    float3 L = gi.light.dir;
    float3 V = giInput.worldView;
    float3 N = s.Normal;
    float3 H = normalize(L + V);

    BxDFContext Context;

    #if defined(ANISO_ON)
        float3 B = s.Binormal;
        float3 T = s.Tangent;
        Init(Context, N, V, L, T, B);
    #else
        Init(Context, N, V, L);
    #endif

    float NdotV = saturate(Context.NdotV);
    float NdotL = saturate(Context.NdotL);
    float NdotH = saturate(Context.NdotH);
    float HdotV = saturate(Context.VdotH);
    float LdotH = saturate(Context.NdotL);

    half3 albedo = s.Albedo;
    half ao = s.Occlusion;
    half atten = giInput.atten;
    half metallic = s.Metallic;
    half scatter = s.Scatter;
    half perceptualRoughness = s.Roughness;
    float roughness = giInput.Roughness;
    float3 F0 = giInput.F0;

    // ================================ Diffuse BRDF ================================
    // float diffuseTerm = DisneyDiffuse(NdotV, NdotL, LdotH, perceptualRoughness) * NdotL;

    float3 diffuseBRDF;
    #if defined(SSS_ON)
        // 次表面散射
        diffuseBRDF = SGDiffuseLighting(Context.NdotL, _ScatterAmt, _ScatterPower) * atten * albedo;
        diffuseBRDF *= UNITY_INV_PI;
    #else
        diffuseBRDF = Diffuse_Burley(albedo, perceptualRoughness, Context.NdotV, Context.NdotL, Context.VdotH) * NdotL * atten;
    #endif

    // return half4(diffuseBRDF, 1);

    // ================================ Specular BRDF ================================
    float3 specularBRDF;
    #if defined(ANISO_ON)
        // 各项异性
        specularBRDF = SpecularGGX(roughness, s.Anisotropy, _SpecularColor, Context, F0, atten) * _SpecularColor;
    #else
        specularBRDF = SpecularGGX(roughness, _SpecularColor, Context, F0, atten) * _SpecularColor;
    #endif
    // return half4(specularBRDF,1);
    
    float3 F = F_FrenelSchlick(HdotV, F0);
    // 反射方程
    float3 ks = F;
    float3 kd = (1.0 - ks) * (1 - metallic);
    float3 directLight = (diffuseBRDF * kd + specularBRDF * NdotL) * gi.light.color;
    // return half4(directLight,1);


    // ================================ 间接光BRDF ================================
    float3 indirectLight = (gi.indirect.diffuse + gi.indirect.specular) * ao;

    float4 finalColor;
    finalColor.rgb = directLight + indirectLight;

    // Emission
    #ifdef EMISSION_ON
        finalColor.rgb += s.Emission;
    #endif

    #if defined(RIM_ON)
        // 风格化菲涅尔边缘光
        finalColor.rgb += StylizedFresnel(NdotV, _RimWidth, _RimIntensity, _RimSmoothness);
    #endif

    finalColor.a = s.Alpha;
    return finalColor;
}
//
half4 LitPassFragment(Varyings IN) : SV_TARGET
{
    LcLSurfaceData surfaceData = InitSurfaceData(IN);

    LcLInputData inputData = InitInputData(IN, surfaceData);
    UnityGI gi = LcLFragmentGI(surfaceData, inputData);

    half4 color = LcLFragmentPBR(surfaceData, inputData, gi);

    // color.rgb = MixFog(color.rgb, inputData.fogCoord);
    return color;
};

#endif
