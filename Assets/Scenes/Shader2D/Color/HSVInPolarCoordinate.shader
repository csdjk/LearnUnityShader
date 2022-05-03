Shader "lcl/shader2D/HSVInPolarCoordinate"
{
    
    SubShader
    {
        Pass
        {
            CGPROGRAM
            // vert_img 是 UnityCG.cginc 内置的
            #pragma vertex vert_img 
            #pragma fragment frag

            #include "UnityCG.cginc"

            #define TWO_PI 6.28318530718

            //  该函数由国外大神 Iñigo Quiles 提供
            //  https://www.shadertoy.com/view/MsS3Wc
            float3 hsb2rgb( float3 c ){
                float3 rgb = clamp( abs(fmod(c.x*6.0+float3(0.0,4.0,2.0),6)-3.0)-1.0, 0, 1);
                rgb = rgb*rgb*(3.0-2.0*rgb);
                return c.z * lerp( float3(1,1,1), rgb, c.y);
            }
            
            // ---------------------------【片元着色器】---------------------------
            fixed4 frag (v2f_img i) : SV_Target
            {
                fixed4 col;
                // 笛卡尔坐标系转换到极坐标系
                float2 toCenter = float2(0.5,0.5)-i.uv;
                float angle = atan2(toCenter.y,toCenter.x);
                float radius = length(toCenter)*2.0;

                // 将角度 从(-PI, PI) 映射到 (0,1)范围
                // 角度决定色相, 半径决定饱和度, 亮度固定
                col.rgb = hsb2rgb(float3((angle/TWO_PI)+0.5,radius,1.0));
                return col;
            }
            ENDCG
        }
    }
}
