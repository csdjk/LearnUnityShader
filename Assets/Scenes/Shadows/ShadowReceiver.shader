// 阴影接收者
Shader "lcl/Shadows/ShadowReceiver"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry"}

        // 作为阴影接收者也需要使用 SHADOWCASTER Pass，不然没有阴影
        // 如果不使用，那么也可以在最后添加 FallBack "Diffuse" (对于不同的 FallBack 会导致阴影效果不同)
        // 即如果在你的shader中这样的shadowCaster pass没有被定义那么unity就会到你的fallback里去找
        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"

        Pass
        {
            Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_fwdbase
            #pragma enable_d3d11_debug_symbols

            #include "UnityCG.cginc"
            // 需要引入该库文件
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                // 定义投影坐标
                // 相当于 float4 _ShadowCoord : TEXCOORD2
                SHADOW_COORDS(1) 
            };

            float4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                // 转换shadow
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                fixed shadow = SHADOW_ATTENUATION(i);
                // UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

                return _Color * shadow;
            }
            ENDCG
        }

    }

    // 一定要 FallBack 不然没有阴影
    FallBack "Diffuse"
}
