// ================================= 局部反射 =================================
Shader "lcl/Reflections/ReflectionLocalCubemap"
{
    Properties
    {
        _CustomReflectTex ("Cubemap", Cube) = "" { }
        _Roughness ("Roughness", Range(0, 1)) = 0.1

        _BBoxSize ("BBoxSize", Vector) = (1, 1, 1, 1)
        _BBoxCenter ("BBox Center", Vector) = (0, 0, 0, 1)
        _MaskSmoothness ("MaskSmoothness", Range(0.01, 1)) = 0.1
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

            half _Roughness;
            half _MaskSmoothness;
            float3 _BBoxSize;
            float3 _BBoxCenter;

            
            samplerCUBE _CustomReflectTex;
            float4 _CustomReflectTex_HDR;


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
            // https://community.arm.com/arm-community-blogs/b/graphics-gaming-and-vr-blog/posts/reflections-based-on-local-cubemaps-in-unity
            float3 LocalCorrect(float3 origVec, float3 bboxSize, float3 vertexPos, float3 cubemapPos)
            {
                // Find the ray intersection with box plane
                float3 invOrigVec = float3(1.0, 1.0, 1.0) / origVec;
                float3 intersecAtMaxPlane = (bboxSize - vertexPos) * invOrigVec;
                float3 intersecAtMinPlane = (-bboxSize - vertexPos) * invOrigVec;
                // Get the largest intersection values (we are not intersted in negative values)
                float3 largestIntersec = max(intersecAtMaxPlane, intersecAtMinPlane);
                // Get the closest of all solutions
                float Distance = min(min(largestIntersec.x, largestIntersec.y), largestIntersec.z);
                // Get the intersection position
                float3 IntersectPositionWS = vertexPos + origVec * Distance;
                // Get corrected vector
                float3 localCorrectedVec = IntersectPositionWS - cubemapPos;
                return localCorrectedVec;
            }

            float4 frag(v2f input) : SV_Target
            {
                float3 viewDirWS = -normalize(input.viewWS);
                float3 normalWS = normalize(input.normalWS);
                float3 reflDirWS = reflect(viewDirWS, normalWS);
                float3 size = _BBoxSize * 0.5;
                // float3 size = _BBoxSize;
                // Get local corrected reflection vector.
                float3 localCorrReflDirWS = LocalCorrect(reflDirWS, size, input.positionWS, _BBoxCenter);
                // Lookup the environment reflection texture with the right vector.

                half mip = PerceptualRoughnessToMipmapLevel(_Roughness);
                // ================================= Custom Reflection Cubemap =================================
                // float3 reflColor = texCUBE(_Cube, localCorrReflDirWS);
                half4 rgbm = texCUBElod(_CustomReflectTex, float4(localCorrReflDirWS, mip));
                float3 reflColor = DecodeHDR(rgbm, _CustomReflectTex_HDR);
                // ================================= Unity Reflection Probe =================================
                // half4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, localCorrReflDirWS, mip);
                // float3 reflColor = DecodeHDR(rgbm, unity_SpecCube0_HDR);


                // ================================= Box Mask =================================
                float mask = 1 - BoxMask(input.positionWS, _BBoxCenter, _BBoxSize, _MaskSmoothness);
                // return mask;
                return half4(reflColor * mask, 1);
            }
            ENDCG
        }
    }
    FallBack "Reflective/VertexLit"
}
