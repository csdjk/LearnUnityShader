//通过VP逆矩阵的方式从深度图构建世界坐标
Shader "lcl/Depth/ReconstructPositionInvMatrix2"
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
                float2 screenPos : TEXCOORD0;
                float3 viewRay : TEXCOORD1;
            };

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                o.screenPos = ComputeScreenPos(o.vertex);
                float4 clipPos = float4(o.screenPos * 2 - 1.0, 1.0, 1.0);
                float4 viewRay = mul(unity_CameraInvProjection, clipPos);
                o.viewRay = viewRay.xyz / viewRay.w;
                return o;
            }
            sampler2D _CameraDepthTexture;
            
            fixed4 frag (v2f i) : SV_Target
            {
                float depthTextureValue = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.screenPos);
                float linear01Depth = Linear01Depth(depthTextureValue);
                float3 viewPos = _WorldSpaceCameraPos.xyz + linear01Depth * i.viewRay;

                // Pixel world position
                float3 worldPos = mul(UNITY_MATRIX_I_V, float4(viewPos, 1)).xyz;
                return float4(worldPos, 1.0);
            }
            ENDCG
        }
    }
}