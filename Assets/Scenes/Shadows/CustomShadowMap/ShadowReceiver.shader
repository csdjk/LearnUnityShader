Shader "lcl/Shadows/CustomShadowMap/ShadowReceiver"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM

            #include "UnityCG.cginc"
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile SHADOW_SIMPLE SHADOW_PCF SHADOW_PCF_POISSON_DISK SHADOW_PCSS SHADOW_ESM SHADOW_VSM
            // #pragma fragmentoption ARB_precision_hint_fastest
            #pragma enable_d3d11_debug_symbols

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 shadowCoord : TEXCOORD0;
            };

            #define EPS 1e-3
            #define NUM_SAMPLES 50
            #define NUM_RINGS 10
            // #define W_LIGHT 2.


            float4x4 _gWorldToShadow;
            sampler2D _gShadowMapTexture;
            float4 _gShadowMapTexture_TexelSize;
            float _gShadowStrength;
            float4 _Color;

            float _gShadow_bias;
            // 滤波步长
            float _gFilterStride;
            // 光源宽度
            float _gLightWidth;
            
            // ESM 常量
            float _gExpConst;
            // VSM 
            // 最小方差
            float _gVarianceBias;
            // 漏光
            float _gLightLeakBias;

            v2f vert(appdata_full v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.shadowCoord = mul(_gWorldToShadow, worldPos);

                return o;
            }

            
            float rand_1to1(float x)
            {
                // -1 -1
                return frac(sin(x) * 10000.0);
            }

            float rand_2to1(float2 uv)
            {
                // 0 - 1
                float a = 12.9898, b = 78.233, c = 43758.5453;
                float dt = dot(uv.xy, float2(a, b));
                float sn = fmod(dt, UNITY_PI);
                return frac(sin(sn) * c);
            }

            float2 poissonDisk[NUM_SAMPLES];
            // 泊松圆盘采样
            void poissonDiskSamples(const in float2 randomSeed)
            {
                float ANGLE_STEP = UNITY_TWO_PI * float(NUM_RINGS) / float(NUM_SAMPLES);
                float INV_NUM_SAMPLES = 1.0 / float(NUM_SAMPLES);

                float angle = rand_2to1(randomSeed) * UNITY_TWO_PI;
                float radius = INV_NUM_SAMPLES;
                float radiusStep = radius;

                UNITY_UNROLL for (int i = 0; i < NUM_SAMPLES; i++)
                {
                    poissonDisk[i] = float2(cos(angle), sin(angle)) * pow(radius, 0.75);
                    radius += radiusStep;
                    angle += ANGLE_STEP;
                }
            }
            // 均匀圆盘采样
            void uniformDiskSamples(const in float2 randomSeed)
            {

                float randNum = rand_2to1(randomSeed);
                float sampleX = rand_1to1(randNum);
                float sampleY = rand_1to1(sampleX);

                float angle = sampleX * UNITY_TWO_PI;
                float radius = sqrt(sampleY);

                UNITY_UNROLL for (int i = 0; i < NUM_SAMPLES; i++)
                {
                    poissonDisk[i] = float2(radius * cos(angle), radius * sin(angle));

                    sampleX = rand_1to1(sampleY);
                    sampleY = rand_1to1(sampleX);

                    angle = sampleX * UNITY_TWO_PI;
                    radius = sqrt(sampleY);
                }
            }

            // 获取遮挡物平均深度
            float findBlocker(sampler2D shadowMap, float2 uv, float zReceiver)
            {
                poissonDiskSamples(uv);
                //uniformDiskSamples(uv);

                // 注意 block 的步长要比 PCSS 中的 PCF 步长长一些，这样生成的软阴影会更加柔和
                float filterStride = _gFilterStride + 5;
                float2 filterRange = _gShadowMapTexture_TexelSize.xy * filterStride;

                // 有多少点在阴影里
                int shadowCount = 0;
                float blockDepth = 0.0;
                UNITY_UNROLL for (int i = 0; i < NUM_SAMPLES; i++)
                {
                    float2 sampleCoord = poissonDisk[i] * filterRange + uv;
                    float closestDepth = DecodeFloatRGBA(tex2D(shadowMap, sampleCoord));
                    if (zReceiver - _gShadow_bias > closestDepth)
                    {
                        blockDepth += closestDepth;
                        shadowCount += 1;
                    }
                }

                if (shadowCount == NUM_SAMPLES)
                {
                    return 2.0;
                }
                // 平均
                return blockDepth / float(shadowCount);
            }


            float useShadowMap(sampler2D shadowMap, float4 coords)
            {
                // 获取深度图中的深度值（最近的深度）
                float closestDepth = DecodeFloatRGBA(tex2D(shadowMap, coords.xy));
                // 获取当前片段在光源视角下的深度
                float currentDepth = coords.z;
                // 比较
                float shadow = currentDepth - _gShadow_bias > closestDepth ? 0.0 : 1.0;

                return shadow;
            }

            float PCF(sampler2D shadowMap, float4 coords)
            {
                float currentDepth = coords.z;
                float shadow = 0.0;
                float2 filterRange = _gShadowMapTexture_TexelSize.xy * _gFilterStride;

                UNITY_UNROLL for (int x = -1; x <= 1; ++x)
                {
                    UNITY_UNROLL for (int y = -1; y <= 1; ++y)
                    {
                        float2 sampleCoord = float2(x, y) * filterRange + coords.xy;
                        float pcfDepth = DecodeFloatRGBA(tex2D(shadowMap, sampleCoord));
                        shadow += currentDepth - _gShadow_bias > pcfDepth ? 0.0 : 1.0;
                    }
                }
                shadow /= 9.0;
                return shadow;
            }

            float PCF_PoissonDisk(sampler2D shadowMap, float4 coords)
            {
                // 采样
                poissonDiskSamples(coords.xy);
                //uniformDiskSamples(coords.xy);

                float currentDepth = coords.z;
                float shadow = 0.0;
                float2 filterRange = _gShadowMapTexture_TexelSize.xy * _gFilterStride;

                UNITY_UNROLL for (int i = 0; i < NUM_SAMPLES; i++)
                {
                    float2 sampleCoord = poissonDisk[i] * filterRange + coords.xy;
                    float pcfDepth = DecodeFloatRGBA(tex2D(shadowMap, sampleCoord));
                    shadow += currentDepth - _gShadow_bias > pcfDepth ? 0.0 : 1.0;
                }
                shadow /= float(NUM_SAMPLES);
                return shadow;
            }
            
            float PCSS(sampler2D shadowMap, float4 coords)
            {

                float zReceiver = coords.z;

                // STEP 1: blocker search
                float zBlocker = findBlocker(shadowMap, coords.xy, zReceiver);
                if (zBlocker < EPS)
                    return 1.0;
                if (zBlocker > 1.0)
                    return 0.0;

                // STEP 2: penumbra size
                float wPenumbra = (zReceiver - zBlocker) * _gLightWidth / zBlocker;

                // STEP 3: filtering
                // 这里的步长要比 STEP 1 的步长小一些
                float filterStride = _gFilterStride;
                float2 filterRange = _gShadowMapTexture_TexelSize.xy * filterStride * wPenumbra;
                float shadow = 0.0;
                UNITY_UNROLL for (int i = 0; i < NUM_SAMPLES; i++)
                {
                    float2 sampleCoord = poissonDisk[i] * filterRange + coords.xy;
                    float pcfDepth = DecodeFloatRGBA(tex2D(shadowMap, sampleCoord));
                    float currentDepth = coords.z;
                    shadow += currentDepth - _gShadow_bias > pcfDepth ? 0.0 : 1.0;
                }
                shadow /= float(NUM_SAMPLES);
                return shadow;
            }


            float ESM(sampler2D shadowMap, float4 coords)
            {
                // e^cd
                float expDepth = DecodeFloatRGBA(tex2D(shadowMap, coords.xy));
                // e^-cz
                float currentExpDepth = exp(-_gExpConst * coords.z);
                // e^-c(z-d) = e^cd-cz = e^cd * e^-cz
                return saturate(expDepth * currentExpDepth);

                // return(exp(_gExpConst * (expDepth - coords.z)));

            }

            float VSM(sampler2D shadowMap, float4 coords)
            {
                float currentDepth = coords.z;
                float2 moments = tex2D(shadowMap, coords.xy).rg;
                float minVariance = _gVarianceBias;
                float lightLeakBias = _gLightLeakBias;
                
                if (currentDepth <= moments.x)
                {
                    return 1.0;
                }


                float E_x2 = moments.y;
                float Ex_2 = moments.x * moments.x;
                // variance sig^2 = E(x^2) - E(x)^2
                float variance = E_x2 - Ex_2;
                variance = max(variance, minVariance);
                float mD = currentDepth - moments.x;
                float mD_2 = mD * mD;
                // 切比雪夫不等式
                float p = variance / (variance + mD_2);

                // return p;

                p = saturate((p - lightLeakBias) / (1.0 - lightLeakBias));
                return max(p, currentDepth <= moments.x);
            }

            fixed4 frag(v2f i) : COLOR0
            {

                float3 coord = 0;
                // NDC
                i.shadowCoord.xyz = i.shadowCoord.xyz / i.shadowCoord.w;
                //[-1, 1]-->[0, 1]
                coord.xy = i.shadowCoord.xy * 0.5 + 0.5;

                #if defined(SHADER_TARGET_GLSL)
                    coord.z = i.shadowCoord.z * 0.5 + 0.5; //[-1, 1]-->[0, 1]
                #elif defined(UNITY_REVERSED_Z)
                    coord.z = 1 - i.shadowCoord.z;       //[1, 0]-->[0, 1]
                #endif

                // float visibility = useShadowMap(_gShadowMapTexture, float4(coord, 1.0));
                // float visibility = PCF(_gShadowMapTexture, float4(coord, 1.0));
                // float visibility = PCF_PoissonDisk(_gShadowMapTexture, float4(coord, 1.0));
                // float visibility = PCSS(_gShadowMapTexture, float4(coord, 1.0));
                float visibility = 1;
                #ifdef SHADOW_SIMPLE
                    visibility = useShadowMap(_gShadowMapTexture, float4(coord, 1.0));
                #elif SHADOW_PCF
                    visibility = PCF(_gShadowMapTexture, float4(coord, 1.0));
                #elif SHADOW_PCF_POISSON_DISK
                    visibility = PCF_PoissonDisk(_gShadowMapTexture, float4(coord, 1.0));
                #elif SHADOW_PCSS
                    visibility = PCSS(_gShadowMapTexture, float4(coord, 1.0));
                #elif SHADOW_ESM
                    visibility = ESM(_gShadowMapTexture, float4(coord, 1.0));
                    // return fixed4(0, 0, 1, 1);
                #elif SHADOW_VSM
                    visibility = VSM(_gShadowMapTexture, float4(coord, 1.0));
                #endif


                visibility = lerp(1, visibility, _gShadowStrength);
                return _Color * visibility;
            }

            
            ENDCG

        }
    }
}