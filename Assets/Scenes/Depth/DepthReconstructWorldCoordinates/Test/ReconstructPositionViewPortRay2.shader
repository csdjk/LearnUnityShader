// ================================ 深度图重建世界坐标 ================================
//视口射线插值方式
// 推荐使用该方法，效率比较高
Shader "lcl/Depth/ReconstructPositionViewPortRay2"
{
    CGINCLUDE
    #include "UnityCG.cginc"
    sampler2D _CameraDepthTexture;
    float4x4 _ViewPortRay;
    
    struct appdata
    {
        float4 vertex : POSITION;
        float4 texcoord : TEXCOORD0;
        uint vid : SV_VertexID;
    };
    struct v2f
    {
        float4 pos : SV_POSITION;
        float2 uv : TEXCOORD0;
        float4 rayDir : TEXCOORD1;
    };
    
    v2f vertex_depth(appdata v)
    {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.uv = v.texcoord.xy;
        //经过测试id： 0在左下角，1：左上角，2：右上角，3：右下角
        o.rayDir = _ViewPortRay[v.vid];
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