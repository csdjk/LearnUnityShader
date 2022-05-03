Shader "lcl/shader2D/fog"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("color",Color) = (1,1,1,1)
        _FogDensity("FogDensity",Range(0,10)) = 4
    }
    SubShader
    {

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
            float4 _Color;
            float _FogDensity;

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
                float scale = 1;
                float res = 0;
                float w = 4;
                for(int i=0;i<_FogDensity;++i)
                {
                    res += noise(x * w);
                    w *= 1.5;
                }
                return res * 0.5;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                fixed3 col = tex2D(_MainTex, i.uv).rgb;
                float rd = fbm(i.uv+_Time.x);//柏林噪声
                fixed3 fogColor = _Color * rd;
                fixed3 newColor = lerp(col,fogColor,0.3);
                return fixed4(newColor,1);
            }
            ENDCG
        }
    }
}
