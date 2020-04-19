Shader "lcl/shader2D/HSV"
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
                // hsb 转换为 rgb
                // uv.x  决定 色相, 
                // uv.y  决定 亮度, 
                col.rgb = hsb2rgb(float3(i.uv.x, 1, 1-i.uv.y));
                return col;
            }
            ENDCG
        }
    }
}
