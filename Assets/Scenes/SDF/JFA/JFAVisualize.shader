Shader "Unlit/JFAVisualize"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _Distance ("Distance", float) = 10
    }

    HLSLINCLUDE
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #pragma multi_compile _ RENDERTEXTURE_UPSIDE_DOWN

    Texture2D _MainTex;
    float4 _MainTex_TexelSize;
    SamplerState sampler_PointClamp;
    float _Distance;

    struct Attributes
    {
        float4 positionOS : POSITION;
        float2 texcoord : TEXCOORD0;
    };

    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float2 uv : TEXCOORD0;
    };

    Varyings Vert(Attributes input)
    {
        Varyings output = (Varyings)0;
        VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
        output.positionCS = vertexInput.positionCS;
        output.uv = input.texcoord;
        return output;
    }

    float4 Frag(Varyings input) : SV_TARGET
    {
        float2 upsideDown = input.uv;
        #if RENDERTEXTURE_UPSIDE_DOWN
            upsideDown = float2(input.uv.x, 1 - input.uv.y);
        #endif
        float2 uvOne = float2(upsideDown.x * 2, upsideDown.y);
        float2 uvTwo = float2(upsideDown.x * 2 - 1, upsideDown.y);
        float4 returnColor = 0;

        if (input.uv.x >= 0.5)
        {
            float4 texColor = _MainTex.SampleLevel(sampler_PointClamp, uvTwo, 0);
            #if RENDERTEXTURE_UPSIDE_DOWN
                float2 realTexcoord = float2(input.uv.x * 2 - 1, input.uv.y);
                realTexcoord = floor(realTexcoord * _MainTex_TexelSize.zw) + 0.5;
                float distance = length(texColor.xy * _MainTex_TexelSize.zw - realTexcoord);
            #else
                float2 realTexcoord = uvTwo;
                realTexcoord = floor(realTexcoord * _MainTex_TexelSize.zw) + 0.5;
                float distance = length(texColor.xy * _MainTex_TexelSize.zw - realTexcoord);
            #endif
            float grayScale = smoothstep(_Distance, 0, distance);
            returnColor = float4(grayScale, grayScale, grayScale, 1);
        }
        else
        {
            returnColor = _MainTex.SampleLevel(sampler_PointClamp, uvOne, 0);
        }
        return returnColor;
    }

    ENDHLSL

    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            Name "JFA Visualize Pass"
            Tags { "LightMode" = "UniversalForward" }
            Cull Back
            ZTest LEqual
            ZWrite On
            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
            ENDHLSL
        }
    }
}
