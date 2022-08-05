Shader "lcl/screenEffect/BloomMobile"  
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
    }
    SubShader
    {
        ZTest Always
        Cull Off
        ZWrite Off
        Fog
        {
            Mode Off
        }

        CGINCLUDE
        #include "UnityCG.cginc"
        
        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        sampler2D _BlurTex;

        half4 _Filter;
        fixed4 _BloomColor;
        float _BlurAmount;
        float _BloomAmount;

        struct v2f
        {
            float4 pos : SV_POSITION;
            float4 uv : TEXCOORD0;
        };
        v2f vert(appdata_img v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord.xyxy + _MainTex_TexelSize.xyxy * float4(1, 1, -1, -1) * _BlurAmount;
            // o.uv = v.texcoord.xyxy;
            return o;
        }
        // Box模糊
        half3 SampleBox(float4 uv)
        {
            fixed4 color = fixed4(0, 0, 0, 0);
            color += tex2D(_MainTex, uv.xy);
            color += tex2D(_MainTex, uv.zy);
            color += tex2D(_MainTex, uv.xw);
            color += tex2D(_MainTex, uv.zw);
            color *= 0.25;
            return color;
        }
        
        // 提取亮度超过阈值的值
        half3 Prefilter(half3 c)
        {
            half brightness = max(c.r, max(c.g, c.b));
            half soft = brightness - _Filter.y;
            soft = clamp(soft, 0, _Filter.z);
            soft = soft * soft * _Filter.w;
            half contribution = max(soft, brightness - _Filter.x);
            contribution /= max(brightness, 0.00001);
            return c * contribution;
        }

        
        ENDCG

        // 过滤提取
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            fixed4 frag(v2f i) : SV_Target
            {
                return half4(Prefilter(SampleBox(i.uv)), 1);
            }
            ENDCG
        }

        //模糊1
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            fixed4 frag(v2f i) : SV_Target
            {
                return half4(SampleBox(i.uv), 1);
            }
            ENDCG
        }

        //模糊2
        Pass
        {
            Blend One One
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            fixed4 frag(v2f i) : SV_Target
            {
                return half4(SampleBox(i.uv), 1);
            }
            ENDCG
        }

        // Bloom
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            fixed4 frag(v2f_img i) : SV_Target
            {
                fixed4 mainColor = tex2D(_MainTex, i.uv);
                fixed4 blurColor = tex2D(_BlurTex, i.uv);
                return mainColor + blurColor * _BloomColor * _BloomAmount;
            }
            ENDCG
        }
    }
}
