Shader "lcl/Mask/UniversalMask2D"
{
    Properties
    {
        _MaskCenter ("Mask Center", Vector) = (0, 0, 0, 1)
        _Intensity ("Intensity", Range(0, 10)) = 3
        _Roundness ("Roundness", Range(0, 10)) = 1
        _Smoothness ("Smoothness", Range(0, 5)) = 0.2
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
            float _Roundness;
            float _Intensity;
            float _Smoothness;
            struct a2v
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
            half4 frag(v2f i) : SV_Target
            {
                
                float mask = UniversalMask2D(i.uv, _MaskCenter, _Intensity, _Roundness, _Smoothness);
                return mask;
            }
            ENDCG
        }
    }
    FallBack "Reflective/VertexLit"
}