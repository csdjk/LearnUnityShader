Shader "Unlit/MaskObject"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Diffuse("Diffuse Color",Color) = (1,1,1,1)
        _MaskID("MaskID",Int) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue" = "Geometry+2" }
        Pass
        {
            Stencil{
                Ref [_MaskID]
                Comp Equal
            }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
			#include "Lighting.cginc"
            #include "UnityCG.cginc"
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal: NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldNormalDir:COLOR0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			float4 _Diffuse;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormalDir = mul(v.normal,(float3x3) unity_WorldToObject);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                fixed3 normalDir = normalize(i.worldNormalDir);
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                //半兰伯特漫反射  值范围0-1
                fixed3 halfLambert = dot(normalDir,lightDir)*0.5+0.5;	
                fixed3 diffuse = _LightColor0.rgb * halfLambert;
                fixed3 resultColor = (diffuse + ambient) * _Diffuse * col;
				return fixed4(resultColor,1);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
