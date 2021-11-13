// 能量柱
Shader "lcl/shader3D/GuiPaiQiGong/energyColumn"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",Color) = (1,1,1,1)
        _Speed("Speed",Range(0,2)) = 1
        _Area("Area",Range(0,1)) = 0
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _Speed;
            float _Area;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float3 permute(float3 x) { return fmod(((x*34.0)+1.0)*x, 289.0); }

            float snoise(float2 v){
                const float4 C = float4(0.211324865405187, 0.366025403784439,
                -0.577350269189626, 0.024390243902439);
                float2 i  = floor(v + dot(v, C.yy) );
                float2 x0 = v -   i + dot(i, C.xx);
                float2 i1;
                i1 = (x0.x > x0.y) ? float2(1.0, 0.0) : float2(0.0, 1.0);
                float4 x12 = x0.xyxy + C.xxzz;
                x12.xy -= i1;
                i = fmod(i, 289.0);
                float3 p = permute( permute( i.y + float3(0.0, i1.y, 1.0 ))
                + i.x + float3(0.0, i1.x, 1.0 ));
                float3 m = lerp(0.5 - float3(dot(x0,x0), dot(x12.xy,x12.xy),
                dot(x12.zw,x12.zw)), 0.0,0);
                m = m*m ;
                m = m*m ;
                float3 x = 2.0 * frac(p * C.www) - 1.0;
                float3 h = abs(x) - 0.5;
                float3 ox = floor(x + 0.5);
                float3 a0 = x - ox;
                m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );
                float3 g;
                g.x  = a0.x  * x0.x  + h.x  * x0.y;
                g.yz = a0.yz * x12.xz + h.yz * x12.yw;
                return 130.0 * dot(m, g);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv_offset = float2(0,0);
                uv_offset.x = _Time.y * _Speed;
                uv_offset.y = _Time.y * _Speed;
                i.uv += uv_offset;
                float a = step(_Area,snoise(i.uv*2));
                return fixed4(_Color.rgb,a);
            }
            ENDCG
        }
    }
}
