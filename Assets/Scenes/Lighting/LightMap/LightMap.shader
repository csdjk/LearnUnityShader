Shader "lcl/LightMap"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _NormalMap ("Normal Map", 2D) = "bump" { }
        _NormalScale ("Normal Scale", Float) = 1.0

        _SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)
        _SpecularPower ("Specular Power", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            #pragma multi_compile _ LIGHTMAP_ON
            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            sampler2D _NormalMap;


            half4 _Color;
            float _NormalScale;
            float _SpecularPower;
            float4 _SpecularColor;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
            };
            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float3x3 tbnMtrix : float3x3;
                float2 uv_lightmap : TEXCOORD2;
            };
            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv_lightmap = v.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;

                o.positionWS = mul(unity_ObjectToWorld, v.vertex).xyz;

                half3 worldNormal = UnityObjectToWorldNormal(v.normal);
                half3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                half3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

                // 切线空间转换到世界空间的矩阵
                o.tbnMtrix = float3x3(
                    worldTangent.x, worldBinormal.x, worldNormal.x,
                    worldTangent.y, worldBinormal.y, worldNormal.y,
                    worldTangent.z, worldBinormal.z, worldNormal.z
                );
                return o;
            }
            half4 frag(v2f i) : SV_Target
            {
                float3 lightColor = _LightColor0.rgb;
                float3 L = normalize(UnityWorldSpaceLightDir(i.positionWS));
                float3 V = normalize(UnityWorldSpaceViewDir(i.positionWS));

                float3 normalTS = UnpackNormalWithScale(tex2D(_NormalMap, i.uv), _NormalScale);
                float3 N = normalize(half3(mul(i.tbnMtrix, normalTS)));

                float3 H = normalize(V + L);

                half3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                half3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                fixed3 diffuse = 0;
                
                half3 lightmapColor = 0;
                #if defined(LIGHTMAP_ON)
                    half4 bakedColorTex = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv_lightmap);
                    diffuse = DecodeLightmap(bakedColorTex);
                #else
                    float NdotL = saturate(dot(N, L)) * 0.5 + 0.5;
                    diffuse = lightColor * albedo * NdotL;
                #endif

                float NdotH = saturate(dot(N, H));
                half3 specular = pow(NdotH, _SpecularPower) * _SpecularColor.rgb * lightColor;


                half3 resCol = diffuse + specular ;
                return half4(resCol, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}