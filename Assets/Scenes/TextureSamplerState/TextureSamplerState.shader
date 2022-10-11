// ================================= 采样器 =================================
Shader "lcl/TextureSamplerState"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        [KeywordEnum(Normal, PointRepeat, LinearRepeat, PointClamp, LinearClamp, PointMirror, LinearMirror, PointMirrorOnce, LinearMirrorOnce, ClampU_RepeatV_Linear)] _SamplerState ("Sampler State", Int) = 0
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

            #pragma multi_compile _SAMPLERSTATE_NORMAL _SAMPLERSTATE_POINTREPEAT _SAMPLERSTATE_LINEARREPEAT _SAMPLERSTATE_POINTCLAMP _SAMPLERSTATE_LINEARCLAMP _SAMPLERSTATE_POINTMIRROR _SAMPLERSTATE_LINEARMIRROR _SAMPLERSTATE_POINTMIRRORONCE _SAMPLERSTATE_LINEARMIRRORONCE _SAMPLERSTATE_CLAMPU_REPEATV_LINEAR

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
            // sampler2D _MainTex;
            Texture2D _MainTex;
            SamplerState sampler_MainTex;

            SamplerState PointRepeatSampler;
            SamplerState LinearRepeatSampler;

            SamplerState PointClampSampler;
            SamplerState LinearClampSampler;
            
            SamplerState PointMirrorSampler;
            SamplerState LinearMirrorSampler;
            
            SamplerState PointMirrorOnceSampler;
            SamplerState LinearMirrorOnceSampler;

            SamplerState ClampU_RepeatV_LinearSampler;
            float4 _MainTex_ST;
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            
            // https://docs.unity3d.com/2019.4/Documentation/Manual/SL-SamplerStates.html
            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col ;
                #ifdef _SAMPLERSTATE_NORMAL
                    // col = tex2D(_MainTex, i.uv);
                    col = _MainTex.Sample(sampler_MainTex, i.uv);
                #elif _SAMPLERSTATE_POINTREPEAT
                    col = _MainTex.Sample(PointRepeatSampler, i.uv);
                #elif _SAMPLERSTATE_LINEARREPEAT
                    col = _MainTex.Sample(LinearRepeatSampler, i.uv);
                    
                #elif _SAMPLERSTATE_POINTCLAMP
                    col = _MainTex.Sample(PointClampSampler, i.uv);
                #elif _SAMPLERSTATE_LINEARCLAMP
                    col = _MainTex.Sample(LinearClampSampler, i.uv);
                    
                #elif _SAMPLERSTATE_POINTMIRROR
                    col = _MainTex.Sample(PointMirrorSampler, i.uv);
                #elif _SAMPLERSTATE_LINEARMIRROR
                    col = _MainTex.Sample(LinearMirrorSampler, i.uv);
                    
                #elif _SAMPLERSTATE_POINTMIRRORONCE
                    col = _MainTex.Sample(PointMirrorOnceSampler, i.uv);
                #elif _SAMPLERSTATE_LINEARMIRRORONCE
                    col = _MainTex.Sample(LinearMirrorOnceSampler, i.uv);
                    
                #elif _SAMPLERSTATE_CLAMPU_REPEATV_LINEAR
                    col = _MainTex.Sample(ClampU_RepeatV_LinearSampler, i.uv);
                #endif
                
                return col;
            }
            ENDCG
        }
    }
}