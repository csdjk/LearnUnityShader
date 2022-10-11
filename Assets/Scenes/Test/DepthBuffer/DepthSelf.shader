// 自身深度计算
Shader "lcl/Test/DepthBuffer/DepthSelfTest"
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
            #pragma enable_d3d11_debug_symbols
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
                float viewSpaceDepth : TEXCOORD1;
                float depth01 : TEXCOORD2;
                float4 screenPos : TEXCOORD3;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.vertex);

                // 一：观察线性深度（Eye depth）
                // 就是顶点在观察空间（View space）中的z分量，即顶点距离相机的距离
                // 符号取反的原因是在Unity的观察空间（View space）中z轴翻转了，
                // 摄像机的前向量就是z轴的正方向。这是和OpenGL中不一样的一点。
                o.viewSpaceDepth = -UnityObjectToViewPos(v.vertex).z;
                return o;
            }
            fixed4 frag(v2f i) : SV_Target
            {
                // 除以 远剪裁面z 就是为了把 观察空间的z 归一到[0,1]范围，也就是线性depth01
                fixed depth01 = i.viewSpaceDepth * _ProjectionParams.w;

                // 01线性深度
                float4 ndcPos = (i.screenPos / i.screenPos.w) * 2 - 1;
                fixed depthBuffer = ndcPos.z * 0.5 + 0.5;
                float linear01Depth = Linear01Depth(depthBuffer);


                //depth01 == linear01Depth
                return linear01Depth;
            }
            ENDCG
        }
    }

    Fallback "Diffuse"
}

