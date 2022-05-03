// 障碍物
Shader "lcl/Stencil/Obstacle" {
    Properties {
        _Color ("Main Color", Color) = (1, 1, 1, 1)
        _MainTex ("MainTex", 2D) = "white" {}
    }

    SubShader {
        Tags { "RenderType"="Opaque" }

        Pass {

            Stencil
            {
                Ref 1
                Comp Always
                Pass Replace
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma enable_d3d11_debug_symbols

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;

            struct v2f {
                half4 pos : POSITION;
                half2 uv : TEXCOORD0;
            };


            v2f vert(appdata_base v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            half4 frag(v2f i) : COLOR {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col*_Color;
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}