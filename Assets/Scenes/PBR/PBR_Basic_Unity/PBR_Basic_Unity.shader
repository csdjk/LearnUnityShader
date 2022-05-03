//PBR - Unity 内置
Shader "lcl/PBR/PBR_Basic_Unity" {
    Properties{
        _MainTex ("Main Tex", 2D) = "white" {}
        _Diffuse("Diffuse Color",Color) = (1,1,1,1)
        _Specular("Specular Color",Color) = (1,1,1,1)
        _Smoothness("Smoothness",Range(0,1)) = 0.1
        _Metallic("Metallic",Range(0,1)) = 0
        
    }
    SubShader {
        Pass{
            Tags { "LightMode"="ForwardBase" "RenderType"="Opaque"}
            CGPROGRAM
            #include "Lighting.cginc"
            #include "UnityPBSLighting.cginc"
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Diffuse;
            fixed3 _Specular;
            half _Metallic;
            half _Smoothness;

            struct a2v {
                float4 vertex : POSITION;
                float3 normal: NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f{
                float4 position:SV_POSITION;
                float3 worldNormal: TEXCOORD0;
                float3 worldVertex: TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            v2f vert(a2v v){
                v2f f;
                f.position = UnityObjectToClipPos(v.vertex);
                f.worldNormal = mul(v.normal,(float3x3) unity_WorldToObject);
                f.worldVertex = mul(unity_ObjectToWorld, v.vertex).xyz;
                f.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return f;
            };


            fixed4 frag(v2f f):SV_TARGET{
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                fixed3 albedo = tex2D(_MainTex, f.uv).rgb;
                fixed3 normalDir = normalize(f.worldNormal);
                fixed3 lightDir = _WorldSpaceLightPos0.xyz;
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - f.worldVertex);
                // 能量守恒
                // half oneMinusReflectivity;
                // albedo = EnergyConservationBetweenDiffuseAndSpecular (albedo,_Specular, oneMinusReflectivity);
                // albedo *= 1-max(_Specular.r,max(_Specular.g,_Specular.b));
                
                // 
                // float oneMinusReflectivity = 1 - _Metallic;
                // _Specular = albedo * _Metallic;
                // albedo *= oneMinusReflectivity;
                // 金属度
                half3 specColor;
                half oneMinusReflectivity;
                albedo = DiffuseAndSpecularFromMetallic (albedo, _Metallic, /*out*/ _Specular, /*out*/ oneMinusReflectivity);
                
                UnityLight light;
                light.color = _LightColor0.rgb;
                light.dir = lightDir;
                light.ndotl = saturate(dot(normalDir,lightDir));

                UnityIndirect indirectLight;
                indirectLight.diffuse = 0;
                indirectLight.specular = 0;
                half4 c = UNITY_BRDF_PBS (albedo, _Specular, oneMinusReflectivity, _Smoothness, normalDir, viewDir, light, indirectLight);

                return c;
                
                // fixed3 diffuse = _LightColor0.rgb * max(dot(normalDir,lightDir),0) * _Diffuse.rgb;
                // //高光反射
                // fixed3 reflectDir = reflect(-lightDir,normalDir);//反射光
                // fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz -f.worldVertex );
                // fixed3 specular = _LightColor0.rgb * pow(max(0,dot(viewDir,reflectDir)),_Smoothness) *_Specular;
                // fixed3 tempColor = diffuse*albedo+ambient+specular;

                // return fixed4(tempColor,1);
            };
            
            ENDCG
        }
    }
    FallBack "VertexLit"
}