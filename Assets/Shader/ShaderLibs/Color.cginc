inline float3 applyHue(float3 aColor, float aHue)
{
    float angle = radians(aHue);
    float3 k = float3(0.57735, 0.57735, 0.57735);
    // float cosAngle = cos(angle);
    float sinAngle, cosAngle;
    sincos(angle, sinAngle, cosAngle);

    return aColor * cosAngle + cross(k, aColor) * sinAngle + k * dot(k, aColor) * (1 - cosAngle);
}

// hsbc = half4(_Hue, _Saturation, _Brightness, _Contrast);
inline float4 applyHSBCEffect(float4 startColor, half4 hsbc)
{
    float hue = 360 * hsbc.r;
    float saturation = hsbc.g * 2;
    float brightness = hsbc.b * 2 - 1;
    float contrast = hsbc.a * 2;
    
    float4 outputColor = startColor;
    outputColor.rgb = applyHue(outputColor.rgb, hue);
    outputColor.rgb = (outputColor.rgb - 0.5f) * contrast + 0.5f;
    outputColor.rgb = outputColor.rgb + brightness;
    float3 intensity = dot(outputColor.rgb, float3(0.39, 0.59, 0.11));
    outputColor.rgb = lerp(intensity, outputColor.rgb, saturation);
    
    return outputColor;
}