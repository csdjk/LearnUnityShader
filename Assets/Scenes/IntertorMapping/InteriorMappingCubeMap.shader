Shader "lcl/InteriorMapping/InteriorMappingCubeMap"
{
    Properties
    {
        _Cube ("Cube", Cube) = "" { }
        _Tilling ("Tilling", Float) = 1.0
        _Angle ("Angle", Float) = 1.0
        _RotateAxis ("RotateAxis", Vector) = (0, 0, 1, 1)
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

            samplerCUBE _Cube;
            float _Tilling;
            float _Angle;
            float3 _RotateAxis;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
            };
            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float3x3 tbnMtrix : float3x3;
            };
            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                o.positionWS = mul(unity_ObjectToWorld, v.vertex).xyz;

                half3 worldNormal = UnityObjectToWorldNormal(v.normal);
                half3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                half3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;
                o.tbnMtrix = float3x3(worldTangent, worldBinormal, worldNormal);
                return o;
            }
         
            half4 frag(v2f i) : SV_Target
            {
                float3 V = Unity_SafeNormalize(UnityWorldSpaceViewDir(i.positionWS));

                float3 viewTS = normalize(mul(i.tbnMtrix, V));

                float3 interuvw = InteriorCubemap(i.uv, _Tilling, viewTS);
                interuvw = RotateAboutAxis_Degrees(interuvw, _RotateAxis, _Angle);
                float3 color = texCUBE(_Cube, interuvw);
                return half4(color, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}