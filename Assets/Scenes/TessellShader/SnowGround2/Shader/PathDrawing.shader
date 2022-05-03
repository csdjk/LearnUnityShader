// 路径绘制shader
Shader "lcl/SnowGround/PathDrawing"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma enable_d3d11_debug_symbols

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

            

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            sampler2D _PrevTex;

            fixed4 frag (v2f i) : SV_Target
            {
                float4 col = tex2D(_MainTex,i.uv);
                float4 prevCol = tex2D(_PrevTex,i.uv);
                return saturate(col + prevCol);
            }
            ENDCG
        }

        // ---------------------------【Box模糊】---------------------------
        Pass  
        {  
            ZTest Always  
            Cull Off  
            ZWrite Off  
            CGPROGRAM  
            #pragma vertex vert  
            #pragma fragment frag  
            #include "UnityCG.cginc"  
            struct VertexOutput  
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

            VertexOutput vert(appdata_img v)  
            {  
                VertexOutput o;  
                o.pos = UnityObjectToClipPos(v.vertex);  
                //uv坐标  
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
            
            // ---------------------------【片元着色器】---------------------------
            fixed4 frag(VertexOutput i) : SV_Target  
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
    }
}
