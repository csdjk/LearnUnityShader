Shader "Unlit/SimpleToon"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" { }
        _NormalMap ("Normal Map", 2D) = "bump" { }
        _NormalScale ("Normal Scale", Float) = 1.0
        _AOTex ("AO", 2D) = "white" { }

        _Roughness ("Roughness", Range(0, 1)) = 1.0
        _Metallic ("Metallic", Range(0, 1)) = 0.0

        [Header(Diffuse)]
        _DiffuseRamp ("Ramp", 2D) = "white" { }
        _TintHighColor ("Tint High Color", Color) = (1, 1, 1, 1)
        _TintHighOffset ("Tint High Offset", Range(-1, 1)) = 0
        _TintMedColor ("Tint Med Color", Color) = (1, 1, 1, 1)
        _TintMedOffset ("Tint Med Offset", Range(-1, 1)) = 0
        _TintMedCurve ("Tint Med Curve", Range(0, 1)) = 0
        _TintLowColor ("Tint Low Color", Color) = (1, 1, 1, 1)
        _TintLowOffset ("Tint Low Offset", Range(-1, 1)) = 0
        _TintLowCurve ("Tint Low Curve", Range(0, 1)) = 0

        [Header(Specular)]
        _SpecTex ("Spec Mask", 2D) = "white" { }
        _SpecColor ("_Spec Color", Color) = (1, 1, 1, 1)
        _SpecIntensity ("_SpecIntensity", Float) = 1
        _SpecPower ("_SpecPower", Float) = 100

        [Header(Rim)]
        _RimWidth ("_RimWidth", Float) = 0.5
        _RimIntensity ("_RimIntensity", Range(0, 1)) = 1
        _RimSmoothness ("_RimSmoothness", Range(0, 1)) = 1

        _EnvIntensity ("_EnvIntensity", Float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "LightMode" = "ForwardBase" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Assets\Shader\ShaderLibs\Node.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3x3 tbnMtrix : float3x3;
            };

            sampler2D _MainTex;
            sampler2D _NormalMap;
            sampler2D _AOTex;
            sampler2D _DiffuseRamp;
            sampler2D _SpecTex;

            float4 _TintHighColor;
            float _TintHighOffset;
            float4 _TintMedColor;
            float _TintMedOffset;
            float _TintMedCurve;
            float4 _TintLowColor;
            float _TintLowOffset;
            float _TintLowCurve;

            float4 _SpecColor;
            float _SpecIntensity;
            float _SpecPower;

            float _NormalScale;
            float _Roughness;
            float _Metallic;

            float _RimWidth;
            float _RimIntensity;
            float _RimSmoothness;
            
            float _EnvIntensity;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

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
                return o;
            }

            // half3 CalculateRampDiffuse(half diffuseTerm, half4 diffuseLayerColor, half offset, half curve, )
            // {
            //     half2 uv = half2(diffuseTerm + offset, curve);
            //     half rampDiffuse = tex2D(_DiffuseRamp, uv).r;
            //     rampDiffuse =
            //     half3 color1 = lerp(1, diffuseLayerColor.rgb, rampDiffuse * diffuseLayerColor.a);
            //     diffuse = baseColor * color1;
            // }
            fixed4 frag(v2f i) : SV_Target
            {
                // ================================= info =================================
                float3 worldPos = i.worldPos;
                float3 L = normalize(UnityWorldSpaceLightDir(worldPos));
                float3 V = normalize(UnityWorldSpaceViewDir(worldPos));
                float3 N = UnpackNormalWithScale(tex2D(_NormalMap, i.uv), _NormalScale);
                N = normalize(half3(mul(i.tbnMtrix, N)));

                half NdotV = dot(N, V);
                half roughness = _Roughness;
                half atten = 1;
                
                // ================================= mask =================================
                half3 baseColor = tex2D(_MainTex, i.uv);
                half ao = tex2D(_AOTex, i.uv);
                half4 specTex = tex2D(_SpecTex, i.uv);
                half specMask = specTex.b;
                half specSmoothness = specTex.a;


                // ================================= Direct Diffuse =================================
                half NdotL = dot(N, L);
                half halfLambert = NdotL * 0.5 + 0.5;
                half diffuseTerm = halfLambert * ao;

                half3 directDiffuse = 0;
                //layer 1
                half2 rampUV1 = half2(diffuseTerm + _TintHighOffset, 0);
                half rampDiffuse1 = tex2D(_DiffuseRamp, rampUV1).r;
                half3 color1 = lerp(1, _TintHighColor.rgb, rampDiffuse1 * _TintHighColor.a);
                directDiffuse = baseColor * color1;
                //layer 2
                half2 rampUV2 = half2(diffuseTerm + _TintMedOffset, _TintMedCurve);
                half rampDiffuse2 = tex2D(_DiffuseRamp, rampUV2).g;
                half3 color2 = lerp(1, _TintMedColor.rgb, rampDiffuse2 * _TintMedColor.a);
                directDiffuse = directDiffuse * color2;
                //layer 3
                half2 rampUV3 = half2(diffuseTerm + _TintLowOffset, _TintLowCurve);
                half rampDiffuse3 = tex2D(_DiffuseRamp, rampUV3).b;
                half3 color3 = lerp(1, _TintLowColor.rgb, rampDiffuse3 * _TintLowColor.a);
                directDiffuse = directDiffuse * color3;


                // ================================ Direct Specular ================================
                half3 H = normalize(L + V);
                half NdotH = dot(N, H);
                half smoothness = 1 - roughness;
                half shininess = lerp(1, _SpecPower, smoothness);
                half spec_term = pow(max(0, NdotH), shininess * smoothness);
                half3 directSpecular = spec_term * _SpecColor * _SpecIntensity * atten * specMask;


                // ================================ Indirect Diffuse ================================
                float3 indirectDiffuse = ShadeSH9(float4(N, 1)) * baseColor * halfLambert;
                // indirectDiffuse = lerp(indirectDiffuse * 0.5, indirectDiffuse, skin);

                // ================================ Indirect Specular ================================
                half fresnel = StylizedFresnel(NdotV, _RimWidth, _RimIntensity, _RimSmoothness, 1);

                half3 R = reflect(-V, N);
                float mip_level = PerceptualRoughnessToMipmapLevel(roughness);
                half4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, R, mip_level);
                half3 env_color = DecodeHDR(rgbm, unity_SpecCube0_HDR);
                half3 indirectSpecular = env_color * _EnvIntensity * fresnel * specMask;


                // ================================ Final Color ================================
                half3 final_color = directDiffuse + directSpecular + indirectSpecular;

                // final_color = ACESToneMapping(final_color, 1);

                // final_color += _Emissive * emissive * albedo_color.rgb;

                // final_color = pow(final_color, 0.45);
                return half4(directDiffuse,1);
            }
            ENDCG
        }
    }
}
