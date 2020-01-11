// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "lcl/otherShader/emission/LightSick" {

    Properties {
        _Color ("Color", Color) = (1,0.6,0,1)
        _GlowColor("Glow Color", Color) = (1,1,0,1)
        _Strength("Glow Strength", Range(5.0, 1.0)) = 2.0
        _GlowRange("Glow Range", Range(0.1,1)) = 0.6
        // _MainTex ("Albedo (RGB)", 2D) = "white" {}
        // _Glossiness ("Smoothness", Range(0,1)) = 0.5
        // _Metallic ("Metallic", Range(0,1)) = 0.0
    }

    SubShader {

        Pass {
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            float4 _Color;

            float4 vert(float4 vertexPos : POSITION) : SV_POSITION {
                return UnityObjectToClipPos(vertexPos);
            }

            float4 frag(void) : COLOR {
                return _Color;
            }

            ENDCG
        }

        Pass {
            Tags { "LightMode"="ForwardBase" "Queue"="Transparent" "RenderType"="Transparent" }
            // Cull Front
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float4 _GlowColor;
            float _Strength;
            float _GlowRange;

            struct a2v {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
            };

            struct v2f {
                float4 position : SV_POSITION;
                float4 col : COLOR;
            };

            v2f vert(a2v a) {
                v2f o;
                float4x4 modelMatrix = unity_ObjectToWorld;
                float4x4 modelMatrixInverse = unity_WorldToObject;
                float3 normalDirection = normalize(mul(a.normal, modelMatrixInverse)).xyz;
                
                float3 viewDirection = normalize(_WorldSpaceCameraPos - mul(modelMatrix, a.vertex).xyz);
                float4 pos = a.vertex + (a.normal * _GlowRange);
                o.position = UnityObjectToClipPos(pos);
                float3 normalDirectionT = normalize(normalDirection);
                float3 viewDirectionT = normalize(viewDirection);
                float strength = abs(dot(viewDirectionT, normalDirectionT));
                float opacity = pow(strength, _Strength);
                float4 col = float4(_GlowColor.xyz, opacity);
                o.col = col;
                return o;
            }

            float4 frag(v2f i) : COLOR {
                return i.col;
            }

            ENDCG
        }

    }
    FallBack "Diffuse"
}