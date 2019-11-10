Shader "lcl/selfDemo/book"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Angle("angle",Range(0,180)) = 0
        _Warp("Warp",Range(0,10))=0
        _WarpPos("WarpPos",Range(0,1))=0
        _Downward("Downward",Range(0,1))=0

    }
    SubShader
    {
        Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}

        LOD 200
        
        Pass{
            Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Angle;
            float _Warp;
            float _Downward;
            float _WarpPos;
            struct a2v {
                float4 vertex : POSITION;
                float2 uv:TEXCOORD0;
            };

            struct v2f{
                float4 position:SV_POSITION;
                float2 uv:TEXCOORD0;

            };

            v2f vert(a2v v){
                v2f f;
                float radian = 3.14/180*_Angle;
                float s,c;
                sincos(radian,s,c);
                float3x3 rotateMatrix = float3x3(
                c,-s,0,
                s,c,0,
                0,0,1
                );
                v.vertex.x +=5;

                float rangeF=saturate(1 - abs(90-_Angle)/90);
                v.vertex.y += -_Warp*sin(v.vertex.x*0.4-_WarpPos* v.vertex.x)*rangeF;
                v.vertex.x -= rangeF * v.vertex.x*_Downward;

                v.vertex.xyz = mul(rotateMatrix,v.vertex.xyz);
                v.vertex.x -=5;

                f.position = UnityObjectToClipPos(v.vertex);
                f.uv = TRANSFORM_TEX(v.uv,_MainTex);
                return f;
            };

            fixed4 frag(v2f f):SV_TARGET{
                
                fixed4 col = tex2D(_MainTex,f.uv);

                return col;
            };
            ENDCG
        }

        
    }
    FallBack "Diffuse"
}
