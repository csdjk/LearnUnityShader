Shader "lcl/shader3D/Emissive/EmissiveInto" {
    Properties {
        _MainTex ("node_8448", 2D) = "gray" {}
        [HDR]_Color ("node_708", Color) = (0.2214533,0.64336,0.9411765,1)
        _Glow ("node_4610", Range(0, 10)) = 1.880342
    }
    SubShader {
        Tags {
            "RenderType"="Opaque"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"

            sampler2D _MainTex;  
            float4 _MainTex_ST;
            float4 _Color;
            float _Glow;
            
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 worldPos : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                UNITY_FOG_COORDS(3)
            };
            VertexOutput vert (appdata_base v) {
                VertexOutput o;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.pos = UnityObjectToClipPos( v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                // 法线方向和视野方向
                float3 normalDir = normalize(i.normalDir);
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                
                float4 col = tex2D(_MainTex,i.uv);
                float3 finalColor = (col.rgb+(pow(1.0-max(0,dot(normalDir, viewDir)),_Glow)*_Color.rgb));
                fixed4 finalRGBA = fixed4(finalColor,1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}