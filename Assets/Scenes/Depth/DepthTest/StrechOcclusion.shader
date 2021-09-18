Shader "ShapeOutline/StrechOcclusion"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
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
                float4 screenPos : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            uniform fixed4 _OutlineColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.vertex);
                return o;
            }
            fixed4 frag (v2f i) : SV_Target
            {
                i.screenPos.xy = i.screenPos.xy/i.screenPos.w;
                fixed4 col1 = tex2D(_MainTex,i.screenPos.xy);
                fixed4 col2 = tex2D(_MainTex,float2(i.screenPos.x + 1/_ScreenParams.x,i.screenPos.y));
                fixed4 col3 = tex2D(_MainTex,float2(i.screenPos.x - 1/_ScreenParams.x,i.screenPos.y));
                fixed4 col4 = tex2D(_MainTex,i.screenPos.xy);
                fixed4 col5 = tex2D(_MainTex,float2(i.screenPos.x ,i.screenPos.y+ 1/_ScreenParams.y));
                fixed4 col6 = tex2D(_MainTex,float2(i.screenPos.x ,i.screenPos.y- 1/_ScreenParams.y));
                if((col1.x + col1.y + col1.z
                 + col2.x + col2.y + col2.z
                 + col3.x + col3.y + col3.z
                 + col4.x + col4.y + col4.z
                 + col5.x + col5.y + col5.z
                 + col6.x + col6.y + col6.z
                 )>0.01)
                return fixed4(_OutlineColor.rgb,i.vertex.z);
                else
                return fixed4(0,0,0,1);
            }
            ENDCG
        }
    }
}