// 深度图获取
Shader "lcl/Projection/ProjectionMatrix"
{
    Properties
    {
        _MainTex("Base (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

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
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
            float4x4 _ProjectionMatx;
            sampler2D _MainTex;

            v2f vert (appdata v)
            {
                v2f o;
                o.uv = v.uv;

                o.vertex = mul(mul(_ProjectionMatx, unity_ObjectToWorld), v.vertex);
                // o.vertex = mul(mul(UNITY_MATRIX_VP, unity_ObjectToWorld), v.vertex);
                // o.vertex = mul(mul(UNITY_MATRIX_P, unity_ObjectToWorld), v.vertex);
                // o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 screenCol = tex2D(_MainTex, i.uv);
                return screenCol;
            }
            ENDCG
        }
    }
}

