//10.1.5,菲尼尔反射
Shader "lcl/ShaderTest/Fresnel1"
{
    Properties
    {
        _Power("Power",range(0,10)) = 1
        _MainTex ("Texture", 2D) = "white" {}
        [HDR]_Color ("Color", Color) = (0, 0, 0, 1)
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "RenderType"="Transparent"}
        Pass
        {
            Blend SrcAlpha One
            // Blend One One
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 viewDir : TEXCOORD0;
                float3 normal : normal;
                float2 uv : TEXCOORD1;
            };

            float _Power;
            float4 _Color;

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.viewDir = ObjSpaceViewDir(v.vertex);
                o.normal = v.normal;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 tex = tex2D(_MainTex, i.uv);
                // 菲尼尔
                float fresnel = pow(1 - saturate(dot(normalize(i.viewDir), normalize(i.normal))), _Power);
                return tex * _Color * fresnel;
            }
            ENDCG
        }
    }
}