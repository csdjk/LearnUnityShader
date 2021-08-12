// 自身深度计算
Shader "lcl/Depth/DepthDebug"
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
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);


                // 一：观察线性深度（Eye depth）
                // 就是顶点在观察空间（View space）中的z分量，即顶点距离相机的距离
                COMPUTE_EYEDEPTH(o.viewSpaceDepth);
                //COMPUTE_EYEDEPTH源码:
                // 符号取反的原因是在Unity的观察空间（View space）中z轴翻转了，
                // 摄像机的前向量就是z轴的正方向。这是和OpenGL中不一样的一点。
                // o.viewSpaceDepth = -UnityObjectToViewPos(v.vertex).z;
                // o.viewSpaceDepth = -mul(UNITY_MATRIX_MV, v.vertex).z;


                // 二：线性深度（01 depth）
                // 就是观察线性深度通过除以摄像机远平面重新映射到[0，1]区间所得到的值
                o.depth01 = COMPUTE_DEPTH_01;
                // COMPUTE_DEPTH_01 源码：
                // o.depth01 = -(UnityObjectToViewPos( v.vertex ).z * _ProjectionParams.w);
                return o;
            }
            fixed4 frag (v2f i) : SV_Target
            {
                // _ProjectionParams：
                // x 表明是不是反向投射
                // y 近剪裁面在view空间(相机空间)的z值，数值上等于相机设置中的近剪裁面的值
                // z 远剪裁面在view空间(相机空间)的z值，数值上等于相机设置中的远剪裁面的值
                // w 1/z的值

                // 观察 线性深度（Eye depth）
                // 除以 远剪裁面z 就是为了把 观察空间的z 归一到[0,1]范围，也就是线性depth01
                fixed depthEye = i.viewSpaceDepth * _ProjectionParams.w;

                // 01 线性深度
                fixed depth01 = i.depth01;

                return depthEye;
            }
            ENDCG
        }
    }
}

