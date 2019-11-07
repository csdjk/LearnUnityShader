Shader "lcl/selfDemo/outLine3D_swell"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",Color)=(1,1,1,1)
        _power("power",Range(0,20)) = 0.2
        _lineColor("lineColor",Color)=(1,1,1,1)
         _OffsetFactor ("Offset Factor", Range(0,200)) = 0
        _OffsetUnits ("Offset Units", Range(0,200)) = 0
    }
    SubShader
    {
        Tags{
            "Queue" = "Transparent"
        }
        Blend SrcAlpha OneMinusSrcAlpha
        
        //背面通道
        Pass
        {
			Cull Front
            //控制深度偏移，描边pass远离相机一些，防止与正常pass穿插
			Offset [_OffsetFactor], [_OffsetUnits]

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            float _power;
            float4 _lineColor;

            v2f vert (appdata v)
            {
                v2f o;
                v.normal = normalize(v.normal);
                _power = pow(0.5,_power);
                v.vertex.xyz +=  v.normal *_power;

                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            //直接输出颜色
            fixed4 frag (v2f i) : SV_Target
            {
                return _lineColor;
            }
            ENDCG
        }

        //正面
         Pass
        {
			Cull Back

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
            sampler2D _MainTex;
            // float4 _MainTex_TexelSize;
            float4 _Color;
            float _power;
            float4 _lineColor;
            v2f vert (appdata v)
            {
                v2f o;
                o.uv = v.uv;
                o.worldNormalDir = mul(v.normal,(float3x3) unity_WorldToObject);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;  
                v.normal = normalize(v.normal);
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            

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

                return float4(result,1);
            }
            ENDCG
        }
    }
}
