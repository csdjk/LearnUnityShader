Shader "lcl/RayTracing/RayTracingShader"
{
    Properties
    {
        _Cubemap ("Skybox", Cube) = "_Skybox" { }
        _TraceCount ("Trace Count", Int) = 5
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        
        
        Pass
        {
            CGPROGRAM
            
            #include "UnityCG.cginc"
            #include "RayTracingShader.cginc"
            
            #pragma target 5.0
            #pragma vertex vert
            #pragma fragment frag
            

            struct v2f
            {
                float4 pos: SV_POSITION;
                float4 uv: TEXCOORD0;
                float4 screenPos: TEXCOORD1;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.pos);
                o.uv = float4(v.texcoord.xy, v.texcoord.z, 1);
                return o;
            }
            
            half4 frag(v2f i): COLOR
            {
                _Pixel = i.uv;

                float2 screenUV = i.screenPos.xy / i.screenPos.w;
                screenUV = screenUV * 2.0f - 1.0f;
                
                Ray ray = CreateCameraRay(screenUV);

                float3 result = float3(0, 0, 0);

                // [unroll(10)]
                for (int i = 0; i < _TraceCount; i ++)
                {
                    RayHit hit = Trace(ray);
                    result += ray.energy * Shade(ray, hit,i);
                    
                    if (!any(ray.energy))
                    break;
                }

                return half4(result, 1);
            }
            
            ENDCG
            
        }
    }
    FallBack "Diffuse"
}
