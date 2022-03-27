Shader "lcl/Painter/DrawShaderWorldPos"
{
    Properties
    {
        // _SourceTex ("Texture", 2D) = "white" {}

    }
    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        Tags { "RenderType" = "Opaque" }
        CGINCLUDE
        sampler2D _MainTex;
        sampler2D _SourceTex;
        float3 _Mouse;
        float4x4 mesh_Object2World;
        
        float4 _BrushColor;
        float _BrushStrength;
        float _BrushHardness;
        float _BrushSize;
        float _IsDraw;

        struct appdata
        {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
        };
        struct v2f
        {
            float2 uv : TEXCOORD0;
            float4 vertex : SV_POSITION;
            float3 worldPos : TEXCOORD1;
        };

        
        v2f vert(appdata v)
        {
            v2f o;
            float2 uvRemapped = v.uv.xy;
            uvRemapped.y = 1. - uvRemapped.y;
            uvRemapped = uvRemapped * 2. - 1.;
            o.vertex = float4(uvRemapped.xy, 0., 1.);

            o.worldPos = mul(mesh_Object2World, v.vertex);
            o.uv = v.uv;
            return o;
        }
        ENDCG

        // pass 0  Add
        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float4 frag(v2f i) : SV_Target
            {
                float2 uv = i.uv;
                float3 worldPos = i.worldPos;
                float3 mouse_pos = _Mouse.xyz;
                
                float4 prevColor = tex2D(_MainTex, uv);

                float size = _BrushSize;
                float dist = length(worldPos - mouse_pos);
                float soft = _BrushHardness;
                float strength = _BrushStrength;
                float4 brushCol = smoothstep(size, size - soft, dist) * strength * _BrushColor;

                // 混合模式：滤色(Screen)，去黑留白
                // 公式：1-(1-a)(1-b)
                float4 col = 1 - (1 - brushCol) * (1 - prevColor);

                col = lerp(prevColor, col, _IsDraw);
                return col;
            }
            ENDCG

        }

        // pass 1 Sub
        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float4 frag(v2f i) : SV_Target
            {
                float2 uv = i.uv;
                float3 worldPos = i.worldPos;
                float3 mouse_pos = _Mouse.xyz;
                
                float4 prevColor = tex2D(_MainTex, uv);

                float size = _BrushSize;
                float dist = length(worldPos - mouse_pos);
                float soft = _BrushHardness;
                float strength = _BrushStrength;
                float4 col;
                col = prevColor - smoothstep(size, size - soft, dist) * strength;

                col = lerp(prevColor, col, _IsDraw);
                return col;
            }
            ENDCG

        }
        // pass 2 Blend
        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            float4 frag(v2f i) : SV_Target
            {
                float2 uv = i.uv;
                float4 maskCol = tex2D(_MainTex, uv);
                float4 sourceCol = tex2D(_SourceTex, uv);
                // 混合模式：滤色(Screen)，去黑留白
                // 公式：1-(1-a)(1-b)
                float4 col = 1 - (1 - maskCol) * (1 - sourceCol);
                return col;
            }
            ENDCG

        }

        // pass 3 Fixed Edge
        // 修复边缘裂缝 - 扩张边缘
        Pass
        {

            CGPROGRAM

            #pragma  vertex  vert_fixed
            #pragma  fragment frag
            
            #include "UnityCG.cginc"

            uniform float4	_MainTex_TexelSize;
            sampler2D _IlsandMap;
            
            v2f vert_fixed(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
            
            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                float map = tex2D(_IlsandMap, i.uv);
                
                float3 average = col;

                if (map.x < 0.2)
                {
                    int n = 0;
                    average = float3(0., 0., 0.);
                    
                    UNITY_UNROLL for (float x = -1.5; x <= 1.5; x++)
                    {
                        UNITY_UNROLL for (float y = -1.5; y <= 1.5; y++)
                        {

                            float3 c = tex2D(_MainTex, i.uv + _MainTex_TexelSize.xy * float2(x, y) * 2);
                            float m = tex2D(_IlsandMap, i.uv + _MainTex_TexelSize.xy * float2(x, y) * 2);

                            n += step(0.1, m);
                            average += c * step(0.1, m);
                        }
                    }

                    average /= n;
                }
                
                col.xyz = average;
                
                return col;
            }
            ENDCG

        }
    }
}
