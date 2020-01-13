// ---------------------------【均值模糊】---------------------------
//create by 长生但酒狂
Shader "lcl/screenEffect/SimpleBlur"  
{  
    // ---------------------------【属性】---------------------------
    Properties  
    {  
        _MainTex("MainTex", 2D) = "white" {}  
    }  
    // ---------------------------【子着色器】---------------------------
    SubShader  
    {  
        //后处理效果一般都是这几个状态  
        ZTest Always  
        Cull Off  
        ZWrite Off  
        Fog{ Mode Off }  
        // ---------------------------【渲染通道】---------------------------
        Pass  
        {  
            // ---------------------------【CG代码】---------------------------
            CGPROGRAM  
            #pragma vertex vert  
            #pragma fragment frag  
            #include "UnityCG.cginc"  
            //顶点着色器输出结构体 
            struct VertexOutput  
            {  
                float4 pos : SV_POSITION;   //顶点位置  
                float2 uv  : TEXCOORD0; //纹理坐标
                float4 uv1 : TEXCOORD1; //存储两个uv坐标
                float4 uv2 : TEXCOORD2; //存储两个uv坐标
            };  
            
            // ---------------------------【变量申明】---------------------------
            sampler2D _MainTex;  
            //纹理中的单像素尺寸  
            float4 _MainTex_TexelSize;  
            // 模糊半径
            float _BlurRadius;
            // ---------------------------【顶点着色器】---------------------------
            VertexOutput vert(appdata_img v)  
            {  
                VertexOutput o;  
                o.pos = UnityObjectToClipPos(v.vertex);  
                //uv坐标  
                o.uv = v.texcoord.xy;  
                //计算周围上下左右的uv坐标
                o.uv1.xy = v.texcoord.xy + _MainTex_TexelSize.xy * float2(1, 0) * _BlurRadius;  
                o.uv1.zw = v.texcoord.xy + _MainTex_TexelSize.xy * float2(-1, 0) * _BlurRadius;  
                o.uv2.xy = v.texcoord.xy + _MainTex_TexelSize.xy * float2(0, 1) * _BlurRadius;  
                o.uv2.zw = v.texcoord.xy + _MainTex_TexelSize.xy * float2(0, -1) * _BlurRadius;  
                return o;  
            }  
            
            // ---------------------------【片元着色器】---------------------------
            fixed4 frag(VertexOutput i) : SV_Target  
            {  
                fixed4 color = fixed4(0,0,0,0);  
                color += tex2D(_MainTex, i.uv.xy);  
                color += tex2D(_MainTex, i.uv1.xy);  
                color += tex2D(_MainTex, i.uv1.zw);  
                color += tex2D(_MainTex, i.uv2.xy);  
                color += tex2D(_MainTex, i.uv2.zw);
                // 取平均值
                return color * 0.2;  
            }
            ENDCG  
        }  
        
    }  
}  