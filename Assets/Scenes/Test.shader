Shader "lichanglong/Test"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", Color) = (0,1,1,0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma enable_d3d11_debug_symbols

            #include "Assets/Shader/ShaderLibs/LightingModel.cginc"
            #include "Assets/Shader/ShaderLibs/Noise.cginc"


            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float3 normal: NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldNormal: TEXCOORD1;
				float3 worldVertex: TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            uniform fixed4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                
                o.worldNormal = mul(v.normal,(float3x3) unity_WorldToObject);
                o.worldVertex = mul(v.vertex,unity_WorldToObject).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 resultColor = ComputePhongLighting(i.worldNormal,i.worldVertex);
                return fixed4(resultColor,0);
            }
            ENDCG
        }
    }
}
