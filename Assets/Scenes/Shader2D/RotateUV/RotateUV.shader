Shader "Unlit/RotateUV"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Angle("Angle", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

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
            float _Angle;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float radian = 3.14/180*_Angle;
                float2 uv = i.uv.xy - float2(0.5, 0.5);//UV原点移动到UV中心点
                float s,c;
                sincos(radian,s,c);
                float3x3 rotateMatrix = float3x3(
                c,-s,0,
                s,c,0,
                0,0,1
                );
                uv = mul(rotateMatrix,uv);
                uv += float2(0.5, 0.5);//UV中心转移回原来原点位置

                fixed4 col = tex2D(_MainTex, uv);
                return col;
            }
            ENDCG
        }
    }
}
