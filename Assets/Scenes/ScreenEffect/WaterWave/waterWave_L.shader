Shader "lcl/screenEffect/waterWave_L"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;

            float _waveLength;
            float _waveHeight;
            float _waveWidth;

            float _currentWaveDis;

            float4 _startPos;



            fixed4 frag (v2f i) : SV_Target
            {

                float2 scale = float2(_ScreenParams.x / _ScreenParams.y, 1);
                //计算该片元到中心点的距离
                float dis = distance(i.uv*scale,_startPos*scale);
                //通过sin计算偏移
                float offsetX = sin(dis * _waveLength) * _waveHeight * 0.05;
                
                //如果该片元不在波纹范围内 偏移设置为0
                if(dis <= _currentWaveDis || dis > _currentWaveDis + _waveWidth){
                    offsetX = 0;
                }
                float2 dv = _startPos.xy - i.uv;

                i.uv.x += offsetX ; 
                return tex2D(_MainTex, i.uv);	

            }
            ENDCG
        }
    }
}