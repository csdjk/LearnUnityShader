Shader "lcl/Debugger"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" { }
        [KeywordEnum(Texture, Texture_R, Texture_G, Texture_B, Texture_A, VertexColor, VertexColor_R, VertexColor_G, VertexColor_B, VertexColor_A, normal, tangent, worldPos, uv0, uv1, uv2)] _ShowValue ("Pass Value", Int) = 0
        [Toggle(_INVERT_ON)]_Invert ("Invert", int) = 0
        _Gamma ("Gamma", Float) = 1

        _ScleraSize ("Size", Range(0, 2)) = 1
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        ZWrite ON

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #pragma multi_compile _SHOWVALUE_TEXTURE _SHOWVALUE_TEXTURE_R _SHOWVALUE_TEXTURE_G _SHOWVALUE_TEXTURE_B _SHOWVALUE_TEXTURE_A _SHOWVALUE_VERTEXCOLOR _SHOWVALUE_VERTEXCOLOR_R _SHOWVALUE_VERTEXCOLOR_G _SHOWVALUE_VERTEXCOLOR_B _SHOWVALUE_VERTEXCOLOR_A _SHOWVALUE_NORMAL _SHOWVALUE_TANGENT _SHOWVALUE_WORLDPOS _SHOWVALUE_UV0 _SHOWVALUE_UV1 _SHOWVALUE_UV2
            #pragma multi_compile __ _INVERT_ON

            struct appdata
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 uv : TEXCOORD0;
                float4 uv1 : TEXCOORD1;
                float4 uv2 : TEXCOORD2;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
                float3 normal : NORMAL;
                float3 tangent : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float4 uv : TEXCOORD2;
                float4 uv1 : TEXCOORD3;
                float4 uv2 : TEXCOORD4;
            };
            float4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _ScleraSize;
            float _Gamma;
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv1 = v.uv1;
                o.uv2 = v.uv2;
                o.color = v.color;
                o.normal = v.normal;
                o.tangent = v.tangent.xyz;
                o.worldPos = mul(UNITY_MATRIX_M, v.vertex);
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {

                // ================================ Test ================================
                // // 虹膜大小
                // float temp = 1 * (0.5 - _ScleraSize);
                // float2 eyeUV = i.uv.xy * (temp + 1) - (temp * 0.5);


                // float2 scleraUV = i.uv.xy * _ScleraSize - (_ScleraSize - 1) * 0.5;
                // float4 color = tex2D(_MainTex, eyeUV);
                // return color;
                // ================================  ================================



                float4 col = tex2D(_MainTex, i.uv) * _Color;
                float3 res = 1;
                #ifdef _SHOWVALUE_TEXTURE
                    res = col;
                #elif _SHOWVALUE_TEXTURE_R
                    res = col.r;
                #elif _SHOWVALUE_TEXTURE_G
                    res = col.g;
                #elif _SHOWVALUE_TEXTURE_B
                    res = col.b;
                #elif _SHOWVALUE_TEXTURE_A
                    res = col.a;
                #elif _SHOWVALUE_VERTEXCOLOR
                    res = i.color.rgb;
                #elif _SHOWVALUE_VERTEXCOLOR_R
                    res = i.color.r;
                #elif _SHOWVALUE_VERTEXCOLOR_G
                    res = i.color.g;
                #elif _SHOWVALUE_VERTEXCOLOR_B
                    res = i.color.b;
                #elif _SHOWVALUE_VERTEXCOLOR_A
                    res = i.color.a;
                #elif _SHOWVALUE_NORMAL
                    res = i.normal;
                #elif _SHOWVALUE_TANGENT
                    res = i.tangent;
                #elif _SHOWVALUE_WORLDPOS
                    res = i.worldPos;
                #elif _SHOWVALUE_UV0
                    res = i.uv.xyz;
                #elif _SHOWVALUE_UV1
                    res = i.uv1.xyz;
                #elif _SHOWVALUE_UV2
                    res = i.uv2.xyz;
                #endif

                #ifdef _INVERT_ON
                    res = 1 - res;
                #endif
                return float4(pow(res, _Gamma), 1);


                // return 0.35;

            }
            ENDCG
        }
    }
}
