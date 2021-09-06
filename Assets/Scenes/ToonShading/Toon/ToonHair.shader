//--------------------------- 卡通渲染 - 头发---------------------
Shader "lcl/ToonShading/ToonHair"
{
    Properties
    {   
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",Color)=(1,1,1,1)
        _LightMap ("LightMap", 2D) = "white" {}

        // 描边
        [Main(outline, _, 3)] _group_outline ("描边", float) = 1
        [Sub(outline)] _OutlinePower("Outline Power",Range(0,0.1)) = 0.05
        [Sub(outline)]_LineColor("Line Color",Color)=(1,1,1,1)
        [Sub(outline)]_OffsetFactor ("Offset Factor", Range(0,200)) = 0
        [Sub(outline)]_OffsetUnits ("Offset Units", Range(0,200)) = 0
        // 是否使用平滑法向量
        [SubToggle(outline, __)] _USE_SMOOTH_NORMAL ("Use Smooth Normal", float) = 0

        // 光照阴影
        [Main(lighting, _, 3)] _group_shadow ("光照阴影", float) = 1
        [Tex(lighting)]_ShadowRamp ("Shadow Ramp", 2D) = "white" {}
        [Sub(lighting)]_ShadowColor("Shadow Color",Color)=(0.2,0.2,0.2,0.2)
        [Sub(lighting)]_ShadowSmoothness ("Shadow Smoothness", Range(0,1)) = 0
        [Sub(lighting)]_ShadowRange ("Shadow Range", Range(-1, 1)) = 0.5

        [Title(lighting, Specular)]
        [Sub(lighting)]_SpecularColor("Specular Color",Color)=(0.5, 0.5, 0.5)
        [Sub(lighting)]_SpecularPower ("Specular Power", Range(8,200)) = 8
        [Sub(lighting)]_SpecularScale("Specular Scale",Range(0,200)) =1
        [Sub(lighting)]_SpecularSmoothness ("Specular Smoothness", Range(0,1)) = 0

        // [Title(, Rim)]
        // [Sub(lighting)]_RimIntensity ("RimIntensity", Range(0,10)) = 0
        // [Sub(lighting)]_RimWidth ("RimWidth", Range(0,1)) = 0

        [KeywordEnum(None,LightMap_R,LightMap_G,LightMap_B,LightMap_A,UV,UV2,VertexColor,BaseColor,BaseColor_A)] _TestMode("_TestMode",Int) = 0
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
        float3 worldNormalDir:TEXCOORD1;
        float3 worldPos:TEXCOORD2;
    };
    int _TestMode;

    sampler2D _MainTex,_LightMap;
    float4 _MainTex_TexelSize;
    float4 _Color;
    // 描边
    float _OutlinePower;
    float4 _LineColor;
    // 阴影
    sampler2D _ShadowRamp;
    float4 _ShadowColor;
    float _ShadowSmoothness,_ShadowRange;
    // 高光
    float4 _SpecularColor;
    float _SpecularPower,_SpecularScale;
    float _SpecularSmoothness;

    float _RimWidth;
    float _RimIntensity;

    ENDCG
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _USE_SECOND_LEVELS_ON

            v2f vert (appdata v)
            {
                //正常渲染
                v2f o;
                o.uv = v.uv;
                o.worldNormalDir = mul(v.normal,(float3x3) unity_WorldToObject);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz; 
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }
            // 计算色阶
            float calculateRamp(float threshold,float value, float smoothness){
                threshold = saturate(1-threshold);
                half minValue = saturate(threshold - smoothness);
                half maxValue = saturate(threshold + smoothness);
                return smoothstep(minValue,maxValue,value);
            }
            // ------------------------【正面-片元着色器】---------------------------
            fixed4 frag (v2f i) : SV_Target
            {
                // fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 normalDir = normalize(i.worldNormalDir);
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 lightCol = _LightColor0.rgb;
                fixed4 texCol = tex2D(_MainTex, i.uv);

                fixed3 halfDir = normalize(lightDir + viewDir);

                float NdotL = dot(normalDir, lightDir);
                float NdotV = dot(normalDir, viewDir);
                float NdotH = dot(normalDir, halfDir);

                float4 LightMap = tex2D(_LightMap,i.uv);
                

                //------------------------【Diffuse】-----------------------------
                fixed halfLambert = 0.5 * NdotL + 0.5;
                // float rampValue = smoothstep(0,_ShadowSmoothness,halfLambert-_ShadowRange);
                // float ramp =  tex2D(_ShadowRamp, float2(saturate(rampValue), 0.5));
                float ramp = calculateRamp(_ShadowRange,halfLambert,_ShadowSmoothness);

                // float ramp =  tex2D(_ShadowRamp, halfLambert);
                float3 diffuse = lerp( _ShadowColor*texCol,texCol,ramp);

                
                //------------------------【Specular】-----------------------------
                float3 specular = pow(saturate(NdotH),_SpecularPower * LightMap.r )*_SpecularScale * LightMap.b;
                specular = saturate(specular * _SpecularColor);

                // float SpecularRange = step(1 - _HairSpecularRange, saturate(NH)); 
                // float ViewRange = step(1 - _HairSpecularViewRange, saturate(NV)); 
                // HairSpecular = SpecularIntensityMask *_HairSpecularIntensity * SpecularRange * ViewRan 
                // HairSpecular = max(0, HairSpecular);

                //------------------------【Rim】-----------------------------
                // float3 Rim = step(1-_RimWidth,1-NdotV)*_RimIntensity;
                // float3 Rim = pow(1 - NdotV,_RimWidth)*_RimIntensity;

                fixed3 result = diffuse + specular;


                int mode = 1;
                if(_TestMode == mode++)
                return LightMap.r;
                if(_TestMode ==mode++)
                return LightMap.g; //阴影 Mask
                if(_TestMode ==mode++)
                return LightMap.b; //漫反射 Mask
                if(_TestMode ==mode++)
                return LightMap.a; //漫反射 Mask
                if(_TestMode ==mode++)
                return float4(i.uv,0,0); //uv
                if(_TestMode ==mode++)
                return texCol.xyzz; //BaseColor
                if(_TestMode ==mode++)
                return texCol.a; //BaseColor.a
                if(_TestMode ==mode++)
                return ramp; 

                return float4(result,1)*1.3;
            }
            ENDCG
        }

        

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Front
            ZWrite On
            Offset [_OffsetFactor], [_OffsetUnits]

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _USE_SMOOTH_NORMAL_ON 

            v2f vert (appdata v)
            {
                v2f o;
                //顶点沿着法线方向扩张
                #ifdef _USE_SMOOTH_NORMAL_ON
                    // 使用平滑的法线计算
                    v.vertex.xyz += normalize(v.tangent.xyz) * _OutlinePower;
                #else
                    // 使用自带的法线计算
                    v.vertex.xyz += normalize(v.normal) * _OutlinePower * 0.2;
                #endif
                o.vertex = UnityObjectToClipPos(v.vertex);

                // float3 normalDir =  normalize(v.tangent.xyz);
                // float4 pos = UnityObjectToClipPos(v.vertex);
                // float3 viewNormal = mul((float3x3)UNITY_MATRIX_IT_MV, normalDir);
                // float3 ndcNormal = normalize(TransformViewToProjection(viewNormal.xyz)) * pos.w;//将法线变换到NDC空间
                // pos.xy += _OutlinePower * ndcNormal.xy * 0.01;
                // o.vertex = pos;
                return o;
            }
            fixed4 frag (v2f i) : SV_Target
            {
                return _LineColor;
            }
            
            ENDCG
        }
    }
}
