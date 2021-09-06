//--------------------------- 卡通渲染---------------------
Shader "lcl/ToonShading/ToonShader"
{
    Properties
    {   
        // 主纹理
        _MainTex ("Texture", 2D) = "white" {}
        // 主颜色
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
        [Sub(lighting)]_ShadowSmoothness ("Shadow Smoothness", Range(0,1)) = 0
        [Sub(lighting)]_ShadowColor1("Shadow Color1",Color)=(0.7, 0.7, 0.7)
        [Sub(lighting)]_ShadowThreshold1 ("Shadow Threshold1", Range(0,1)) = 0
        [SubToggle(lighting, __)] _USE_SECOND_LEVELS ("Use Second Levels", float) = 0
        [Sub(lighting_USE_SECOND_LEVELS_ON)]_ShadowColor2("Shadow Color2",Color)=(0.5, 0.5, 0.5)
        [Sub(lighting_USE_SECOND_LEVELS_ON)]_ShadowThreshold2 ("Shadow Threshold2", Range(0,1)) = 0

        [Title(lighting, Specular)]
        [Sub(lighting)]_SpecularColor("Specular Color",Color)=(0.5, 0.5, 0.5)
        [Sub(lighting)]_SpecularPower ("Specular Power", Range(8,200)) = 8
        [Sub(lighting)]_SpecularThreshold ("Specular Threshold", Range(0,1)) = 0
        [Sub(lighting)]_SpecularSmoothness ("Specular Smoothness", Range(0,1)) = 0

        [Title(, Rim)]
        [Sub(lighting)]_RimIntensity ("RimIntensity", Range(0,10)) = 0
        [Sub(lighting)]_RimWidth ("RimWidth", Range(0,1)) = 0

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
        float3 forward:TEXCOORD3;
    };
    int _TestMode;

    sampler2D _MainTex;
    float4 _MainTex_TexelSize;
    float4 _Color;
    // 描边
    float _OutlinePower;
    float4 _LineColor;
    // 阴影
    sampler2D _LightMap;
    float4 _ShadowColor1;
    float4 _ShadowColor2;
    float _ShadowThreshold1;
    float _ShadowThreshold2;
    float _ShadowSmoothness;
    // 高光
    float4 _SpecularColor;
    float _SpecularThreshold;
    float _SpecularPower;
    float _SpecularSmoothness;

    float _RimWidth;
    float _RimIntensity;

    ENDCG
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Front
            ZWrite Off
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

                o.forward = normalize(UnityObjectToWorldNormal(float3(0,0,1)));

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
                float3 worldForward = normalize(i.forward);

                fixed3 halfDir = normalize(lightDir + viewDir);

                float NdotL = dot(normalDir, lightDir);
                float NdotV = dot(normalDir, viewDir);
                float NdotH = dot(normalDir, halfDir);

                //------------------------【Diffuse】-----------------------------
                fixed lambert = 0.5 * NdotL + 0.5;
                // 阈值判断，类似以下：
                // half3 diffuse = lambert > _ShadowThreshold1 ? _Color.xyz : _ShadowColor;
                half3 diffuse = half3(0,0,0);
                #ifdef _USE_SECOND_LEVELS_ON
                    // 二阶色阶
                    float ramp1 = calculateRamp(_ShadowThreshold1,lambert,_ShadowSmoothness);
                    float ramp2 = calculateRamp(_ShadowThreshold2,lambert,_ShadowSmoothness);
                    float mid = saturate(ramp2-ramp1);
                    float end = 1-ramp2;
                    // half3 diffuse = _Color.xyz * ramp1 + _ShadowColor1 * mid + _ShadowColor2 * end;
                    diffuse = fixed3(1,1,1) * ramp1 + _ShadowColor1 * mid + _ShadowColor2 * end;
                    diffuse *= _Color.xyz * texCol;
                #else
                    // 一阶色阶
                    float ramp1 = calculateRamp(_ShadowThreshold1,lambert,_ShadowSmoothness);
                    diffuse = lerp(_ShadowColor1,_Color.xyz,ramp1) * _Color.xyz * texCol;
                #endif
                
                //------------------------【Specular】-----------------------------
                fixed specular =  pow(max(0,NdotH),_SpecularPower);
                // 阈值判断，类似以下：
                // fixed3 specularCol = specular <= _SpecularThreshold ? fixed3(0,0,0) : _SpecularColor;
                float specularRamp = calculateRamp(_SpecularThreshold,specular,_SpecularSmoothness);
                fixed3 specularCol = lerp(fixed3(0,0,0),_SpecularColor,specularRamp);


                //------------------------【Rim】-----------------------------
                float3 Rim = step(1-_RimWidth,1-NdotV)*_RimIntensity;
                // float3 Rim = pow(1 - NdotV,_RimWidth)*_RimIntensity;

                fixed3 result = (diffuse + specularCol) * lightCol * texCol;

                return float4(result,1);
            }
            ENDCG
        }

        

        
    }
}
