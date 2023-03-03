Shader "lcl/GPUInstance/Grass3"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _Color ("Color", Color) = (1, 1, 1, 1)
        _Cutoff ("Alpha Cutoff", Range(0.0, 1.0)) = 0.5
        _Wind ("Wind(x,y,z,str)", Vector) = (1, 0, 0, 10)
        _NoiseMap ("WaveNoiseMap", 2D) = "white" { }
        [PowerSlider(3.0)]_WindNoiseStrength ("WindNoiseStr", Range(0, 20)) = 10
    }
    SubShader
    {
        Tags { "Queue" = "AlphaTest" "RenderType" = "TransparentCutout" }
        
        // 投影
        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            ZWrite On
            ZTest On
            Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // #pragma hull hs
            // #pragma domain ds
            // GPU Instancing
            #pragma multi_compile_instancing
            // 表示每次实例渲染的时候，都会执行以下setup这个函数
            // #pragma instancing_options procedural:setup

            #pragma multi_compile_fwdbase


            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #include "Tessellation.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float4 worldPosition : TEXCOORD2;
                SHADOW_COORDS(3)
            };

            struct GrassInfo
            {
                float4x4 localToWorld;
                float4 texParams;
            };
            StructuredBuffer<GrassInfo> _GrassInfoBuffer;


            float2 _GrassQuadSize;
            float4x4 _TerrianLocalToWorld;

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _Cutoff;
            float3 _Color;

            float4 _Wind;
            float _WindNoiseStrength;
            sampler2D _NoiseMap;

            // 交互对象坐标和范围（w）
            float4 _PlayerPos;
            // 下压强度
            float _PushStrength;
            
            ///计算被风影响后的世界坐标
            ///positionWS - 施加风力前的世界坐标
            ///grassUpWS - 草的生长方向，单位向量，世界坐标系
            ///windDir - 是风的方向，单位向量，世界坐标系
            ///windStrength - 风力强度,范围0-1
            ///vertexLocalHeight - 顶点在草面片空间中的高度
            float3 applyWind(float3 positionWS, float3 grassUpWS, float3 windDir, float windStrength, float vertexLocalHeight)
            {
                //根据风力，计算草弯曲角度，从0到90度
                float rad = radians(-windStrength);
                //得到wind与grassUpWS的正交向量
                windDir = windDir - dot(windDir, grassUpWS);

                float x, y;  //弯曲后,x为单位球在wind方向计量，y为grassUp方向计量
                sincos(rad, x, y);

                //offset表示grassUpWS这个位置的顶点，在风力作用下，会偏移到windedPos位置
                float3 windedPos = x * windDir + y * grassUpWS;

                vertexLocalHeight += 0.5 * _GrassQuadSize.y;
                //加上世界偏移
                return positionWS + (windedPos - grassUpWS) * vertexLocalHeight;
            }

            v2f vert(appdata input, uint instanceID : SV_InstanceID)
            {
                v2f o;
                float2 uv = input.uv;
                float4 positionOS = input.vertex;
                float3 normalOS = input.normal;
                // 缩放
                positionOS.xy = positionOS.xy * _GrassQuadSize;

                GrassInfo grassInfo = _GrassInfoBuffer[instanceID];
                //UV偏移缩放
                uv = uv * grassInfo.texParams.xy + grassInfo.texParams.zw;

                //从本地坐标转换到世界坐标
                float4 positionWS = mul(grassInfo.localToWorld, positionOS);
                positionWS /= positionWS.w;

                // 风
                // half dis =  uv.y;
                // half time = (_Time.y + _TimeDelay) * _TimeScale;
                // positionWS.xyz += dis * (sin(time + positionWS.x) * cos(time * 2 / 3) + 0.3)* _Direction.xyz;

                // 风2
                float3 grassUpDir = float3(0, 1, 0);
                float3 windDir = normalize(_Wind.xyz);
                //风力强度
                float windStrength = _Wind.w ;
                float localVertexHeight = positionOS.y;
                grassUpDir = mul(grassInfo.localToWorld, float4(grassUpDir, 0)).xyz;


                // 随机噪声
                float time = _Time.y;
                float2 noiseUV = (positionWS.xz - time) / 30;
                float noiseValue = tex2Dlod(_NoiseMap, float4(noiseUV, 0, 0)).r;
                //通过sin函数进行周期摆动,乘以windStrength来控制摆动频率。通常风力越强，摆动频率越高
                noiseValue = sin(noiseValue * windStrength);
                //将扰动再加到风力上,_WindNoiseStrength为扰动幅度，通过材质球配置
                windStrength += noiseValue * _WindNoiseStrength;


                // 与玩家的交互
                float3 offsetDir = normalize(_PlayerPos.xyz - positionWS.xyz);
                float dis = distance(positionWS.xyz, _PlayerPos.xyz);
                float radius = _PlayerPos.w;

                // 下压
                // float isPushRange = step(dis,radius);
                float isPushRange = smoothstep(dis, dis + 0.8, radius);
                // float isPushRange = 1-smoothstep(radius,radius+0.8,dis);
                windDir.xz = offsetDir.xz * isPushRange + windDir.xz * (1 - isPushRange);
                windStrength += _PushStrength * isPushRange;

                // if(dis<=radius){
                //     windDir.xz = offsetDir.xz;
                //     windStrength += _PushStrength;
                // }

                positionWS.xyz = applyWind(positionWS.xyz, grassUpDir, windDir, windStrength, localVertexHeight);

                //输出到片段着色器
                o.uv = uv;
                o.worldPosition = positionWS;
                // o.worldNormal = isPushRange;
                o.worldNormal = mul(grassInfo.localToWorld, float4(normalOS, 0)).xyz;
                o.pos = mul(UNITY_MATRIX_VP, positionWS);

                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 color = tex2D(_MainTex, i.uv);
                clip(color.a - _Cutoff);


                float3 worldPos = i.worldPosition;
                //计算光照和阴影，光照采用Lembert Diffuse.
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;
                float3 worldNormal = normalize(i.worldNormal);
                // 半兰伯特光照模型
                fixed3 halfLambert = dot(worldNormal, lightDir) * 0.5 + 0.5;
                fixed3 diffuse = max(halfLambert, 0.5);

                // 阴影
                // UNITY_LIGHT_ATTENUATION(atten, i, worldPos);

                color.rgb *= _Color;
                return color;

                // return float4(i.worldNormal,1);

            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
