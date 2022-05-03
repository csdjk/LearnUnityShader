Shader "lcl/FilmInterference/LaserPBRFilm"
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

        [Header(Indirect)]
        _IrradianceCubemap ("Irradiance Cubemap", Cube) = "_Skybox" { }

        // 自发光
        [Main(_emissionGroup, __, 0)] _emissionGroup ("Emission", float) = 1
        [Tex(_emissionGroup, _EmissionColor)] _EmissionTex ("Emission Tex", 2D) = "white" { }
        [HideInInspector][HDR]_EmissionColor ("Emission Color", Color) = (0, 0, 0, 0)


        [Space(20)][Header(ColorRamp)][Space(20)]
        _ColorRamp ("ColorRamp", 2D) = "white" { }
        _ContrastMask1 ("ContrastMask1", Color) = (0, 0, 1, 1)
        _Tile ("Tile", Range(0, 20)) = 1
        _MainColor ("MainColor", Color) = (1, 1, 1, 0)
        _MaskRgb ("MaskRgb", Color) = (1, 1, 1, 0)
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" "Queue" = "Geometry" }
            Cull off
            
            CGPROGRAM

            #pragma target 3.0

            #include "Assets\Shader\ShaderLibs\LCL_BRDF.cginc"
            #include "Assets\Shader\ShaderLibs\Color.cginc"

            #pragma multi_compile _ _EMISSIONGROUP_ON
            // #pragma enable_d3d11_debug_symbols


            #pragma vertex LitPassVertex
            #pragma fragment LaserFragment


            sampler2D _ColorRamp;
            float4 _ColorRamp_ST;
            
            half _Tile;
            half4 _MainColor;
            half4 _MaskRgb;
            half4 _ContrastMask1;

            inline half3 thinFilm(float3 V,float3 N,float2 uv)
            {
                half3 CameraPos = V * _Tile;
                half3 DotPostion = dot(CameraPos, N);
                half3 Mask01 = saturate(cos(DotPostion) * _ContrastMask1.rgb);
                half3 CrossColor = cross(_ContrastMask1.rgb, float4(1, 1, 1, 1));
                half3 Mask02 = saturate(sin(DotPostion) * CrossColor);
                half3 AddMask = Mask01 + Mask02;
                half RGBToGray = saturate(0.2989 * AddMask.r + 0.587 * AddMask.g + 0.114 * AddMask.b);
                half4 c = tex2D(_ColorRamp, uv) * _MaskRgb;
                half3 laserColor = lerp(c, _MainColor, RGBToGray);
                return laserColor;
            }
            
            fixed4 LaserFragment(VertexOutput i) : SV_Target
            {
                LclSurfaceOutput s = LclSurf(i);
                LclUnityGIInput giInput = LclGetGIInput(i, s);
                UnityGI gi = LclFragmentGI(s, giInput);

                half3 laserColor = thinFilm(i.worldView,s.Normal,i.uv_MainTex);

                s.Albedo *= laserColor;
                fixed4 finalColor = LCL_BRDF_Unity_PBS(s, giInput, gi);


                return finalColor;
            }

            ENDCG

        }
    }
    FallBack "VertexLit"
    CustomEditor "JTRP.ShaderDrawer.LWGUI"
}