// 根据深度重建时间坐标
Shader "lcl/Depth/DepthReconstructWorldCoordinates"
{
    Properties { }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #pragma enable_d3d11_debug_symbols
            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 screenPos : TEXCOORD0;
                float3 viewVec : TEXCOORD1;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                // Compute texture coordinate
                o.screenPos = ComputeScreenPos(o.vertex);

                // NDC position
                float4 ndcPos = (o.screenPos / o.screenPos.w) * 2 - 1;

                // Camera parameter
                float far = _ProjectionParams.z;

                // 指向远平面的空间向量
                float3 clipVec = float3(ndcPos.x, ndcPos.y, 1.0) * far;
                o.viewVec = mul(unity_CameraInvProjection, clipVec.xyzz).xyz;

                return o;
            }

            sampler2D _CameraDepthTexture;

            half4 frag(v2f i) : SV_Target
            {
                // Sample the depth texture to get the linear 01 depth
                float depth = UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture, i.screenPos));
                depth = Linear01Depth(depth);

                // View space position
                float3 viewPos = i.viewVec * depth;

                // Pixel world position
                float3 worldPos = mul(UNITY_MATRIX_I_V, float4(viewPos, 1)).xyz;

                return float4(worldPos, 1.0);
            }
            ENDCG
        }
    }
}

