Shader "lcl/FilmInterference/SimpleColorRamp"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _ColorRamp ("ColorRamp", 2D) = "white" { }
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
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
             sampler2D _ColorRamp;
            float4 _ColorRamp_ST;
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
                half3 col = tex2D(_MainTex, i.uv);

                float3 normalWS = normalize(i.normalWS);
                float3 viewWS = normalize(i.viewWS);
                
                float NdotV = saturate(dot(normalWS, viewWS));
                float3 rampCol = tex2D(_ColorRamp, TRANSFORM_TEX(float2(NdotV, NdotV), _ColorRamp));

                half3 resCol = col * rampCol * _Color.rgb;
                return half4(resCol, 1.0);
            }
            ENDCG

        }
    }
    FallBack "Reflective/VertexLit"
}

