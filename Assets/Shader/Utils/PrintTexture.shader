//打印纹理 Gamma Space or Linear Space
Shader "lcl/Common/PrintTexture"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [KeywordEnum(All,R,G,B,A,VertexColor)] _ShowValue("Pass Value",Int) = 0
        [Toggle(_INVERT_ON)]_Invert("Invert",int) = 0
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
            #pragma multi_compile _SHOWVALUE_ALL _SHOWVALUE_R _SHOWVALUE_G _SHOWVALUE_B _SHOWVALUE_A _SHOWVALUE_VERTEXCOLOR
            #pragma multi_compile __ _INVERT_ON

            struct appdata
            {
                float4 vertex : POSITION;
                fixed4 color : COLOR;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                fixed3 res = 1;
                #ifdef _SHOWVALUE_ALL
                    res = col;
                #elif _SHOWVALUE_R
                    res = col.r;
                #elif _SHOWVALUE_G
                    res = col.g;
                #elif _SHOWVALUE_B
                    res = col.b;
                #elif _SHOWVALUE_A
                    res = col.a;
                #elif _SHOWVALUE_A
                    res = i.color.rgb;
                #endif

                #ifdef _INVERT_ON
                    res = 1-res;
                #endif
                
                return fixed4(res,1);
            }
            ENDCG
        }
    }
}
