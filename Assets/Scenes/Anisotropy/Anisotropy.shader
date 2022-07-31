Shader "lcl/Anisotropy/Anisotropy"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _FlowMap ("Flow Map", 2D) = "white" { }

        _NoiseTex ("Nosie Tex", 2D) = "black" { }
        _AnisoNoiseStrength ("Noise Shift", Range(0, 1)) = 0.3

        _AnisoShift ("Anisotropy Shift", Range(-2, 2)) = 0
        _AnisoSpecPower ("Anisotropy Specular Power", Range(0, 500)) = 10
        _AnisoStrength ("Anisotropy Strength", Range(0, 1)) = 1
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


            sampler2D _FlowMap;
            sampler2D _NoiseTex;
            float3 _Color;

            
            float _AnisoNoiseStrength;
            float _AnisoStrength;
            float _AnisoShift;
            float _AnisoSpecPower;
            
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
                float3 positionWS : TEXCOORD1;
                float3 tangentWS : TEXCOORD2;
                float3 binormalWS : TEXCOORD3;
                float3 normalWS : TEXCOORD4;
            };
            
            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord.xy;
                
                o.positionWS = mul(unity_ObjectToWorld, v.vertex).xyz;

                o.normalWS = UnityObjectToWorldNormal(v.normal);
                o.tangentWS = UnityObjectToWorldDir(v.tangent.xyz);
                o.binormalWS = cross(o.normalWS, o.tangentWS) * v.tangent.w;
                return o;
            }

            
            // // ------------Anisotropy---------------------------
            // half3 ShiftTangent(fixed3 T, fixed3 N, half shift)
            // {
            //     return normalize(T + shift * N);
            // }
            // half Anisotropy(fixed3 T, fixed3 V, fixed3 L, half specPower)
            // {
            //     fixed3 H = normalize(V + L);
            //     half HdotT = dot(T, H);
            //     half sinTH = sqrt(1 - HdotT * HdotT);
            //     half dirAtten = smoothstep(-1, 0, HdotT);
            //     return dirAtten * saturate(pow(sinTH, specPower));
            // }

            
            half4 frag(v2f i) : SV_Target
            {
                float3 positionWS = i.positionWS;
                float3 L = normalize(UnityWorldSpaceLightDir(positionWS));
                float3 V = normalize(UnityWorldSpaceViewDir(positionWS));
                float3 T = normalize(i.tangentWS);
                float3 B = normalize(i.binormalWS);
                float3 N = normalize(i.normalWS);
                
                float2 anisoFlowmap = tex2D(_FlowMap, i.uv).rg;
                anisoFlowmap = anisoFlowmap * 2 - 1;

                float2 shiftNoise = tex2D(_NoiseTex, i.uv).r;
                shiftNoise = (shiftNoise * 2 - 1) * _AnisoNoiseStrength;

                T = normalize(anisoFlowmap.x * T + anisoFlowmap.y * B);

                T = ShiftTangent(T, N, _AnisoShift + shiftNoise);
                half anisoSpec = AnisotropyKajiyaKay(T, V, L, _AnisoSpecPower);


                // ================================ Diffuse Specular ================================
                half diffuse_term = max(0, dot(N, L));
                half half_limbert = diffuse_term * 0.5 + 0.5;
                
                half3 diffuse = _Color * half_limbert * _LightColor0.rgb;
                

                half3 final_color = anisoSpec + diffuse;
                return half4(final_color, 1.0);
            }
            
            ENDCG
        }
    }
    FallBack "Specular"
}
