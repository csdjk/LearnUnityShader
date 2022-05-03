Shader "lcl/shader3D/wave"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _waveLeng("wavelenth",Range(0,100)) = 10
        _swing("swing",Range(0,1)) = 0.5
        _waveRange("waveRange",Range(0,1)) = 0.2
        _smooth("smooth",Range(0,1)) = 0.2
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

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
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
            sampler2D _MainTex;
            float _waveLeng;
            float _waveRange;
            float _swing;
            float _smooth;
            
            static float2 center = float2(0.5,0.5);

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }


            fixed4 frag (v2f i) : SV_Target
            {
                float len = distance(center,i.uv);

                // if(len > _waveRange){
                //     _swing = 0;
                // }
                float swing = smoothstep(len,len+_smooth,_waveRange)*_swing;

                i.uv.y += sin(len*UNITY_PI*_waveLeng)*swing;

                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
