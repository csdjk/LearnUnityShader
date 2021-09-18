Shader "ShapeOutline/Mix"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
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
                float4 screenPos : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            uniform sampler2D _occlusionTex;
            uniform sampler2D _strechTex;
            uniform fixed4 _OutlineColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                i.screenPos.xy /= i.screenPos.w;
                fixed4 srcCol = tex2D(_MainTex,float2(i.screenPos.x,1-i.screenPos.y));
                fixed4 occlusionCol = tex2D(_occlusionTex,fixed2(i.screenPos.x,i.screenPos.y));
                fixed4 strechCol = tex2D(_strechTex,fixed2(i.screenPos.x,i.screenPos.y));
                float isOcclusion = occlusionCol.x + occlusionCol.y + occlusionCol.z;
                float isStrech = strechCol.x + strechCol.y + strechCol.z;
                if(isStrech > 0.5 && isOcclusion<0.1)
                    return _OutlineColor;
                else
                    return srcCol;
            }
            ENDCG
        }
    }
}