//PBR - 自定义 todo
Shader "lcl/PBR/PBR_Custom"
{
    Properties
    {
        [Tex(_, _DiffuseColor)]_MainTex ("Albedo Tex", 2D) = "white" { }
        [HideInInspector]_DiffuseColor ("Diffuse Color", Color) = (1, 1, 1, 1)

        [Tex(_, _SpecularColor)]_SpecularTex ("Specular Tex", 2D) = "white" { }
        [HideInInspector]_SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)

        [Tex(_, _Metallic)] _MetallicTex ("Metallic Tex", 2D) = "white" { }
        [HideInInspector]_Metallic ("Metallic", Range(0, 1)) = 0

        [Tex(_, _Roughness)] _RoughnessTex ("Roughness Tex", 2D) = "white" { }
        [HideInInspector]_Roughness ("Roughness", Range(0, 1)) = 0.1
        
        [Tex(_, _AoPower)]_AOTex ("AO Tex", 2D) = "white" { }
        [HideInInspector]_AoPower ("AO Power", Range(0, 1)) = 0.1

        [Tex(_, _NormalScale)]_NormalTex ("Normal Tex", 2D) = "bump" { }
        [HideInInspector]_NormalScale ("Normal Scale", Range(0, 10)) = 1

        [Header(Indirect)]
        _IrradianceCubemap ("Irradiance Cubemap", Cube) = "_Skybox" { }

        // 自发光
        [Main(_emissionGroup, __, 0)] _emissionGroup ("Emission", float) = 1
        [Tex(_emissionGroup, _EmissionColor)] _EmissionTex ("Emission Tex", 2D) = "white" { }
        [HideInInspector][HDR]_EmissionColor ("Emission Color", Color) = (0, 0, 0, 0)

        // 自定义反射球
        [Toggle(_CUSTOM_REFL_CUBE_ON)]_CUSTOM_REFL_CUBE ("Custom Reflect Cube", int) = 0
        _CustomReflectTex ("Custom Reflect Tex", Cube) = "_Skybox" { }

        // [SubToggle(_emissionGroup, _KEYWORD)] _toggle_keyword ("toggle_keyword", float) = 0
        // [Sub(_emissionGroup_KEYWORD)]  _float_keyword ("float_keyword", float) = 0

    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" "RenderType" = "Opaque" }
            CGPROGRAM

            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            
            #pragma multi_compile_fwdbase
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            
            #pragma multi_compile _ _EMISSIONGROUP_ON
            #pragma shader_feature _CUSTOM_REFL_CUBE_ON

            // #pragma enable_d3d11_debug_symbols

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
            samplerCUBE _CustomReflectTex;
            half4 _CustomReflectTex_HDR;

            sampler2D _NormalTex;
            fixed _NormalScale;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
                float2 texcoord1 : TEXCOORD1;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float4 uv : TEXCOORD2;
                SHADOW_COORDS(3)
                float3x3 tbnMtrix : float3x3;
            };

            
            inline half PerceptualRoughnessToMipmapLevel(half perceptualRoughness, int maxMipLevel)
            {
                perceptualRoughness = perceptualRoughness * (1.7 - 0.7 * perceptualRoughness);
                return perceptualRoughness * maxMipLevel;
            }
            inline half PerceptualRoughnessToMipmapLevel(half perceptualRoughness)
            {
                return PerceptualRoughnessToMipmapLevel(perceptualRoughness, UNITY_SPECCUBE_LOD_STEPS);
            }

            // float PerceptualRoughnessToRoughness(float perceptualRoughness)
            // {
            //     return perceptualRoughness * perceptualRoughness;
            // }

            // half RoughnessToPerceptualRoughness(half roughness)
            // {
            //     return sqrt(roughness);
            // }

            // // Smoothness is the user facing name
            // // it should be perceptualSmoothness but we don't want the user to have to deal with this name
            // half SmoothnessToRoughness(half smoothness)
            // {
            //     return (1 - smoothness) * (1 - smoothness);
            // }

            // float SmoothnessToPerceptualRoughness(float smoothness)
            // {
            //     return (1 - smoothness);
            // }

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

            // https://zhuanlan.zhihu.com/p/69380665
            float D_GTR1(float NdotH, float roughness)
            {
                float a2 = roughness * roughness;
                float cos2th = NdotH * NdotH;
                float den = (1.0 + (a2 - 1.0) * cos2th);

                return (a2 - 1.0) / (UNITY_PI * log(a2) * den);
            }

            float D_GTR2(float NdotH, float roughness)
            {
                float a2 = roughness * roughness;
                float cos2th = NdotH * NdotH;
                float den = (1.0 + (a2 - 1.0) * cos2th);

                return a2 / (UNITY_PI * den * den);
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
            // Black Ops II
            // float2 EnvBRDFApprox(float Roughness, float NV)
            // {
            //     float g = 1 -Roughness;
            //     float4 t = float4(1/0.96, 0.475, (0.0275 - 0.25*0.04)/0.96, 0.25);
            //     t *= float4(g, g, g, g);
            //     t += float4(0, 0, (0.015 - 0.75*0.04)/0.96, 0.75);
            //     float A = t.x * min(t.y, exp2(-9.28 * NV)) + t.z;
            //     float B = t.w;
            //     return float2 ( t.w-A,A);
            // }

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = v.texcoord1 * unity_LightmapST.xy + unity_LightmapST.zw;

                float3 worldNormal = normalize(mul(v.normal, (float3x3) unity_WorldToObject));
                float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                float3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;
                o.tbnMtrix = float3x3(worldTangent, worldBinormal, worldNormal);
                o.worldNormal = worldNormal;

                TRANSFER_SHADOW(o);
                return o;
            };

            fixed4 frag(v2f i) : SV_TARGET
            {
                float2 uv = i.uv.xy;
                float2 uv_lightmap = i.uv.zw;
                
                float4 tangentNormal = tex2D(_NormalTex, uv);
                float3 N = UnpackNormal(tangentNormal);
                N.xy *= _NormalScale;
                N = normalize(half3(mul(N, i.tbnMtrix)));
                

                float3 L = normalize(UnityWorldSpaceLightDir(i.worldPos));
                float3 V = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 H = normalize(L + V);

                float NdotL = max(dot(N, L), 0);
                float NdotV = max(dot(N, V), 0);
                float NdotH = max(dot(N, H), 0);
                float HdotV = max(dot(H, V), 0);
                float LdotH = max(dot(L, H), 0);
                // ================================= 阴影 =================================
                // UNITY_LIGHT_ATTENUATION(shadowAttenuation, i, i.worldPos);
                fixed shadowAttenuation = SHADOW_ATTENUATION(i);

                half distanceAttenuation = 1;
                #if defined(LIGHTMAP_ON) && defined(LIGHTMAP_SHADOW_MIXING)
                    //Subtractive Mixing模式
                    distanceAttenuation = 0;
                #endif
                float3 lightColor = _LightColor0.xyz * shadowAttenuation * distanceAttenuation;
                fixed3 albedo = tex2D(_MainTex, uv).rgb * _DiffuseColor;

                fixed ao = tex2D(_AOTex, uv).r;
                ao = LerpOneTo(ao, _AoPower);

                // return fixed4(ao,ao,ao,1);
                // 粗糙度
                float perceptualRoughness = tex2D(_RoughnessTex, uv).r * _Roughness;
                // 将其重新映射到感知线性范围(perceptualRoughness*perceptualRoughness)
                float roughness = max(PerceptualRoughnessToRoughness(perceptualRoughness), 0.002);
                // float roughness = max(perceptualRoughness, 0.002);
                // return fixed4(perceptualRoughness,perceptualRoughness,perceptualRoughness,1);

                float metallic = tex2D(_MetallicTex, uv).r * _Metallic;
                // return fixed4(metallic,metallic,metallic,1);

                float3 F0 = lerp(0.04, albedo, metallic);
                
                // -------------------【直接光 - Direct Light】-------------------------
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
                float3 directLight = (diffuseBRDF * kd + specularBRDF) * NdotL * lightColor;

                // -------------------【间接光 - Indirect Light】-------------------------

                float3 ks_indirect = FresnelSchlickRoughness(NdotV, F0, roughness);
                float3 kd_indirect = 1.0 - ks_indirect;
                kd_indirect *= (1 - metallic);

                // -----Diffuse-----
                // 球谐函数
                float3 diffuseIndirect = 0;
                // LightMap: Subtractive Mixing模式
                #if defined(LIGHTMAP_ON) && defined(LIGHTMAP_SHADOW_MIXING)
                    half4 bakedColorTex = UNITY_SAMPLE_TEX2D(unity_Lightmap, uv_lightmap);
                    diffuseIndirect = DecodeLightmap(bakedColorTex) * albedo;
                    // diffuseIndirect = kd_indirect * SubtractMainLightWithRealtimeAttenuationFromLightmap(diffuseIndirect, shadowAttenuation, bakedColorTex, N);
                    // return half4(diffuseIndirect, 1);

                #else
                    float3 irradianceSH = ShadeSH9(float4(N, 1));
                    diffuseIndirect = kd_indirect * irradianceSH * albedo;
                #endif
                

                // 环境cubemap
                // float3 irradiance = texCUBE(_IrradianceCubemap,N).rgb;
                // float3 diffuseIndirect = kd_indirect * irradiance * albedo;
                
                // diffuseIndirect /= UNITY_PI;

                // -----Specular------
                // 积分拆分成两部分：Li*NdotL 和 DFG/(4*NdotL*NdotV)

                // 1.Li*NdotL
                // 预过滤环境贴图方式
                float3 R = reflect(-V, N);
                

                // 根据粗糙度计算mip level
                half mip = PerceptualRoughnessToMipmapLevel(perceptualRoughness);
                float3 prefilteredColor = 0;
                // 自定义反射球
                #if defined(_CUSTOM_REFL_CUBE_ON)
                    // 自定义反射求需要把Cube Map贴图的 Mapping Convolution Type选项选为Specular(Glossy Reflection)
                    half4 rgbm = texCUBElod(_CustomReflectTex, float4(R, mip));
                    prefilteredColor = DecodeHDR(rgbm, _CustomReflectTex_HDR);
                #else
                    half4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, R, mip);
                    //unity_SpecCube0_HDR储存的是 最近的ReflectionProbe
                    prefilteredColor = DecodeHDR(rgbm, unity_SpecCube0_HDR);
                #endif

                //2.DFG/(4*NdotL*NdotV)：

                // 2.1 用BRDF积分贴图方式：2D 查找纹理(LUT)
                // 查找纹理的时候，我们以 BRDF 的输入NdotV作为横坐标，以粗糙度(roughness)作为纵坐标。
                // float2 envBRDF = tex2D(_BRDFLUTTex, float2(NdotV, roughness)).rg;

                // 2.2 数值拟合方式计算：
                float2 envBRDF = EnvBRDFApprox(roughness, NdotV);

                // 最后结合两部分
                float3 specularIndirect = prefilteredColor * (ks_indirect * envBRDF.x + envBRDF.y);

                // 间接光BRDF
                float3 indirectLight = (diffuseIndirect + specularIndirect) * ao;


                // -------------------【最后叠加直接光和间接光】-------------------------
                float3 resColor = directLight + indirectLight;


                // 自发光
                #ifdef _EMISSIONGROUP_ON
                    fixed3 emission = tex2D(_EmissionTex, uv) * _EmissionColor;
                    resColor += emission;
                #endif
                
                // resColor = prefilteredColor;
                return fixed4(resColor, 1);
            };
            
            ENDCG
        }
    }
    FallBack "VertexLit"
    CustomEditor "JTRP.ShaderDrawer.LWGUI"
}