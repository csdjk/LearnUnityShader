Shader "lcl/ShaderGUI/CustomLightDir"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        [LightDir]_LightDir ("Light Dir", Vector) = (0, 0, -1, 0)
        _Gloss ("Gloss", float) = 128
        [hdr]_SpecularCol ("Specular Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag


            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 tangent : TANGENT;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                half3 normalDir : TEXCOORD0;
                half3 viewDir : TEXCOORD1;
                half3 lightDir : TEXCOORD2;
            };

            fixed4 _Color;

            half4 _LightDir;
            half _Gloss;
            fixed4 _SpecularCol;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                o.viewDir = ObjSpaceViewDir(v.vertex);
                o.lightDir = -_LightDir.xyz;
                o.normalDir = v.normal;

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                half3 viewDir = normalize(i.viewDir);
                half3 lightDir = normalize(i.lightDir);
                half3 normalDir = normalize(i.normalDir);
                half3 halfDir = normalize(viewDir + lightDir);

                half diff = saturate(dot(normalDir, lightDir));
                half spec = pow(saturate(dot(halfDir, normalDir)), _Gloss) * _SpecularCol.rgb;

                fixed3 col = _Color.rgb * diff + spec * _SpecularCol.rgb;

                return fixed4(col, _Color.a);
            }
            ENDCG
        }
    }
    // CustomEditor "CustomLightDir"
}