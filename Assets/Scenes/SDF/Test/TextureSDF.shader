Shader "lcl/SDF/TextureSDF"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _MainColor ("Color", Color) = (1, 1, 1, 1)
        _SmoothDelta ("Smooth Delta", Range(0, 1)) = 0.01
        _DistanceMark ("Distance Mark", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
        LOD 100

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
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
                float4 vertex : SV_POSITION;
                float4 screenPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainColor;
            float _SmoothDelta;
            float _DistanceMark;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                float distance = col.r;

                // do some anti-aliasing
                col.a = smoothstep(_DistanceMark - _SmoothDelta, _DistanceMark + _SmoothDelta, distance);
                col.rgb = _MainColor.rgb;


              
                // return col.a;

                return col;
            }
            ENDCG
        }
    }
}
