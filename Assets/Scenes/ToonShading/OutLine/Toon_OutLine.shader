//--------------------------- 卡通渲染 - 描边---------------------
Shader "lcl/ToonShading/OutLine/Toon_OutLine"
{
    Properties
    {   
        // 主纹理
        _MainTex ("Texture", 2D) = "white" {}
        // 主颜色
        _Color("Color",Color)=(1,1,1,1)

        // 描边
        [Main(outline)] _group_outline ("描边", float) = 1
        [Sub(outline)] _Power("Power",Range(0,0.2)) = 0.05
        [Sub(outline)]_lineColor("lineColor",Color)=(1,1,1,1)
        [Sub(outline)]_OffsetFactor ("Offset Factor", Range(0,200)) = 0
        [Sub(outline)]_OffsetUnits ("Offset Units", Range(0,200)) = 0

        // 光照阴影
        [Main(shadow)] _group_shadow ("光照阴影", float) = 1
        [Sub(shadow)]_ShadowColor1("Shadow Color1",Color)=(1,1,1,1)
        [Sub(shadow)]_ShadowColor2("Shadow Color2",Color)=(1,1,1,1)
        [Sub(shadow)]_ShadowThreshold1 ("Shadow Threshold1", Range(0,1)) = 0
        [Sub(shadow)]_ShadowThreshold2 ("Shadow Threshold2", Range(0,1)) = 0
        [Sub(shadow)]_ShadowSmoothness ("Shadow Smoothness", Range(0,1)) = 0
        
    }

    CGINCLUDE
    #include "UnityCG.cginc"
    #include "Lighting.cginc"
    //顶点着色器输入结构体
    struct appdata
    {
        float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
        float3 normal:NORMAL;
        float4 tangent : TANGENT;
    };
    //顶点着色器输出结构体
    struct v2f
    {
        float4 vertex : SV_POSITION;
        float2 uv : TEXCOORD0;
        float3 worldNormalDir:COLOR0;
        float3 worldPos:COLOR1;
    };

    sampler2D _MainTex;
    float4 _MainTex_TexelSize;
    float4 _Color;

    float _Power;
    float4 _lineColor;

    float4 _ShadowColor1;
    float4 _ShadowColor2;
    float _ShadowThreshold1;
    float _ShadowThreshold2;
    float _ShadowSmoothness;
    

    ENDCG
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Front
            ZWrite On
            Offset [_OffsetFactor], [_OffsetUnits]
            CGPROGRAM

            v2f vert (appdata v)
            {
                v2f o;
                //顶点沿着平均法线方向扩张
                v.vertex.xyz +=  v.normal * _Power;
                v.vertex.xyz +=  normalize(v.tangent.xyz) * _Power;
                o.vertex = UnityObjectToClipPos(v.vertex);

                // float3 normalDir =  normalize(v.tangent.xyz);
                // float4 pos = UnityObjectToClipPos(v.vertex);
                // float3 viewNormal = mul((float3x3)UNITY_MATRIX_IT_MV, normalDir);
                // float3 ndcNormal = normalize(TransformViewToProjection(viewNormal.xyz)) * pos.w;//将法线变换到NDC空间
                // pos.xy += _Power * ndcNormal.xy * 0.01;
                // o.vertex = pos;
                return o;
            }
            fixed4 frag (v2f i) : SV_Target
            {
                return _lineColor;
            }
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            v2f vert (appdata v)
            {
                //正常渲染
                v2f o;
                o.uv = v.uv;
                //法线从模型空间坐标系转换到世界坐标系
                o.worldNormalDir = mul(v.normal,(float3x3) unity_WorldToObject);
                //顶点从模型空间坐标系转换到世界坐标系
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz; 
                //由模型空间坐标系转换到裁剪空间
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            // 计算色阶
            float calculateRamp(float Threshold,float NdotL){
                half diffuseMin = saturate(Threshold - _ShadowSmoothness);
                half diffuseMax = saturate(Threshold + _ShadowSmoothness);
                return smoothstep(diffuseMin,diffuseMax,NdotL);
            }

            // ------------------------【正面-片元着色器】---------------------------
            fixed4 frag (v2f i) : SV_Target
            {
                //正常渲染
                //纹理颜色值
                fixed4 col = tex2D(_MainTex, i.uv);
                //环境光
                // fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                //视角方向
                float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                //法线方向
                float3 normaleDir = normalize(i.worldNormalDir);
                //光照方向归一化
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                //半兰伯特模型
                fixed3 lambert = 0.5 * dot(normaleDir, worldLightDir) + 0.5;

                // half3 diffuse = lambert > _ShadowThreshold1 ? _Color.xyz : _ShadowColor;

                // 一维色阶
                // float ramp1 = calculateRamp(_ShadowThreshold1,lambert);
                // half3 diffuse = lerp(_ShadowColor,_Color.xyz,ramp1);

                // 二维色阶
                float ramp1 = calculateRamp(_ShadowThreshold1,lambert);
                float ramp2 = calculateRamp(_ShadowThreshold2,lambert);
                half3 diffuse = _ShadowColor1*ramp1 + _ShadowColor2 * ramp2 + _Color.xyz * (1-ramp1-ramp2);

                fixed3 result = diffuse * _LightColor0 * col;
                return float4(result,1);
            }
            ENDCG
        }

        

        
    }
}
