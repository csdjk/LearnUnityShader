// shader GUI插件LWGUI
Shader "lcl/ShaderGUI/ShaderLcLGUI"
{
    Properties
    {
        [Enum(UnityEngine.Rendering.StencilOp)]_StencilFail ("Stencil Fail", Float) = 0
        [KeywordEnum(None, Add, Multiply)] _Overlay ("Overlay mode", Float) = 0

        [Foldout(_SWITCH)] _SWITCH ("溶解面板", int) = 0
        [LightDir]_LightDir ("Light Dir", Vector) = (0, 0, -1, 0)
        [PowerSlider(2)]_WaveAmp3 ("Wave Amp3", Range(0, 1)) = 1.0
        [HDR]_Color ("Color", Color) = (1, 1, 1, 1)
        [SingleLine]_RampTex ("Ramp", 2D) = "white" { }
        [VectorRange(0, 1)]_WorldSize ("World Size", vector) = (1, 1, 1, 1)
        [Foldout(_SWITCH3)] _SWITCH3 ("溶解面板3", int) = 0
        [FoldoutEnd]_HeightCutoff2 ("Height Cutoff2", float) = 1.2

        _WaveSpeed ("Wave Speed", float) = 1.0
        [FoldoutEnd]_WaveAmp ("Wave Amp", float) = 1.0
        [Foldout(_SWITCH2)] _SWITCH2 ("溶解面板2", int) = 0

        _HeightFactor ("Height Factor", float) = 1.0

        [PowerSlider(2)]_WaveAmp2 ("Wave Amp2", Range(0, 1)) = 1.0
        _HeightCutoff ("Height Cutoff", float) = 1.2
        _WindTex ("Wind Texture", 2D) = "white" { }
        [FoldoutEnd] _WindSpeed ("Wind Speed", vector) = (1, 1, 1, 1)
        _HeightCutoff ("Height Cutoff", float) = 1.2
        _WindTex ("Wind Texture", 2D) = "white" { }
        _HeightCutoff ("Height Cutoff", float) = 1.2
        _WindTex ("Wind Texture", 2D) = "white" { }
        _HeightCutoff ("Height Cutoff", float) = 1.2
        _WindTex ("Wind Texture", 2D) = "white" { }
        _HeightCutoff ("Height Cutoff", float) = 1.2
        _WindTex ("Wind Texture", 2D) = "white" { }
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

            #pragma multi_compile _ _GROUP_ON

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
    CustomEditor "LcLShaderEditor.LcLShaderGUI"
}
