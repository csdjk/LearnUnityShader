// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "lcl/ddxddy/MipMap/mipmap_ddxddy"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [Toggle(_OPEN_MIMMAP_ON)] _OPEN_MIMMAP("Open MimMap", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // #pragma multi_compile _OPEN_MIMMAP_ON
            #pragma shader_feature _OPEN_MIMMAP_ON

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv,_MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 默认会计算MipMap等级
                // half4 c = tex2D(_MainTex, i.uv);
                half4 c = 0;
                #ifdef _OPEN_MIMMAP_ON
                    // ddx ddy计算MipMap等级
                    c = tex2D(_MainTex, i.uv,ddx(i.uv),ddy(i.uv));
                #else
                    // 不计算MipMap等级
                    c = tex2Dlod(_MainTex,float4(i.uv,0,0));
                #endif
                return c;
            }
            ENDCG
        }
    }
}
