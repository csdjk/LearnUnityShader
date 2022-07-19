#ifndef PHOTOSHOP_BLENDMODES_INCLUDED
#define PHOTOSHOP_BLENDMODES_INCLUDED

//
// Ported from https://www.shadertoy.com/view/XdS3RW
//
// Original License:
//
// Creative Commons CC0 1.0 Universal (CC-0)
//
// 25 of the layer blending modes from Photoshop.
//
// The ones I couldn't figure out are from Nvidia's advanced blend equations extension spec -
// http://www.opengl.org/registry/specs/NV/blend_equation_advanced.txt
//
// ~bj.2013
//

// Helpers

const fixed3 l = fixed3(0.3, 0.59, 0.11);

/** @private */
float pinLight(float s, float d)
{
    return (2.0 * s - 1.0 > d) ? 2.0 * s - 1.0 : (s < 0.5 * d) ? 2.0 * s : d;
}

/** @private */
float vividLight(float s, float d)
{
    return (s < 0.5) ? 1.0 - (1.0 - d) / (2.0 * s) : d / (2.0 * (1.0 - s));
}

/** @private */
float hardLight(float s, float d)
{
    return (s < 0.5) ? 2.0 * s * d : 1.0 - 2.0 * (1.0 - s) * (1.0 - d);
}

/** @private */
float softLight(float s, float d)
{
    return (s < 0.5) ? d - (1.0 - 2.0 * s) * d * (1.0 - d)
    : (d < 0.25) ? d + (2.0 * s - 1.0) * d * ((16.0 * d - 12.0) * d + 3.0)
    : d + (2.0 * s - 1.0) * (sqrt(d) - d);
}

/** @private */
float overlay(float s, float d)
{
    return (d < 0.5) ? 2.0 * s * d : 1.0 - 2.0 * (1.0 - s) * (1.0 - d);
}

//    rgb<-->hsv functions by Sam Hocevar
//    http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl
/** @private */
fixed3 rgb2hsv(fixed3 c)
{
    fixed4 K = fixed4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    fixed4 p = lerp(fixed4(c.bg, K.wz), fixed4(c.gb, K.xy), step(c.b, c.g));
    fixed4 q = lerp(fixed4(p.xyw, c.r), fixed4(c.r, p.yzx), step(p.x, c.r));
    
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return fixed3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

/** @private */
fixed3 hsv2rgb(fixed3 c)
{
    fixed4 K = fixed4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    fixed3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

// Public API Blend Modes

fixed3 ColorBurn(fixed3 s, fixed3 d)
{
    return 1.0 - (1.0 - d) / s;
}

fixed3 LinearBurn(fixed3 s, fixed3 d)
{
    return s + d - 1.0;
}

fixed3 DarkerColor(fixed3 s, fixed3 d)
{
    return (s.x + s.y + s.z < d.x + d.y + d.z) ? s : d;
}

fixed3 Lighten(fixed3 s, fixed3 d)
{
    return max(s, d);
}

fixed3 Screen(fixed3 s, fixed3 d)
{
    return s + d - s * d;
}

fixed3 ColorDodge(fixed3 s, fixed3 d)
{
    return d / (1.0 - s);
}

fixed3 LinearDodge(fixed3 s, fixed3 d)
{
    return s + d;
}

fixed3 LighterColor(fixed3 s, fixed3 d)
{
    return (s.x + s.y + s.z > d.x + d.y + d.z) ? s : d;
}

fixed3 Overlay(fixed3 s, fixed3 d)
{
    fixed3 c;
    c.x = overlay(s.x, d.x);
    c.y = overlay(s.y, d.y);
    c.z = overlay(s.z, d.z);
    return c;
}

fixed3 SoftLight(fixed3 s, fixed3 d)
{
    fixed3 c;
    c.x = softLight(s.x, d.x);
    c.y = softLight(s.y, d.y);
    c.z = softLight(s.z, d.z);
    return c;
}

fixed3 HardLight(fixed3 s, fixed3 d)
{
    fixed3 c;
    c.x = hardLight(s.x, d.x);
    c.y = hardLight(s.y, d.y);
    c.z = hardLight(s.z, d.z);
    return c;
}

fixed3 VividLight(fixed3 s, fixed3 d)
{
    fixed3 c;
    c.x = vividLight(s.x, d.x);
    c.y = vividLight(s.y, d.y);
    c.z = vividLight(s.z, d.z);
    return c;
}

fixed3 LinearLight(fixed3 s, fixed3 d)
{
    return 2.0 * s + d - 1.0;
}

fixed3 PinLight(fixed3 s, fixed3 d)
{
    fixed3 c;
    c.x = pinLight(s.x, d.x);
    c.y = pinLight(s.y, d.y);
    c.z = pinLight(s.z, d.z);
    return c;
}

fixed3 HardMix(fixed3 s, fixed3 d)
{
    return floor(s + d);
}

fixed3 Difference(fixed3 s, fixed3 d)
{
    return abs(d - s);
}

fixed3 Exclusion(fixed3 s, fixed3 d)
{
    return s + d - 2.0 * s * d;
}

fixed3 Subtract(fixed3 s, fixed3 d)
{
    return s - d;
}

fixed3 Divide(fixed3 s, fixed3 d)
{
    return s / d;
}

fixed3 Add(fixed3 s, fixed3 d)
{
    return s + d;
}

fixed3 Hue(fixed3 s, fixed3 d)
{
    d = rgb2hsv(d);
    d.x = rgb2hsv(s).x;
    return hsv2rgb(d);
}

fixed3 Color(fixed3 s, fixed3 d)
{
    s = rgb2hsv(s);
    s.z = rgb2hsv(d).z;
    return hsv2rgb(s);
}

fixed3 Saturation(fixed3 s, fixed3 d)
{
    d = rgb2hsv(d);
    d.y = rgb2hsv(s).y;
    return hsv2rgb(d);
}

fixed3 Luminosity(fixed3 s, fixed3 d)
{
    float dLum = dot(d, l);
    float sLum = dot(s, l);
    float lum = sLum - dLum;
    fixed3 c = d + lum;
    float minC = min(min(c.x, c.y), c.z);
    float maxC = max(max(c.x, c.y), c.z);
    if (minC < 0.0) return sLum + ((c - sLum) * sLum) / (sLum - minC);
    else if (maxC > 1.0) return sLum + ((c - sLum) * (1.0 - sLum)) / (maxC - sLum);
    else return c;
}

#endif 
// PHOTOSHOP_BLENDMODES_INCLUDED