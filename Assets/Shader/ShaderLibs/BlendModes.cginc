#ifndef LCL_BLEND_MODES_INCLUDED
#define LCL_BLEND_MODES_INCLUDED

float4 BlendDarken(float4 a, float4 b)
{
    return float4(min(a.rgb, b.rgb), 1);
}
float4 BlendMultiply(float4 a, float4 b)
{
    return (a * b);
}
float4 BlendColorBurn(float4 a, float4 b)
{
    return (1 - (1 - a) / b);
}
float4 BlendLinearBurn(float4 a, float4 b)
{
    return (a + b - 1);
}
float4 BlendLighten(float4 a, float4 b)
{
    return float4(max(a.rgb, b.rgb), 1);
}
float4 BlendScreen(float4 a, float4 b)
{
    return (1 - (1 - a) * (1 - b));
}

float BlendOverlay(float a, float b)
{
    float v1 = 2.0 * a * b ;
    float v2 = 1.0 - 2.0 * (1.0 - a) * (1.0 - b);
    return lerp(v1, v2, step(0.5, b));
}
float4 BlendOverlay(float4 a, float4 b)
{
    float4 color;
    color.r = BlendOverlay(a.r, b.r);
    color.g = BlendOverlay(a.g, b.g);
    color.b = BlendOverlay(a.b, b.b);
    return color;
}

float4 BlendColorDodge(float4 a, float4 b)
{
    return (a / (1 - b));
}
float4 BlendLinearDodge(float4 a, float4 b)
{
    return (a + b);
}
float4 BlendDifference(float4 a, float4 b)
{
    return (abs(a - b));
}
float4 BlendExclusion(float4 a, float4 b)
{
    return (0.5 - 2 * (a - 0.5) * (b - 0.5));
}

#endif