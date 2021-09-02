Shader "Unlit/OutlinePostProcessByStencil"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _EdgeColor("Edge Color",Color)= (1,1,1,1)
    }
    SubShader
    {
        ZTest Always Cull Off ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct v2f
            {
                float2 uv[9] : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _StencilBufferToColor;
            float4 _StencilBufferToColor_TexelSize;
            float4 _EdgeColor;

            v2f vert (appdata_img v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                half2 uv = v.texcoord;

                o.uv[0] = uv + _StencilBufferToColor_TexelSize.xy * half2(-1, -1);
                o.uv[1] = uv + _StencilBufferToColor_TexelSize.xy * half2(0, -1);
                o.uv[2] = uv + _StencilBufferToColor_TexelSize.xy * half2(1, -1);
                o.uv[3] = uv + _StencilBufferToColor_TexelSize.xy * half2(-1, 0);
                o.uv[4] = uv + _StencilBufferToColor_TexelSize.xy * half2(0, 0);
                o.uv[5] = uv + _StencilBufferToColor_TexelSize.xy * half2(1, 0);
                o.uv[6] = uv + _StencilBufferToColor_TexelSize.xy * half2(-1, 1);
                o.uv[7] = uv + _StencilBufferToColor_TexelSize.xy * half2(0, 1);
                o.uv[8] = uv + _StencilBufferToColor_TexelSize.xy * half2(1, 1);

                return o;
            }

            float SobelEdge(v2f i){

                const half Gx[9] = {-1,  0,  1,
                    -2,  0,  2,
                -1,  0,  1};
                const half Gy[9] = {-1, -2, -1,
                    0,  0,  0,
                1,  2,  1}; 

                float edge = 0;
                float edgeY = 0;
                float edgeX = 0;    
                float luminance =0;
                for(int it=0; it<9; it++){
                    luminance = tex2D(_StencilBufferToColor,i.uv[it]).a;
                    edgeX += luminance*Gx[it];
                    edgeY += luminance*Gy[it];
                }

                edge =  1 - abs(edgeX) - abs(edgeY);
                return edge;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 sourceColor = tex2D(_MainTex, i.uv[4]);
                float edge = SobelEdge(i);
                // return lerp(_EdgeColor,sourceColor,edge);

                return 1;
            }
            ENDCG
        }
    }
}