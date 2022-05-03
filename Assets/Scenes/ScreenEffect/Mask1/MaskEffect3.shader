//遮罩
Shader "lcl/screenEffect/MaskEffect3"
{
    Properties
    {
        // 被遮罩纹理
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        // 遮罩纹理
        _MaskTex ("Mask Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always
        Tags{   "Queue"="Transparent" }

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
            sampler2D _MaskTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 遮罩
                float mask = tex2D(_MaskTex, i.uv).a;
                // 颜色
                fixed4 mainCol = tex2D(_MainTex, i.uv);
             
                return mainCol* mask;
            }
            ENDCG
        }
    }
}
