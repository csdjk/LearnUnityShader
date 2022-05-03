// create by 长生但酒狂
// create time 2020.4.8
// ---------------------------【放大镜特效】---------------------------

Shader "lcl/screenEffect/Zoom"
{
    // ---------------------------【属性】---------------------------
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    // ---------------------------【子着色器】---------------------------
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always
        // ---------------------------【渲染通道】---------------------------
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            //顶点输入结构体
            struct VertexInput
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            // 顶点输出结构体
            struct VertexOutput
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
            
            // 变量申明
            sampler2D _MainTex;
            float2 _Pos;
            float _ZoomFactor;
            float _EdgeFactor;
            float _Size;
            // ---------------------------【顶点着色器】---------------------------
            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
            // ---------------------------【片元着色器】---------------------------
            fixed4 frag (VertexOutput i) : SV_Target
            {

                //屏幕长宽比 缩放因子
                float2 scale = float2(_ScreenParams.x / _ScreenParams.y, 1);
                // 放大区域中心
                float2 center = _Pos;
                float2 dir = center-i.uv;
                
                //当前像素到中心点的距离
                float dis = length(dir * scale);
                // 是否在放大镜区域
                // fixed atZoomArea = 1-step(_Size,dis);
                float atZoomArea = smoothstep(_Size + _EdgeFactor,_Size,dis );

                fixed4 col = tex2D(_MainTex, i.uv + dir * _ZoomFactor * atZoomArea );
                return col;
            }
            ENDCG
        }
    }
}
