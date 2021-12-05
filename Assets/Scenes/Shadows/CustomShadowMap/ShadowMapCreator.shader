Shader "lcl/Shadows/CustomShadowMap/ShadowMapCreator"
{
    SubShader
    {
        Tags { "RenderType" = "Opaque" }

        Pass
        {
            Fog
            {
                Mode Off
            }

            // 正面剔除 防止发生自阴影遮挡
            Cull front

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 depth : TEXCOORD0;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.depth = o.pos.zw;
                return o;
            }

            fixed4 frag(v2f i) : COLOR
            {
                float depth = i.depth.x / i.depth.y;
                #if defined(SHADER_TARGET_GLSL)
                    depth = depth * 0.5 + 0.5; //(-1, 1)-->(0, 1)
                #elif defined(UNITY_REVERSED_Z)
                    depth = 1 - depth;       //(1, 0)-->(0, 1)
                #endif
                
                return EncodeFloatRGBA(depth);
                // return fixed4(depth,depth,depth,1);
                // return fixed4(1,0,0,1); 
            }
            ENDCG

        }
    }
}