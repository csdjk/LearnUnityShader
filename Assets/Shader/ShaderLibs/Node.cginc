// Create by lichanglong
// https://github.com/csdjk/LearnUnityShader
// 2022.4.5
// 封装的一些功能节点

#ifndef NODE_INCLUDED
#define NODE_INCLUDED

float2 Flipbook(float2 UV, float Width, float Height, float Tile, float2 Invert)
{
    Tile = fmod(Tile, Width * Height);
    float2 tileCount = float2(1.0, 1.0) / float2(Width, Height);
    float tileY = abs(Invert.y * Height - (floor(Tile * tileCount.x) + Invert.y * 1));
    float tileX = abs(Invert.x * Width - ((Tile - Width * floor(Tile * tileCount.x)) + Invert.x * 1));
    return (UV + float2(tileX, tileY)) * tileCount;
}

// Flow Map
half4 FlowMapNode(sampler2D mainTex, sampler2D flowMap, float2 mainUV, float tilling, float flowSpeed, float strength)
{
    half speed = _Time.x * flowSpeed;
    half speed1 = frac(speed);
    half speed2 = frac(speed + 0.5);

    half4 flow = tex2D(flowMap, mainUV);
    half2 flow_uv = - (flow.xy * 2 - 1);

    half2 flow_uv1 = flow_uv * speed1 * strength;
    half2 flow_uv2 = flow_uv * speed2 * strength;

    flow_uv1 += (mainUV * tilling);
    flow_uv2 += (mainUV * tilling);

    half4 col = tex2D(mainTex, flow_uv1);
    half4 col2 = tex2D(mainTex, flow_uv2);

    float lerpValue = abs(speed1 * 2 - 1);
    half4 finalCol = lerp(col, col2, lerpValue);

    return finalCol;
}

// https://habr.com/en/post/180743/
// 混合两种贴图，a通道=高度图，u1 u2 = uv.x;
// use example ： color.rgb = BlendTexture(c1, i.uv1.x, c2, i.uv2.x);
float3 BlendTexture(float4 texture1, float u1, float4 texture2, float u2)
{
    float depth = 0.2;
    float ma = max(texture1.a + u1, texture2.a + u2) - depth;
    float b1 = max(texture1.a + u1 - ma, 0);
    float b2 = max(texture2.a + u2 - ma, 0);
    return (texture1.rgb * b1 + texture2.rgb * b2) / (b1 + b2);
}

// 序列帧
half4 SquenceImage(sampler2D tex, float2 uv, float2 amount, float speed)
{
    float time = floor(_Time.y * speed);
    float row = floor(time / amount.x);
    float column = time - row * amount.x;

    half2 new_uv = float2(uv.x / amount.x, uv.y / amount.y);
    new_uv.x = new_uv.x + column / amount.x;
    new_uv.y = new_uv.y - row / amount.y;
    return tex2D(tex, new_uv);
}

// 平滑值(可以用于色阶分层)
inline half SmoothValue(half NdotL, half threshold, half smoothness)
{
    half minValue = saturate(threshold - smoothness * 0.5);
    half maxValue = saturate(threshold + smoothness * 0.5);
    return smoothstep(minValue, maxValue, NdotL);
}

// SSS  近似模拟次表面散射
inline float SubsurfaceScattering(float3 V, float3 L, float3 N, float distortion, float power, float scale)
{
    float3 H = (L + N * distortion);
    float I = pow(saturate(dot(V, -H)), power) * scale;
    return I;
}

// 对应Blender color ramp 节点
half3 ColorRamp(float fac, half2 mulbias, half3 color1, half3 color2)
{
    fac = clamp(fac * mulbias.x + mulbias.y, 0.0, 1.0);
    half3 outcol = lerp(color1, color2, fac);
    return outcol;
}

