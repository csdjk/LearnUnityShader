// ---------------------------【径向模糊】---------------------------
Shader "lcl/screenEffect/RadialBlur"
{
    // ---------------------------【属性】---------------------------
    Properties 
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
    }
    // ---------------------------【子着色器】---------------------------
    SubShader
    {
        Pass
        {
            ZTest Always
            Cull Off
            ZWrite Off
            Fog{ Mode off }
            
            //调用CG函数	
            CGPROGRAM
            //使效率更高的编译宏
            #pragma fragmentoption ARB_precision_hint_fastest 
            //vert_img 是在UnityCG.cginc中内置的
            #pragma vertex vert_img
            #pragma fragment frag 

            #include "UnityCG.cginc"
            uniform sampler2D _MainTex;
            uniform float _BlurFactor;	//模糊强度
            uniform float2 _BlurCenter; //模糊中心点
            
            // ---------------------------【片元着色器】---------------------------
            fixed4 frag(v2f_img i) : SV_Target
            {
                //模糊方向: 中心像素 - 当前像素
                float2 dir = _BlurCenter.xy - i.uv ;
                float4 resColor = 0;
                //迭代
                for (int j = 0; j < 5; ++j)
                {
                    //计算采样uv值：正常uv值+从中间向边缘逐渐增加的采样距离
                    float2 uv = i.uv + _BlurFactor * dir * j;
                    resColor += tex2D(_MainTex, uv);
                }
                //取平均值(乘法比除法性能好)
                resColor *= 0.2;
                return resColor;
            }
            ENDCG
        }
    }
    Fallback off
}
