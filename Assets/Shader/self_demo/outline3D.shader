Shader "lcl/selfDemo/outline3D"
{
    Properties
    {
        // _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",Color)=(1,1,1,1)
        _lineWidth("lineWidth",Range(-1,1)) = 1
        _lineColor("lineColor",Color)=(1,1,1,1)
    }
    SubShader
    {
        Tags{
            "Queue" = "Transparent"
        }
        Blend SrcAlpha OneMinusSrcAlpha
        
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
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
				float3 worldNormalDir:COLOR0;
				float3 worldPos:COLOR1;

            };

            v2f vert (appdata v)
            {
                v2f o;
                o.uv = v.uv;
				o.worldNormalDir = mul(v.normal,(float3x3) unity_WorldToObject);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;  

                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            // sampler2D _MainTex;
            // float4 _MainTex_TexelSize;
            float4 _Color;
            float _lineWidth;
            float4 _lineColor;

            fixed4 frag (v2f i) : SV_Target
            {
                // fixed4 col = tex2D(_MainTex, i.uv);

				float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				float3 normaleDir = normalize(i.worldNormalDir);
                float value = dot(viewDir,normaleDir);
                // if(value <= 0 && value >= -1){
                //     col = _lineColor;
                // }
                value = value +_lineWidth;
                // col =lerp(col,_lineColor,value) ;
                float4 col =lerp(_lineColor,_Color,value) ;

                return col;
            }
            ENDCG
        }
    }
}