// 分层Diffuse
half3 ColorLayer(float3 NdotL, half smoothness, half threshold1, half threshold2, half3 color1, half3 color2, half3 color3)
{
    float NdotL2 = NdotL + 1;
    NdotL2 = SmoothValue(NdotL2, threshold1, smoothness);
    float3 middleC = lerp(color1, color2, NdotL2);

    NdotL = SmoothValue(NdotL, threshold2, smoothness);
    float3 heightC = lerp(color2, color3, NdotL);

    return lerp(middleC, heightC, 1 - step(NdotL, 0));
}

// 重映射
// 将值从一个范围重映射到另一个范围
float Remap(float In, float2 InMinMax, float2 OutMinMax)
{
    return OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}

// 以半径扩散溶解
// dissolveData => x : threshold , y : maxDistance, z : noiseStrength
// edgeData => x : length , y : blur
half4 DissolveByRadius(
    half4 color, sampler2D NoiseTex, float2 uv, float3 positionOS, float3 center,
    float3 dissolveData, float2 edgeData,
    half4 edgeFirstColor, half4 edgeSecondColor)
{
    float dist = length(positionOS.xyz - center.xyz);
    float normalizedDist = saturate(dist / dissolveData.y);
    half noise = tex2D(NoiseTex, uv).r;
    
    fixed cutout = lerp(noise, normalizedDist, dissolveData.z);
    half cutoutThreshold = dissolveData.x - cutout;
    clip(cutoutThreshold);

    cutoutThreshold = cutoutThreshold / edgeData.x;
    //边缘颜色过渡
    float degree = saturate(cutoutThreshold - edgeData.y);
    half4 edgeColor = lerp(edgeFirstColor, edgeSecondColor, degree);
    half4 finalColor = lerp(edgeColor, color, degree);


    // 软边缘透明过渡
    half a = saturate(color.a);
    finalColor.a = lerp(saturate(cutoutThreshold / edgeData.y) * a, a, degree);

    return finalColor;
}


// 绘制圆环
half DrawRing(float2 uv, float2 center, float width, float size, float smoothness)
{
    float dis = distance(uv, center);
    float halfWidth = width * 0.5;
    float threshold1 = size - halfWidth;
    float threshold2 = size + halfWidth;

    float value = smoothstep(threshold1, threshold1 + smoothness, dis);
    float value2 = smoothstep(threshold2, threshold2 + smoothness, dis);
    
    return value - value2;
}

float ObjectPosRand01()
{
    return frac(UNITY_MATRIX_M[0][3] + UNITY_MATRIX_M[1][3] + UNITY_MATRIX_M[2][3]);
}

float3 GetPivotPos()
{
    return float3(UNITY_MATRIX_M[0][3], UNITY_MATRIX_M[1][3] + 0.25, UNITY_MATRIX_M[2][3]);
}
// ddx ddy计算法线
float3 CalculateNormal(float3 positionWS)
{
    float3 dpx = ddx(positionWS);
    float3 dpy = ddy(positionWS) * _ProjectionParams.x;
    return normalize(cross(dpx, dpy));
}


// float3 NormalFromTexture(TEXTURE2D_PARAM(bumpMap, sampler_bumpMap), float2 UV, float offset, float Strength)
// {
//     offset = pow(offset, 3) * 0.1;
//     float2 offsetU = float2(UV.x + offset, UV.y);
//     float2 offsetV = float2(UV.x, UV.y + offset);
//     float normalSample = SAMPLE_TEXTURE2D(bumpMap, sampler_bumpMap, UV);
//     float uSample = SAMPLE_TEXTURE2D(bumpMap, sampler_bumpMap, offsetU);
//     float vSample = SAMPLE_TEXTURE2D(bumpMap, sampler_bumpMap, offsetV);
//     float3 va = float3(1, 0, (uSample - normalSample) * Strength);
//     float3 vb = float3(0, 1, (vSample - normalSample) * Strength);
//     return normalize(cross(va, vb));
// }
float FresnelEffect(float3 Normal, float3 ViewDir, float Power)
{
    return pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
}
float FresnelEffect(float3 Normal, float3 ViewDir, float Power, float Scale)
{
    return Scale + (1 - Scale) * FresnelEffect(Normal, ViewDir, Power);
}



#endif
