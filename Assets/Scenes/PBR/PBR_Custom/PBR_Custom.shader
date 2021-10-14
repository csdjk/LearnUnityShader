//PBR - 自定义 todo
Shader "lcl/PBR/PBR_Custom" {
    Properties{
        _MainTex ("Albedo Tex", 2D) = "white" {}
        _DiffuseColor("Diffuse Color",Color) = (1,1,1,1)
        _SpecularColor("Specular Color",Color) = (1,1,1,1)
        _Metallic("Metallic",Range(0,1)) = 0
        _Smoothness("Smoothness",Range(0,1)) = 0.1
    }
    SubShader {
        Pass{
            Tags { "LightMode"="ForwardBase" "RenderType"="Opaque"}
            CGPROGRAM
            #include "Lighting.cginc"
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _DiffuseColor;
            fixed3 _SpecularColor;
            half _Metallic;
            half _Smoothness;

            struct a2v {
                float4 vertex : POSITION;
                float3 normal: NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f{
                float4 position:SV_POSITION;
                float3 worldNormal: TEXCOORD0;
                float3 worldPos: TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            v2f vert(a2v v){
                v2f o;
                o.position = UnityObjectToClipPos(v.vertex);
                o.worldNormal = mul(v.normal,(float3x3) unity_WorldToObject);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            };


            half DisneyDiffuse(half NdotV, half NdotL, half LdotH, half roughness,half3 baseColor)
            {
                half fd90 = 0.5 + 2 * LdotH * LdotH * roughness;
                // Two schlick fresnel term
                half lightScatter   = (1 + (fd90 - 1) * Pow5(1 - NdotL));
                half viewScatter    = (1 + (fd90 - 1) * Pow5(1 - NdotV));
                return baseColor * lightScatter * viewScatter;
            }

            // D 法线分布函数
            float D_GGX_TR (float NdotH, float roughness)
            {
                float a2 = roughness * roughness;
                NdotH  = max(NdotH, 0.0);
                float NdotH2 = NdotH*NdotH;
                float denom  = (NdotH2 * (a2 - 1.0) + 1.0);
                denom  = UNITY_PI * denom * denom;
                denom = max(denom,0.0000001); //防止分母为0
                return a2 / denom;
            }
            // F 菲涅尔函数
            float3 F_FrenelSchlick(float HdotV, float3 F0)
            {
                return F0 + (1 - F0) * pow(1 - HdotV , 5.0);
            }

            // G 几何遮蔽函数
            float GeometrySchlickGGX(float NdotV, float roughness)
            {
                float a = (roughness + 1.0)/2;
                float k = a*a / 4;
                float nom   = NdotV;
                float denom = NdotV * (1.0 - k) + k;
                denom = max(denom,0.0000001); //防止分母为0
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

            fixed4 frag(v2f i):SV_TARGET{
                float2 uv = i.uv;
                fixed3 N = normalize(i.worldNormal);
                float3 L = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 V = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 H = normalize(L + V);

                float NdotL = dot(N,L);
                float NdotV = dot(N,V);
                float NdotH = dot(N,H);
                float HdotV = dot(H,V);
                float LdotH = dot(L,H);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _DiffuseColor;
                // fixed3 diffuseColor = _DiffuseColor * albedo;

                float3 lightColor = _LightColor0.xyz;
                float roughness = 1-_Smoothness;
                float metallic = _Metallic;
                float3 F0 = lerp(0.04,albedo,metallic);
                
                // -------------------【直接光 - Direct Light】-------------------------
                // Diffuse BRDF
                float3 diffuseBRDF = DisneyDiffuse(NdotV, NdotL, LdotH, roughness, albedo);

                // float3 diffuseBRDF = max(NdotL,0) * albedo ;

                // diffuseBRDF /= UNITY_PI;
                
                // return fixed4(diffuseBRDF,1);

                // Specular BRDF
                float D = D_GGX_TR(NdotH,roughness);
                float3 F = F_FrenelSchlick(HdotV,F0);
                float G = G_GeometrySmith(NdotV,NdotL,roughness);
                
                // Cook-Torrance BRDF = (D * G * F) / (4 * NdotL * NdotV)
                float3 DGF = D * G * F;
                float denominator = 4.0 * max(NdotL, 0.0) * max(NdotV, 0.0) + 0.00001; 
                float3 specularBRDF = DGF/denominator;
                
                // 反射方程
                float3 ks = F;
                float3 kd = 1-ks;
                kd *= (1-metallic);
                float3 directLight = (diffuseBRDF * kd + specularBRDF) * NdotL * lightColor;
                // -------------------【间接光 - Indirect Light】-------------------------




                // directLight = D;
                return fixed4(directLight,1);
            };
            
            ENDCG
        }
    }
    FallBack "VertexLit"
}