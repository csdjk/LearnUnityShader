// Create by lichanglong
// https://github.com/csdjk/LearnUnityShader
// 2022.4.5
// 封装的一些功能节点

#ifndef NODE_INCLUDED
#define NODE_INCLUDED

float sum(float3 v)
{
    return v.x + v.y + v.z;
}

float2 Flipbook(float2 UV, float Width, float Height, float Tile, float2 Invert)
{
    Tile = fmod(Tile, Width * Height);
    float2 tileCount = float2(1.0, 1.0) / float2(Width, Height);
    float tileY = abs(Invert.y * Height - (floor(Tile * tileCount.x) + Invert.y * 1));
    float tileX = abs(Invert.x * Width - ((Tile - Width * floor(Tile * tileCount.x)) + Invert.x * 1));
    return (UV + float2(tileX, tileY)) * tileCount;
}

// ================================= Flow Map =================================
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

// ================================= 混合贴图 =================================
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

// https://habr.com/en/post/180743/
inline half4 LayerBlend(half high1, half high2, half high3, half high4, half4 control, half weight)
{
    half4 blend;
    blend.r = high1 * control.r;
    blend.g = high2 * control.g;
    blend.b = high3 * control.b;
    blend.a = high4 * control.a;
    half ma = max(blend.r, max(blend.g, max(blend.b, blend.a))) - max(0.001, weight);
    blend = max(blend - ma, 0) * control;
    return blend / (blend.r + blend.g + blend.b + blend.a);
}

//
float3 BlendNormalsLiner(float3 N1, float3 N2)
{
    return normalize(N1 + N2);
}
// 来自ShaderGraph的 BlendNormal节点
float3 BlendNormalWhiteout(float3 N1, float3 N2)
{
    return normalize(float3(N1.rg + N2.rg, N1.b * N2.b));
}

// ref http://blog.selfshadow.com/publications/blending-in-detail/
// ref https://gist.github.com/selfshadow/8048308
// Reoriented Normal Mapping
// Blending when n1 and n2 are already 'unpacked' and normalised
// assume compositing in tangent space
real3 BlendNormalRNM(real3 n1, real3 n2)
{
    real3 t = n1.xyz + real3(0.0, 0.0, 1.0);
    real3 u = n2.xyz * real3(-1.0, -1.0, 1.0);
    real3 r = (t / t.z) * dot(t, u) - u;
    return r;
}
// ================================= 序列帧 =================================
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

// ================================= 平滑值 =================================
// 平滑值(可以用于色阶分层)
inline half SmoothValue(half NdotL, half threshold, half smoothness)
{
    half minValue = saturate(threshold - smoothness);
    half maxValue = saturate(threshold + smoothness);
    return smoothstep(minValue, maxValue, NdotL);
}

// ================================= Fast SSS =================================
// SSS  近似模拟次表面散射
inline float SubsurfaceScattering(float3 V, float3 L, float3 N, float distortion, float power, float scale)
{
    float3 H = (L + N * distortion);
    float I = pow(saturate(dot(V, -H)), power) * scale;
    return I;
}

// ================================= ColorRamp =================================
// 对应Blender color ramp 节点
half3 ColorRamp(float fac, half2 mulbias, half3 color1, half3 color2)
{
    fac = clamp(fac * mulbias.x + mulbias.y, 0.0, 1.0);
    half3 outcol = lerp(color1, color2, fac);
    return outcol;
}

