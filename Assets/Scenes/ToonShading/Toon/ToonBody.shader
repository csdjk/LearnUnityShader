//--------------------------- 卡通渲染---------------------
Shader "lcl/ToonShading/ToonBody"
{
    Properties
    {   
        // 主纹理
        _MainTex ("Texture", 2D) = "white" {}
        // 主颜色
        _Color("Color",Color)=(1,1,1,1)
        _LightMap ("LightMap", 2D) = "white" {}

        [HDR]_EmissionColor("Emission Color",Color)=(1,1,1,1)
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
        [Sub(lighting)]_RampOffset ("Ramp Offset", Range(-1, 1)) = 0.5

        [Title(lighting, Specular)]
        [Sub(lighting)]_SpecularColor("Specular Color",Color)=(0.5, 0.5, 0.5)
        [Sub(lighting)]_SpecularPower ("Specular Power", Range(8,200)) = 8
        [Sub(lighting)]_SpecularScale("Specular Scale",Range(0,200)) =1
        [Sub(lighting)]_SpecularSmoothness ("Specular Smoothness", Range(0,1)) = 0
        [Title(, Rim)]
        [Sub(lighting)]_RimIntensity ("RimIntensity", Range(0,10)) = 0
        [Sub(lighting)]_RimWidth ("RimWidth", Range(0,1)) = 0

        [KeywordEnum(None,LightMap_R,LightMap_G,LightMap_B,LightMap_A,UV,BaseColor,BaseColor_A,Ramp,RampPlane)] _TestMode("_TestMode",Int) = 0
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
    float4 _Color,_EmissionColor;
    // 描边
    float _OutlinePower;
    float4 _LineColor;
    // 阴影
    sampler2D _ShadowRamp;
    float4 _ShadowColor;
    float _ShadowSmoothness,_ShadowRange,_RampOffset;
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
            #pragma enable_d3d11_debug_symbols

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

                // 光照贴图信息含义
                // LightMap.r :高光类型Layer,根据值域选择不同的高光类型(eg:BlinPhong 裁边视角光) 
                // LightMap.g :阴影AO ShadowAOMask 
                // LightMap.b :BlinPhong高光强度Mask SpecularIntensityMask 
                // LightMap.a :Ramp类型Layer，根据值域选择不同的Ramp 
                // VertexColor.g :Ramp偏移值,值越大的区域 越容易"感光"(在一个特定的角度，偏移光照明暗) 
                // VertexColor.a :描边粗细
                float SpecularLayerMask = LightMap.r; // 高光类型Layer
                float ShadowAOMask = LightMap.g; //ShadowAOMask
                float SpecularIntensityMask = LightMap.b; //SpecularIntensityMask
                float LayerMask = LightMap.a; //LayerMask Ramp类型Layer
                // float RampOffsetMask = VertexColor.g; //Ramp偏移值,值越大的区域 越容易"感光"(在一个特定的角度，偏移光照明暗) 
                float RampOffsetMask = 0; //Ramp偏移值,值越大的区域 越容易"感光"(在一个特定的角度，偏移光照明暗) 

                //Ramp图大小为256x20 
                float RampPixelY = 0.05; // 1.0/20.0; 
                float RampPixelX = 0.00390625; //1.0/256.0 
                float halfLambert = (NdotL * 0.5 + 0.5 + _RampOffset + RampOffsetMask); 
                halfLambert = clamp(halfLambert, RampPixelX, 1 - RampPixelX); //头发Shader中,LightMap.A==1 为特殊材质 
                //根据LightMap.a选择Ramp中不同的层。 
                float RampIndex = 1; 
                if (LayerMask >= 0 && LayerMask <= 0.1) 
                { RampIndex = 6; }
                if (LayerMask >= 0.11 && LayerMask <= 0.33) 
                { RampIndex = 2; }
                if (LayerMask >= 0.34 && LayerMask <= 0.55) 
                { RampIndex = 3; }
                if (LayerMask >= 0.56 && LayerMask <= 0.9) 
                { RampIndex = 4; }
                if (LayerMask >= 0.95 && LayerMask <= 1.0) 
                { RampIndex = RampIndex; }

                //漫反射分类 用于区别Ramp 
                //高光也分类 用于区别高光 
                float PixelInRamp = RampPixelY * (RampIndex * 2 - 1); 
                ShadowAOMask = 1 - smoothstep(saturate(ShadowAOMask), 0.2, 0.6); //平滑ShadowAOMask,减弱 //为了将ShadowAOMask区域常暗显示 
                float3 ramp = tex2D(_ShadowRamp, saturate(float2(halfLambert * lerp(0.5, 1.0, ShadowAOMask),PixelInRamp))); 


                // float3 BaseMapShadowed = lerp(BaseMap * ramp, BaseMap, ShadowAOMask); 
                // BaseMapShadowed = lerp(BaseMap, BaseMapShadowed, _ShadowRampLerp); 
                // float IsBrightSide = ShadowAOMask * step(_LightThreshold, halfLambert); 
                // float3 Diffuse = lerp(lerp(BaseMapShadowed, BaseMap * ramp, _RampLerp) * _DarkIntensit


                //------------------------【Diffuse】-----------------------------
                // fixed halfLambert = 0.5 * NdotL + 0.5;
                // float rampValue = smoothstep(0,_ShadowSmoothness,halfLambert-_ShadowRange);
                // float ramp =  tex2D(_ShadowRamp, float2(saturate(rampValue), 0.5));
                // float ramp = calculateRamp(_ShadowRange,halfLambert,_ShadowSmoothness);

                // float ramp =  tex2D(_ShadowRamp, halfLambert);
                float3 diffuse = lerp( _ShadowColor*texCol,texCol,ramp);

                
                //------------------------【Specular】-----------------------------
                float3 specular = pow(saturate(NdotH),_SpecularPower * LightMap.r )*_SpecularScale * LightMap.b;
                specular = saturate(specular * _SpecularColor);

                //------------------------【Rim】-----------------------------
                // float3 Rim = step(1-_RimWidth,1-NdotV)*_RimIntensity;
                // float3 Rim = pow(1 - NdotV,_RimWidth)*_RimIntensity;

                // 自发光
                float3 emission = texCol.a * _EmissionColor;

                fixed3 result = diffuse + specular + emission;


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
                return float4(ramp,0);
                if(_TestMode ==mode++){
                    float index = 10;
                    float rampH = RampPixelY * (index * 2 - 1); 
                    float3 rampC = tex2D(_ShadowRamp, saturate(float2(i.uv.x,rampH))); 
                    return float4(rampC,0);
                }

                return float4(result,1);
            }
            ENDCG
        }

        
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
        
    }
}
