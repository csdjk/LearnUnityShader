// 根据深度重建时间坐标
Shader "lcl/Depth/DepthScan"
{
    Properties
    {
        _MainTex("Base (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

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
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;
            fixed4 _ScanLineColor;
            float _ScanValue;
            float _ScanLineWidth;
            float _ScanLightStrength;

            half4 frag(v2f i) : SV_Target
            {
                float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
                depth = Linear01Depth(depth); //转换成[0,1]内的线性变化深度值
                
                fixed4 screenCol = tex2D(_MainTex, i.uv);

                float dif = abs(depth - _ScanValue);
                
                float smoothFactor = 0.005f;

                float line1 = _ScanValue;
                float lineEdge1 = line1 + smoothFactor;

                float line2 = _ScanValue + _ScanLineWidth;
                float lineEdge2 = line2 + smoothFactor;
                float value = smoothstep(line1,lineEdge1,dif) - smoothstep(line2,lineEdge2,dif);
                return lerp(screenCol,_ScanLineColor*_ScanLightStrength,value);

                // if (depth > _ScanValue && depth < _ScanValue + _ScanLineWidth)
                // {
                //     return screenCol * _ScanLightStrength * _ScanLineColor;
                // }
                // return screenCol;
            }
            ENDCG
        }
    }
}

