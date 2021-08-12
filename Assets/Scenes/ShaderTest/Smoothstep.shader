Shader "Unlit/Smoothstep"
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
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 col1 = float3(1,0,0);
                float3 col2 = float3(0,1,0);

                float dis = distance(float2(0.5f,0.5f),i.uv);

                float value = smoothstep(0.2f,0.3f,dis) - smoothstep(0.5f,0.6f,dis);

                float3 l = lerp(col1,col2,value);

                return  float4(l,1);
                // return col;
            }
            ENDCG
        }
    }
}
