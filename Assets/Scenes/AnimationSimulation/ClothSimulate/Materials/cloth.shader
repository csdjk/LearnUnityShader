Shader "lcl/Cloth/Cloth_Diffuse" {
    //属性
    Properties{
        _MainTex ("Main Tex", 2D) = "white" {}
        _Diffuse("Diffuse Color",Color) = (1,1,1,1)
    }
    SubShader {
        Pass{
            Tags { "LightMode"="ForwardBase" }
            Cull Off

            CGPROGRAM
            #include "Lighting.cginc"
            #pragma vertex vert
            #pragma fragment frag

			fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;

            struct a2v {
                float4 vertex : POSITION;
                float3 normal: NORMAL;
				float4 texcoord : TEXCOORD0;
            };

            struct v2f{
                float4 position:SV_POSITION;
                float3 worldNormalDir:COLOR0;
                float4 uv:COLOR1;
            };

            v2f vert(a2v v){
                v2f f;
                f.position = UnityObjectToClipPos(v.vertex);
				f.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                f.worldNormalDir = mul(v.normal,(float3x3) unity_WorldToObject);
                return f;
            };

            float4 _Diffuse;

            fixed4 frag(v2f f):SV_TARGET{
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                fixed3 normalDir = normalize(f.worldNormalDir);
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                //半兰伯特漫反射  值范围0-1
                fixed3 halfLambert = dot(normalDir,lightDir)*0.5+0.5;	
                fixed3 diffuse = _LightColor0.rgb * halfLambert;
                fixed3 resultColor = (diffuse + ambient) * _Diffuse;

				fixed3 albedo = tex2D(_MainTex, f.uv.xy).rgb ;

                return fixed4(resultColor*albedo,1);
            };
            
            ENDCG
        }
    }
    FallBack "VertexLit"
}