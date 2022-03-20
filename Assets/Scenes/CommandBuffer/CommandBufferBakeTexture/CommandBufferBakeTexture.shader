Shader "lcl/CommandBuffer/CommandBufferBakeTexture"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry"}
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
                float2 uv : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert(appdata v)
            {
                v2f o;
                float2 uvRemapped = v.uv.xy;
                uvRemapped.y = 1. - uvRemapped.y;
                uvRemapped = uvRemapped * 2. - 1.;

                o.vertex = float4(uvRemapped.xy, 0., 1.);
                // o.worldPos = mul(mesh_Object2World, v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG

        }
    }
}
