// 场景扫描
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
            fixed3 _ScanLineColor;
            float _ScanValue;
            float _ScanLineWidth;
            float _ScanLightStrength;

            half4 frag(v2f i) : SV_Target
            {
                float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
                depth = Linear01Depth(depth); //转换成[0,1]内的线性变化深度值
                
                fixed3 screenCol = tex2D(_MainTex, i.uv);
                
                if (depth > _ScanValue && depth < _ScanValue + _ScanLineWidth)
                {
                        float3 res = screenCol * _ScanLightStrength * _ScanLineColor;
                        return float4(res,1);
                }

                return float4(screenCol,1);

                // float dif = abs(depth - _ScanValue);
                // float flag = step(_ScanLineWidth,dif);
                // float3 res = screenCol * flag  + _ScanLightStrength * _ScanLineColor * (1-flag);
                // return float4(res,1);

                
                // float smoothFactor = 0.005f;
                // float line1 = _ScanValue;
                // float lineEdge1 = line1 + smoothFactor;

                // float line2 = _ScanValue + _ScanLineWidth;
                // float lineEdge2 = line2 + smoothFactor;
                // float value = smoothstep(line1,lineEdge1,dif) - smoothstep(line2,lineEdge2,dif);
                // float3 res = lerp(screenCol,_ScanLineColor*_ScanLightStrength,value);
                // return float4(res,1);

                // float step = dif / 0.01f;
                // float3 res = lerp(_ScanLineColor*_ScanLightStrength,screenCol,step).rgb;

                // return float4(res,1);
                // return float4(step,step,step,1);
                // return float4(dif,dif,dif,1);
            }
            ENDCG
        }
    }
}

