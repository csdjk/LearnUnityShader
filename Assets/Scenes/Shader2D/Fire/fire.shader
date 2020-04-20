Shader "lcl/shader2D/fire"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _scale("scale",Range(0,1)) = 0.2
        _speed("speed",Range(0,10)) = 2
        _len("len",Range(0.2,2)) = 1
    }
    SubShader
    {
        // Tags{
            //     "Queue" = "Transparent"
        // }
        Blend SrcAlpha OneMinusSrcAlpha
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _Color;
            float _scale;
            float _speed;
            float _len;
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
            //----柏林噪声---
            float rand(float2 p){
                return frac(sin(dot(p ,float2(12.9898,78.233))) * 43758.5453);
            }

            float noise(float2 x)
            {
                float2 i = floor(x);
                float2 f = frac(x);
                
                float a = rand(i);
                float b = rand(i + float2(1.0, 0.0));
                float c = rand(i + float2(0.0, 1.0));
                float d = rand(i + float2(1.0, 1.0));
                float2 u = f * f * f * (f * (f * 6 - 15) + 10);
                
                float x1 = lerp(a,b,u.x);
                float x2 = lerp(c,d,u.x);
                return lerp(x1,x2,u.y);
            }

            float fbm(float2 x)
            {
                float scale = 3;
                float res = 0;
                float w = 4;
                for(int i=0;i<4;++i)
                {
                    res += noise(x * w);
                    w *= 1.5;
                }
                return res*_scale;
            }
            //----柏林噪声  end---
           

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

           

            fixed4 frag (v2f i) : SV_Target
            {
                float4 rd = fbm(i.uv - float2(0,_Time.x * _speed));//柏林噪声
                float4 rd1 = fbm(i.uv - float2(0,_Time.x * _speed/2));//柏林噪声
                rd = (rd+rd1)/2;
                float4 col = rd * _Color;
                //通过插值计算 越高的透明度越接近0
                col = lerp(col,fixed4(0,0,0,0),i.uv.y);
                col = pow(col,_len);

                float4 mask = tex2D(_MainTex,i.uv);
                col = col*mask;
                //透明度小于0.4的裁剪掉
                clip(col.a - 0.6);
                return col;
            }
            ENDCG
        }
    }
}
