Shader "lcl/PBR/Anisotropy"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _AnisotropicPowerValue ("AnisotropicPowerValue", Range(0, 10)) = 0
        _AnisotropicPowerScale ("AnisotropicPowerScale", Range(0, 10)) = 0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 tangent : TANGENT;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _AnisotropicPowerValue;
            float _AnisotropicPowerScale;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.tangent = v.tangent;
                o.normal = mul(v.normal, (float3x3) unity_WorldToObject);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }


            float StrandSpecular(float3 T, float3 V, float3 L, float exponent, float strength)
            {
                float3 H = normalize(V + L);
                float dotTH = dot(T, H);
                float sinTH = sqrt(1 - dotTH * dotTH);
                float dirAtten = smoothstep(-1, 0, dotTH);
                return dirAtten * pow(sinTH, exponent) * strength;
            }

            float3 ShiftTangent(float3 T, float3 N, float shift)
            {
                float3 shiftedT = T + shift * N;
                return normalize(shiftedT);
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                float3 T = i.tangent.xyz;
                float3 N = i.normal.xyz;
                float3 V = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 L = normalize(UnityWorldSpaceLightDir(i.worldPos));

                // float3 T_Shift = normalize(T + N);
                // float3 H = normalize(V + L);
                // //因为 sin^2+cos^2 =1 所以 sin = sqrt(1-cos^2)
                // float dotTH = dot(T_Shift, H);
                // float sinTH = sqrt(1 - dotTH * dotTH);

                // float dirAtten = smoothstep(-1, 0, dotTH);
                // float Specular = dirAtten * pow(sinTH, _AnisotropicPowerValue) * _AnisotropicPowerScale;


                fixed3 res = StrandSpecular(T, V, L, _AnisotropicPowerValue, _AnisotropicPowerScale);
                return fixed4(res, 1);
            }
            ENDCG

        }
    }
}
