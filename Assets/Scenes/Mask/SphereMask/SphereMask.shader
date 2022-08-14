Shader "lcl/Mask/SphereMask"
{
    Properties
    {
        _MaskCenter ("Sphere Mask Center", Vector) = (0, 0, 0, 1)
        _MaskRadius ("Sphere Mask Radius", Vector) = (1, 1, 1, 1)
        _Hardness ("Hardness", Range(0, 10)) = 5
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
            float3 _MaskRadius;
            float _Hardness;
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
                
                float mask = SphereMask(i.positionWS, _MaskCenter, _MaskRadius, _Hardness);
                return mask;
            }
            ENDCG
        }
    }
    FallBack "Reflective/VertexLit"
}