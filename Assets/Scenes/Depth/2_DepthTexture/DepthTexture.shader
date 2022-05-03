// 深度图获取
Shader "lcl/Depth/DepthTexture"
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
            sampler2D _CameraDepthTexture;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 screenPosition : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPosition = ComputeScreenPos(o.vertex);
                o.uv = v.uv;
                return o;
            }
            fixed4 frag (v2f i) : SV_Target
            {
                // 后处理可以直接用uv采样
                float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
                // 利用投影纹理采样
                // float depth = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPosition));
                // float depth = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPosition));

                float linear01Depth = Linear01Depth(depth); //转换成[0,1]内的线性变化深度值
                float linearEyeDepth = LinearEyeDepth(depth)*_ProjectionParams.w;; //转换到摄像机空间

                // 未经过Linear01Depth处理的depth不是线性变化的，近处深度变化较明显，而远处几乎全白
                // return 1 - depth;

                return linear01Depth;
            }
            ENDCG
        }
    }
}

