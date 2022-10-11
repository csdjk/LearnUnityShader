Shader "lcl/Common/Debugger"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        [KeywordEnum(Texture, Texture_R, Texture_G, Texture_B, Texture_A, VertexColor, VertexColor_R, VertexColor_G, VertexColor_B, VertexColor_A, normal, worldPos, uv0, uv1, uv2)] _ShowValue ("Pass Value", Int) = 0
        [KeywordEnum(None, GammaToLinear, LinearToGamma)] _ColorSpace ("Color Space", Int) = 0
        [Toggle(_INVERT_ON)]_Invert ("Invert", int) = 0
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
            #pragma multi_compile _SHOWVALUE_TEXTURE _SHOWVALUE_TEXTURE_R _SHOWVALUE_TEXTURE_G _SHOWVALUE_TEXTURE_B _SHOWVALUE_TEXTURE_A _SHOWVALUE_VERTEXCOLOR _SHOWVALUE_VERTEXCOLOR_R _SHOWVALUE_VERTEXCOLOR_G _SHOWVALUE_VERTEXCOLOR_B _SHOWVALUE_VERTEXCOLOR_A _SHOWVALUE_NORMAL _SHOWVALUE_WORLDPOS _SHOWVALUE_UV0 _SHOWVALUE_UV1 _SHOWVALUE_UV2
            #pragma multi_compile __ _INVERT_ON
            #pragma multi_compile _COLORSPACE_NONE _COLORSPACE_GAMMATOLINEAR _COLORSPACE_LINEARTOGAMMA

            struct appdata
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float3 normal : NORMAL;
                float4 uv : TEXCOORD0;
                float4 uv1 : TEXCOORD1;
                float4 uv2 : TEXCOORD2;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
                float3 normal : NORMAL;
                float4 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float4 uv1 : TEXCOORD2;
                float4 uv2 : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.uv1 = v.uv1;
                o.uv2 = v.uv2;
                o.color = v.color;
                o.normal = v.normal;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                float4 col = tex2D(_MainTex, i.uv);
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
                #elif _SHOWVALUE_WORLDPOS
                    res = i.worldPos;
                #elif _SHOWVALUE_UV0
                    res = i.uv.xyz;
                #elif _SHOWVALUE_UV1
                    res = i.uv1.xyz;
                #elif _SHOWVALUE_UV2
                    res = i.uv2.xyz;
                #endif


                // 颜色空间转换
                #ifdef _COLORSPACE_GAMMATOLINEAR
                    res = pow(res, 2.2);
                #elif _COLORSPACE_LINEARTOGAMMA
                    res = pow(res, 0.45);
                #endif

                #ifdef _INVERT_ON
                    res = 1 - res;
                #endif
                return float4(res, 1);
            }
            ENDCG
        }
    }
}
