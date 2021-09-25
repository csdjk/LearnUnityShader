// 深度图获取
Shader "lcl/Depth/Depth_OutlineShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        // ------------------------对比深度计算被遮挡部分------------------------
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _CameraDepthTexture;
            sampler2D _ObjectDepthTex;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 screenPosition : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPosition = ComputeScreenPos(o.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            fixed4 frag (v2f i) : SV_Target
            {
                float3 col = tex2D(_MainTex,i.uv);

                // 物体深度
                float objDepth = tex2D(_ObjectDepthTex,i.uv).r;
                // 场景深度
                float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
                depth = Linear01Depth(depth);
                
                // return objDepth;
                // return depth;

                // 计算被遮挡部分
                float isObj = 1-step(1,objDepth);
                float shield = step(depth,objDepth-0.0001);
                return shield*isObj;

                // // 计算被遮挡部分
                // if(objDepth >= 0.8){
                //     return 0;
                // }
                // if(objDepth-0.0001 > depth){
                //     return 1;
                // }
                // return 0;
            }
            ENDCG
        }

        // ------------------------模糊处理------------------------
        Pass  
        {  
            CGPROGRAM  
            #pragma vertex vert  
            #pragma fragment frag  
            #include "UnityCG.cginc"  
            struct v2f  
            {  
                float4 pos : SV_POSITION;
                float2 uv  : TEXCOORD0;
                float4 uv1 : TEXCOORD1;
                float4 uv2 : TEXCOORD2;
                float4 uv3 : TEXCOORD3;
                float4 uv4 : TEXCOORD4;
            };  
            
            sampler2D _MainTex;  
            float4 _MainTex_TexelSize;  
            float _BlurRadius;
            v2f vert(appdata_img v)  
            {  
                v2f o;  
                o.pos = UnityObjectToClipPos(v.vertex);  
                o.uv = v.texcoord.xy;  
                //计算周围的8个uv坐标
                o.uv1.xy = v.texcoord.xy + _MainTex_TexelSize.xy * float2(1, 0) * _BlurRadius;  
                o.uv1.zw = v.texcoord.xy + _MainTex_TexelSize.xy * float2(-1, 0) * _BlurRadius;

                o.uv2.xy = v.texcoord.xy + _MainTex_TexelSize.xy * float2(0, 1) * _BlurRadius;
                o.uv2.zw = v.texcoord.xy + _MainTex_TexelSize.xy * float2(0, -1) * _BlurRadius;

                o.uv3.xy = v.texcoord.xy + _MainTex_TexelSize.xy * float2(1, 1) * _BlurRadius;
                o.uv3.zw = v.texcoord.xy + _MainTex_TexelSize.xy * float2(-1, 1) * _BlurRadius;

                o.uv4.xy = v.texcoord.xy + _MainTex_TexelSize.xy * float2(1, -1) * _BlurRadius;
                o.uv4.zw = v.texcoord.xy + _MainTex_TexelSize.xy * float2(-1, -1) * _BlurRadius;
                return o;  
            }  
            
            fixed4 frag(v2f i) : SV_Target  
            {  
                fixed4 color = fixed4(0,0,0,0);  
                color += tex2D(_MainTex, i.uv.xy);
                color += tex2D(_MainTex, i.uv1.xy);
                color += tex2D(_MainTex, i.uv1.zw);
                color += tex2D(_MainTex, i.uv2.xy);
                color += tex2D(_MainTex, i.uv2.zw);
                color += tex2D(_MainTex, i.uv3.xy);
                color += tex2D(_MainTex, i.uv3.zw);
                color += tex2D(_MainTex, i.uv4.xy);
                color += tex2D(_MainTex, i.uv4.zw);
                // 取平均值
                return color / 9;
            }
            ENDCG  
        }

        // Blur图和原图进行相减获得轮廓
        Pass  
        {  
            CGPROGRAM  
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            struct v2f
            {
                float4 pos : SV_POSITION;
                half2 uv: TEXCOORD0;
            };
            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            sampler2D _BlurTex;
            sampler2D _ObjectDepthTex;
            float4 _OutlineColor;
            float _OutlinePower;
            
            v2f vert(appdata_img v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord.xy;
                //dx中纹理从左上角为初始坐标，需要反向
                #if UNITY_UV_STARTS_AT_TOP
                    if (_MainTex_TexelSize.y < 0)
                    o.uv.y = 1 - o.uv.y;
                #endif	
                return o;
            }
            
            fixed4 frag(v2f i) : SV_Target
            {
                //取原始场景纹理进行采样
                fixed4 mainColor = tex2D(_MainTex, i.uv);
                //对blur之前的rt进行采样
                fixed4 srcColor = tex2D(_ObjectDepthTex, i.uv);
                srcColor = 1-step(1,srcColor);
                //对blur后的纹理进行采样
                fixed4 blurColor = tex2D(_BlurTex, i.uv);
                //相减后得到轮廓图
                fixed4 outline = ( blurColor - srcColor) * _OutlineColor * _OutlinePower;
                // 叠加原图
                fixed4 final = saturate(outline) + mainColor;
                return final;
            }
            ENDCG  
        }
    }
    FallBack "Diffuse"
}

