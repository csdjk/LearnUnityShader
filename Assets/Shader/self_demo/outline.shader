Shader "lcl/selfDemo/outline"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _lineWidth("lineWidth",Range(0,10)) = 1
        _lineColor("lineColor",Color)=(1,1,1,1)
    }
    SubShader
    {
        Tags{
            "Queue" = "Transparent"
        }
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
                return o;
            }

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            float _lineWidth;
            float4 _lineColor;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                float2 up_uv = i.uv + float2(0,1) * _lineWidth * _MainTex_TexelSize.xy;
                float2 down_uv = i.uv + float2(0,-1) * _lineWidth * _MainTex_TexelSize.xy;
                float2 left_uv = i.uv + float2(-1,0) * _lineWidth * _MainTex_TexelSize.xy;
                float2 right_uv = i.uv + float2(1,0) * _lineWidth * _MainTex_TexelSize.xy;

                float w = tex2D(_MainTex,up_uv).a *tex2D(_MainTex,down_uv).a *tex2D(_MainTex,left_uv).a *tex2D(_MainTex,right_uv).a;

                // if(w == 0){
                //    col.rgb = _lineColor;
                // }
                col.rgb = lerp(_lineColor,col.rgb,w);

                return col;
            }
            ENDCG
        }
    }
}
