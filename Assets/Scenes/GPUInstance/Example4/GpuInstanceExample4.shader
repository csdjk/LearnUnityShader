Shader "lcl/GPUInstance/Example/InstancedShader3" {
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #include "UnityCG.cginc"

            StructuredBuffer<float4x4> localToWorldBuffer;

            struct appdata
            {
                float4 vertex : POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID // 只有当你想访问片段着色器中的实例属性时才有必要。
            };

            // 常规定义属性
            // float4 _Color;

            // Instance 定义属性
            UNITY_INSTANCING_BUFFER_START(Props)
            UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
            UNITY_INSTANCING_BUFFER_END(Props)

            v2f vert(appdata v, uint instanceID : SV_InstanceID)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o); // 只有当你想要访问片段着色器中的实例属性时才需要。

                float4x4 localToWorldMatrix = localToWorldBuffer[instanceID];
                float4 positionWS = mul(localToWorldMatrix,v.vertex);
                positionWS /= positionWS.w;

                o.vertex = mul(UNITY_MATRIX_VP,positionWS);
                // o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i); // 只有当你想要访问片段着色器中的实例属性时才需要。
                return UNITY_ACCESS_INSTANCED_PROP(Props, _Color);
                // return _Color;
            }
            ENDCG
        }
    }
}