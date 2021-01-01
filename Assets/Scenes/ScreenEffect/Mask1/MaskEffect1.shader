//遮罩
Shader "lcl/screenEffect/MaskEffect1"
{
    Properties
    {
        // 遮罩纹理
        _MainTex ("Mask Texture", 2D) = "white" {}
        // 被遮罩纹理
        _BaseTex ("Base Texture", 2D) = "white" {}
        _Pos("Pos",Vector) = (0.5,0.5,0,0)
        _Size("Size", Range(-1,10)) = 1
        _EdgeBlurLength("EdgeBlurLength", Range(0.001,0.1)) = 0.1
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always
        Tags{   "Queue"="Transparent" }

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

            float4 _MainTex_ST;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            sampler2D _MainTex;
            half4 _MaskTex_TexelSize;

            sampler2D _BaseTex;
            float2 _Pos;
            float _Size;
            float _EdgeBlurLength;
            // 创建圆
            fixed3 createCircle(float2 pos,float radius,float2 uv){
                //当前像素到中心点的距离
                float dis = distance(pos,uv);
                //  smoothstep 平滑过渡
                float col = smoothstep(radius + _EdgeBlurLength,radius,dis);
                return fixed3(col,col,col) ;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 根据屏幕比例缩放
                float2 scale = float2(_ScreenParams.x / _ScreenParams.y, 1);

                fixed4 col = tex2D(_MainTex, i.uv);

                // 遮罩图形
                fixed3 mask = createCircle(_Pos *scale ,_Size,i.uv *scale);

                 // 底图颜色
                fixed4 baseCol = tex2D(_BaseTex, i.uv);
                // 根据mask.x 判断是 底图还是遮罩颜色 0 为 底色 1 为 mask 色
                baseCol = baseCol * (1-mask.x);
                // 遮罩颜色
                fixed4 maskCol = lerp(baseCol, col,mask.x) * mask.x;

                // 叠加颜色
                return baseCol + maskCol;
            }
            ENDCG
        }
    }
}
