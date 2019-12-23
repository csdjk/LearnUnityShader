Shader "lcl/shader2D/fireTexNoise"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NoiseTex ("NoiseTex", 2D) = "white" {}
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
            sampler2D _NoiseTex;
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
          

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

           

            fixed4 frag (v2f i) : SV_Target
            {
                float4 noise = tex2D(_NoiseTex,i.uv- float2(0,_Time.x * _speed));
              
                float4 col = noise * _Color;
                // //通过插值计算 越高的透明度越接近0
                // col = lerp(col,fixed4(0,0,0,0),i.uv.y);
                // col = pow(col,_len);

                //透明度小于0.4的裁剪掉
                clip(noise.x - 0.2);
                return col;
            }
            ENDCG
        }
    }
}
