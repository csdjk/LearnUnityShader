Shader "lcl/Shader2D/DistortionSelf" {
    Properties {
        _MainTex ("Main Texutre (A)", 2D) = "white" {}
        _NoiseTex ("Noise Texture (RG)", 2D) = "white" {}
        _HeatForceX  ("Heat ForceX", range (-2,2)) = 0.1
        _HeatForceY  ("Heat ForceY", range (-2,2)) = 0.1
        _Uspeed ("Uspeed", range(-10,10)) = 1
        _Vspeed ("Vspeed", range(-10,10)) = 1
    }

    Category {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        AlphaTest Greater .01
        Cull Off Lighting Off ZWrite Off
        

        SubShader {
            Pass {
                Name "BASE"
                Tags { "LightMode" = "Always" }
                
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma fragmentoption ARB_precision_hint_fastest
                #include "UnityCG.cginc"

                struct appdata_t {
                    float4 vertex : POSITION;
                    fixed4 color : COLOR;
                    float2 texcoord: TEXCOORD0;
                };

                struct v2f {
                    float4 vertex : POSITION;
                    float4 uv : TEXCOORD0;
                    fixed4 color : COLOR;
                };

                float _HeatForceX;
                float _HeatForceY;
                float _Uspeed;
                float _Vspeed;
                sampler2D _MainTex;
                float4 _MainTex_ST;
                sampler2D _NoiseTex;
                float4 _NoiseTex_ST;

                v2f vert (appdata_t v)
                {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv.xy = TRANSFORM_TEX( v.texcoord, _MainTex );
                    o.uv.zw = TRANSFORM_TEX( v.texcoord, _NoiseTex );
                    o.color = v.color;
                    return o;
                }

                half4 frag( v2f i ) : COLOR
                {
                    half4 offsetColor1 = tex2D(_NoiseTex, i.uv.zw + _Time.xz * _Uspeed);
                    half4 offsetColor2 = tex2D(_NoiseTex, i.uv.zw - _Time.yx * _Vspeed);
                    
                    i.uv.x += ((offsetColor1.r + offsetColor2.r) - 1) * _HeatForceX;
                    i.uv.y += ((offsetColor1.g + offsetColor2.g) - 1) * _HeatForceY ;
                    
                    half4 col = tex2D(_MainTex, i.uv.xy);
                    return col*i.color;
                }
                ENDCG
            }
        }
    }
}
