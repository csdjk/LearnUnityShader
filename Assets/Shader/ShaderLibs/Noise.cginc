// ================================= Noise 集合 =================================
float random(float2 p)
{
    p = frac(p * 0.3183099 + .1);
    p *= 17.0;
    return frac(p.x * p.y * (p.x + p.y));
}
inline float random2(float2 pos)
{
    return frac(sin(dot(pos, float2(12.9898, 78.233))) * 43758.5453);
}
inline float hash(float p)
{
    p = frac(p * 0.011); p *= p + 7.5; p *= p + p; return frac(p);
}
inline float noise1d(float x)
{
    float i = floor(x); float f = frac(x); float u = f * f * (3.0 - 2.0 * f); return lerp(hash(i), hash(i + 1.0), u);
}

// ==================snoise==================
float3 permute(float3 x)
{
    return fmod(((x * 34.0) + 1.0) * x, 289.0);
}

float snoise(float2 v)
{
    const float4 C = float4(0.211324865405187, 0.366025403784439,
    - 0.577350269189626, 0.024390243902439);
    float2 i = floor(v + dot(v, C.yy));
    float2 x0 = v - i + dot(i, C.xx);
    float2 i1;
    i1 = (x0.x > x0.y) ? float2(1.0, 0.0) : float2(0.0, 1.0);
    float4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;
    i = fmod(i, 289.0);
    float3 p = permute(permute(i.y + float3(0.0, i1.y, 1.0))
    + i.x + float3(0.0, i1.x, 1.0));
    float3 m = lerp(0.5 - float3(dot(x0, x0), dot(x12.xy, x12.xy),
    dot(x12.zw, x12.zw)), 0.0, 0);
    m = m * m ;
    m = m * m ;
    float3 x = 2.0 * frac(p * C.www) - 1.0;
    float3 h = abs(x) - 0.5;
    float3 ox = floor(x + 0.5);
    float3 a0 = x - ox;
    m *= 1.79284291400159 - 0.85373472095314 * (a0 * a0 + h * h);
    float3 g;
    g.x = a0.x * x0.x + h.x * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
}
// ==================end==================



// ================================= Voronoi Noise =================================
inline float2 unity_voronoi_noise_randomVector(float2 UV, float offset)
{
    float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
    UV = frac(sin(mul(UV, m)) * 46839.32);
    return float2(sin(UV.y * + offset) * 0.5 + 0.5, cos(UV.x * offset) * 0.5 + 0.5);
}
float VoronoiNoise(float2 UV, float AngleOffset, float CellDensity, out float Cells)
{
    float Out;
    float2 g = floor(UV * CellDensity);
    float2 f = frac(UV * CellDensity);
    float t = 8.0;
    float3 res = float3(8.0, 0.0, 0.0);
    UNITY_UNROLL
    for (int y = -1; y <= 1; y++)
    {
        UNITY_UNROLL
        for (int x = -1; x <= 1; x++)
        {
            float2 lattice = float2(x, y);
            float2 offset = unity_voronoi_noise_randomVector(lattice + g, AngleOffset);
            float d = distance(lattice + offset, f);
            if (d < res.x)
            {
                res = float3(d, offset.x, offset.y);
                Out = res.x;
                Cells = res.y;
            }
        }
    }
    return Out;
}
// ==================end==================


// ================================= Gradient Noise =================================
float2 unity_gradientNoise_dir(float2 p)
{
    p = p % 289;
    float x = (34 * p.x + 1) * p.x % 289 + p.y;
    x = (34 * x + 1) * x % 289;
    x = frac(x / 41) * 2 - 1;
    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

float unity_gradientNoise(float2 p)
{
    float2 ip = floor(p);
    float2 fp = frac(p);
    float d00 = dot(unity_gradientNoise_dir(ip), fp);
    float d01 = dot(unity_gradientNoise_dir(ip + float2(0, 1)), fp - float2(0, 1));
    float d10 = dot(unity_gradientNoise_dir(ip + float2(1, 0)), fp - float2(1, 0));
    float d11 = dot(unity_gradientNoise_dir(ip + float2(1, 1)), fp - float2(1, 1));
    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
    return lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x);
}

float GradientNoise(float2 UV, float Scale)
{
    return unity_gradientNoise(UV * Scale) + 0.5;
}
// ==================end==================


// ==================SimpleNoise==================
inline float unity_noise_randomValue(float2 uv)
{
    return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
}

inline float unity_noise_interpolate(float a, float b, float t)
{
    return (1.0 - t) * a + (t * b);
}

inline float unity_valueNoise(float2 uv)
{
    float2 i = floor(uv);
    float2 f = frac(uv);
    f = f * f * (3.0 - 2.0 * f);

    uv = abs(frac(uv) - 0.5);
    float2 c0 = i + float2(0.0, 0.0);
    float2 c1 = i + float2(1.0, 0.0);
    float2 c2 = i + float2(0.0, 1.0);
    float2 c3 = i + float2(1.0, 1.0);
    float r0 = unity_noise_randomValue(c0);
    float r1 = unity_noise_randomValue(c1);
    float r2 = unity_noise_randomValue(c2);
    float r3 = unity_noise_randomValue(c3);

    float bottomOfGrid = unity_noise_interpolate(r0, r1, f.x);
    float topOfGrid = unity_noise_interpolate(r2, r3, f.x);
    float t = unity_noise_interpolate(bottomOfGrid, topOfGrid, f.y);
    return t;
}
// Shader Graph
float SimpleNoise(float2 UV, float Scale)
{
    float t = 0.0;

    float freq = pow(2.0, float(0));
    float amp = pow(0.5, float(3 - 0));
    t += unity_valueNoise(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

    freq = pow(2.0, float(1));
    amp = pow(0.5, float(3 - 1));
    t += unity_valueNoise(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

    freq = pow(2.0, float(2));
    amp = pow(0.5, float(3 - 2));
    t += unity_valueNoise(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

    return t;
}


//From  Next Generation Post Processing in Call of Duty: Advanced Warfare [Jimenez 2014]
// http://advances.realtimerendering.com/s2014/index.html
float InterleavedGradientNoise(float2 pixCoord, int frameCount)
{
    const float3 magic = float3(0.06711056f, 0.00583715f, 52.9829189f);
    float2 frameMagicScale = float2(2.083f, 4.867f);
    pixCoord += frameCount * frameMagicScale;
    return frac(magic.z * frac(dot(pixCoord, magic.xy)));
}
// ==================end==============



// ================================= 可无缝平铺任意Noise =================================
float SeamlessNoise(float x, float y, float dx, float dy, float xyOffset)
{
    float s = x;
    float t = y;

    float nx = xyOffset +cos(s * 2.0f * UNITY_PI) * dx / (2.0f * UNITY_PI);
    float ny = xyOffset +cos(t * 2.0f * UNITY_PI) * dy / (2.0f * UNITY_PI);
    float nz = xyOffset +sin(s * 2.0f * UNITY_PI) * dx / (2.0f * UNITY_PI);
    float nw = xyOffset +sin(t * 2.0f * UNITY_PI) * dy / (2.0f * UNITY_PI);

    //  return Noise(nx, ny, nz, nw);
    return random2(float2(nx, ny));
}