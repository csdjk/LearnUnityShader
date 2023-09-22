// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "lcl/learnShader2/010_billboard"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" { }
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _VerticalBillboarding ("Vertical Restraints", Range(0, 1)) = 1
    }
    SubShader
    {
        // Need to disable batching because of the vertex animation
        Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "DisableBatching" = "True" }
        
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            
            #include "Lighting.cginc"
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            fixed _VerticalBillboarding;
            
            struct a2v
            {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
            };
            
            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
            
            v2f vert(a2v v)
            {
                v2f o;
                
                // 假设物体空间的中心是固定的 -  Suppose the center in object space is fixed
                float3 center = float3(0, 0, 0);
                float3 viewer = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));
                
                float3 normalDir = viewer - center;
                // If _VerticalBillboarding equals 1, we use the desired view dir as the normal dir
                // Which means the normal dir is fixed
                // Or if _VerticalBillboarding equals 0, the y of normal is 0
                // Which means the up dir is fixed
                normalDir.y = normalDir.y * _VerticalBillboarding;
                normalDir = normalize(normalDir);
                // Get the approximate up dir
                // If normal dir is already towards up, then the up dir is towards front
                float3 upDir = abs(normalDir.y) > 0.999 ? float3(0, 0, 1) : float3(0, 1, 0);
                float3 rightDir = normalize(cross(upDir, normalDir));
                upDir = normalize(cross(normalDir, rightDir));
                
                // Use the three vectors to rotate the quad
                float3 centerOffs = v.vertex.xyz - center;
                //以下所有方法计算结果都相同
                // float3 localPos = center + rightDir * centerOffs.x + upDir * centerOffs.y + normalDir * centerOffs.z;

                // float3 localPos = center+mul(centerOffs,float3x3(rightDir,upDir,normalDir));
                //左乘一个基向量矩阵    由于CG是行优先,所有需要 transpose 转置矩阵
                float3 localPos = center + mul(transpose(float3x3(rightDir, upDir, normalDir)), centerOffs);

                // float3 localPos = center+mul(float3x3(
                //     rightDir.x,upDir.x,normalDir.x,
                //     rightDir.y,upDir.y,normalDir.y,
                //     rightDir.z,upDir.z,normalDir.z
                //     ),centerOffs);

                o.pos = UnityObjectToClipPos(float4(localPos, 1));
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);




                // https://zhuanlan.zhihu.com/p/397620652
                // float3 centerWS = GetModelCenterWorldPos();
                // float3 cameraTransformRightWS = UNITY_MATRIX_V[0].xyz;
                // float3 cameraTransformUpWS = UNITY_MATRIX_V[1].xyz;
                // float3 cameraTransformForwardWS = -UNITY_MATRIX_V[2].xyz;
                // float3 positionOS = v.vertex.x * cameraTransformRightWS;
                // positionOS += v.vertex.y * cameraTransformUpWS;


                // float3 positionWS = positionOS + centerWS;
                // o.vertex = UnityWorldToClipPos(positionWS);
                return o;
            }
            
            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 c = tex2D(_MainTex, i.uv);
                c.rgb *= _Color.rgb;
                return c;
            }
            
            ENDCG
        }
    }
    FallBack "Transparent/VertexLit"
}
