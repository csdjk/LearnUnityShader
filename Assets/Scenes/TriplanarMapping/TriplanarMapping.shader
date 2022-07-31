Shader "lcl/TriplanarMapping/TriplanarMapping"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _BlendSmoothness ("Blend Smoothness", Float) = 15
        _Tiling ("Texture Tiling", Float) = 1
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
            #include "Assets\Shader\ShaderLibs\Node.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half _BlendSmoothness;
            half _Tiling;
            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
            };
            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.positionWS = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.normalWS = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                half3 N = normalize(i.normalWS);
                half4 color = TriplanarMapping(_MainTex, i.positionWS, N, _Tiling, _BlendSmoothness);
                return color;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}