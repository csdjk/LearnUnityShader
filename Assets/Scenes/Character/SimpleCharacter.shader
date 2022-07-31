Shader "lcl/Character/SimpleCharacter"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" { }
        _NormalMap ("Normal Map", 2D) = "bump" { }
        _NormalScale ("Normal Scale", Float) = 1.0
        _MaskTex ("Mask Map(Roughness - Metallic - Skin - Emissive)", 2D) = "white" { }

        _Roughness ("Roughness", Range(0, 1)) = 1.0
        _Metallic ("Metallic", Range(0, 1)) = 0.0

        [Header(Specular)]
        _SpecShininess ("Spec Shininess", Range(0, 100)) = 10

        [Header(Emissive)]
        [HDR]_Emissive ("Emissive Color", Color) = (1, 1, 1, 1)

        [Header(SSS)]
        _SkinLut ("Skin LUT", 2D) = "white" { }
        _SSSCurve ("SSS Curve", Range(0, 1)) = 1
        _SSSOffset ("SSS Offset", Range(-1, 1)) = 0

        [Header(IBL)]
        _Expose ("Expose", Float) = 1.0
    }
    SubShader
    {

        Pass
        {
            Tags { "RenderType" = "Qpaque" "LightMode" = "ForwardBase" }
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            #include "Assets\Shader\ShaderLibs\Node.cginc"
            

            sampler2D _MainTex;
            sampler2D _NormalMap;
            sampler2D _MaskTex;
            sampler2D _SkinLut;

            float4 _Emissive;
            
            float _NormalScale;
            float _Roughness;
            float _Metallic;
            float _SpecShininess;
            float _SSSOffset;
            float _SSSCurve;
            float _Expose;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };
            
            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                LIGHTING_COORDS(2, 3)
                float3x3 tbnMtrix : float3x3;
            };
            
            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                
                o.uv = v.texcoord.xy;
                
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                half3 worldNormal = UnityObjectToWorldNormal(v.normal);
                half3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                half3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

                o.worldPos = worldPos;
                o.tbnMtrix = float3x3(
                    worldTangent.x, worldBinormal.x, worldNormal.x,
                    worldTangent.y, worldBinormal.y, worldNormal.y,
                    worldTangent.z, worldBinormal.z, worldNormal.z
                );
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                float3 worldPos = i.worldPos;
                float3 L = normalize(UnityWorldSpaceLightDir(worldPos));
                float3 V = normalize(UnityWorldSpaceViewDir(worldPos));
                
                float3 N = UnpackNormalWithScale(tex2D(_NormalMap, i.uv), _NormalScale);
                N = normalize(half3(mul(i.tbnMtrix, N)));


                half4 albedo_color_gamma = tex2D(_MainTex, i.uv);
                half4 albedo_color = pow(albedo_color_gamma, 2.2);
                half4 mask = tex2D(_MaskTex, i.uv);
                half roughness = saturate(mask.r * _Roughness);
                half metallic = saturate(mask.g * _Metallic);
                half skin = mask.b;
                half emissive = mask.a;

                half3 base_color = albedo_color.rgb * (1 - metallic);
                half3 spec_color = lerp(0.04, albedo_color.rgb, metallic);
                

                // ================================ Lighting ================================
                half atten = LIGHT_ATTENUATION(i);

                // ================================ Diffuse Specular ================================
                half diffuse_term = max(0, dot(N, L));
                half half_limbert = diffuse_term * 0.5 + 0.5;
                half3 common_diffuse = diffuse_term * base_color * atten * _LightColor0.rgb;

                half2 uv_lut = half2(diffuse_term * atten + _SSSOffset, _SSSCurve);
                half3 lut_color = tex2D(_SkinLut, uv_lut);

                lut_color = pow(lut_color, 2.2);
                half3 sss_diffuse = lut_color * base_color * half_limbert * _LightColor0.rgb;

                // return diffuse_term;
                // return half4(N, 1.0);


                half3 direct_diffuse = lerp(common_diffuse, sss_diffuse, skin);

                // ================================ Direct Specular ================================
                half3 H = normalize(L + V);
                half NdotH = dot(N, H);
                half smoothness = 1 - roughness;
                half shininess = lerp(1, _SpecShininess, smoothness);
                half spec_term = pow(max(0, NdotH), shininess * smoothness);
                half3 direct_specular = spec_term * spec_color * _LightColor0 * atten;


                // ================================ Indirect Diffuse ================================
                float3 indirect_diffuse = ShadeSH9(float4(N, 1)) * base_color * half_limbert;
                indirect_diffuse = lerp(indirect_diffuse * 0.5, indirect_diffuse, skin);


                // ================================ Indirect Specular ================================
                half3 R = reflect(-V, N);
                roughness = roughness * (1.7 - 0.7 * roughness);
                float mip_level = perceptualRoughnessToMipmapLevel(roughness);
                half4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, R, mip_level);
                half3 env_color = DecodeHDR(rgbm, unity_SpecCube0_HDR);
                half3 indirect_specular = env_color * _Expose * spec_color * half_limbert;

                // ================================ Final Color ================================
                half3 final_color = direct_diffuse + direct_specular + indirect_diffuse + indirect_specular;

                final_color = ACESToneMapping(final_color, 1);

                final_color += _Emissive * emissive * albedo_color.rgb;

                final_color = pow(final_color, 0.45);
                return half4(final_color, 1.0);
            }
            
            ENDCG
        }
    }
    FallBack "Specular"
}
