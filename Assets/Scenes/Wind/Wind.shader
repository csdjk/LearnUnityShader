Shader "lcl/Wind/Wind"
{
    Properties
    {
        _WindDir("WindDir", Vector) = (0,0,0,0)
        [PowerSlider(3.0)]_Angle("Angle", Range (-90, 90)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

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

            float4 _WindDir;
            float _Angle;

            v2f vert (appdata v)
            {
                v2f o;
                // half4 wind = SAMPLE_TEXTURE2D_LOD(_LuxLWRPWindRT, sampler_LuxLWRPWindRT, positionWS.xz * _LuxLWRPWindDirSize.w + phase * _WindMultiplier.z, _WindMultiplier.w);                

                // half3 windDir = _WindDir.xyz;
                // half windStrength = _WindDir.w;

                // /* not a "real" normal as we want to keep the base direction */
                // wind.r = wind.r   *   (wind.g * 2.0h - 0.243h);
                // windStrength *= wind.r;
                // positionWS.xz += windDir.xz * windStrength;
                

                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return 1;
            }
            ENDCG
        }
    }
}
