Shader "lcl/Shader2D/UI-Dissolve"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" { }
        _Color ("Tint", Color) = (1, 1, 1, 1)

        [HideInInspector]_StencilComp ("Stencil Comparison", Float) = 8
        [HideInInspector]_Stencil ("Stencil ID", Float) = 0
        [HideInInspector]_StencilOp ("Stencil Operation", Float) = 0
        [HideInInspector]_StencilWriteMask ("Stencil Write Mask", Float) = 255
        [HideInInspector]_StencilReadMask ("Stencil Read Mask", Float) = 255
        [HideInInspector]_ColorMask ("Color Mask", Float) = 15
        [HideInInspector][Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0


        _NoiseTex ("Noise", 2D) = "white" { }
        _CenterPoint ("Center Point", Vector) = (0, 0, 0, 0)
        _Threshold ("Threshold", Range(0.0, 1.0)) = 0.5
        _MaxDistance ("Max Distance", Range(0.0, 1000)) = 0
        [Header(Edge Data)][Space(20)]
        _EdgeFirstColor ("EdgeFirstColor", Color) = (1, 1, 1, 1)
        _EdgeSecondColor ("EdgeSecondColor", Color) = (1, 1, 1, 1)
        _EdgeLength ("Edge Length", Range(0.0, 0.2)) = 0.1
        _EdgeBlur ("Edge Blur", Range(0.0, 0.2)) = 0.1
        _NoiseStrength ("Noise Strength", Range(0.0, 1.0)) = 0.5
    }

    SubShader
    {
        Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "PreviewType" = "Plane" "CanUseSpriteAtlas" = "True" }

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask [_ColorMask]

        Pass
        {
            Name "Default"
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            #include "UnityCG.cginc"
            #include "UnityUI.cginc"
            #include "Assets\Shader\ShaderLibs\Node.cginc"

            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP

            struct appdata_t
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
                float2 texcoord : TEXCOORD0;
                float4 positionOS : TEXCOORD1;
                half4 mask : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            fixed4 _Color;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;
            float4 _MainTex_ST;
            float _UIMaskSoftnessX;
            float _UIMaskSoftnessY;

            
            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;
            float _Threshold;
            float _EdgeLength;
            float _EdgeBlur;
            float _MaxDistance;
            float4 _CenterPoint;
            float _NoiseStrength;
            fixed4 _EdgeFirstColor;
            fixed4 _EdgeSecondColor;

            v2f vert(appdata_t v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                float4 vPosition = UnityObjectToClipPos(v.vertex);
                OUT.positionOS = v.vertex;
                OUT.vertex = vPosition;

                float2 pixelSize = vPosition.w;
                pixelSize /= float2(1, 1) * abs(mul((float2x2)UNITY_MATRIX_P, _ScreenParams.xy));

                float4 clampedRect = clamp(_ClipRect, -2e10, 2e10);
                float2 maskUV = (v.vertex.xy - clampedRect.xy) / (clampedRect.zw - clampedRect.xy);
                OUT.texcoord = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
                OUT.mask = half4(v.vertex.xy * 2 - clampedRect.xy - clampedRect.zw, 0.25 / (0.25 * half2(_UIMaskSoftnessX, _UIMaskSoftnessY) + abs(pixelSize.xy)));

                OUT.color = v.color * _Color;
                return OUT;
            }
            
            // // 以半径扩散溶解
            // // dissolveData => x : threshold , y : maxDistance, z : noiseStrength
            // // edgeData => x : length , y : blur
            // half4 DissolveByRadius(
            //     half4 color, sampler2D NoiseTex, float2 uv, float3 positionOS, float3 center,
            //     float3 dissolveData, float2 edgeData,
            //     half4 edgeFirstColor, half4 edgeSecondColor)
            // {
            //     float dist = length(positionOS.xyz - center.xyz);
            //     float normalizedDist = saturate(dist / dissolveData.y);
            //     half noise = tex2D(NoiseTex, uv).r;
                
            //     fixed cutout = lerp(noise, normalizedDist, dissolveData.z);
            //     half cutoutThreshold = dissolveData.x - cutout;
            //     clip(cutoutThreshold);

            //     cutoutThreshold = cutoutThreshold / edgeData.x;
            //     //边缘颜色过渡
            //     float degree = saturate(cutoutThreshold - edgeData.y);
            //     half4 edgeColor = lerp(edgeFirstColor, edgeSecondColor, degree);
            //     half4 finalColor = lerp(edgeColor, color, degree);


            //     // 软边缘透明过渡
            //     half a = saturate(color.a);
            //     finalColor.a = lerp(saturate(cutoutThreshold / edgeData.y) * a, a, degree);

            //     return finalColor;
            // }

            fixed4 frag(v2f IN) : SV_Target
            {
                half4 color = IN.color * (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd);

                #ifdef UNITY_UI_CLIP_RECT
                    half2 m = saturate((_ClipRect.zw - _ClipRect.xy - abs(IN.mask.xy)) * IN.mask.zw);
                    color.a *= m.x * m.y;
                #endif

                #ifdef UNITY_UI_ALPHACLIP
                    clip(color.a - 0.001);
                #endif


                return DissolveByRadius(
                    color, _NoiseTex, IN.texcoord, IN.positionOS, _CenterPoint.xyz,
                    float3(_Threshold, _MaxDistance, _NoiseStrength), float2(_EdgeLength, _EdgeBlur),
                    _EdgeFirstColor, _EdgeSecondColor
                );
            }
            ENDCG
        }
    }
}
