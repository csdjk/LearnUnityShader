// Based on tutorial:
// https://learnopengl.com/#!Advanced-Lighting/Parallax-Mapping

Shader "Custom/ParallaxMapping"
{
    Properties
    {
        _MainTex ("Diffuse", 2D) = "white" { }
        _NormalMap ("Normal", 2D) = "white" { }
        _NormalActive ("NormalActive", Int) = 1
        _DepthMap ("Depth", 2D) = "white" { }
        _HeightScale ("HeightScale", Range(0, 0.1)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "LightMode" = "ForwardBase" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc" // for _LightColor0

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 viewDir : TEXCOORD1;
                float3 lightDir : TEXCOORD2;
                float4 vertex : SV_POSITION;

                float3 normalWorld : TEXCOORD3;
                float3 tangentWorld : TEXCOORD4;
                float3 binormalWorld : TEXCOORD5;
            };

            sampler2D _MainTex;
            sampler2D _NormalMap;
            sampler2D _DepthMap;
            float _HeightScale;
            int _NormalActive;

            float4 _MainTex_ST;

            v2f vert(appdata v)
            {
                v2f o;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.vertex = UnityObjectToClipPos(v.vertex);

                float4 worldPosition = mul(unity_ObjectToWorld, v.vertex);
                // calc lightDir vector heading current vertex
                o.lightDir = normalize(_WorldSpaceLightPos0.xyz);

                o.normalWorld = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
                o.tangentWorld = normalize(mul((float3x3)unity_ObjectToWorld, v.tangent));
                o.binormalWorld = normalize(cross(o.normalWorld, o.tangentWorld) * v.tangent.w);
                // tangent.w is specific to Unity

                // Normal Transpose Matrix
                float3x3 TBN = transpose(float3x3(
                    o.tangentWorld,
                    o.binormalWorld,
                    o.normalWorld
                ));

                // calc viewDir vector in tangent space
                float3 viewDir = normalize(v.vertex - mul(TBN, _WorldSpaceCameraPos.xyz));
                o.viewDir = viewDir;

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // Parallax mapping
                const float minLayers = 8.0;
                const float maxLayers = 32.0;
                float layerCount = lerp(maxLayers, minLayers, abs(dot(float3(0.0, 0.0, 1.0), i.viewDir)));

                float layerDepth = 1.0 / layerCount;
                float currentLayerDepth = 0.0;
                // the amount to shift the texture coordinates per layer (from vector P)
                float2 p = i.viewDir.xy * _HeightScale;
                float2 deltaTexCoords = p / layerCount;

                // get initial values
                float2 currentTexCoords = i.uv;
                float currentDepthMapValue = tex2D(_DepthMap, currentTexCoords).r;

                [unroll(32)]
                while (currentLayerDepth < currentDepthMapValue)
                {
                    // shift texture coordinates along direction of P
                    currentTexCoords -= deltaTexCoords;
                    // get depthmap value at current texture coordinates
                    currentDepthMapValue = tex2D(_DepthMap, currentTexCoords).r;
                    // get depth of next layer
                    currentLayerDepth += layerDepth;
                }

                float2 prevTexCoords = currentTexCoords + deltaTexCoords;

                // get depth after and before collision for linear interpolation
                float afterDepth = currentDepthMapValue - currentLayerDepth;
                float beforeDepth = tex2D(_DepthMap, prevTexCoords).r - currentLayerDepth + layerDepth;
                
                // interpolation of texture coordinates
                float weight = afterDepth / (afterDepth - beforeDepth);
                float2 uv = prevTexCoords * weight + currentTexCoords * (1.0 - weight);

                if (uv.x > 1.0 || uv.y > 1.0 || uv.x < 0.0 || uv.y < 0.0)
                    discard;

                // Get from normal map
                float3 n = i.normalWorld;
                if (_NormalActive == 1)
                {
                    float4 encodedNormal = tex2D(_NormalMap, uv);
                    n = float3(2.0 * encodedNormal.a - 1.0, 2.0 * encodedNormal.g - 1.0, 0.0);
                    n.z = sqrt(1.0 - dot(n, n));

                    // Normal Transpose Matrix
                    float3x3 TBN = transpose(float3x3(
                        i.tangentWorld,
                        i.binormalWorld,
                        i.normalWorld
                    ));
                    // Calculate normal out of world normal & normal map
                    n = normalize(mul(TBN, n));
                }
                half3 l = i.lightDir;

                // sample the texture
                // apply lighting
                fixed4 col = _LightColor0 * tex2D(_MainTex, uv) * max(0, dot(n, l));

                return col;
            }
            ENDCG
        }
    }
}