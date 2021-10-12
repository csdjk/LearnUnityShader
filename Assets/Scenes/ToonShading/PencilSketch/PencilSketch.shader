///  Reference: 	Lake A, Marshall C, Harris M, et al. Stylized rendering techniques for scalable real-time 3D animation[C]
///						Proceedings of the 1st international symposium on Non-photorealistic animation and rendering. ACM, 2000: 13-20.
///
Shader "lcl/PencilSketch/PencilSketch" {
    Properties {
        _Color ("Diffuse Color", Color) = (1, 1, 1, 1)
        _Outline ("Outline", Range(0.001, 1)) = 0.1
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
        _TileFactor ("Tile Factor", Range(1, 10)) = 5
        _Level1 ("Level 1 (Darkest)", 2D) = "white" {}
        _Level2 ("Level 2 ", 2D) = "white" {}
        _Level3 ("Level 3 ", 2D) = "white" {}
        _Level4 ("Level 4 ", 2D) = "white" {}
        _Level5 ("Level 5 ", 2D) = "white" {}
        _Level6 ("Level 6 ", 2D) = "white" {}
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200
        
        // UsePass "NPR/Cartoon/Antialiased Cel Shading/OUTLINE"
        
        Pass {
            Tags { "LightMode"="ForwardBase" }
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            #pragma multi_compile_fwdbase
            
            #pragma glsl
            
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #include "UnityShaderVariables.cginc"
            
            #define DegreeToRadian 0.0174533
            
            fixed4 _Color;
            float _TileFactor;
            sampler2D _Level1;
            sampler2D _Level2;
            sampler2D _Level3;
            sampler2D _Level4;
            sampler2D _Level5;
            sampler2D _Level6;
            
            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
                float4 tangent : TANGENT;
            }; 
            
            struct v2f {
                float4 pos : POSITION;
                float4 scrPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldLightDir : TEXCOORD2;
                float3 worldPos : TEXCOORD3;	
                SHADOW_COORDS(4)
            };
            
            v2f vert (a2v v) {
                v2f o;
                
                o.pos = UnityObjectToClipPos( v.vertex);
                o.worldNormal  = mul(v.normal, (float3x3)unity_WorldToObject);
                o.worldLightDir = WorldSpaceLightDir(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.scrPos = ComputeScreenPos(o.pos);
                
                TRANSFER_SHADOW(o);
                
                return o;
            }
            
            float4 frag(v2f i) : COLOR { 
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(i.worldLightDir);
                fixed2 scrPos = i.scrPos.xy / i.scrPos.w * _TileFactor;
                
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
                
                fixed diff = (dot(worldNormal, worldLightDir) * 0.5 + 0.5) * atten * 6.0;
                fixed3 fragColor;
                if (diff < 1.0) {
                    fragColor = tex2D(_Level1, scrPos).rgb;
                    } else if (diff < 2.0) {
                    fragColor = tex2D(_Level2, scrPos).rgb;
                    } else if (diff < 3.0) {
                    fragColor = tex2D(_Level3, scrPos).rgb;
                    } else if (diff < 4.0) {
                    fragColor = tex2D(_Level4, scrPos).rgb;
                    } else if (diff < 5.0) {
                    fragColor = tex2D(_Level5, scrPos).rgb;
                    } else {
                    fragColor = tex2D(_Level6, scrPos).rgb;
                }
                
                fragColor *= _Color.rgb * _LightColor0.rgb;
                
                return fixed4(fragColor, 1.0);
            } 
            
            ENDCG
        }
    }
    FallBack "Diffuse"
}
