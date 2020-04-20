// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'
// ---------------------------【后处理-描边】---------------------------
Shader "lcl/screenEffect/outLine"
{
    // ---------------------------【属性】---------------------------
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    // ---------------------------【子着色器】---------------------------
    SubShader
    {
        CGINCLUDE
        #include "UnityCG.cginc"
        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        float _BlurSize;
        sampler2D _BlurTex;
        sampler2D _SrcTex;
        fixed4 _OutlineColor;
        // ---------------------------【高斯模糊】---------------------------
        struct v2f
        {
            float4 pos : SV_POSITION;
            half2 uv[5]: TEXCOORD0;
        };

        //垂直方向的高斯模糊
        v2f vertBlurVertical(appdata_img v) {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            half2 uv = v.texcoord;
            o.uv[0] = uv;
            o.uv[1] = uv + float2(0.0, _MainTex_TexelSize.y * 1.0) * _BlurSize;
            o.uv[2] = uv - float2(0.0, _MainTex_TexelSize.y * 1.0) * _BlurSize;
            o.uv[3] = uv + float2(0.0, _MainTex_TexelSize.y * 2.0) * _BlurSize;
            o.uv[4] = uv - float2(0.0, _MainTex_TexelSize.y * 2.0) * _BlurSize;
            return o;
        }
        //水平方向的高斯模糊
        v2f vertBlurHorizontal(appdata_img v) {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            half2 uv = v.texcoord;
            o.uv[0] = uv;
            o.uv[1] = uv + float2(_MainTex_TexelSize.x * 1.0, 0.0) * _BlurSize;
            o.uv[2] = uv - float2(_MainTex_TexelSize.x * 1.0, 0.0) * _BlurSize;
            o.uv[3] = uv + float2(_MainTex_TexelSize.x * 2.0, 0.0) * _BlurSize;
            o.uv[4] = uv - float2(_MainTex_TexelSize.x * 2.0, 0.0) * _BlurSize;
            return o;
        }
        //高斯模糊片段着色器
        fixed4 fragBlur(v2f i) : SV_Target {
            float weight[3] = {0.4026, 0.2442, 0.0545};
            fixed3 sum = tex2D(_MainTex, i.uv[0]).rgb * weight[0];

            for (int it = 1; it < 3; it++) {
                sum += tex2D(_MainTex, i.uv[it*2-1]).rgb * weight[it];
                sum += tex2D(_MainTex, i.uv[it*2]).rgb * weight[it];
            }
            return fixed4(sum, 1.0);
        }
        // ---------------------------【轮廓图】---------------------------
        //Blur图和原图进行相减获得轮廓
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
            //相减后得到轮廓图
            fixed4 outline = ( srcColor - blurColor) * _OutlineColor;
            //输出：blur部分为0的地方返回原始图像，否则为0，然后叠加描边
            fixed4 final = saturate(outline) + mainColor;
            return final;
        }
        ENDCG
        
        // No culling or depth
        Cull Off ZWrite Off ZTest Always
        
        //垂直高斯模糊
        Pass {
            CGPROGRAM
            #pragma vertex vertBlurVertical  
            #pragma fragment fragBlur
            ENDCG  
        }
        //水平高斯模糊
        Pass {  
            CGPROGRAM  
            #pragma vertex vertBlurHorizontal  
            #pragma fragment fragBlur
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
