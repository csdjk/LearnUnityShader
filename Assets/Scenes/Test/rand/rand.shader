Shader "lcl/rand"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _Scale ("_Scale", Vector) = (1, 1, 1, 1)
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
            #include "Assets\Shader\ShaderLibs\Noise.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half4 _Color;
            half4 _Scale;
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
                float3 normalWS : NORMAL;
                float3 positionWS : TEXCOORD1;
                float3 viewWS : TEXCOORD2;
            };
            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normalWS = UnityObjectToWorldNormal(v.normal);
                o.positionWS = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.viewWS = UnityWorldSpaceViewDir(o.positionWS);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            half4 frag(v2f i) : SV_Target
            {
                
                // half rand = random2(i.positionWS.xz * _Scale.x) * _Scale.z;
                // half rand = random(i.positionWS.xz * _Scale.x) * _Scale.z;
                half rand = noise1d(i.positionWS.x * _Scale.x) * _Scale.z;
                return rand;
            }
            ENDCG
        }
    }
    FallBack "Reflective/VertexLit"
}