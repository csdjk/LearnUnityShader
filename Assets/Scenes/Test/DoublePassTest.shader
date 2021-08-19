Shader "Unlit/Flipbook"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Sequence ("Sequence", 2D) = "white" {}
        _RowCont("RowCont",float) = 0
        _Colcont("Colcont",float) = 0
        _Speed("Speed",float) = 0
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType"="Transparent" }
        Pass
        {
            Name"FORWARD_AB"
            //  Blend One OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

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
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;


            v2f vert (appdata v)
            {
                v2f o = (v2f)0;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half4 tex = tex2D(_MainTex, i.uv);

                return tex;
            }
            ENDCG
        }

        Pass
        {
            Name"FORWARD_AD"

            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

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
            };

            sampler2D _Sequence;
            float4 _Sequence_ST;
            half _Speed;
            half _Colcont;
            half _RowCont;


            v2f vert (appdata v)
            {
                v2f o = (v2f)0;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _Sequence);

                float id = floor(_Time.z*_Speed);
                float idV = floor(id/_Colcont);
                float idU = id-idV*_Colcont;
                float stepU = 1.0/_Colcont;
                float stepV = 1.0/_RowCont;
                float2 initUV = o.uv*float2(stepU,stepV)+float2(0.0,stepV*(_RowCont-1));
                o.uv = initUV+float2(idU*stepU,-idV*stepV);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half4 tex = tex2D(_Sequence, i.uv);
                half3 rpg = tex.rgb;
                half opacity = tex.a;
                
                return tex;
            }
            ENDCG
        }
    }
}
