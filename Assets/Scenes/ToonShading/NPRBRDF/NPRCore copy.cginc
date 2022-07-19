#ifndef NPR_INCLUDED
#define NPR_INCLUDED

#include "Lighting.cginc"
#include "AutoLight.cginc"
#include "BRDF.cginc"
// ---------------- Properties ----------------

sampler2D _MainTex;
float4 _MainTex_ST;

half4 _DiffuseColor;
half _DiffuseSmooth;

half3 _SpecularColor;
half _SpecularThreshold;
half _SpecularSmoothness;
float _SpecBlend;

sampler2D _NormalTex;
half _NormalScale;

sampler2D _OcclusionTex;

half _Roughness;
half _Metallic;
half _OcclusionPower;

// sampler2D _EmissionTex;
half3 _EmissionColor;

half3 _SSSColor;
float _SSSDistortion;
float _SSSPower;
float _SSSScale;


float _SSSFrontLighting;
float _SSSBackLighting;

float _FillLightingPower;
float _FillLightingScale;

float _FsssPower;
float _BsssPower;
float _BsssScale;


float _RampSmoothness;
float _RampThreshold;

// NPR
sampler2D _RampTex;
half4 _HighlightColor;
half4 _ShadowColor;

// Rim
half3 _RimColor;
float _RimWidth;
float _RimIntensity;
float _RimSmoothness;

struct VertexInput
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float4 tangent : TANGENT;
    float4 texcoord : TEXCOORD0;
};

struct VertexOutput
{
    float4 position : SV_POSITION;
    float2 uv_MainTex : TEXCOORD0;
    float3 worldNormal : TEXCOORD1;
    float3 worldPos : TEXCOORD2;
    UNITY_SHADOW_COORDS(4)
    float3x3 tbnMtrix : float3x3;
};


struct NPRSurfaceOutput
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
};


struct GIInputData
{
    UnityLight light;

    half3 worldView;
    half atten;
    half3 ambient;
    
    // HDR cubemap properties, use to decompress HDR texture
    float4 probeHDR[1];

    half3 NdotV;
    half3 F0;
    half3 ReflUVW;
    float Roughness;
    float F90;
};


inline half StylizedSpecular(half specularTerm, half specSmoothness)
{
    return smoothstep(specSmoothness * 0.5, 0.5 + specSmoothness * 0.5, specularTerm);
}

inline half3 StylizedFresnel(half NdotV, half rimWidth, float rimIntensity, half smoothness)
{
    half revertNdotV = 1 - NdotV;
    float threshold = 1 - rimWidth;
    float3 rim = smoothstep(threshold - smoothness, threshold + smoothness, revertNdotV) * rimIntensity;
    return rim * _RimColor;
}


VertexOutput LitPassVertex(VertexInput v)
{
    VertexOutput o;
    UNITY_INITIALIZE_OUTPUT(VertexOutput, o);

    o.position = UnityObjectToClipPos(v.vertex);
    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
    o.uv_MainTex = TRANSFORM_TEX(v.texcoord, _MainTex);

    float3 worldNormal = normalize(mul(v.normal, (float3x3) unity_WorldToObject));
    float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
    float3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;
    o.tbnMtrix = float3x3(worldTangent, worldBinormal, worldNormal);
    o.worldNormal = worldNormal;
    return o;
};


NPRSurfaceOutput InitSurfaceData(VertexOutput IN)
{
    NPRSurfaceOutput o;
    UNITY_INITIALIZE_OUTPUT(NPRSurfaceOutput, o);

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
    
    half4 mask = tex2D(_OcclusionTex, IN.uv_MainTex);
    o.Roughness = _Roughness;
    o.Metallic = _Metallic;
    o.Occlusion = mask.r * _OcclusionPower;
    o.SpecularColor = _SpecularColor;
    o.Emission = 0;
    return o;
}

