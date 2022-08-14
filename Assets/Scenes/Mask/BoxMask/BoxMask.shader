Shader "lcl/Mask/BoxMask"
{
    Properties
    {
        _MaskCenter ("Box Mask Center", Vector) = (0, 0, 0, 1)
        _MaskSize ("Box Mask Size", Vector) = (1, 1, 1, 1)
        _Falloff ("Falloff", Range(0, 1)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            #include "Assets\Shader\ShaderLibs\Node.cginc"

            float3 _MaskCenter;
            float3 _MaskSize;
            float _Falloff;
            struct a2v
            {
                float4 vertex : POSITION;
            };
            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 positionWS : TEXCOORD1;
            };
            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.positionWS = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }
            half4 frag(v2f i) : SV_Target
            {
                
                float mask = BoxMask(i.positionWS, _MaskCenter, _MaskSize, _Falloff);
                return mask;
            }
            ENDCG
        }
    }
    FallBack "Reflective/VertexLit"
}