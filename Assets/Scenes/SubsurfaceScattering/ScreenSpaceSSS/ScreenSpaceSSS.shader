// 基于屏幕空间的次表面
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
        CGINCLUDE
        #include "UnityCG.cginc"
        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        float _BlurSize;
        float _ScatteringStrenth;
        sampler2D _BlurTex;
        sampler2D _MaskTex;
        fixed4 _SSSColor;
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
        // ---------------------------【SSS】---------------------------
        struct v2fSSS
        {
            float4 pos : SV_POSITION;
            half2 uv: TEXCOORD0;
        };
        v2fSSS vertSSS(appdata_img v)
        {
            v2fSSS o;
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
        
        fixed4 fragSSS(v2fSSS i) : SV_Target
        {
            //对原图进行uv采样
            fixed4 srcCol = tex2D(_MainTex, i.uv);
            //对模糊处理后的图进行uv采样
            fixed4 blurCol = tex2D(_BlurTex, i.uv);
            // mask遮罩
            fixed4 maskCol = tex2D(_MaskTex, i.uv);
            blurCol *= maskCol;
            float fac = 1-pow(saturate(max(max(srcCol.r, srcCol.g), srcCol.b) * 1), 0.5);
            // float fac = fixed4(1,0.2,0,0);

            return srcCol + blurCol * _SSSColor * _ScatteringStrenth * fac;
            // return maskCol;
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
        //SSS
        Pass {  
            CGPROGRAM  
            #pragma vertex vertSSS  
            #pragma fragment fragSSS
            ENDCG
        }
    }
    FallBack "Diffuse"

}