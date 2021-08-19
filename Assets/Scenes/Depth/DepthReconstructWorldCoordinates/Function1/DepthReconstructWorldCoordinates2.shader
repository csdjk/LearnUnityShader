// 根据深度重建时间坐标
Shader "lcl/Depth/DepthReconstructWorldCoordinates2"
{
    Properties
    {
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 screenPos : TEXCOORD0;
                float3 worldSpaceDir : TEXCOORD1;
                float viewSpaceZ : TEXCOORD2;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                // World space vector from camera to the vertex position
                o.worldSpaceDir = WorldSpaceViewDir(v.vertex);

                // Z value of the vector in view space
                o.viewSpaceZ = mul(UNITY_MATRIX_V, float4(o.worldSpaceDir, 0.0)).z;

                // Compute texture coordinate
                o.screenPos = ComputeScreenPos(o.vertex);
                return o;
            }

            sampler2D _CameraDepthTexture;

            half4 frag(v2f i) : SV_Target
            {
                // Sample the depth texture to get the linear eye depth
                float eyeDepth = UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture, i.screenPos));
                eyeDepth = LinearEyeDepth(eyeDepth);

                // Rescale the vector
                i.worldSpaceDir *= -eyeDepth / i.viewSpaceZ;

                // Pixel world position
                float3 worldPos = _WorldSpaceCameraPos + i.worldSpaceDir;

                return float4(worldPos, 1.0);
            }
            ENDCG
        }
    }
}

