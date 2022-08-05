//打印纹理 Gamma Space or Linear Space
Shader "lcl/Common/ConvertColorSpace"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [KeywordEnum(None,Gamma,Linear)] _ColorSpace("Color Space",Int) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #pragma multi_compile _COLORSPACE_NONE _COLORSPACE_GAMMA _COLORSPACE_LINEAR

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            int _ColorSpace;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                #ifdef _COLORSPACE_GAMMA
                    //Linear => Gamma
                    col = pow(col,0.45);
                #elif _COLORSPACE_LINEAR
                    //Gamma => Linear
                    col = pow(col,2.2);
                #endif
                return col;
            }
            ENDCG
        }
    }
}
