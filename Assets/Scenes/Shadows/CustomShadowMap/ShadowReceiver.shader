Shader "lcl/Shadows/CustomShadowMap/ShadowMapCreator"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM

            #include "UnityCG.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 shadowCoord : TEXCOORD0;
            };

            uniform float4x4 _gWorldToShadow;
            uniform sampler2D _gShadowMapTexture;
            uniform float4 _gShadowMapTexture_TexelSize;
            uniform float _gShadowStrength;

            v2f vert(appdata_full v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.shadowCoord = mul(_gWorldToShadow, worldPos);

                return o;
            }

            float4 _Color;

            fixed4 frag(v2f i) : COLOR0
            {
                // shadow
                i.shadowCoord.xy = i.shadowCoord.xy / i.shadowCoord.w;
                float2 uv = i.shadowCoord.xy;
                uv = uv * 0.5 + 0.5; //(-1, 1)-->(0, 1)

                float currentDepth = i.shadowCoord.z / i.shadowCoord.w;
                #if defined(SHADER_TARGET_GLSL)
                    currentDepth = currentDepth * 0.5 + 0.5; //(-1, 1)-->(0, 1)
                #elif defined(UNITY_REVERSED_Z)
                    currentDepth = 1 - currentDepth ;       //(1, 0)-->(0, 1)
                #endif

                // sample depth texture
                float4 col = tex2D(_gShadowMapTexture, uv);

                float closestDepth = DecodeFloatRGBA(col);

                // 偏移量,防止发生自阴影遮挡
                float shadowBias = 0.0005;
                float shadow = currentDepth-shadowBias > closestDepth ?(1 - _gShadowStrength) : 1;

                return _Color * shadow;
            }

            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest
            ENDCG

        }
    }
}