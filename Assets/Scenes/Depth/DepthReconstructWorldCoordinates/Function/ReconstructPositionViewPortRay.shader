// ================================ 深度图重建世界坐标 ================================
//视口射线插值方式
// 推荐使用该方法，效率比较高
Shader "lcl/Depth/ReconstructPositionViewPortRay"
{
    CGINCLUDE
    #include "UnityCG.cginc"
    sampler2D _CameraDepthTexture;
    float4x4 _ViewPortRay;
    
    struct v2f
    {
        float4 pos : SV_POSITION;
        float2 uv : TEXCOORD0;
        float4 rayDir : TEXCOORD1;
    };
    
    v2f vertex_depth(appdata_base v)
    {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.uv = v.texcoord.xy;
        
        //用texcoord区分四个角
        // int index = 0;
        // if (v.texcoord.x < 0.5 && v.texcoord.y < 0.5)
        //     index = 0;
        // else if (v.texcoord.x < 0.5 && v.texcoord.y > 0.5)
        //     index = 1;
        // else if (v.texcoord.x > 0.5 && v.texcoord.y > 0.5)
        //     index = 2;
        // else
        //     index = 3;

        // (0,0) (0,1) (1,1) (1,0)
        // 0 2 3 1
        int index = int(v.texcoord.x + 0.5) + 2 * int(v.texcoord.y + 0.5);

        o.rayDir = _ViewPortRay[index];
        return o;
    }
    
    fixed4 frag_depth(v2f i) : SV_Target
    {
        float depthTextureValue = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
        float linear01Depth = Linear01Depth(depthTextureValue);
        //worldpos = campos + 射线方向 * depth
        float3 worldPos = _WorldSpaceCameraPos + linear01Depth * i.rayDir.xyz;
        return fixed4(worldPos, 1.0);
    }
    ENDCG
    
    SubShader
    {
        Pass
        {
            ZTest Off
            Cull Off
            ZWrite Off
            Fog
            {
                Mode Off
            }
            
            CGPROGRAM
            #pragma vertex vertex_depth
            #pragma fragment frag_depth
            ENDCG
        }
    }
}