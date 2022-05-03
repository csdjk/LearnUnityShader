Shader "lcl/Shader2D/UI-OldPhoto"
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

        _Saturation ("Saturation", Range(0, 2)) = 1
        _Brightness ("Brightness", Range(0, 2)) = 1
        _Contrast ("Contrast", Range(0, 2)) = 1
        _OldPower ("Old Power", Range(0, 1)) = 0
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
                float4 worldPosition : TEXCOORD1;
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

            half _Saturation;
            half _Brightness;
            half _Contrast;
            half _OldPower;
            v2f vert(appdata_t v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                float4 vPosition = UnityObjectToClipPos(v.vertex);
                OUT.worldPosition = v.vertex;
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
            half3 GetOldPhotoColor(half3 color)
            {
                half r = 0.393 * color.r + 0.769 * color.g + 0.189 * color.b;
                half g = 0.349 * color.r + 0.686 * color.g + 0.168 * color.b;
                half b = 0.272 * color.r + 0.534 * color.g + 0.131 * color.b;
                return half3(r, g, b);
            }

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

                // 亮度
                color.rgb *= _Brightness;
                // 饱和度
                half luminance = LinearRgbToLuminance(color.rgb);
                fixed3 luminanceColor = fixed3(luminance, luminance, luminance);
                color.rgb = lerp(luminanceColor, color.rgb, _Saturation);
                // 对比度
                fixed3 avgColor = fixed3(0.5, 0.5, 0.5);
                color.rgb = lerp(avgColor, color.rgb, _Contrast);
                // 老照片风格
                color.rgb = lerp(color.rgb, GetOldPhotoColor(color.rgb), _OldPower);
                
                return color;
            }
            ENDCG

        }
    }
}
