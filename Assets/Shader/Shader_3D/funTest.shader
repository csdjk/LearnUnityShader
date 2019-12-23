Shader "lcl/funTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",Color) = (1,1,1,1)
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
            float4 _Color;


            // 绘制直线
            float3 DrawLine(float2 uv){
                // 线的宽度
                float lineWidth = 0.01;
                // 直线方程 f(y) = ax+b; 求出对应的y值
                float y = 1 * uv.x + 0;
                // step(a,x) (step函数: 如果 a>x，返回0；否则，返回1)
                // 约束y值范围.  计算y值与uv.y值的差值的绝对值, 如果不在[0-lineWidth]范围内,就属于背景,颜色值为0. 否则为线条颜色,1
                float col = step(abs(y - uv.y),lineWidth); 
                return float3(col,col,col);
            }



            float3 DrawSmoothstep(float2 uv){
                // uv+=0.5;
                float val = smoothstep(0.0,1.0,uv.x);
                val = step(abs(val-uv.y),0.01); 
                return float3(val,val,val);
            }

            

            float3 DrawCircle(float2 uv){
                float val = (1.0-length(uv)*5);
                val = smoothstep(0.0,0.1,val);
                return float3(val,val,val);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                float3 val = DrawCircle(i.uv);
                return float4(val,1)*_Color;
            }
            ENDCG
        }
    }
}