// ================================= 调色处理 =================================
inline float3 ApplyHue(float3 aColor, float aHue)
{
    float angle = radians(aHue);
    float3 k = float3(0.57735, 0.57735, 0.57735);
    float sinAngle, cosAngle;
    sincos(angle, sinAngle, cosAngle);

    return aColor * cosAngle + cross(k, aColor) * sinAngle + k * dot(k, aColor) * (1 - cosAngle);
}
// hsbc = half4(_Hue, _Saturation, _Brightness, _Contrast);
inline float4 ApplyHSBCEffect(float4 startColor, half4 hsbc)
{
    float hue = 360 * hsbc.r;
    float saturation = hsbc.g * 2;
    float brightness = hsbc.b * 2 - 1;
    float contrast = hsbc.a * 2;
    
    float4 outputColor = startColor;
    outputColor.rgb = ApplyHue(outputColor.rgb, hue);
    outputColor.rgb = (outputColor.rgb - 0.5f) * contrast + 0.5f;
    outputColor.rgb = outputColor.rgb + brightness;
    float3 intensity = dot(outputColor.rgb, float3(0.39, 0.59, 0.11));
    outputColor.rgb = lerp(intensity, outputColor.rgb, saturation);
    return outputColor;
}

// ================================= 分层Diffuse =================================
half3 ColorLayer(float3 NdotL, half smoothness, half threshold1, half threshold2, half3 color1, half3 color2, half3 color3)
{
    float NdotL2 = NdotL + 1;
    NdotL2 = SmoothValue(NdotL2, threshold1, smoothness);
    float3 middleC = lerp(color1, color2, NdotL2);

    NdotL = SmoothValue(NdotL, threshold2, smoothness);
    float3 heightC = lerp(color2, color3, NdotL);

    return lerp(middleC, heightC, 1 - step(NdotL, 0));
}

// ================================= 重映射 =================================
// 将值从一个范围重映射到另一个范围
float Remap(float In, float2 InMinMax, float2 OutMinMax)
{
    return OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}

// ================================= 旋转向量(角度) =================================
// From Shader Graph RotateAboutAxis Node
float3 RotateAboutAxis_Degrees(float3 In, float3 Axis, float Rotation)
{
    Rotation = radians(Rotation);
    float s = sin(Rotation);
    float c = cos(Rotation);
    float one_minus_c = 1.0 - c;

    Axis = normalize(Axis);
    float3x3 rot_mat = {
        one_minus_c * Axis.x * Axis.x + c, one_minus_c * Axis.x * Axis.y - Axis.z * s, one_minus_c * Axis.z * Axis.x + Axis.y * s,
        one_minus_c * Axis.x * Axis.y + Axis.z * s, one_minus_c * Axis.y * Axis.y + c, one_minus_c * Axis.y * Axis.z - Axis.x * s,
        one_minus_c * Axis.z * Axis.x - Axis.y * s, one_minus_c * Axis.y * Axis.z + Axis.x * s, one_minus_c * Axis.z * Axis.z + c
    };
    return mul(rot_mat, In);
}

// ================================= 以半径扩散溶解 =================================
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
    
    half cutout = lerp(noise, normalizedDist, dissolveData.z);
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
// ================================ 横向或纵向溶解 ================================
half4 DissolveLinear(
    half4 color, sampler2D NoiseTex, float2 uv,
    half threshold, half noiseIntensity, half edgeLength, half edgeBlur,
    half4 edgeFirstColor, half4 edgeSecondColor)
{
    #if defined(_HORIZONTAL)
        float dist = uv.x;
    #else
        float dist = uv.y;
    #endif

    #if defined(_INVERT)
        dist = 1 - dist;
    #endif
    half noise = tex2D(NoiseTex, uv).r;
    fixed cutout = lerp(dist, noise, noiseIntensity);
    half cutoutThreshold = threshold - cutout;
    clip(cutoutThreshold);

    cutoutThreshold = cutoutThreshold / edgeLength;
    //边缘颜色过渡
    float degree = saturate(cutoutThreshold - edgeBlur);
    half4 edgeColor = lerp(edgeFirstColor, edgeSecondColor, degree) * color;
    half4 finalColor = lerp(edgeColor, color, degree);

    // 软边缘透明过渡
    half a = saturate(color.a);
    finalColor.a = lerp(saturate(cutoutThreshold / edgeBlur) * a, a, degree);

    return finalColor;
}

