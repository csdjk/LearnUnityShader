#include "Lighting.cginc"
#include "AutoLight.cginc"

// ---------------- Properties ----------------
sampler2D _MainTex;
float4 _MainTex_ST;

fixed4 _DiffuseColor;

sampler2D _SpecularTex;
fixed3 _SpecularColor;

sampler2D _MetallicTex;
half _Metallic;

sampler2D _RoughnessTex;
half _Roughness;

sampler2D _AOTex;
half _AoPower;

sampler2D _EmissionTex;
fixed3 _EmissionColor;

samplerCUBE _IrradianceCubemap;

sampler2D _NormalTex;
fixed _NormalScale;


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
    float3 worldView : TEXCOORD3;
    UNITY_SHADOW_COORDS(4)
    float3x3 tbnMtrix : float3x3;
};


struct LclSurfaceOutput
{
    fixed3 Albedo;
    float3 Normal;
    fixed3 Emission;
    fixed Metallic;
    half Roughness;
    half Occlusion;
    fixed Alpha;
    fixed3 SpecularColor;
};


struct LclUnityGIInput
{
    UnityLight light; // pixel light, sent from the engine

    float3 worldPos;
    half3 worldView;
    half atten;
    half3 ambient;
    
    // HDR cubemap properties, use to decompress HDR texture
    float4 probeHDR[1];


    half3 NdotV;
    float F0;
    float Roughness;
    half3 ReflUVW;
};

struct LclGlossyEnvironmentData
{
    half3 NdotV;
    float F0;
    float Roughness;
    half3 ReflUVW;
};


float3 DisneyDiffuse(half NdotV, half NdotL, half LdotH, half roughness, half3 baseColor)
{
    half fd90 = 0.5 + 2 * LdotH * LdotH * roughness;
    // Two schlick fresnel term
    half lightScatter = (1 + (fd90 - 1) * Pow5(1 - NdotL));
    half viewScatter = (1 + (fd90 - 1) * Pow5(1 - NdotV));
    return baseColor * (lightScatter * viewScatter);
}

// D 法线分布函数
float D_GGX_TR(float NdotH, float roughness)
{
    float a2 = roughness * roughness;
    float NdotH2 = NdotH * NdotH;
    float denom = (NdotH2 * (a2 - 1.0) + 1.0);
    denom = UNITY_PI * denom * denom;
    denom = max(denom, 0.0000001); //防止分母为0
    return a2 / denom;
}
// F 菲涅尔函数
float3 F_FrenelSchlick(float HdotV, float3 F0)
{
    return F0 + (1 - F0) * pow(1 - HdotV, 5.0);
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


//UE4 Black Ops II modify version
float2 EnvBRDFApprox(float Roughness, float NoV)
{
    // [ Lazarov 2013, "Getting More Physical in Call of Duty: Black Ops II" ]
    // Adaptation to fit our G term.
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

    o.worldView = normalize(UnityWorldSpaceViewDir(o.worldPos));
    return o;
};


LclSurfaceOutput LclSurf(VertexOutput IN)
{
    LclSurfaceOutput o;
    UNITY_INITIALIZE_OUTPUT(LclSurfaceOutput, o);

    // Albedo
    fixed4 albedo = tex2D(_MainTex, IN.uv_MainTex) * _DiffuseColor;
    o.Albedo = albedo.rgb;
    o.Alpha = albedo.a;

    // Normal
    float4 tangentNormal = tex2D(_NormalTex, IN.uv_MainTex);
    float3 normalWS = UnpackNormal(tangentNormal);
    normalWS.xy *= _NormalScale;
    o.Normal = normalize(half3(mul(normalWS, IN.tbnMtrix)));

    // Emission
    #ifdef _EMISSIONGROUP_ON
        o.Emission = tex2D(_EmissionTex, IN.uv_MainTex) * _EmissionColor;
    #endif
    // Metallic
    o.Metallic = tex2D(_MetallicTex, IN.uv_MainTex).r * _Metallic;

    // Roughness
    o.Roughness = tex2D(_RoughnessTex, IN.uv_MainTex).r * _Roughness;

    // Occlusion
    fixed ao = tex2D(_AOTex, IN.uv_MainTex).r;
    o.Occlusion = LerpOneTo(ao, _AoPower);

    // SpecularColor
    o.SpecularColor = _SpecularColor;

    return o;
}

UnityLight LclMainLight()
{
    UnityLight l;

    l.color = _LightColor0.rgb;
    l.dir = _WorldSpaceLightPos0.xyz;
    return l;
}

inline LclUnityGIInput LclGetGIInput(VertexOutput i, LclSurfaceOutput s)
{
    LclUnityGIInput d;
    d.light = LclMainLight();

    d.worldPos = i.worldPos;
    d.worldView = i.worldView;
    d.ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
    d.probeHDR[0] = unity_SpecCube0_HDR;
    d.atten = SHADOW_ATTENUATION(i);

    //
    d.NdotV = max(dot(i.worldNormal, i.worldView), 0);
    d.F0 = lerp(0.04, s.Albedo, s.Metallic);
    d.Roughness = max(PerceptualRoughnessToRoughness(s.Roughness), 0.002);
    d.ReflUVW = reflect(-i.worldView, i.worldNormal);
    return d;
}


inline UnityGI LclFragmentGI(LclSurfaceOutput s, LclUnityGIInput giInput)
{
    UnityGI gi;
    ResetUnityGI(gi);
    gi.light = giInput.light;

    float NdotV = giInput.NdotV;
    half3 albedo = s.Albedo;
    float metallic = s.Metallic;
    half roughness = giInput.Roughness;
    float F0 = giInput.F0;
    // half ao = s.Occlusion;
    
    // 系数
    float3 ks_indirect = FresnelSchlickRoughness(NdotV, F0, roughness);
    float3 kd_indirect = 1.0 - ks_indirect;
    kd_indirect *= (1 - metallic);

    // ---------------Diffuse---------------
    // 球谐函数
    float3 irradianceSH = ShadeSH9(float4(s.Normal, 1));
    float3 diffuseIndirect = kd_indirect * irradianceSH * albedo;

    //  diffuseIndirect = roughness;

    // 环境cubemap
    // float3 irradiance = texCUBE(_IrradianceCubemap,N).rgb;
    // float3 diffuseIndirect = kd_indirect * irradiance * albedo;
    
    // diffuseIndirect /= UNITY_PI;

    // ---------------Specular---------------
    // 积分拆分成两部分：Li*NdotL 和 DFG/(4*NdotL*NdotV)

    // 1.Li*NdotL
    // 预过滤环境贴图方式
    half mip = perceptualRoughnessToMipmapLevel(roughness);
    half4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, giInput.ReflUVW, mip);
    //unity_SpecCube0_HDR储存的是 最近的ReflectionProbe
    float3 prefilteredColor = DecodeHDR(rgbm, unity_SpecCube0_HDR);

    //2.DFG/(4*NdotL*NdotV)：

    // 2.1 用BRDF积分贴图方式：2D 查找纹理(LUT)
    // 查找纹理的时候，我们以 BRDF 的输入NdotV作为横坐标，以粗糙度(roughness)作为纵坐标。
    // float2 envBRDF = tex2D(_BRDFLUTTex, float2(NdotV, roughness)).rg;

    // 2.2 数值拟合方式计算：
    float2 envBRDF = EnvBRDFApprox(roughness, NdotV);

    // 最后结合两部分
    float3 specularIndirect = prefilteredColor * (ks_indirect * envBRDF.x + envBRDF.y);


    //
    gi.indirect.diffuse = diffuseIndirect;
    gi.indirect.specular = specularIndirect;
    return gi;
}

