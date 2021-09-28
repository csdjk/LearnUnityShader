Shader "Unlit/CartoonWater"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        // 浅滩颜色
        _ShallowColor("Shallow Color", Color) = (0.325, 0.807, 0.971, 0.725)
        // 深水区颜色
        _DeepColor("Deep Color", Color) = (0.086, 0.407, 1, 0.749)
        // 深度最大距离
        _DepthMaxDistance("Depth Maximum Distance", Range(0,2)) = 1
        _SurfaceNoise("Surface Noise", 2D) = "white" {}
        _SurfaceNoiseCutoff("Surface Noise Cutoff", Range(0, 1)) = 0.777

        _FoamDistance("Foam Distance", Float) = 0.4
        // 运动方向
        _SurfaceNoiseScroll("Surface Noise Scroll Amount", Vector) = (0.03, 0.03, 0, 0)

        _SurfaceDistortion("Surface Distortion", 2D) = "white" {}	
        // 控制，以倍增的强度扭曲
        _SurfaceDistortionAmount("Surface Distortion Amount", Range(0, 1)) = 0.27
        // 泡沫颜色
        _FoamColor("Foam Color", Color) = (1,1,1,1)

        // 透明度
        _WaterAlpha("water Alpha", Range(0, 1)) = 0.5


        // _distanceFactor("distanceFactor", Range(-10, 10)) = 0.5
        // _timeFactor("timeFactor", Range(-10, 10)) = 0.5
        // _totalFactor("totalFactor", Range(-10, 10)) = 0.5
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" }
        LOD 100
        
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #include "UnityCG.cginc"


            float4 _ShallowColor;
            float4 _DeepColor;
            float _DepthMaxDistance;
            sampler2D _CameraDepthTexture;
            float _SurfaceNoiseCutoff;
            float _FoamDistance;
            float2 _SurfaceNoiseScroll;
            sampler2D _SurfaceDistortion;
            float4 _SurfaceDistortion_ST;
            float _SurfaceDistortionAmount;
            float4 _FoamColor;
            fixed _WaterAlpha;

            // // 波浪
            // fixed _distanceFactor;
            // fixed _timeFactor;
            // fixed _totalFactor;
            

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 screenPosition : TEXCOORD2;
                float2 noiseUV : TEXCOORD3;
                float2 distortUV : TEXCOORD4;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _SurfaceNoise;
            float4 _SurfaceNoise_ST;


            v2f vert (appdata v)
            {
                v2f o;
                // float dist = distance(v.vertex.xyz, float3(0,0,0));
                // float h = sin(dist * 2 + _Time.z) / 5;
                // fixed sinFactor = sin(dist*_distanceFactor + _Time.y * _timeFactor) * _totalFactor * 0.01;
                // v.vertex.y = sinFactor;
                
                o.vertex = UnityObjectToClipPos(v.vertex);

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.screenPosition = ComputeScreenPos(o.vertex);
                o.noiseUV = TRANSFORM_TEX(v.uv, _SurfaceNoise);
                o.distortUV = TRANSFORM_TEX(v.uv, _SurfaceDistortion);
                return o;
            }
            #define SMOOTHSTEP_AA 0.01
            fixed4 frag (v2f i) : SV_Target
            {
                // 获取屏幕深度
                float existingDepth01 = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPosition)).r;
                float existingDepthLinear = LinearEyeDepth(existingDepth01);
                float depthDifference = existingDepthLinear - i.screenPosition.w;
                // 深水和潜水颜色做插值
                float waterDepthDifference01 = saturate(depthDifference / _DepthMaxDistance);
                float4 waterColor = lerp(_ShallowColor, _DeepColor, waterDepthDifference01);
                // 采样噪声图
                float2 distortSample = (tex2D(_SurfaceDistortion, i.distortUV).xy * 2 - 1) * _SurfaceDistortionAmount;
                float2 noiseUV = float2((i.noiseUV.x + _Time.y * _SurfaceNoiseScroll.x) + distortSample.x, (i.noiseUV.y + _Time.y * _SurfaceNoiseScroll.y) + distortSample.y);

                float surfaceNoiseSample = tex2D(_SurfaceNoise, noiseUV).r;
                
                float foamDepthDifference01 = saturate(depthDifference / _FoamDistance);
                float surfaceNoiseCutoff = foamDepthDifference01 * _SurfaceNoiseCutoff;
                // 噪声点
                float surfaceNoise = smoothstep(surfaceNoiseCutoff - SMOOTHSTEP_AA, surfaceNoiseCutoff + SMOOTHSTEP_AA, surfaceNoiseSample);
                float4 surfaceNoiseColor = _FoamColor * surfaceNoise;
                
                // fixed sinFactor = sin(_distanceFactor + _Time.y * _timeFactor) * _totalFactor * 0.01;
                // return depthDifference;
                // return waterColor;
                // return waterColor + surfaceNoiseSample;
                // return waterColor + surfaceNoise;

                fixed3 col = waterColor.rgb + surfaceNoiseColor.rgb;
                return fixed4(col,saturate(_WaterAlpha+depthDifference));
            }
            ENDCG
        }
    }
}