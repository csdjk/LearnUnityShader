Shader "lcl/ComputerShader/ParticleShader"
{
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            struct v2f
            {
                float4 col : COLOR0;
                float4 vertex : SV_POSITION;
            };
            
            struct particleData
            {
                float3 pos;
                float4 color;
            };

            StructuredBuffer<particleData> _particleDataBuffer;
            
            v2f vert(uint id : SV_VertexID)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(float4(_particleDataBuffer[id].pos, 0));
                o.col = _particleDataBuffer[id].color;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return i.col;
            }
            ENDCG
        }
    }
}