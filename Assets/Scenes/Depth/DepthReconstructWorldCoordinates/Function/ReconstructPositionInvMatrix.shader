//通过VP逆矩阵的方式从深度图构建世界坐标
Shader "lcl/Depth/ReconstructPositionInvMatrix"
{
    CGINCLUDE
    #include "UnityCG.cginc"
    sampler2D _CameraDepthTexture;
    float4x4 _InverseVPMatrix;
    
    fixed4 frag_depth(v2f_img i) : SV_Target
    {
        float depthTextureValue = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
        //自己操作深度的时候，需要注意Reverse_Z的情况
        #if defined(UNITY_REVERSED_Z)
            depthTextureValue = 1 - depthTextureValue;
        #endif
        // 转换到ndc空间[-1,1]
        float4 ndc = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1, depthTextureValue * 2 - 1, 1);
        
        float4 worldPos = mul(_InverseVPMatrix, ndc);
        worldPos /= worldPos.w;
        return worldPos;
    }
    ENDCG
    
    SubShader
    {
        Pass
        {
            ZTest Off
            Cull Off
            ZWrite Off
            Fog{ Mode Off }
            
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag_depth
            ENDCG
        }
    }
}