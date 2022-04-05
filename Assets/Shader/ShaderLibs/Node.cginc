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