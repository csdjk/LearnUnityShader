Shader "lcl/Character/SimpleCharacterHair"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        _MainTex ("Main Tex", 2D) = "white" { }

        _NormalMap ("Normal Map", 2D) = "bump" { }
        _NormalScale ("Normal Scale", Float) = 1.0
        _Roughness ("Roughness", Range(0, 1)) = 1.0

        [Header(Specular)]
        _NoiseTex ("Noise Map", 2D) = "black" { }
        _PrimaryColor ("Primary Color", Color) = (1, 1, 1, 1)
        _PrimaryPower ("Primary Power", Range(0, 500)) = 500
        _PrimaryShift ("Primary Shift", Range(-1, 1)) = 0
        _PrimaryStrength ("Primary Noise Strength", Range(0, 2)) = 1
        
        _SecondaryColor ("Second Color", Color) = (1, 1, 1, 1)
        _SecondPower ("Second Power", Range(0, 500)) = 500
        _SecondShift ("Second Shift", Range(-1, 1)) = 0
        _SecondStrength ("Second Noise Strength", Range(0, 2)) = 1

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
            sampler2D _NoiseTex;

            float4 _NoiseTex_ST;
            float4 _BaseColor;
            float _NormalScale;
            float _Roughness;
            float _Expose;

            float4 _PrimaryColor;
            float _PrimaryPower;
            float _PrimaryShift;
            float _PrimaryStrength;
            
            
            float4 _SecondaryColor;
            float _SecondPower;
            float _SecondShift;
            float _SecondStrength;

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
                float4 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                LIGHTING_COORDS(2, 3)
                float3x3 tbnMtrix : float3x3;
            };
            
            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                
                o.uv.xy = v.texcoord.xy;
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _NoiseTex);
                
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
                
                float3 N = UnpackNormalWithScale(tex2D(_NormalMap, i.uv.xy), _NormalScale);
                N = normalize(half3(mul(i.tbnMtrix, N)));
                float3 T = normalize(i.tbnMtrix[0]);
                float3 B = normalize(i.tbnMtrix[1]);


                half4 albedo_color_gamma = tex2D(_MainTex, i.uv.xy);
                half4 albedo_color = pow(albedo_color_gamma, 2.2);
                // half4 albedo_color = albedo_color_gamma;
                half roughness = _Roughness;

                half3 base_color = albedo_color.rgb * _BaseColor;
                // return half4(base_color, 1.0);
                

                // ================================ Lighting ================================
                half atten = LIGHT_ATTENUATION(i);

                // ================================ Direct Diffuse ================================
                half diffuse_term = max(0, dot(N, L));
                half half_limbert = diffuse_term * 0.5 + 0.5;

                half3 direct_diffuse = half_limbert * base_color * 2;
                // return half4(direct_diffuse, 1.0);


                // ================================ Direct Specular ================================
                // Kajiya-Kay
                half anisoNoise = tex2D(_NoiseTex, i.uv.zw);

                half4 specColor1 = half4(_PrimaryColor.rgb + base_color, _PrimaryColor.a);
                half4 specColor2 = half4(_SecondaryColor.rgb + base_color, _SecondaryColor.a);

                half3 direct_specular = HairStrandSpecular(N, B, V, L, anisoNoise,
                specColor1, half3(_PrimaryPower, _PrimaryShift, _PrimaryStrength),
                specColor2, half3(_SecondPower, _SecondShift, _SecondStrength));


                // return half4(direct_specular, 1.0);
                // ================================ Indirect Diffuse ================================
                // float3 indirect_diffuse = ShadeSH9(float4(N, 1)) * base_color * half_limbert;

                // ================================ Indirect Specular ================================
                half3 R = reflect(-V, N);
                float mip_level = PerceptualRoughnessToMipmapLevel(roughness);
                half4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, R, mip_level);
                half3 env_color = DecodeHDR(rgbm, unity_SpecCube0_HDR);
                half3 indirect_specular = env_color * _Expose * half_limbert * anisoNoise * base_color;

                // ================================ Final Color ================================
                half3 final_color = direct_diffuse + direct_specular + indirect_specular;
                final_color = final_color * atten;
                final_color = ACESToneMapping(final_color, 1);
                final_color = pow(final_color, 0.45);
                return half4(final_color, 1.0);
            }
            
            ENDCG
        }
    }
    FallBack "Specular"
}
