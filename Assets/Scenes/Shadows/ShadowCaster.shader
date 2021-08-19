// 阴影投射者
Shader "lcl/Shadows/ShadowCaster"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
        }

        // 如果物体需要产生阴影就必须加该pass，或者 在最后添加 FallBack "Diffuse"
        // UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"

        // 或者：自定义投影pass
        // Pass
        // {   
        //     // 
        //     Tags { "LightMode" = "ShadowCaster" }

        //     CGPROGRAM
        //     #pragma vertex vert
        //     #pragma fragment frag
        //     #pragma multi_compile_shadowcaster
        //     #include "UnityCG.cginc"

        //     struct v2f {
        //         // 投影数据
        //         V2F_SHADOW_CASTER;
        //         // 实际定义如下:
        //         // float4 pos : SV_POSITION;
        //         // float3 vec : TEXCOORD0;
        //     };

        //     v2f vert(appdata_base v)
        //     {
        //         v2f o;
        //         TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
        //         // 源码如下：
        //         // o.pos = UnityClipSpaceShadowCasterPos(v.vertex, v.normal);
        //         // o.pos = UnityApplyLinearShadowBias(o.pos);
        //         return o;
        //     }

        //     float4 frag(v2f i) : SV_Target
        //     {
        //         SHADOW_CASTER_FRAGMENT(i)
        //     }
        //     ENDCG
        // }
        
        // 正常渲染pass
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

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float4 _Color;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col * _Color;
            }
            ENDCG
        }
    }
    // 
    FallBack "Diffuse"
}
