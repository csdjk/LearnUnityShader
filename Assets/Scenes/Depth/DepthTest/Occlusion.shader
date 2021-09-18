Shader "ShapeOutline/Occlusion"
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
                float4 ScreenPos : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
            sampler2D _MainTex;
            float4 _MainTex_ST;
            uniform sampler2D _CameraDepthTexture;
            fixed4 _OutlineColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.ScreenPos = ComputeScreenPos(o.vertex);
                return o;
            }
            fixed4 frag (v2f i) : SV_Target
            {
                i.ScreenPos.xy = i.ScreenPos.xy/i.ScreenPos.w;
                float2 uv = float2(i.ScreenPos.x,i.ScreenPos.y);
                float depth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, uv));
                float depthTex = tex2D(_MainTex,i.ScreenPos.xy);
                if((depthTex > depth) && depthTex!= 1)
                    return fixed4(_OutlineColor.rgb,i.vertex.z);
                else
                    return fixed4(0,0,0,1);
            }
            ENDCG
        }
    }
}