//create by 长生但酒狂
Shader "lcl/shader2D/gaussBlur2D"  
{
    Properties
    {
        _MainTex ("Base (RGB), Alpha (A)", 2D) = "black" {}
        _TexSize("Texture Size", vector) = (256,256,0,0)
        _BlurOffset("Blur Offset", Range(1, 10)) = 1
    }
    
    SubShader
    {
        LOD 200

        Tags
        {
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"
        }

        Pass
        {
            Cull Off
            Lighting Off
            ZWrite Off
            Fog { Mode Off }
            Offset -1, -1
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag            
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _TexSize;
            fixed _BlurOffset;
            float4 _MainTex_ST;

            struct appdata_t
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
            };
    
            struct v2f
            {
                float4 vertex : SV_POSITION;
                half2 uv : TEXCOORD0;
                fixed4 color : COLOR;
            };
            
            v2f vert (appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.color = v.color;
                return o;
            }
            
            //对图像做滤波操作
            float4 filter(float3x3 filter, sampler2D tex, float2 coord, float2 texSize)
            {
                float4 outCol = float4(0,0,0,0);
                for (int i = 0; i < 3; i++)
                {
                    for (int j = 0; j < 3; j++)
                    {
                        //计算采样点，得到当前像素附近的像素的坐标
                        float2 newCoord = float2(coord.x + (i-1)*_BlurOffset, coord.y + (j-1)*_BlurOffset);
                        float2 newUV = float2(newCoord.x / texSize.x, newCoord.y / texSize.y);
                        //采样并乘以滤波器权重，然后累加
                        outCol += tex2D(tex, newUV) * filter[i][j];
                    }
                }
                return outCol;
            }
            
            fixed4 frag (v2f IN) : COLOR
            {
                // float3x3 gaussFilter = 
                // {
                //     1.0f/16, 2.0f/16, 1.0f/16, 
                //     2.0f/16, 4.0f/16, 2.0f/16, 
                //     1.0f/16, 2.0f/16, 1.0f/16, 
                // };
                float3x3 gaussFilter = 
                {
                    0.0947416, 0.118318, 0.0947416, 
                    0.118318,  0.147761, 0.118318, 
                    0.0947416, 0.118318, 0.0947416, 
                };
                float2 coord = float2(IN.uv.x * _TexSize.x, IN.uv.y * _TexSize.y);
                return filter(gaussFilter, _MainTex, coord, _TexSize);
            }
            ENDCG
        }
    }

    SubShader
    {
        LOD 100

        Tags
        {
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"
        }
        
        Pass
        {
            Cull Off
            Lighting Off
            ZWrite Off
            Fog { Mode Off }
            Offset -1, -1
            ColorMask RGB
            Blend SrcAlpha OneMinusSrcAlpha
            ColorMaterial AmbientAndDiffuse
            
            SetTexture [_MainTex]
            {
                Combine Texture * Primary
            }
        }
    }
}