Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _TillingOfffset ("TillingOfffset", Vector) = (1, 1, 1, 1)
        _Distortion ("Distortion", Range(0, 1)) = 0.2
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 positionVS : TEXCOORD1;
                float3 normalVS : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _TillingOfffset;
            float _Distortion;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                o.positionVS = UnityObjectToViewPos(v.vertex) - UnityObjectToViewPos(float3(0, 0, 0));
                o.normalVS = mul(UNITY_MATRIX_V, UnityObjectToWorldNormal(v.normal)).xyz;


                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 uv = i.positionVS.xy * _TillingOfffset.xy + _TillingOfffset.zw;
                uv += i.normalVS.xy * _Distortion;
                fixed4 col = tex2D(_MainTex, uv);
                return col;
            }
            ENDCG
        }
    }
}
