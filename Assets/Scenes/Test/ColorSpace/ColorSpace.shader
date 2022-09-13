Shader "lcl/ColorSpace"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _Color ("Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

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
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half4 _Color;
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                // col.rgb = GammaToLinearSpace(col.rgb);
                col.rgb = pow(col.rgb, 2.2);
                // col.rgb = LinearToGammaSpace(col.rgb);

                col.rgb *= _Color;

                col.rgb = pow(col.rgb, 0.45);
                // col.rgb = LinearToGammaSpace(col.rgb);
                // col.rgb = GammaToLinearSpace(col.rgb);
                return col;
            }
            ENDCG
        }
    }
}
