Shader "lcl/ParallaxMapping/ParallaxMapping"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Main Tex", 2D) = "white" { }
        _BumpMap ("Normal Map", 2D) = "bump" { }
        _BumpScale ("Bump Scale", Range(0, 5)) = 1.0
        _ParallaxMap ("Parallax Map", 2D) = "black" { }
        _ParallaxStrength ("Parallax Strength", Range(0, 1)) = 1.0

        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Lighting.cginc"
            
            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _BumpMap;

            sampler2D _ParallaxMap;

            half4 _Color;
            float _BumpScale;
            float _ParallaxStrength;
            half4 _Specular;
            float _Gloss;
            
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
                float4 TtoW0 : TEXCOORD1;
                float4 TtoW1 : TEXCOORD2;
                float4 TtoW2 : TEXCOORD3;
                float3 worldPos : TEXCOORD4;
                float3x3 tbnMtrix : float3x3;
            };
            
            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                
                o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                
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


            //计算uv偏移值(viewdir 切线空间下的视线方向)
            inline float2 CalculateParallaxUV(float2 uv, float3 viewDir)
            {
                float height = tex2D(_ParallaxMap, uv).r;
                viewDir = normalize(viewDir);
                // 通过切平面垂直的z分量来调整xy方向（uv方向）偏移的大小，也就是说当我们视角越平，uv偏移越大；视角越垂直于表面，uv偏移值越小。
                float2 offset = viewDir.xy / viewDir.z * height * _ParallaxStrength * 0.1;
                return offset;
            }
            
            half4 frag(v2f i) : SV_Target
            {
                float3 worldPos = i.worldPos;
                float3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                float3 viewDir = UnityWorldSpaceViewDir(worldPos);
                viewDir = mul(transpose(i.tbnMtrix), viewDir);
                // float3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                
                // 视差计算uv
                half height = tex2D(_ParallaxMap, i.uv);
                half2 uvOffset = CalculateParallaxUV(i.uv, viewDir);
                i.uv = i.uv + uvOffset;

                uvOffset = CalculateParallaxUV(i.uv, viewDir);
                i.uv = i.uv + uvOffset;
                
                uvOffset = CalculateParallaxUV(i.uv, viewDir);
                i.uv = i.uv + uvOffset;


                float3 normal = UnpackNormal(tex2D(_BumpMap, i.uv));
                normal.xy *= _BumpScale;
                normal.z = sqrt(1.0 - saturate(dot(normal.xy, normal.xy)));
                normal = normalize(half3(mul(i.tbnMtrix, normal)));


                half3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                
                half3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                
                half3 diffuse = _LightColor0.rgb * albedo * max(0, dot(normal, lightDir));

                // half3 halfDir = normalize(lightDir + viewDir);
                // half3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(normal, halfDir)), _Gloss);
                
                return half4(ambient + diffuse, 1.0);
            }
            
            ENDCG
        }
    }
    FallBack "Specular"
}
