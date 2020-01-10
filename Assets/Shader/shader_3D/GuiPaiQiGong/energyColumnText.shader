// 能量柱
Shader "lcl/shader3D/GuiPaiQiGong/energyColumnText"
{
    Properties
    {
        _NoiseTex ("NoiseTex", 2D) = "white" {}
        _Color("Color",Color) = (1,1,1,1)
        _Color1("Color1",Color) = (1,1,1,1)
        _Speed("Speed",Range(-5,5)) = 1
        _Area("Area",Range(0,1)) = 0
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
            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;
            float4 _Color;
            float4 _Color1;
            float _Speed;
            float _Area;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _NoiseTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv_offset = float2(0,0);
                uv_offset.x = _Time.y * _Speed;
                uv_offset.y = _Time.y * _Speed;
                i.uv += uv_offset;
                fixed3 col = tex2D(_NoiseTex,i.uv);
                float a = step(_Area,col.x);
                fixed3 result = lerp(_Color,_Color1,1-col.x);

                return fixed4(result.rgb,a);
            }
            ENDCG
        }
    }
}
