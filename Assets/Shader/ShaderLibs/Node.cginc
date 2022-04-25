// Create by lichanglong
// https://github.com/csdjk/LearnUnityShader
// 2022.4.5
// 封装的一些功能节点

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