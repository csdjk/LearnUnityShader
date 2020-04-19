// ---------------------------【2D 描边效果】---------------------------
// create by 长生但酒狂
Shader "lcl/shader2D/outline"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _lineWidth("lineWidth",Range(0,10)) = 1
        _lineColor("lineColor",Color)=(1,1,1,1)
    }
    // ---------------------------【子着色器】---------------------------
    SubShader
    {
        // 渲染队列采用 透明
        Tags{
            "Queue" = "Transparent"
        }
        Blend SrcAlpha OneMinusSrcAlpha
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            //顶点着色器输入结构体 
            struct VertexInput
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            //顶点着色器输出结构体 
            struct VertexOutput
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            // ---------------------------【顶点着色器】---------------------------
            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            float _lineWidth;
            float4 _lineColor;

            // ---------------------------【片元着色器】---------------------------
            fixed4 frag (VertexOutput i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                // 采样周围4个点
                float2 up_uv = i.uv + float2(0,1) * _lineWidth * _MainTex_TexelSize.xy;
                float2 down_uv = i.uv + float2(0,-1) * _lineWidth * _MainTex_TexelSize.xy;
                float2 left_uv = i.uv + float2(-1,0) * _lineWidth * _MainTex_TexelSize.xy;
                float2 right_uv = i.uv + float2(1,0) * _lineWidth * _MainTex_TexelSize.xy;
                // 如果有一个点透明度为0 说明是边缘
                float w = tex2D(_MainTex,up_uv).a * tex2D(_MainTex,down_uv).a * tex2D(_MainTex,left_uv).a * tex2D(_MainTex,right_uv).a;

                // if(w == 0){
                    //    col.rgb = _lineColor;
                // }
                // 和原图做插值
                col.rgb = lerp(_lineColor,col.rgb,w);
                return col;
            }
            ENDCG
        }
    }
}
