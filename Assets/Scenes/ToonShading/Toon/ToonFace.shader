//--------------------------- 卡通渲染 - 脸---------------------
Shader "lcl/ToonShading/ToonFace"
{
    Properties
    {
        // 主纹理
        _MainTex ("Texture", 2D) = "white" { }
        // 主颜色
        _Color ("Color", Color) = (1, 1, 1, 1)

        // 描边
        [Main(outline, _, 3)] _group_outline ("描边", float) = 1
        [Sub(outline)] _OutlinePower ("Outline Power", Range(0, 0.1)) = 0.05
        [Sub(outline)]_LineColor ("Line Color", Color) = (1, 1, 1, 1)
        [Sub(outline)]_OffsetFactor ("Offset Factor", Range(0, 200)) = 0
        [Sub(outline)]_OffsetUnits ("Offset Units", Range(0, 200)) = 0
        // 是否使用平滑法向量
        [SubToggle(outline, __)] _USE_SMOOTH_NORMAL ("Use Smooth Normal", float) = 0

        // 光照阴影
        [Main(lighting, _, 3)] _group_shadow ("光照阴影", float) = 1
        [Tex(lighting)]_FaceSDFTex ("FaceSDFTex", 2D) = "white" { }
        [Sub(lighting)]_SDFThreshold ("SDFThreshold", Range(0, 1)) = 0
        [Sub(lighting)]_ShadowColor ("Shadow Color", Color) = (0.7, 0.7, 0.7)
        [Sub(lighting)]_FaceLightOffset ("Face Lightmap Offset", Range(-1, 1)) = 0

        [KeywordEnum(None, halfLambert, texCol_R, texCol_G, texCol_B, texCol_A, UV)] _TestMode ("_TestMode", Int) = 0
    }

    CGINCLUDE
    #include "UnityCG.cginc"
    #include "Lighting.cginc"
    //顶点着色器输入结构体
    struct appdata
    {
        float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
        float3 normal : NORMAL;
        float4 tangent : TANGENT;
    };
    //顶点着色器输出结构体
    struct v2f
    {
        float4 vertex : SV_POSITION;
        float2 uv : TEXCOORD0;
        float3 worldNormalDir : TEXCOORD1;
        float3 worldPos : TEXCOORD2;
        float3 forward : TEXCOORD3;
    };
    int _TestMode;

    sampler2D _MainTex;
    float4 _MainTex_TexelSize;
    float4 _Color;
    // 描边
    float _OutlinePower;
    float4 _LineColor;
    // 阴影
    sampler2D _FaceSDFTex;
    float4 _FaceSDFTex_TexelSize;
    float4 _ShadowColor;
    float _SDFThreshold;
    float _FaceLightOffset;

    ENDCG
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Front
            ZWrite Off
            Offset [_OffsetFactor], [_OffsetUnits]

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            v2f vert(appdata v)
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
            fixed4 frag(v2f i) : SV_Target
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

            v2f vert(appdata v)
            {
                //正常渲染
                v2f o;
                o.uv = v.uv;
                o.worldNormalDir = mul(v.normal, (float3x3) unity_WorldToObject);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            // 计算色阶
            float calculateRamp(float threshold, float value, float smoothness)
            {
                threshold = saturate(1 - threshold);
                half minValue = saturate(threshold - smoothness);
                half maxValue = saturate(threshold + smoothness);
                return smoothstep(minValue, maxValue, value);
            }

            float GetFaceSDF(in float2 uv, in float Threshold)
            {
                ///抗锯齿 ///https://steamcdn-a.akamaihd.net/apps/valve/2007/SIGGRAPH2007_AlphaTestedMagnifi
                float dist = (tex2D(_FaceSDFTex, (uv)).r);
                float color = dist; // uv distance per pixel density for texture on screen
                float2 duv = fwidth(uv);
                // texel-per-pixel density for texture on screen (scalar)
                // nb: in unity, z and w of TexelSize are the texture dimensions
                float dtex = length(duv * _FaceSDFTex_TexelSize.zw);
                // distance to edge in pixels (scalar)
                float pixelDist = (Threshold - color) / _FaceSDFTex_TexelSize.x * 2 / dtex;


                return step(pixelDist, 0.5);
                // return pixelDist;

            }

            // ------------------------【正面-片元着色器】---------------------------
            fixed4 frag(v2f i) : SV_Target
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

                //------------------------【Diffuse】-----------------------------
                fixed halfLambert = 0.5 * NdotL + 0.5;

                float3 faceLightMap = tex2D(_FaceSDFTex, i.uv);

                // float4 Front = mul(unity_ObjectToWorld,float4(0,0,1,0));
                // float4 Right = mul(unity_ObjectToWorld,float4(1,0,0,0));
                // float4 Up = mul(unity_ObjectToWorld,float4(0,1,0,0));
                // float3 Left = -Right;
                
                // float FL =  dot(normalize(Front.xz), normalize(lightDir.xz));
                // float LL = dot(normalize(Left.xz), normalize(lightDir.xz));
                // float RL = dot(normalize(Right.xz), normalize(lightDir.xz));
                // float faceLight = faceLightMap.r+_FaceLightOffset;
                // float faceLightRamp = (FL > 0) * min((faceLight > LL),(1 > faceLight+RL) ) ;

                // float3 diffuse = lerp( _ShadowColor*texCol,texCol,faceLightRamp);

                // half minValue = saturate(threshold - smoothness);
                // half maxValue = saturate(threshold + smoothness);
                // return smoothstep(minValue,maxValue,value);


                //输入脸部的局部坐标，原神的每个英雄 局部坐标并不统一，因此要与每个英雄对应
                
                float4 Front = normalize(mul(unity_ObjectToWorld, float4(0, 0, 1, 0)));
                float4 Right = normalize(mul(unity_ObjectToWorld, float4(1, 0, 0, 0)));
                float3 Left = -Right;
                
                #define InvHalfPi 0.6366197722844561

                float faceLight = faceLightMap.b + _FaceLightOffset; //用来和 头发 身体的明暗过渡对齐

                float IsFront = dot(normalize(Front.xz), normalize(lightDir.xz)) > 0;
                float LeftAngleCos = dot(normalize(Left.xz), normalize(lightDir.xz));
                float RightAngleCos = dot(normalize(Right.xz), normalize(lightDir.xz));
                //将非线性的cos值转换为线性的角度值，使得过渡更平滑
                float Angle01 = 0.5 * lerp(2 - acos(RightAngleCos) * InvHalfPi, acos(LeftAngleCos) * InvHalfPi, LeftAngleCos > RightAngleCos);
                float FaceLight = IsFront * (1 - step(Angle01, faceLight));
                float3 diffuse = lerp(_ShadowColor * texCol.rgb, texCol.rgb, FaceLight);
                fixed3 result = diffuse * lightCol * texCol;


                int mode = 1;
                if (_TestMode == mode++)
                    return halfLambert;
                if (_TestMode == mode++)
                    return texCol.r;
                if (_TestMode == mode++)
                    return texCol.g;
                if (_TestMode == mode++)
                    return texCol.b;
                if (_TestMode == mode++)
                    return texCol.a;
                if (_TestMode == mode++)
                    return float4(i.uv, 0, 0);
                if (_TestMode == mode++)
                    return float4(diffuse, 0);

                return float4(result, 1);
                // return FaceLight;

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

            v2f vert(appdata v)
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
            fixed4 frag(v2f i) : SV_Target
            {
                return _LineColor;
            }
            
            ENDCG
        }
    }
}
