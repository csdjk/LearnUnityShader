


Shader "lcl/Matcap/MatcapReflection"
{
    Properties
    {
        _MatcapTex ("Matcap Texture", 2D) = "white" { }
        _Center ("Center", Vector) = (0, 0, 0, 1)
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            sampler2D _MatcapTex;
            half4 _Center;

            struct a2v
            {
                float4 vertex : POSITION;
            };
            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 positionVS : TEXCOORD0;
            };
            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.positionVS = v.vertex.xyz;
                return o;
            }
            half4 frag(v2f i) : SV_Target
            {
                float3 dir = i.positionVS - _Center;
                dir = UnityObjectToWorldDir(dir);
                dir = UnityWorldToViewPos(dir);
                float2 uv = dir.xy * 0.5 + 0.5;

                float4 matcapColor = tex2D(_MatcapTex, uv);
                return matcapColor;
            }
            ENDCG
        }
    }
    FallBack "Reflective/VertexLit"
}