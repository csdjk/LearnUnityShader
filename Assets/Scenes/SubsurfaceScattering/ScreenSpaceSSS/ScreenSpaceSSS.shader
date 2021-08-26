Shader "lcl/SubsurfaceScattering/ScreenSpaceSSS/ScreenSpaceSSS"  
{
    // ---------------------------【属性】---------------------------
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    // ---------------------------【子着色器】---------------------------
    SubShader
    {
        //后处理效果一般都是这几个状态  
        ZTest Always  
        Cull Off  
        ZWrite Off  
        Fog{ Mode Off } 

        CGINCLUDE
        #include "UnityCG.cginc"
        
        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        sampler2D _BlurTex;
        float4 _offsets;
        
        float _ScatteringStrenth;
        fixed4 _SSSColor;

        
        // ---------------------------【高斯模糊 - start】---------------------------
        struct v2fBlur  
        {  
            float4 pos : SV_POSITION;   //顶点位置  
            float2 uv  : TEXCOORD0;     //纹理坐标  
            float4 uv01 : TEXCOORD1;    //一个vector4存储两个纹理坐标  
            float4 uv23 : TEXCOORD2;    //一个vector4存储两个纹理坐标  
        };  

        //高斯模糊顶点着色器
        v2fBlur vertBlur(appdata_img v)  
        {  
            v2fBlur o;  
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
        fixed4 fragBlur(v2fBlur i) : SV_Target  
        {  
            fixed4 color = fixed4(0,0,0,0);  
            color += 0.4026 * tex2D(_MainTex, i.uv);  
            color += 0.2442 * tex2D(_MainTex, i.uv01.xy);  
            color += 0.2442 * tex2D(_MainTex, i.uv01.zw);  
            color += 0.0545 * tex2D(_MainTex, i.uv23.xy);  
            color += 0.0545 * tex2D(_MainTex, i.uv23.zw);  
            return color;  
        }
        // ---------------------------【高斯模糊 - end】---------------------------

        // ---------------------------【合并 - start】---------------------------
        struct v2fBloom {
            float4 pos : SV_POSITION; 
            half2 uv : TEXCOORD0;
        };
        // 顶点着色器
        v2fBloom vertBloom(appdata_img v) {
            v2fBloom o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;
            return o;
        }
        
        // 片元着色器
        fixed4 fragBloom(v2fBloom i) : SV_Target {
            //对原图进行uv采样
            fixed4 srcCol = tex2D(_MainTex, i.uv);
            //对模糊处理后的图进行uv采样
            fixed4 blurCol = tex2D(_BlurTex, i.uv);

            blurCol = saturate(srcCol-blurCol );//散射像素落地的范围
            
            float fac = 1-pow(saturate(max(max(srcCol.r, srcCol.g), srcCol.b) * 1), 0.5);

            return srcCol + blurCol * _SSSColor * _ScatteringStrenth * fac;
            // return blurCol;
        } 
        // ---------------------------【Bloom - end】---------------------------

        ENDCG
        //高斯模糊
        Pass {
            CGPROGRAM
            #pragma vertex vertBlur  
            #pragma fragment fragBlur
            ENDCG  
        }

        // Bloom
        Pass {
            CGPROGRAM
            #pragma vertex vertBloom  
            #pragma fragment fragBloom
            ENDCG  
        }

    }
}
