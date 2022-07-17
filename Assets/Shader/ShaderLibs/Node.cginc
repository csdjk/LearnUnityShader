// Create by lichanglong
// https://github.com/csdjk/LearnUnityShader
// 2022.4.5
// 封装的一些功能节点

#ifndef NODE_INCLUDED
#define NODE_INCLUDED


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

// 平滑值
inline half SmoothValue(half NdotL, half threshold, half smoothness)
{
    half minValue = saturate(threshold - smoothness * 0.5);
    half maxValue = saturate(threshold + smoothness * 0.5);
    return smoothstep(minValue, maxValue, NdotL);
}

// SSS
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


#endif
