Shader "ShapeOutline/Depth"
{
    Properties
    {
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
                float2 depth : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.depth  = o.vertex.zw;
                return o;
            }
            fixed4 frag (v2f i) : SV_Target
            {
                float depth = i.vertex.z/i.vertex.w;

                return fixed4(depth,depth,depth,0);
            }
            ENDCG
        }
    }
}