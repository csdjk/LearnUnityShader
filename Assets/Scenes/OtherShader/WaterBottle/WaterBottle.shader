Shader "lcl/WaterBottle"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _TopColor("Top Color", Color) = (1,1,1,1)
        _FoamColor("Foam Color", Color) = (1,1,1,1)
        _FluidHeight("Fluid Height", Range(-0.5, 0.5)) = 0
        _Threshold("Threshold", Range(0, 1)) = 0.1
        _DepthMaxDistance("Foam Distance", Range(0,2)) = 1


        [HideInInspector]_WobbleX("MaxHeightInX", Float) = 0
        [HideInInspector]_WobbleZ("MaxHeightInZ", Float) = 0

        _LiquidRimColor ("Liquid Rim Color", Color) = (1,1,1,1)
        _LiquidRimPower ("Liquid Rim Power", Range(0,50)) = 0
        _LiquidRimScale ("Liquid Rim Scale", Range(0,1)) = 1

        [Header(Bottle)]

        _BottleColor ("Bottle Color", Color) = (0.5,0.5,0.5,1)
        _BottleThickness ("Bottle Thickness", Range(0,1)) = 0.1
        
        _BottleRimColor ("Bottle Rim Color", Color) = (1,1,1,1)
        _BottleRimPower ("Bottle Rim Power", Range(0,10)) = 0.0
        _BottleRimIntensity ("Bottle Rim Intensity", Range(0.0,3.0)) = 1.0
        
        _BottleSpecular ("Bottle Specular Color", Color) = (1,1,1,1)
        _BottleGloss ("BottleGloss", Range(0,1) ) = 0.5
        // _SpecularThreshold ("Specular Threshold", Range(0,1)) = 0
        // _SpecularSmoothness ("Specular Smoothness", Range(0,1)) = 0
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "RenderType"="Transparent"}

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha

            Tags{"LightMode" = "ForwardBase"}
            CGPROGRAM
            #include "UnityCG.cginc"
            #pragma vertex vert
            #pragma fragment frag
            // #pragma enable_d3d11_debug_symbols

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;	
                float3 normal : TEXCOORD0;
                float3 viewDir : COLOR;
                float3 localPos : COLOR2;
                float4 screenPos : TEXCOORD1;
            };

            fixed4 _Color;
            fixed4 _TopColor;
            fixed4 _FoamColor;
            fixed _FluidHeight;
            fixed _Threshold;
            float _WobbleX;
            float _WobbleZ;

            float _LiquidRimPower;
            float _LiquidRimScale;
            fixed4 _LiquidRimColor;

            sampler2D _CameraDepthTexture;
            half _DepthMaxDistance;

            v2f vert(a2v v)
            {
                v2f o;
                float rate = sqrt((0.5 * 0.5 - _FluidHeight * _FluidHeight) / (v.vertex.x * v.vertex.x + v.vertex.z * v.vertex.z));
                float vertexDis = min(rate, 1);
                fixed vertexHeight = step(_FluidHeight, v.vertex.y);
                v.vertex.y = vertexHeight * _FluidHeight + (1 - vertexHeight) * v.vertex.y;
                v.normal = vertexHeight * fixed3(0, 1, 0) + (1 - vertexHeight) * v.normal;

                // 等同于下面的if分支
                vertexDis = lerp(1,vertexDis,vertexHeight);
                v.vertex.xz *= vertexDis;
                float isRate = (rate - 1 < _Threshold && rate - 1 > 0);
                isRate *= vertexHeight;
                rate = lerp(1,rate,isRate);
                v.vertex.xz *= rate;
                // if (vertexHeight == 1)
                // {
                //         if (rate - 1 < _Threshold && rate - 1 > 0)
                //         v.vertex.xz *= rate;
                //         v.vertex.xz *= vertexDis;
                // }

                float X, Z;
                X = atan(_WobbleZ / 2);
                Z = atan(_WobbleX / 2);
                float3x3 rotMatX, rotMatZ;
                rotMatX[0] = float3(1, 0, 0);
                rotMatX[1] = float3(0, cos(X), sin(X));
                rotMatX[2] = float3(0, -sin(X), cos(X));
                rotMatZ[0] = float3(cos(Z), sin(Z), 0);
                rotMatZ[1] = float3(-sin(Z), cos(Z), 0);
                rotMatZ[2] = float3(0, 0, 1);
                v.vertex.xyz = mul(rotMatX, mul(rotMatZ, v.vertex.xyz));
                o.pos = UnityObjectToClipPos(v.vertex);
                o.localPos = v.vertex;
                o.normal = v.normal;
                o.viewDir = normalize(ObjSpaceViewDir(v.vertex));
                o.screenPos = ComputeGrabScreenPos(o.pos);
                return o;
            }
            fixed4 frag(v2f i) : SV_Target
            {
                // 获取屏幕深度
                half existingDepth01 = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos)).r;
                half existingDepthLinear = LinearEyeDepth(existingDepth01);
                half depthDifference = existingDepthLinear - i.screenPos.w;
                // 泡沫
                half waterDepthDifference01 = saturate(depthDifference / _DepthMaxDistance);
                float4 topColor = lerp(_FoamColor, _TopColor, waterDepthDifference01);

                float3 N = normalize(i.normal);
                float3 V = normalize(i.viewDir);
                float NdotV = max(0,dot(N, V));

                fixed fresnel = _LiquidRimScale + (1 - _LiquidRimScale) * pow(1 - NdotV, _LiquidRimPower);
                fixed4 color = lerp(_Color,_LiquidRimColor,fresnel);
                topColor = lerp(topColor,_LiquidRimColor,fresnel);

                color.a += fresnel;

                fixed isTop = i.normal.y > 0.99;

                return lerp(color,topColor,isTop);
            }
            ENDCG
        }

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            
            CGPROGRAM
            #include "UnityCG.cginc"
            #pragma vertex vert
            #pragma fragment frag
            #pragma enable_d3d11_debug_symbols
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL; 
            };
            
            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 viewDir : COLOR;
                float3 normal : COLOR2;
                float2 uv : TEXCOORD0;
                float3 lightDir : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float3 viewDirWorld : TEXCOORD3;
            };
            
            float4 _BottleColor, _BottleRimColor,_BottleSpecular;
            float _BottleThickness, _BottleRim, _BottleRimPower, _BottleRimIntensity;
            float _BottleGloss,_SpecularThreshold,_SpecularSmoothness;
            
            v2f vert (appdata v)
            {
                v2f o;
                v.vertex.xyz += _BottleThickness * v.normal;
                o.vertex = UnityObjectToClipPos(v.vertex);

                o.viewDir = normalize(ObjSpaceViewDir(v.vertex));
                o.normal = v.normal;
                
                float4 posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.viewDirWorld = normalize(_WorldSpaceCameraPos.xyz - posWorld.xyz);
                o.normalDir = UnityObjectToWorldNormal (v.normal);
                o.lightDir = normalize(_WorldSpaceLightPos0.xyz);
                return o;
            }
            
            // 计算色阶
            float calculateRamp(float threshold,float value, float smoothness){
                threshold = saturate(1-threshold);
                half minValue = saturate(threshold - smoothness);
                half maxValue = saturate(threshold + smoothness);
                return smoothstep(minValue,maxValue,value);
            }

            fixed4 frag (v2f i, fixed facing : VFACE) : SV_Target
            {
                // specular
                float3 N = normalize(i.normalDir);
                float3 V = normalize(i.viewDir);
                float specularPow = exp2 ((1 - _BottleGloss) * 10.0 + 1.0);
                
                float3 H = normalize (i.lightDir + i.viewDirWorld);
                float NdotH = max(0,dot(N, H));
                float NdotV = max(0,dot(N, V));

                fixed specularCol = pow(NdotH,specularPow)*_BottleSpecular;
                // 阈值判断
                // float specularRamp = calculateRamp(_SpecularThreshold,specular,_SpecularSmoothness);
                // fixed4 specularCol = specularRamp*_BottleSpecular;

                // rim
                float fresnel = 1 - pow(NdotV, _BottleRimPower);
                fixed4 rim = _BottleRimColor * smoothstep(0.5, 1.0, fresnel) * _BottleRimIntensity;
                rim.rgb = rim.a > 0.25 ? _BottleColor.rgb : rim.rgb;

                fixed4 finalCol = rim + _BottleColor + specularCol;
                return finalCol;
            }
            ENDCG
        }	
    }
    FallBack "Diffuse"
}
