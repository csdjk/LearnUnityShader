Shader "lcl/Glass/Glass"
{
    Properties
    {
        [Enum(UnityEngine.Rendering.CullMode)]_CullMode ("CullMode", float) = 2
        [Enum(Off, 0, On, 1)]_ZWriteMode ("ZWriteMode", float) = 0

        _ReflectionTex ("Reflection Texture", 2D) = "white" { }
        _RefractionTex ("Reflection Texture", 2D) = "white" { }

        _RefractColor ("Refract Color", Color) = (1, 1, 1, 1)
        _RefractIntensity ("Refract Intensity", Range(0, 1)) = 0.5

        _RefractThreshold ("Refract Threshold", Range(0, 1)) = 0.5
        _RefractSmooth ("Refract Smooth", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull [_CullMode]
        ZWrite [_ZWriteMode]

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            // Cull Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            #include "Assets\Shader\ShaderLibs\Node.cginc"
            #include "Assets\Shader\ShaderLibs\PSBlendModes.cginc"


            sampler2D _ReflectionTex;
            sampler2D _RefractionTex;

            half4 _RefractColor;
            half _RefractIntensity;

            half _RefractThreshold;
            half _RefractSmooth;

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
                float3 viewWS : TEXCOORD1;
                //  float3 positionWS : TEXCOORD1;

            };
            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                o.normalWS = UnityObjectToWorldNormal(v.normal);
                o.viewWS = WorldSpaceViewDir(v.vertex);
                //  o.positionWS = mul(unity_ObjectToWorld, v.vertex).xyz;
                
                // matcap uv
                float3 viewnormal = mul(UNITY_MATRIX_IT_MV, v.normal);
                float3 viewPos = UnityObjectToViewPos(v.vertex);
                viewPos = normalize(viewPos);
                float3 vcn = cross(viewPos, viewnormal);
                float2 uv = float2(-vcn.y, vcn.x);
                o.uv = uv * 0.5 + 0.5;

                return o;
            }
            half4 frag(v2f i) : SV_Target
            {
                float3 N = normalize(i.normalWS);
                float3 V = normalize(i.viewWS);
                float NdotV = dot(N, V);
                
                // 反射
                float3 reflectColor = tex2D(_ReflectionTex, i.uv);

                
                // 折射
                //   float fresnel = 1 - smoothstep(0, 1, NdotV);
                float fresnel = 1 - SmoothValue(NdotV, _RefractThreshold, _RefractSmooth);
                
                float refractIntensity = fresnel * _RefractIntensity;
                float2 refractUV = i.uv + refractIntensity;

                float3 refractColor = tex2D(_RefractionTex, refractUV) * _RefractColor;
                float3 refractColor2 = _RefractColor * 0.5f;

                refractColor = lerp(refractColor2, refractColor, saturate(refractIntensity));
                // 最终颜色
                half3 resColor = reflectColor + refractColor;
                //  half3 resColor = refractColor;

                // Alpha
                half alpha = saturate(max(reflectColor.r, fresnel));


                //   return refractIntensity*refractColor2;


                //   float3 debug = fresnel;
                //   return half4(debug, 1);


                return half4(resColor, alpha);
            }
            ENDCG
        }
    }
    FallBack "Reflective/VertexLit"
}

