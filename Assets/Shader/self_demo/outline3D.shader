Shader "lcl/selfDemo/outline3D"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",Color)=(1,1,1,1)
        _power("lineWidth",Range(0,10)) = 1
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
			#include "Lighting.cginc"

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

            sampler2D _MainTex;
            // float4 _MainTex_TexelSize;
            float4 _Color;
            float _power;
            float4 _lineColor;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                //环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * _Color.xyz;

                float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 normaleDir = normalize(i.worldNormalDir);
                //光照方向归一化
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                //半兰伯特模型
                fixed3 lambert = 0.5 * dot(normaleDir, worldLightDir) + 0.5;
                //漫反射
                fixed3 diffuse = lambert * _Color.xyz * _LightColor0.xyz + ambient;
                
                fixed3 result = diffuse * col.xyz;
                //计算观察方向与法线的夹角(夹角越大，value值越小，越接近边缘)
                float value = dot(viewDir,normaleDir);

                value = 1 - saturate(value);
                value = pow(value,_power);

                result =lerp(result,_lineColor,value) ;

                return float4(result,1);
            }
            ENDCG
        }
    }
}
