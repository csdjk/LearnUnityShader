Shader "lcl/shader2D/playerShadow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.uv.y = 1 - o.uv.y;
                return o;
            }

            sampler2D _MainTex;
            sampler2D _HeroTex;
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_HeroTex, i.uv);

                if(col.a > 0 ){
                    col.rgb = 0;
                }
                return col;
            }
            ENDCG
        }
    }
}
