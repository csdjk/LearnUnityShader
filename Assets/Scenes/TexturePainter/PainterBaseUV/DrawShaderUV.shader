Shader "lcl/Painter/DrawShaderUV"
{
    Properties
    {
        // _SourceTex ("Texture", 2D) = "white" {}

    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        CGINCLUDE
        sampler2D _MainTex;
        sampler2D _SourceTex;
        float3 _Mouse;
        
        float4 _BrushColor;
        float _BrushStrength;
        float _BrushHardness;
        float _BrushSize;

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
            o.uv = v.uv;
            o.vertex = UnityObjectToClipPos(v.vertex);
            return o;
        }
        ENDCG

        // pass 0
        Pass
        {
            Name "Add_Mask"
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float4 frag(v2f i) : SV_Target
            {
                float2 uv = i.uv;
                float2 mouse_uv = _Mouse.xy;
                
                float4 prevColor = tex2D(_MainTex, uv);

                float size = _BrushSize;
                float dist = length(uv - mouse_uv);
                float soft = _BrushHardness;
                float strength = _BrushStrength;
                float4 brushCol = smoothstep(size, size - soft, dist) * strength * _BrushColor;

                // 混合模式：滤色(Screen)，去黑留白
                // 公式：1-(1-a)(1-b)
                float4 col = 1 - (1 - brushCol) * (1 - prevColor);
                return col;
            }
            ENDCG

        }

        // pass 1
        Pass
        {
            Name "Sub_Mask"
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float4 frag(v2f i) : SV_Target
            {
                float2 uv = i.uv;
                float2 mouse_uv = _Mouse.xy;
                
                float3 prevColor = tex2D(_MainTex, uv);

                float size = _BrushSize;
                float dist = length(uv - mouse_uv);
                float soft = _BrushHardness;
                float strength = _BrushStrength;
                float4 col;
                col.rgb = prevColor - smoothstep(size, size - soft, dist) * strength;
                return col;
            }
            ENDCG

        }


        // pass 2
        Pass
        {
            Name "Mark"

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            float4 frag(v2f i) : SV_Target
            {
                float2 uv = i.uv;
                float2 mouse_uv = _Mouse.xy;

                float4 maskCol = tex2D(_MainTex, uv);
                float4 sourceCol = tex2D(_SourceTex, uv);

                float size = _BrushSize;
                float dist = length(uv - mouse_uv);
                float soft = _BrushHardness;
                float strength = _BrushStrength;
                float4 brushCol = smoothstep(size, size - soft, dist) * strength * _BrushColor;
                // 混合模式：滤色(Screen)，去黑留白
                // 公式：1-(1-a)(1-b)
                float4 col = 1 - (1 - maskCol) * (1 - sourceCol);
                col = 1 - (1 - col) * (1 - brushCol);
                return col;
            }
            ENDCG

        }


        // pass 3
        Pass
        {
            Name "BlendColor"

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
    }
}
