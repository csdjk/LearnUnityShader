Shader "lcl/shader3D/outline/outLine3D_stencil" {
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _OutLinePower("OutLine Power",Range(0,1)) = 0.03
        _OutLineColor ("OutLine Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            Cull Back
            Stencil
            {
                Ref 1
                Comp Always
                Pass Replace
                ZFail Replace
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            
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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }

        Pass
        {
            Name "OUT_LINE_PASS"
            Cull Front
            ZWrite Off
            Stencil{
                Ref 1
                Comp NotEqual
            }
            ZTest Greater
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature _OUTLINE_SWITCH_ON

            #include "UnityCG.cginc"

            //描边强度
            float _OutLinePower;
            //描边颜色
            float4 _OutLineColor;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
            v2f vert (appdata v)
            {
                v2f o;
                //顶点沿着法线方向扩张
                v.normal = normalize(v.normal);
                v.vertex.xyz +=  v.normal * _OutLinePower * 0.2;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //输出结果
                return o;
            }
            fixed4 frag (v2f i) : SV_Target
            {
                return _OutLineColor;
            }
            ENDCG
        }
    }
}