UnityLight AppMainLight()
{
    UnityLight l;

    l.color = _LightColor0.rgb;
    l.dir = _WorldSpaceLightPos0.xyz;
    return l;
}

inline GIInputData InitGIInput(VertexOutput i, NPRSurfaceOutput s)
{
    GIInputData d;
    d.light = AppMainLight();
    d.worldView = normalize(UnityWorldSpaceViewDir(i.worldPos));
    d.ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
    d.probeHDR[0] = unity_SpecCube0_HDR;
    d.atten = SHADOW_ATTENUATION(i);

    //
    d.NdotV = dot(i.worldNormal, d.worldView);
    d.F0 = lerp(0.04, s.Albedo, s.Metallic);
    d.Roughness = max(PerceptualRoughnessToRoughness(s.Roughness), 0.002);
    d.ReflUVW = reflect(-d.worldView, i.worldNormal);
    return d;
}


// -----------------------------
inline UnityGI AppFragmentGI(NPRSurfaceOutput s, GIInputData giInput)
{
    UnityGI gi;
    ResetUnityGI(gi);
    gi.light = giInput.light;

    float NdotV = saturate(giInput.NdotV);
    half3 albedo = s.Albedo;
    float metallic = s.Metallic;
    half roughness = giInput.Roughness;
    float3 F0 = giInput.F0;
    
    // 系数
    float3 ks_indirect = FresnelSchlickRoughness(NdotV, F0, roughness);
    float3 kd_indirect = 1.0 - ks_indirect;
    kd_indirect *= (1 - metallic);

    // ---------------Diffuse---------------
    // 球谐函数
    float3 irradianceSH = ShadeSH9(float4(s.Normal, 1));
    float3 diffuseIndirect = kd_indirect * irradianceSH * albedo;

    diffuseIndirect /= UNITY_PI;

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


inline half SmoothValue(half NdotL, half threshold, half smoothness)
{
    half minValue = saturate(threshold - smoothness * 0.5);
    half maxValue = saturate(threshold + smoothness * 0.5);
    return smoothstep(minValue, maxValue, NdotL);
}


inline float SubsurfaceScattering(float3 viewDir, float3 lightDir, float3 normalDir, float distortion, float power, float scale)
{
    float3 H = (lightDir + normalDir * distortion);
    float I = pow(saturate(dot(viewDir, -H)), power) * scale;
    return I;
}


half3 ColorRamp(float fac, half2 mulbias, half3 color1, half3 color2)
{
    fac = clamp(fac * mulbias.x + mulbias.y, 0.0, 1.0);
    half3 outcol = lerp(color1, color2, fac);
    return outcol;
}

half3 ColorLayer(float3 NdotL, half smoothness, half threshold1, half threshold2, half3 color1, half3 color2, half3 color3)
{
    float NdotL2 = NdotL + 1;
    NdotL2 = SmoothValue(NdotL2, threshold1, smoothness);
    float3 middleC = lerp(color1, color2, NdotL2);

    NdotL = SmoothValue(NdotL, threshold2, smoothness);
    float3 heightC = lerp(color2, color3, NdotL);

    return lerp(middleC, heightC, 1 - step(NdotL, 0));
}

float Remap(float In, float2 InMinMax, float2 OutMinMax)
{
    return OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}

half3 SSSShading(float3 NdotL, float3 V, float3 L, float3 N)
{
    half NdL = NdotL;
    half InvNdL = -NdotL;
    
    float frontLayer = step(0, NdL);
    // return frontLayer;

    float backLayer = 1 - frontLayer;
    const half2 mulbias = half2(0.8, 0);
    // front
    half3 frontRamp = ColorRamp(NdL, mulbias, 1, 0);
    frontLayer = pow(frontLayer, _FillLightingPower) * _SSSFrontLighting;
    frontRamp *= frontLayer;
    frontRamp = pow(frontRamp, _FillLightingPower) * _FillLightingScale;

    // back
    half3 backRamp = ColorRamp(InvNdL, mulbias, 1, 0);
    backLayer = pow(backLayer, _FillLightingPower) * _SSSBackLighting;
    backRamp *= backLayer;
    backRamp = pow(backRamp, _FillLightingPower) * _FillLightingScale;

    float3 sss = SubsurfaceScattering(V, L, N, _SSSDistortion, _SSSPower, _SSSScale);
    sss = saturate(sss);
    sss = (backRamp + frontRamp + sss) * _SSSColor;
    return sss;
}

half4 NPR_BRDF_Shading(NPRSurfaceOutput s, GIInputData giInput, UnityGI gi)
{
    float3 L = gi.light.dir;
    float3 V = giInput.worldView;
    float3 N = s.Normal;

    BxDFContext Context;
    Init(Context, N, V, L);

    float NdotV = saturate(Context.NdotV);
    float NdotL = saturate(Context.NdotL);
    float NdotH = saturate(Context.NdotH);
    float HdotV = saturate(Context.VdotH);
    half3 lightColor = giInput.light.color;
    half3 albedo = s.Albedo;
    half ao = s.Occlusion;
    half atten = giInput.atten;
    half metallic = s.Metallic;
    half scatter = s.Scatter;
    half perceptualRoughness = s.Roughness;
    float roughness = giInput.Roughness;
    float3 F0 = giInput.F0;

    // --------------------------------- Diffuse ---------------------------------
    // float diffuseBRDF = Diffuse_Burley(albedo, perceptualRoughness, Context.NdotV, Context.NdotL, Context.VdotH) * NdotL ;
    float remapNL = Remap(Context.NdotL, float2(0, 3), float2(0, 1));
    float3 colorLayer = ColorLayer(remapNL, 0.02, 0.5, 0, 0, 0.3, 0.6);
    float3 colorLayer2 = ColorLayer(remapNL, 0.8, 0.5, 0, 0, 0.3, 0.8);
    float3 diffuse = lerp(colorLayer, colorLayer2, _DiffuseSmooth);
    float3 diffuseBRDF = diffuse * _DiffuseColor * albedo * lightColor;

    // return half4(colorLayer, 1);
    // --------------------------------- SSS ---------------------------------
    float3 sss = SSSShading(Context.NdotL, V, L, N) * albedo;
    // return half4(sss, 1);
    diffuseBRDF = diffuseBRDF + sss;
    // return half4(diffuseBRDF, 1);

    // --------------------------------- Specular ---------------------------------
    float3 specularBRDF = SpecularGGX(roughness, _SpecularColor, Context, F0, atten);
    half r = sqrt(roughness) * 0.85;
    r += 1e-4h;
    specularBRDF = lerp(specularBRDF, StylizedSpecular(specularBRDF, _SpecularSmoothness) * (1 / r), _SpecBlend);

    // 反射方程
    float3 F = F_FrenelSchlick(HdotV, F0);
    float3 ks = F;
    float3 kd = (1.0 - ks) * (1 - metallic);
    float3 directLight = (diffuseBRDF * kd + specularBRDF * diffuse) * gi.light.color * ao;
    float3 H = normalize(L + V);

    // --------------------------------- 间接光BRDF ---------------------------------
    float3 indirectLight = (gi.indirect.diffuse + gi.indirect.specular) * ao;

    float4 finalColor;
    finalColor.rgb = directLight + indirectLight;
    // Emission
    #ifdef _EMISSIONGROUP_ON
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
half4 LitPassFragment(VertexOutput IN) : SV_TARGET
{
    NPRSurfaceOutput s = InitSurfaceData(IN);

    GIInputData giInput = InitGIInput(IN, s);
    UnityGI gi = AppFragmentGI(s, giInput);

    // NPR - PBR
    half4 nprColor = NPR_BRDF_Shading(s, giInput, gi);
    half4 finalColor;
    finalColor.rgb = nprColor.rgb;
    finalColor.a = nprColor.a;
    return finalColor;
};

#endif