half4 LCL_BRDF_Unity_PBS(LclSurfaceOutput s, LclUnityGIInput giInput, UnityGI gi)
{

    float3 L = gi.light.dir;
    float3 V = giInput.worldView;
    float3 N = s.Normal;
    float3 H = normalize(L + V);

    float NdotV = giInput.NdotV;
    float NdotL = max(dot(N, L), 0);
    float NdotH = max(dot(N, H), 0);
    float HdotV = max(dot(H, V), 0);
    float LdotH = max(dot(L, H), 0);


    half3 albedo = s.Albedo;
    half ao = s.Occlusion;
    half atten = giInput.atten;
    half metallic = s.Metallic;
    half perceptualRoughness = s.Roughness;
    float roughness = giInput.Roughness;
    float3 F0 = giInput.F0;

    // Diffuse BRDF
    float3 diffuseBRDF = DisneyDiffuse(NdotV, NdotL, LdotH, perceptualRoughness, albedo) * NdotL;
    // float3 diffuseBRDF = NdotL * albedo;

    // diffuseBRDF /= UNITY_PI;
    
    // Specular BRDF
    float D = D_GGX_TR(NdotH, roughness);
    float3 F = F_FrenelSchlick(HdotV, F0);
    float G = G_GeometrySmith(NdotV, NdotL, roughness);
    
    // Cook-Torrance BRDF = (D * G * F) / (4 * NdotL * NdotV)
    float3 DGF = D * G * F;
    float denominator = 4.0 * NdotL * NdotV + 0.00001;
    float3 specularBRDF = DGF / denominator * _SpecularColor;
    
    // 反射方程
    float3 ks = F;
    float3 kd = 1.0 - ks;
    kd *= (1 - metallic);
    float3 directLight = (diffuseBRDF * kd + specularBRDF) * NdotL * gi.light.color * atten;


    // 间接光BRDF
    float3 indirectLight = (gi.indirect.diffuse + gi.indirect.specular) * ao;

    float4 finalColor;
    finalColor.rgb = directLight + indirectLight;

    // Emission
    #ifdef _EMISSIONGROUP_ON
        finalColor.rgb += s.Emission;
    #endif

    finalColor.a = s.Alpha;
    return finalColor;
}

fixed4 LitPassFragment(VertexOutput IN) : SV_TARGET
{
    LclSurfaceOutput s = LclSurf(IN);
    LclUnityGIInput giInput = LclGetGIInput(IN, s);

    UnityGI gi = LclFragmentGI(s, giInput);

    fixed4 finalColor = LCL_BRDF_Unity_PBS(s, giInput, gi);

    return finalColor;
};
