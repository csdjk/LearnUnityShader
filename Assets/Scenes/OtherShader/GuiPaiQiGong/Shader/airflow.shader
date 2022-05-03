// 气流
Shader "lcl/shader3D/GuiPaiQiGong/baseAirflow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",Color) = (1,1,1,1)
        _Speed("Speed",Range(-5,5)) = 1
        _TexScale("TexScale",Range(0,10)) = 1
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _Speed;
            float _TexScale;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }


            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv_offset = float2(0,0);
                uv_offset.x = _Time.y * _Speed;
                // uv_offset.y = _Time.y * 0.25;

                // fixed4 col = tex2D(_MainTex, i.uv+uv_offset);
                // fixed3 result = lerp(col,_Color,col);
                // fixed alpha = step(0.1,col.x);
                // return fixed4(_Color.rgb,alpha);

                float2x2 scaleM = float2x2(_TexScale,0,0,_TexScale);
                i.uv = mul(scaleM,i.uv);
                fixed4 col = tex2D(_MainTex, i.uv+uv_offset);

                // fixed3 result = lerp(col,_Color,col.a);
                return fixed4(_Color.rgb,col.a);
            }
            ENDCG
        }
    }
}
