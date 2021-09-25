// 能量球 - 表面
Shader "lcl/shader3D/GuiPaiQiGong/energyBallSurface"
{
    // ---------------------------【属性】---------------------------
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NoiseTex ("NoiseTex", 2D) = "white" {}
        _Color("Color",Color) = (1,1,1,1)
        _Speed("Speed",Range(-5,5)) = 1
        _Area("Area",Range(0,1)) = 0
    }
    // ---------------------------【子着色器】---------------------------
    SubShader
    {
        Blend SrcAlpha OneMinusSrcAlpha
        Tags{ "Queue" = "Transparent"}
        // ---------------------------【渲染通道】---------------------------
        Pass
        {
            ZWrite Off 
            CGPROGRAM
            #pragma vertex vert_front
            #pragma fragment frag_front

            #include "UnityCG.cginc"
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainTex_TexelSize;
            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;
            float4 _Color;
            float _Speed;
            float _Area;

            struct v2f_front
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f_front vert_front (appdata_base v)
            {
                v2f_front o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag_front (v2f_front i) : SV_Target
            {
                float2 uv_offset = float2(0,0);
                float angle = _Time.y * _Speed;
                uv_offset.x = angle;
                uv_offset.y = angle;
                i.uv += uv_offset;
                // 获取噪声纹理
                fixed3 col = tex2D(_NoiseTex,i.uv);
                float opacity = step(_Area,col.x);

                return fixed4(_Color.rgb,opacity);
            }
            ENDCG
        }
    }
}