// ================================= 绘制圆环 =================================
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

// ================================= 随机值(根据坐标) =================================
float ObjectPosRand01()
{
    return frac(UNITY_MATRIX_M[0][3] + UNITY_MATRIX_M[1][3] + UNITY_MATRIX_M[2][3]);
}
// ================================ 获取轴心点，也就是模型中心坐标================================
float3 GetModelPivotPos()
{
    return float3(UNITY_MATRIX_M[0][3], UNITY_MATRIX_M[1][3] + 0.25, UNITY_MATRIX_M[2][3]);
}
float3 GetModelScale()
{
    return float3(UNITY_MATRIX_M[0][0], UNITY_MATRIX_M[1][1] + 0.25, UNITY_MATRIX_M[2][2]);
}
// ================================ 获取Camera Forward 方向 ================================
float3 GetCameraForwardDir()
{
    return normalize(UNITY_MATRIX_V[2].xyz);
}
// float3 GetModelCenterWorldPos()
// {
//     return float3(UNITY_MATRIX_M[0].w, UNITY_MATRIX_M[1].w, UNITY_MATRIX_M[2].w);
// }
// ================================= 根据世界坐标计算法线 =================================
// ddx ddy计算法线
float3 CalculateNormal(float3 positionWS)
{
    float3 dpx = ddx(positionWS);
    float3 dpy = ddy(positionWS) * _ProjectionParams.x;
    return normalize(cross(dpx, dpy));
}
// ================================= 根据深度重建世界坐标 =================================
float3 CalculateWorldPosition(float2 screen_uv, float eyeDepth)
{
    // NDC
    float4 ndcPos = float4(float3(screen_uv, eyeDepth) * 2 - 1, 1);
    // 裁剪空间
    float4 clipPos = mul(unity_CameraInvProjection, ndcPos);
    clipPos = float4(((clipPos.xyz / clipPos.w) * float3(1, 1, -1)), 1.0);
    return mul(unity_CameraToWorld, clipPos);
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

// ================================= 菲涅尔效果 =================================
float FresnelEffect(float3 Normal, float3 ViewDir, float Power)
{
    return pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
}
float FresnelEffect(float3 Normal, float3 ViewDir, float Power, float Scale)
{
    return Scale + (1 - Scale) * FresnelEffect(Normal, ViewDir, Power);
}

// ================================= 风格化菲涅尔 =================================
inline half3 StylizedFresnel(half NdotV, half rimWidth, float rimIntensity, half smoothness, half3 rimColor)
{
    half revertNdotV = 1 - NdotV;
    float threshold = 1 - rimWidth;
    float3 rim = smoothstep(threshold - smoothness, threshold + smoothness, revertNdotV) * rimIntensity;
    return rim * rimColor;
}

// ================================= 色调映射 =================================
half3 ACESToneMapping(half3 color, float adapted_lum)
{
    const float A = 2.51f;
    const float B = 0.03f;
    const float C = 2.43f;
    const float D = 0.59f;
    const float E = 0.14f;

    color *= adapted_lum;
    return saturate((color * (A * color + B)) / (color * (C * color + D) + E));
}
// 移动端版本的色调映射(曲线非常接近ACES)
// todo:垃圾
half3 MobileACESToneMapping(half3 color)
{
    return color / (color + 0.155) * 1.019;
}
// ================================= 压暗对比色 =================================
// todo 测试...
float ToneMaping(float3 color)
{
    return sqrt(max(exp2(log2(max(color, 0)) * 2.2), 0));
}

// ================================= 2D Box 遮罩 =================================
half UniversalMask2D(float2 uv, float2 center, float intensity, float roundness, float smoothness)
{
    float2 d = abs(uv - center) * intensity;
    d = pow(saturate(d), roundness);
    float dist = length(d);
    float vfactor = pow(saturate(1 - dist * dist), smoothness);
    return vfactor;
}
half MaskTriangle(half2 uv, half smoothness)
{
    // half t1 = uv.x * - 0.5 + 1;
    half t1 = uv.x * - 0.3 + 0.8;
    half value = smoothstep(t1 + smoothness, t1, uv.y);
    // half t2 = uv.x * 0.5;
    half t2 = uv.x * 0.3 + 0.2;
    half value2 = smoothstep(t2, t2 - smoothness, uv.y);
    return value - value2;
}
// ================================= 3D Box 遮罩 =================================
half BoxMask(float3 positionWS, float3 center, float3 size, float falloff)
{
    return distance(max(abs(positionWS - center) - (size * 0.5), 0), 0) / falloff;
}
// ================================= 3D Sphere 遮罩=================================
half SphereMask(float3 positionWS, float3 center, float3 radius, float hardness)
{
    float3 halfv = (positionWS - center) / radius * 2;
    return pow(saturate(dot(halfv, halfv)), hardness);
}

// ================================ 转换亮度值 ================================
float Luminance(float3 rgb)
{
    return dot(rgb, float3(0.2126729, 0.7151522, 0.0721750));
}
// ================================= 三维映射 =================================
half4 TriplanarMapping(sampler2D textures, float3 positionWS, half3 N, float tiling, float blendSmoothness)
{
    half2 yUV = positionWS.xz * tiling;
    half2 xUV = positionWS.zy * tiling;
    half2 zUV = positionWS.xy * tiling;

    half3 yDiff = tex2D(textures, yUV);
    half3 xDiff = tex2D(textures, xUV);
    half3 zDiff = tex2D(textures, zUV);

    half3 blendWeights = pow(abs(N), blendSmoothness);
    blendWeights = blendWeights / (blendWeights.x + blendWeights.y + blendWeights.z);

    fixed4 col = fixed4(xDiff * blendWeights.x + yDiff * blendWeights.y + zDiff * blendWeights.z, 1.0);
    return col;
}
// ================================ 没有重复感的四方连续纹理 ================================
// https://iquilezles.org/articles/texturerepetition/
float4 TexNoTileTech(sampler2D baseTex, sampler2D noiseTex, float2 uv)
{
    // sample variation pattern
    float k = tex2D(noiseTex, 0.005 * uv).x;
    // compute index
    float index = k * 8.0;
    float i = floor(index);
    float f = frac(index);

    // offsets for the different virtual patterns
    float2 offa = sin(float2(3.0, 7.0) * (i + 0.0)); // can replace with any other hash
    float2 offb = sin(float2(3.0, 7.0) * (i + 1.0)); // can replace with any other hash

    // compute derivatives for mip-mapping
    float2 dx = ddx(uv);
    float2 dy = ddy(uv);

    // sample the two closest virtual patterns
    float4 cola = tex2Dgrad(baseTex, uv + offa, dx, dy);
    float4 colb = tex2Dgrad(baseTex, uv + offb, dx, dy);

    // interpolate between the two virtual patterns
    return lerp(cola, colb, smoothstep(0.2, 0.8, f - 0.1 * sum(cola - colb)));
}


// ================================= InteriorMapping CubeMap =================================
// From UE InteriorCubemap Node
float3 InteriorCubemap(float2 uv, float2 tilling, float3 viewTS)
{
    uv = uv * float2(1, -1);
    uv *= tilling;
    uv = frac(uv) * float2(2, -2) - float2(1, -1);
    float3 uvw = float3(uv, -1);

    float3 view = viewTS * float3(-1, -1, 1);
    float3 viewInverse = 1 / view;
    
    float3 fractor = viewInverse * uvw;

    fractor = abs(viewInverse) - fractor;
    float3 minview = min(min(fractor.x, fractor.y), fractor.z) * view;
    minview = minview + uvw;

    return minview.zxy;
}
// ================================= InteriorMapping 2D =================================
//bgolus's original source code: https://forum.unity.com/threads/interior-mapping.424676/#post-2751518
float2 ConvertOriginalRawUVToInteriorUV(float2 originalRawUV, float3 viewDirTangentSpace, float roomMaxDepth01Define)
{
    //remap [0,1] to [+inf,0]
    //->if input roomMaxDepth01Define = 0    -> depthScale = +inf   (0 volume room)
    //->if input roomMaxDepth01Define = 0.5  -> depthScale = 1
    //->if input roomMaxDepth01Define = 1    -> depthScale = 0              (inf depth room)
    float depthScale = rcp(roomMaxDepth01Define) - 1.0;

    //normalized box space is a space where room's min max corner = (-1,-1,-1) & (+1,+1,+1)
    //apply simple scale & translate to tangent space = transform tangent space to normalized box space

    //now prepare ray box intersection test's input data in normalized box space
    float3 viewRayStartPosBoxSpace = float3(originalRawUV * 2 - 1, -1); //normalized box space's ray start pos is on trinagle surface, where z = -1
    float3 viewRayDirBoxSpace = viewDirTangentSpace * float3(1, 1, -depthScale);//transform input ray dir from tangent space to normalized box space

    //do ray & axis aligned box intersection test in normalized box space (all input transformed to normalized box space)
    //intersection test function used = https://www.iquilezles.org/www/articles/intersectors/intersectors.htm
    //============================================================================
    float3 viewRayDirBoxSpaceRcp = rcp(viewRayDirBoxSpace);

    //hitRayLengthForSeperatedAxis means normalized box space depth hit per x/y/z plane seperated
    //(we dont care about near hit result here, we only want far hit result)
    float3 hitRayLengthForSeperatedAxis = abs(viewRayDirBoxSpaceRcp) - viewRayStartPosBoxSpace * viewRayDirBoxSpaceRcp;
    //shortestHitRayLength = normalized box space real hit ray length
    float shortestHitRayLength = min(min(hitRayLengthForSeperatedAxis.x, hitRayLengthForSeperatedAxis.y), hitRayLengthForSeperatedAxis.z);
    //normalized box Space real hit pos = rayOrigin + t * rayDir.
    float3 hitPosBoxSpace = viewRayStartPosBoxSpace + shortestHitRayLength * viewRayDirBoxSpace;
    //============================================================================

    // remap from [-1,1] to [0,1] room depth
    float interp = hitPosBoxSpace.z * 0.5 + 0.5;

    // account for perspective in "room" textures
    // assumes camera with an fov of 53.13 degrees (atan(0.5))
    //hard to explain, visual result = transform nonlinear depth back to linear
    float realZ = saturate(interp) / depthScale + 1;
    interp = 1.0 - (1.0 / realZ);
    interp *= depthScale + 1.0;

    //linear iterpolate from wall back to near
    float2 interiorUV = hitPosBoxSpace.xy * lerp(1.0, 1 - roomMaxDepth01Define, interp);

    //convert back to valid 0~1 uv, ready for user's tex2D() call
    interiorUV = interiorUV * 0.5 + 0.5;
    return interiorUV;
}



// ================================= 各向异性 Kajiya-Kay =================================
half3 ShiftTangent(half3 T, half3 N, half shift)
{
    return normalize(T + shift * N);
}
half AnisotropyKajiyaKay(half3 T, half3 V, half3 L, half specPower)
{
    half3 H = normalize(V + L);
    half HdotT = dot(T, H);
    half sinTH = sqrt(1 - HdotT * HdotT);
    half dirAtten = smoothstep(-1, 0, HdotT);
    return dirAtten * saturate(pow(sinTH, specPower));
}


// ================================= 头发高光(双层各向异性) =================================
half3 HairStrandSpecular(half3 N, half3 T, half3 V, half3 L, float anisoShiftNoise,
half4 specColor1, half3 specData1, half4 specColor2, half3 specData2)
{
    half power1 = specData1.r;
    half shift1 = specData1.g;
    half strength1 = specData1.b;

    half power2 = specData2.r;
    half shift2 = specData2.g;
    half strength2 = specData2.b;

    half3 t1 = ShiftTangent(T, N, shift1 + anisoShiftNoise * strength1);
    half3 t2 = ShiftTangent(T, N, shift2 + anisoShiftNoise * strength2);

    half3 specular = 0;
    specular += specColor1.rgb * specColor1.a * AnisotropyKajiyaKay(t1, V, L, power1);
    specular += specColor2.rbg * specColor2.a * AnisotropyKajiyaKay(t2, V, L, power2);
    
    // 衰减
    half NdotV = saturate(dot(N, V));
    half NdotL = saturate(dot(N, L)) * 0.5 + 0.5;
    half anisoAtten = saturate(NdotL / NdotV);

    return specular * anisoAtten;
}



// // =================================  =================================
// half3 HairAnisoSpecular(float3 T, float3 N, half H, half TdotH, half NdotH, half shift, half anisoShiftNoise, half noiseStrength, half specSmoothness, half anisoAtten, half3 specColor)
// {
//     half3 B = ShiftTangent(T, N, shift + anisoShiftNoise * noiseStrength);
//     half BdotH = dot(B, H);
//     BdotH = BdotH / specSmoothness;
//     half3 spec_term = exp( - (TdotH * TdotH + BdotH * BdotH) / (1.0 + NdotH));
//     return spec_term * anisoAtten * specColor;
// }


// half3 HairSpecular(half3 N, half3 L, half3 V, half3 T, half3 B, float anisoShiftNoise,
// half3 specColor1, half3 specData1, half3 specColor2, half3 specData2)
// {
//     float3 H = normalize(L + V);
//     half NdotL = saturate(dot(N, L)) * 0.5 + 0.5;
//     half NdotV = saturate(dot(N, V));
//     half TdotH = dot(T, H);
//     half BdotH = dot(B, H);
//     half NdotH = dot(N, H);

//     half smoothness1 = specData1.r;
//     half shift1 = specData1.g;
//     half strength1 = specData1.b;

//     half smoothness2 = specData2.r;
//     half shift2 = specData2.g;
//     half strength2 = specData2.b;

//     half anisoAtten = saturate(sqrt(max(0, NdotL / NdotV)));

//     half3 spec1 = HairAnisoSpecular(T, N, H, TdotH, NdotH, shift1, anisoShiftNoise, strength1, smoothness1, anisoAtten, specColor1);
//     half3 spec2 = HairAnisoSpecular(T, N, H, TdotH, NdotH, shift2, anisoShiftNoise, strength2, smoothness2, anisoAtten, specColor2);

//     return spec1 ;
// }


// ================================= 粗糙度转换Mipmap Level =================================
inline half PerceptualRoughnessToMipmapLevel(half perceptualRoughness, int maxMipLevel)
{
    perceptualRoughness = perceptualRoughness * (1.7 - 0.7 * perceptualRoughness);
    return perceptualRoughness * maxMipLevel;
}
inline half PerceptualRoughnessToMipmapLevel(half perceptualRoughness)
{
    return PerceptualRoughnessToMipmapLevel(perceptualRoughness, 6);
}








// ================================= 【Transform Coordinates 】 =================================

// ================================= 局部转切线(向量) =================================
float3 ObjectToTangentDir(float3 inputDirOS, float3 normalOS, float4 tangentOS)
{
    float tangentSign = tangentOS.w * unity_WorldTransformParams.w;
    float3 bitangentOS = cross(normalOS, tangentOS.xyz) * tangentSign;
    return float3(
        dot(inputDirOS, tangentOS.xyz),
        dot(inputDirOS, bitangentOS),
        dot(inputDirOS, normalOS)
    );
}
#endif
