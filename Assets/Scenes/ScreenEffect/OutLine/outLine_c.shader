// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "lcl/screenEffect/outLine_c"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        CGINCLUDE
        #include "UnityCG.cginc"
        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        float4 _offsets;
       
        //高斯模糊-------------start-----------------
        struct v2f_blur  
        {  
            float4 pos : SV_POSITION;   //顶点位置  
            float2 uv  : TEXCOORD0;     //纹理坐标  
            float4 uv01 : TEXCOORD1;    //一个vector4存储两个纹理坐标  
            float4 uv23 : TEXCOORD2;    //一个vector4存储两个纹理坐标  
        };  

        //高斯模糊顶点着色器
        v2f_blur vert_blur(appdata_img v)  
        {  
            v2f_blur o;  
            o.pos = UnityObjectToClipPos(v.vertex);  
            //uv坐标  
            o.uv = v.texcoord.xy;  
            
            //计算一个偏移值，offset可能是（1，0，0，0）也可能是（0，1，0，0）这样就表示了横向或者竖向取像素周围的点  
            _offsets *= _MainTex_TexelSize.xyxy;  
            
            //由于uv可以存储4个值，所以一个uv保存两个vector坐标，_offsets.xyxy * float4(1,1,-1,-1)可能表示(0,1,0-1)，表示像素上下两个  
            //坐标，也可能是(1,0,-1,0)，表示像素左右两个像素点的坐标，下面*2.0，*3.0同理  
            o.uv01 = v.texcoord.xyxy + _offsets.xyxy * float4(1, 1, -1, -1);  
            o.uv23 = v.texcoord.xyxy + _offsets.xyxy * float4(1, 1, -1, -1) * 2.0;  
            return o;  
        }  
        
        //高斯模糊片段着色器
        fixed4 frag_blur(v2f_blur i) : SV_Target  
        {  
            fixed4 color = fixed4(0,0,0,0);  
            color += 0.4026 * tex2D(_MainTex, i.uv);  
            color += 0.2442 * tex2D(_MainTex, i.uv01.xy);  
            color += 0.2442 * tex2D(_MainTex, i.uv01.zw);  
            color += 0.0545 * tex2D(_MainTex, i.uv23.xy);  
            color += 0.0545 * tex2D(_MainTex, i.uv23.zw);  
            return color;  
        }
        //高斯模糊-------------end-----------------

        //Blur图和原图进行相减获得轮廓
        sampler2D _BlurTex;
        sampler2D _SrcTex;
        fixed4 _OutlineColor;

        struct v2f_cull
        {
            float4 pos : SV_POSITION;
            half2 uv: TEXCOORD0;
        };
        v2f_cull vert_cull(appdata_img v)
        {
            v2f_cull o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord.xy;
            //dx中纹理从左上角为初始坐标，需要反向
            //通过判断_MainTex_TexelSize.y是否小于0来检验是否开启了抗体锯齿
            #if UNITY_UV_STARTS_AT_TOP
                if (_MainTex_TexelSize.y < 0)
                o.uv.y = 1 - o.uv.y;
            #endif	
            return o;
        }
        
        fixed4 frag_cull(v2f_cull i) : SV_Target
        {
            //取原始场景纹理进行采样
            fixed4 mainColor = tex2D(_MainTex, i.uv);

            //对blur之前的rt进行采样
            fixed4 srcColor = tex2D(_SrcTex, i.uv);
            //对blur后的纹理进行采样
            fixed4 blurColor = tex2D(_BlurTex, i.uv);
            //最后的颜色是 blurColor - srcColor
            fixed4 outline = ( blurColor - srcColor)*_OutlineColor;
            //输出：blur部分为0的地方返回原始图像，否则为0，然后叠加描边
            // fixed4 final = mainColor * (1 - all(outline.rgb)) + _OutlineColor * any(outline.rgb);//0.01,1,1
            fixed4 final = saturate(outline) + mainColor;
            return final;
        }

        ENDCG
        
        Cull Off ZWrite Off ZTest Always
        
        //高斯模糊
        Pass {
            CGPROGRAM
            #pragma vertex vert_blur  
            #pragma fragment frag_blur
            ENDCG  
        }
        
        //轮廓图
        Pass {  
            CGPROGRAM  
            #pragma vertex vert_cull  
            #pragma fragment frag_cull
            ENDCG
        }
    }
    FallBack "Diffuse"

}
