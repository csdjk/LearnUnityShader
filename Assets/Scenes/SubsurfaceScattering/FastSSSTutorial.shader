/*
* @Descripttion: 次表面散射
* @Author: lichanglong
* @Date: 2021-08-20 18:21:10
 * @FilePath: \LearnUnityShader\Assets\Scenes\SubsurfaceScattering\FastSSSTutorial.shader
*/
Shader "lcl/SubsurfaceScattering/FastSSSTutorial" {
    Properties{
        _MainTex ("Texture", 2D) = "white" {}
        _BaseColor("Base Color",Color) = (1,1,1,1)
        _Specular("Specular Color",Color) = (1,1,1,1)
        [PowerSlider()]_Gloss("Gloss",Range(1,200)) = 10
        
        [Main(sss,_,3)] _group ("SubsurfaceScattering", float) = 1
        [Tex(sss)]_ThicknessTex ("Thickness Tex", 2D) = "white" {}
        [Sub(sss)]_ThicknessPower ("ThicknessPower", Range(0,10)) = 1

        [Sub(sss)][HDR]_ScatterColor ("Scatter Color", Color) = (1,1,1,1)
        [Sub(sss)]_WrapValue ("WrapValue", Range(0,1)) = 0.0
        [Title(sss, Back SSS Factor)]
        [Sub(sss)]_DistortionBack ("Back Distortion", Range(0,1)) = 1.0
        [Sub(sss)]_PowerBack ("Back Power", Range(0,10)) = 1.0
        [Sub(sss)]_ScaleBack ("Back Scale", Range(0,1)) = 1.0

        // 是否开启计算点光源
        [SubToggle(sss, __)] _CALCULATE_POINTLIGHT ("Calculate Point Light", float) = 0
    }
    SubShader {
        Pass{
            Tags { "LightMode"="Forwardbase" }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            // #pragma enable_d3d11_debug_symbols
            #pragma multi_compile _ _CALCULATE_POINTLIGHT_ON 

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            sampler2D _MainTex,_ThicknessTex;
            float4 _MainTex_ST;
            fixed4 _BaseColor;
            half _Gloss;
            float3 _Specular;
            
            float4 _ScatterColor;
            float _DistortionBack;
            float _PowerBack;
            float _ScaleBack;
            
            float _ThicknessPower;
            float _WrapValue;
            float _ScatterWidth;

            // float  _RimPower;
            // float _RimIntensity;
            struct a2v {
                float4 vertex : POSITION;
                float3 normal: NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f{
                float4 position:SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalDir: TEXCOORD1;
                float3 worldPos: TEXCOORD2;
                float3 viewDir: TEXCOORD3;
                float3 lightDir: TEXCOORD4;
            };

            v2f vert(a2v v){
                v2f o;
                o.position = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = mul (unity_ObjectToWorld, v.vertex);
                o.normalDir = UnityObjectToWorldNormal (v.normal);
                o.viewDir = UnityWorldSpaceViewDir(o.worldPos);
                o.lightDir = UnityWorldSpaceLightDir(o.worldPos);
                return o;
            };
            
            // 计算SSS
            inline float SubsurfaceScattering (float3 V, float3 L, float3 N, float distortion,float power,float scale)
            {
                // float3 H = normalize(L + N * distortion);
                float3 H = L + N * distortion;
                float I = pow(saturate(dot(V, -H)), power) * scale;
                return I;
            }
            
            // 计算点光源SSS（参考UnityCG.cginc 中的Shade4PointLights）
            float3 CalculatePointLightSSS (
            float4 lightPosX, float4 lightPosY, float4 lightPosZ,
            float3 lightColor0, float3 lightColor1, float3 lightColor2, float3 lightColor3,
            float4 lightAttenSq,float3 pos,float3 N,float3 V)
            {
                // to light vectors
                float4 toLightX = lightPosX - pos.x;
                float4 toLightY = lightPosY - pos.y;
                float4 toLightZ = lightPosZ - pos.z;
                // squared lengths
                float4 lengthSq = 0;
                lengthSq += toLightX * toLightX;
                lengthSq += toLightY * toLightY;
                lengthSq += toLightZ * toLightZ;
                // don't produce NaNs if some vertex position overlaps with the light
                lengthSq = max(lengthSq, 0.000001);

                // NdotL
                float4 ndotl = 0;
                ndotl += toLightX * N.x;
                ndotl += toLightY * N.y;
                ndotl += toLightZ * N.z;
                // correct NdotL
                float4 corr = rsqrt(lengthSq);
                ndotl = max (float4(0,0,0,0), ndotl * corr);
                
                float4 atten = 1.0 / (1.0 + lengthSq * lightAttenSq);
                float4 diff = ndotl * atten;
                
                float3 pointLightDir0 = normalize(float3(toLightX[0],toLightY[0],toLightZ[0]));
                float pointSSS0 = SubsurfaceScattering(V,pointLightDir0,N,_DistortionBack,_PowerBack,_ScaleBack)*3;

                float3 pointLightDir1 = normalize(float3(toLightX[1],toLightY[1],toLightZ[1]));
                float pointSSS1 = SubsurfaceScattering(V,pointLightDir1,N,_DistortionBack,_PowerBack,_ScaleBack)*3;

                float3 pointLightDir2 = normalize(float3(toLightX[2],toLightY[2],toLightZ[2]));
                float pointSSS2 = SubsurfaceScattering(V,pointLightDir2,N,_DistortionBack,_PowerBack,_ScaleBack)*3;

                float3 pointLightDir3 = normalize(float3(toLightX[3],toLightY[3],toLightZ[3]));
                float pointSSS3 = SubsurfaceScattering(V,pointLightDir3,N,_DistortionBack,_PowerBack,_ScaleBack)*3;

                // final color
                float3 col = 0;
                // col += lightColor0 * diff.x;
                // col += lightColor1 * diff.y;
                // col += lightColor2 * diff.z;
                // col += lightColor3 * diff.w;
                col += lightColor0 * atten.x * (pointSSS0+ndotl.x);
                col += lightColor1 * atten.y * (pointSSS1+ndotl.y);
                col += lightColor2 * atten.z * (pointSSS2+ndotl.z);
                col += lightColor3 * atten.w * (pointSSS3+ndotl.w);
                
                return col;
            }

            fixed4 frag(v2f i): SV_TARGET{
                fixed4 col = tex2D(_MainTex, i.uv) * _BaseColor;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                fixed3 lightColor = _LightColor0.rgb;
                float3 N = normalize(i.normalDir);
                float3 V = normalize(i.viewDir);
                float3 L = normalize(i.lightDir);
                float NdotL = dot(N, L);
                float3 H = normalize(L + V);
                float NdotH = dot(N, H);
                float NdotV = dot(N, V);

                float thickness = tex2D(_ThicknessTex, i.uv).r * _ThicknessPower;
                // -----------------------------SSS-----------------------------
                // 快速模拟次表面散射
                float3 sss = SubsurfaceScattering(V,L,N,_DistortionBack,_PowerBack,_ScaleBack) * lightColor * _ScatterColor * thickness;

                // -----------------------------Wrap Lighting-----------------------------
                // float wrap_diffuse = pow(dot(N,L)*_WrapValue+(1-_WrapValue),2) * col;
                float wrap_diffuse = max(0, (NdotL + _WrapValue) / (1 + _WrapValue));
                // float scatter = smoothstep(0.0, _ScatterWidth, wrap_diffuse) * smoothstep(_ScatterWidth * 2.0, _ScatterWidth,wrap_diffuse);
                
                // -----------------------------Diffuse-----------------------------
                // float diffuse = lightColor * (max(0, NdotL)*0.5+0.5) * col;
                // float diffuse = lightColor * (max(0, NdotL)) * col;
                float3 diffuse = lightColor * wrap_diffuse  * col;

                // --------------------------Specular-BlinnPhong-----------------------------
                fixed3 specular = lightColor * pow(max(0,NdotH),_Gloss) * _Specular;
                
                // -----------------------------Rim-----------------------------
                // float rim = 1.0 - max(0, NdotV);
                // return rim;

                // -----------------------------Point Light SSS-----------------------------
                fixed3 pointColor = fixed3(0,0,0);
                // 计算点光源
                #ifdef _CALCULATE_POINTLIGHT_ON
                    pointColor = CalculatePointLightSSS(unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                    unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
                    unity_4LightAtten0,i.worldPos,N,V) * thickness;
                #endif

                float3 resCol = diffuse + sss + pointColor + specular;

                return fixed4(resCol,1);
                
            };
            
            ENDCG
        }
      
    }
    FallBack "Diffuse"
}