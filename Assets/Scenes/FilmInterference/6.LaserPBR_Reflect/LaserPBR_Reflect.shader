Shader "lcl/FilmInterference/LaserPBR_Reflect"
{
    Properties
    {
        [Tex(_, _DiffuseColor)]_MainTex ("Albedo Tex", 2D) = "white" { }
        [HideInInspector]_DiffuseColor ("Diffuse Color", Color) = (1, 1, 1, 1)

        [Tex(_, _SpecularColor)]_SpecularTex ("Specular Tex", 2D) = "white" { }
        [HideInInspector]_SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)

        [Tex(_, _Metallic)] _MetallicTex ("Metallic Tex", 2D) = "white" { }
        [HideInInspector]_Metallic ("Metallic", Range(0, 1)) = 0

        [Tex(_, _Roughness)] _RoughnessTex ("Roughness Tex", 2D) = "white" { }
        [HideInInspector]_Roughness ("Roughness", Range(0, 1)) = 0.1
        
        [Tex(_, _AoPower)]_AOTex ("AO Tex", 2D) = "white" { }
        [HideInInspector]_AoPower ("AO Power", Range(0, 1)) = 0.1

        [Tex(_, _NormalScale)]_NormalTex ("Normal Tex", 2D) = "bump" { }
        [HideInInspector]_NormalScale ("Normal Scale", Range(0, 10)) = 1
        
        // 自发光
        [Main(_emissionGroup, __, 0)] _emissionGroup ("Emission", float) = 1
        [Tex(_emissionGroup, _EmissionColor)] _EmissionTex ("Emission Tex", 2D) = "white" { }
        [HideInInspector][HDR]_EmissionColor ("Emission Color", Color) = (0, 0, 0, 0)


        [Space(20)][Header(ColorRamp)][Space(20)]
        _ColorRamp ("ColorRamp", 2D) = "white" { }
        _ColorRamp2 ("ColorRamp2", 2D) = "white" { }
        _Distortion ("Distortion", Range(0, 10)) = 6
        _LaserPower ("LaserPower", Range(0, 10)) = 1

        [Space(20)][Header(Hue)][Space(20)]
        _Hue ("Hue", Range(0, 1)) = 0
        _Saturation ("Saturation", Range(0, 1.0)) = 0.5
        _Brightness ("Brightness", Range(0, 1.0)) = 0.5
        _Contrast ("Contrast", Range(0, 1.0)) = 0.5
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" "Queue" = "Transparent" "RenderType" = "Transparent" }
            Cull off
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM

            #pragma target 3.0

            #include "Assets\Shader\ShaderLibs\LcLLighting.cginc"
            #include "Assets\Shader\ShaderLibs\Node.cginc"

            #pragma multi_compile _ _EMISSIONGROUP_ON

            #pragma vertex LitPassVertex
            #pragma fragment LaserFragment


            sampler2D _ColorRamp;
            float4 _ColorRamp_ST;
            sampler2D _ColorRamp2;

            float _Distortion, _LaserPower;
            half _Hue, _Saturation, _Brightness, _Contrast;

            fixed4 LaserFragment(Varyings i) : SV_Target
            {
                LcLSurfaceData surfaceData = InitSurfaceData(i);
                LcLInputData inputData = InitInputData(i, surfaceData);
                UnityGI gi = LcLFragmentGI(surfaceData, inputData);

                float3 N = surfaceData.Normal;
                float3 V = inputData.worldView;
                float3 L = inputData.light.dir;

                float NdotV = saturate(dot(N, V));
                float NdotL = saturate(dot(N, L));
                
                float3 H = normalize(L + V);
                float NdotH = saturate(dot(N, H));
                

                float3 laserColor = tex2D(_ColorRamp, TRANSFORM_TEX(float2(NdotV, NdotV), _ColorRamp) * _Distortion);

                // 色相偏移
                half4 hsbc = half4(_Hue, _Saturation, _Brightness, _Contrast);
                laserColor = ApplyHSBCEffect(float4(laserColor, 1), hsbc);
                laserColor = laserColor * (NdotL * 0.5 + 0.5) + laserColor * pow(NdotH, 25);


                float R = normalize(reflect(-V, N));
                float RdotV = (dot(R, -V));
                RdotV = Remap(RdotV, float2(-1, 1), float2(0, 1));

                float3 rcolor = tex2D(_ColorRamp2, float2(RdotV, RdotV) * _Distortion);
                rcolor = pow(rcolor, 10);
                laserColor = rcolor * laserColor;

                RdotV = pow(RdotV, _LaserPower);
                laserColor = laserColor * RdotV;

                surfaceData.Albedo = saturate(laserColor);


                half4 finalColor = LcLFragmentPBR(surfaceData, inputData, gi);

                finalColor.a = 1;

                return finalColor;
            }

            ENDCG
        }
    }
    FallBack "VertexLit"
    CustomEditor "JTRP.ShaderDrawer.LWGUI"
}