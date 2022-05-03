Shader "lcl/CommandBuffer/CommandBufferBakeTexture"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _Color ("Color", Color) = (1, 1, 1, 1)
        _PixelNumber ("PixelNumber", Range(0, 500)) = 200
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }
        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _PixelNumber;
            float4 _Color;

            v2f vert(appdata v)
            {
                v2f o;
                float2 uvRemapped = v.uv.xy;
                uvRemapped.y = 1. - uvRemapped.y;
                uvRemapped = uvRemapped * 2. - 1.;
                o.vertex = float4(uvRemapped.xy, 0., 1.);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // fixed4 col = tex2D(_MainTex, i.uv);
                half2 uv = floor(i.uv * _PixelNumber) / _PixelNumber;
                fixed4 col = tex2D(_MainTex, uv);
                return col * _Color;
            }
            ENDCG

        }
    }
}
