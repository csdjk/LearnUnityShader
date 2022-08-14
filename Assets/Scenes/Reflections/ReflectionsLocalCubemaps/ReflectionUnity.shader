
Shader "lcl/Reflections/ReflectionUnity"
{
    Properties
    {
        _Roughness ("Roughness", Range(0, 1)) = 0.1
        _MaskSize ("Mask Size", Vector) = (10, 10, 10, 1)
        _MaskSmoothness ("MaskSmoothness", Range(0.01, 1)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma target 3.0

            // #pragma enable_d3d11_debug_symbols
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "Assets\Shader\ShaderLibs\Node.cginc"

            half _Roughness;
            half _MaskSmoothness;
            half3 _MaskSize;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };
            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalWS : NORMAL;
                float3 positionWS : TEXCOORD1;
                float3 viewWS : TEXCOORD2;
            };
            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normalWS = UnityObjectToWorldNormal(v.normal);
                o.positionWS = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.viewWS = UnityWorldSpaceViewDir(o.positionWS);
                o.uv = v.uv;
                return o;
            }
            half4 frag(v2f i) : SV_Target
            {
                // float3 size = abs(unity_SpecCube0_BoxMax - unity_SpecCube0_BoxMin);

                float3 reflUVW = reflect(-i.viewWS, i.normalWS);
                half mip = PerceptualRoughnessToMipmapLevel(_Roughness);
                // ================================= 开启Box Projection =================================
                #if UNITY_SPECCUBE_BOX_PROJECTION
                    reflUVW = BoxProjectedCubemapDirection(reflUVW, i.positionWS, unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin, unity_SpecCube0_BoxMax);
                #endif

                half4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflUVW, mip);
                float3 reflectionColor = DecodeHDR(rgbm, unity_SpecCube0_HDR);


                // ================================= Box Mask =================================
                
                float mask = 1 - BoxMask(i.positionWS, unity_SpecCube0_ProbePosition, _MaskSize, _MaskSmoothness);
                return half4(reflectionColor * mask, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Reflective/VertexLit"
}
