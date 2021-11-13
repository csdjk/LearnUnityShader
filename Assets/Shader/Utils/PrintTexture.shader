//打印纹理
Shader "lcl/Common/PrintTexture"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [KeywordEnum(All,R,G,B,A,vertexColor,normal,uv0,uv1,uv2)] _ShowValue("Pass Value",Int) = 0
        [Toggle(_INVERT_ON)]_Invert("Invert",int) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        ZWrite ON

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #pragma multi_compile _SHOWVALUE_ALL _SHOWVALUE_R _SHOWVALUE_G _SHOWVALUE_B _SHOWVALUE_A _SHOWVALUE_VERTEXCOLOR _SHOWVALUE_NORMAL _SHOWVALUE_UV0 _SHOWVALUE_UV1 _SHOWVALUE_UV2
            #pragma multi_compile __ _INVERT_ON

            struct appdata
            {
                float4 vertex : POSITION;
                fixed4 color : COLOR;
                float3 normal : NORMAL;
                float4 uv : TEXCOORD0;
                float4 uv1 : TEXCOORD1;
                float4 uv2 : TEXCOORD2;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
                float3 normal : NORMAL;
                float4 uv1 : TEXCOORD1;
                float4 uv2 : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.uv1 = v.uv1;
                o.uv2 = v.uv2;
                o.color = v.color;
                o.normal = v.normal;
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
                #elif _SHOWVALUE_UV0
                    res = i.uv.xyz;
                #elif _SHOWVALUE_UV1
                    res = i.uv1.xyz;
                #elif _SHOWVALUE_UV2
                    res = i.uv2.xyz;
                #elif _SHOWVALUE_VERTEXCOLOR
                    res = i.color.rgb;
                #elif _SHOWVALUE_NORMAL
                    res = i.normal;
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
