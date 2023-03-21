Shader "lcl/Matcap/SimpleMatcap"
{
    Properties
    {
        _MatcapTex ("Matcap Texture", 2D) = "white" { }
        _Color ("Color", Color) = (1, 1, 1, 1)
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
            half4 _Color;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };
            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                // matcap uv
                // https://blog.csdn.net/puppet_master/article/details/83582477
                float3 viewnormal = normalize(mul(UNITY_MATRIX_IT_MV, v.normal));
                o.uv = viewnormal.xy * 0.5 + 0.5;


                // matcap uv2 (推荐使用这种方式,性价比高\效果好)
                // float3 viewnormal = mul(UNITY_MATRIX_IT_MV, v.normal);
                // float3 viewPos = UnityObjectToViewPos(v.vertex);
                // viewPos = normalize(viewPos);
                // float3 vcn = cross(viewPos, viewnormal);
                // float2 uv = float2(-vcn.y, vcn.x);
                // o.uv = uv * 0.5 + 0.5;

                // matcap uv3
                // float3 viewnormal = mul(UNITY_MATRIX_IT_MV, v.normal);
                // viewnormal = normalize(viewnormal);
                // float3 viewPos = UnityObjectToViewPos(v.vertex);
                // float3 r = reflect(viewPos, viewnormal);
                // float m = 2.0 * sqrt(r.x * r.x + r.y * r.y + (r.z + 1) * (r.z + 1));
                // o.uv = r.xy / m + 0.5;

                
                return o;
            }
            half4 frag(v2f i) : SV_Target
            {
                float3 matcapColor = tex2D(_MatcapTex, i.uv);

                half3 resCol = matcapColor * _Color.rgb;
                return half4(resCol, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Reflective/VertexLit"
}