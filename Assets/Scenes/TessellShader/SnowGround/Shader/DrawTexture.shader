Shader "lcl/DrawTexture/DrawTextureShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma enable_d3d11_debug_symbols

            #include "UnityCG.cginc"

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

            

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            float4 _Pos;
            float4 _Color;
            float _Size;
            float _Strength;
            fixed4 frag (v2f i) : SV_Target
            {
                // float2 uv = i.uv;
                // return length(uv - _Pos.xy);
                // return max(_Pos.z - length(uv - _Pos.xy)/_Pos.z,0) + tex2D(_SourceTex,uv).x;

                // 一：
                float4 col = tex2D(_MainTex,i.uv);
                float4 draw = pow(saturate(1-distance(i.uv,_Pos.xy)),500/_Size);
                float4 drawCol = _Color * draw * _Strength;
                return saturate(col + drawCol);

                // 二：
                // float4 col = tex2D(_MainTex,i.uv);
                // float dis = distance(i.uv,_Pos.xy);
                // float isDraw = step(dis,_Size/100);
                // float4 drawCol = isDraw * _Color + (1-isDraw)*col;
                // return drawCol;
            }
            ENDCG
        }
    }
}
