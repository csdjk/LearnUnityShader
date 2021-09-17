<!--
 * @Descripttion: 
 * @Author: lichanglong
 * @Date: 2021-09-09 13:03:49
 * @FilePath: \LearnUnityShader\Assets\Scenes\SubsurfaceScattering\FastSSS.md
-->


# 前言

感觉好久没更新博客了，这段时间决定重新把写博客的习惯捡起来！前段时间学习研究了一下**次表面散射**相关的知识，这次我们就在Unity中简单实现一下该效果。如果哪里有错误的地方，希望大家能够指出，多多讨论。

## 次表面散射（Subsurface scattering）
次表面散射是光在传播时的一种现象，表现为光在穿过透明物体表面后，与材料之间发生交互作用而导致光被散射开来，光路也在其他的位置穿出物体。光一般会穿透物体的表面，在物体内部在不同的角度被反射若干次，最终穿出物体。次表面散射在三维计算机图形中十分重要，可用来渲染大理石、皮肤、树叶、蜡、牛奶等多种不同材料。

例如：

![](https://i.loli.net/2021/09/09/hAvjIU9e4MEzuxZ.png)
![](https://pic3.zhimg.com/80/7185e21a555e346d9bf15690230082be_720w.png)
![](https://i.loli.net/2021/09/09/dt8r9NTsEW7ko5X.png)

当然为了能在游戏中实时渲染，我们只能近似模拟次表面散射现象。本篇文章实现原理主要参考了这篇文章
[Fast Subsurface Scattering](https://www.alanzucconi.com/2017/08/30/fast-subsurface-scattering-2/)

话不多说，下面我们一步一步的来实现伪次表面散射，在本篇文章中只贴出关键的Shader代码，基础的Shader代码就不再一一解释了。

# 实现

在自然界中，光线的传播一般包含三种情况，即：
1. 反射: 入射光与反射光在表面的同一侧，且入射点与反射点相同
![quicker_bef181a7-cba1-45bb-880d-9e5dc4ca49c1.png](https://i.loli.net/2021/09/09/c2apw4sy7qizCvB.png)

2. 次表面散射:入射光与反射光在表面的同一侧，且入射点与反射点不同
![quicker_6174a912-9741-43ac-a6c1-b794d734eb77.png](https://i.loli.net/2021/09/09/UpHnYVZMLzBC8To.png)

3. 透射:入射光与反射光在表面的不同侧，即光线投过了物体
![quicker_39b1ccd2-4b72-4fb6-957b-be0c08098f9c.png](https://i.loli.net/2021/09/09/6c2kQeMmpJSKFWB.png)


为了模拟这种背面透光的效果，我们可以把法线向光源方向偏移一定程度后，然后取反，再去和视线方向做运算。

![](https://www.alanzucconi.com/wp-content/uploads/2017/08/translucent_08.png)

模拟背光反射率的方程如下：

![](https://www.alanzucconi.com/wp-content/ql-cache/quicklatex.com-577e07757a85aaf42b85235abb657979_l3.svg)

- L 光源方向，
- V 视图方向，
- N 法线方向。

公式转换为Shader代码：
```c
    //fragment
    float3 H = L + N * distortion;
    float sss = pow(saturate(dot(V, -H)), power) * scale;
    return sss;
```

在平行光下的渲染效果如图：
![backSss](https://i.loli.net/2021/09/09/jzcNhZ9uOeICQHT.png)

## 环绕照明（Warp Lighting）

其实还有一种简单模拟次表面的技巧：环绕照明（Warp Lighting），正常情况下，当表面的法线对于光源方向垂直的时候，Lambert漫反射提供的照明度是0。而环绕光照修改漫反射函数，使得光照环绕在物体的周围，越过那些正常时会变黑变暗的点。这减少了漫反射光照明的对比度，从而减少了环境光和所要求的填充光的量。

下图和代码片段显示了如何将漫反射光照函数进行改造，使其包含环绕效果。

其中，wrap变量为环绕值，是一个范围为0到1之间的浮点数，用于控制光照环绕物体周围距离。
![](https://pic1.zhimg.com/80/v2-5b090360792e221b034be0c913e5520c_720w.jpg)

代码：
```c
    float diffuse = max(0, dot(L, N));
    float wrap_diffuse = max(0, (dot(L, N) + _WrapValue) / (1 + _WrapValue));
    return wrap_diffuse;
```

渲染效果：
![wrap_diffuse](https://i.loli.net/2021/09/09/n4vPAsCxNGrye2X.png)


然后，我们把前两种合成看看效果

代码：
```c
    float3 H = L + N * distortion;
    float sss = pow(saturate(dot(V, -H)), power) * scale;

    float diffuse = max(0, dot(L, N));
    float wrap_diffuse = max(0, (dot(L, N) + _WrapValue) / (1 + _WrapValue));
    
    return sss + wrap_diffuse;
```

![wrap_diffuse+sss](https://i.loli.net/2021/09/10/OWKC1IUfmBNjDAg.png)
![1.gif](https://i.loli.net/2021/09/10/ETWRsgzca6hqUmS.gif)
现在看来是不是有点散射那味了


叠加上自定义的颜色再看看效果如何：

![quicker_46ea681c-3e8b-4ba5-8faa-66ebc0c44e8e.png](https://i.loli.net/2021/09/10/IP7ZpKhfvamHYdo.png)


现在还只是考虑了平行光，下面我们把点光源也考虑进去看看效果如何

说到关于点光源相关的计算，那么一般都是在 ForwardAdd 的Pass 中去计算，但是这样会造成每多一盏灯，DrawCall就会翻一倍，所以这里我就直接在 ForwardBase 里面计算点光源了。

在Unity中 有一个内置函数用来计算点光源 `Shade4PointLights`,

使用如下：
```c
float3 pointColor = Shade4PointLights (
unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
unity_4LightAtten0, i.worldPos, -N);

return fixed4(pointColor,1);
```

然后我去看看该方法的源码，分析一下大概意思, 源码可以在 UnityCG.cginc 文件中找到：
```c
// Used in ForwardBase pass: Calculates diffuse lighting from 4 point lights, with data packed in a special way.
float3 Shade4PointLights (
    float4 lightPosX, float4 lightPosY, float4 lightPosZ,
    float3 lightColor0, float3 lightColor1, float3 lightColor2, float3 lightColor3,
    float4 lightAttenSq,
    float3 pos, float3 normal)
{
    // to light vectors
    float4 toLightX = lightPosX - pos.x;
    float4 toLightY = lightPosY - pos.y;
    float4 toLightZ = lightPosZ - pos.z;
    // squared lengths
    float4 lengthSq = 0;
    lengthSq += toLightX * toLightX;
    lengthSq += toLightY * toLightY;
    lengthSq += toLightZ * toLightZ;
    // don't produce NaNs if some vertex position overlaps with the light
    lengthSq = max(lengthSq, 0.000001);

    // NdotL
    float4 ndotl = 0;
    ndotl += toLightX * normal.x;
    ndotl += toLightY * normal.y;
    ndotl += toLightZ * normal.z;
    // correct NdotL
    float4 corr = rsqrt(lengthSq);
    ndotl = max (float4(0,0,0,0), ndotl * corr);
    // attenuation
    float4 atten = 1.0 / (1.0 + lengthSq * lightAttenSq);
    float4 diff = ndotl * atten;
    // final color
    float3 col = 0;
    col += lightColor0 * diff.x;
    col += lightColor1 * diff.y;
    col += lightColor2 * diff.z;
    col += lightColor3 * diff.w;
    return col;
}
```

具体分析可以参考这篇文章：[Unity3D ShaderLab 之 Shade4PointLights 解读](https://zhuanlan.zhihu.com/p/27842876)

以上代码可以很明显的发现，引擎会把四盏点光源的x, y, z坐标，分别存储到lightPosX, lightPosY, lightPosZ中，
换句话说：  
light0 的位置是 float3(lightPosX[0], lightPosY[0], lightPosZ[0])    
light1 的位置是 float3(lightPosX[1], lightPosY[1], lightPosZ[1])    
light2 的位置是 float3(lightPosX[2], lightPosY[2], lightPosZ[2])    
light3 的位置是 float3(lightPosX[3], lightPosY[3], lightPosZ[3])    

unity_LightColor数组就是点光源颜色。

有了以上信息就好办了，我们来魔改一下，改成我们需要的次表面散射。

代码如下：

```c
 // 计算SSS
inline float SubsurfaceScattering (float3 V, float3 L, float3 N, float distortion,float power,float scale)
{
    // float3 H = normalize(L + N * distortion);
    float3 H = L + N * distortion;
    float I = pow(saturate(dot(V, -H)), power) * scale;
    return I;
}

// 计算点光源SSS（参考UnityCG.cginc 中的Shade4PointLights）
float3 CalculatePointLightSSS (
float4 lightPosX, float4 lightPosY, float4 lightPosZ,
float3 lightColor0, float3 lightColor1, float3 lightColor2, float3 lightColor3,
float4 lightAttenSq,float3 pos,float3 N,float3 V)
{
    // to light vectors
    float4 toLightX = lightPosX - pos.x;
    float4 toLightY = lightPosY - pos.y;
    float4 toLightZ = lightPosZ - pos.z;
    // squared lengths
    float4 lengthSq = 0;
    lengthSq += toLightX * toLightX;
    lengthSq += toLightY * toLightY;
    lengthSq += toLightZ * toLightZ;
    // don't produce NaNs if some vertex position overlaps with the light
    lengthSq = max(lengthSq, 0.000001);

    // NdotL
    float4 ndotl = 0;
    ndotl += toLightX * N.x;
    ndotl += toLightY * N.y;
    ndotl += toLightZ * N.z;
    // correct NdotL
    float4 corr = rsqrt(lengthSq);
    ndotl = max (float4(0,0,0,0), ndotl * corr);
    
    float4 atten = 1.0 / (1.0 + lengthSq * lightAttenSq);
    // float4 diff = ndotl * atten;
    
    float3 pointLightDir0 = normalize(float3(toLightX[0],toLightY[0],toLightZ[0]));
    float pointSSS0 = SubsurfaceScattering(V,pointLightDir0,N,_DistortionBack,_PowerBack,_ScaleBack);

    float3 pointLightDir1 = normalize(float3(toLightX[1],toLightY[1],toLightZ[1]));
    float pointSSS1 = SubsurfaceScattering(V,pointLightDir1,N,_DistortionBack,_PowerBack,_ScaleBack);

    float3 pointLightDir2 = normalize(float3(toLightX[2],toLightY[2],toLightZ[2]));
    float pointSSS2 = SubsurfaceScattering(V,pointLightDir2,N,_DistortionBack,_PowerBack,_ScaleBack);

    float3 pointLightDir3 = normalize(float3(toLightX[3],toLightY[3],toLightZ[3]));
    float pointSSS3 = SubsurfaceScattering(V,pointLightDir3,N,_DistortionBack,_PowerBack,_ScaleBack);

    // final color
    float3 col = 0;
    col += lightColor0 * atten.x * (pointSSS0+ndotl.x);
    col += lightColor1 * atten.y * (pointSSS1+ndotl.y);
    col += lightColor2 * atten.z * (pointSSS2+ndotl.z);
    col += lightColor3 * atten.w * (pointSSS3+ndotl.w);
    return col;
}


// farg

float3 pointColor = CalculatePointLightSSS(unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
    unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
    unity_4LightAtten0,i.worldPos,N,V);

return fixed4(pointColor,1);
```

然后我们在场景中放3盏点光源看看效果如何：

![](https://s3.bmp.ovh/imgs/2021/09/be40c8a921837efa.png)

叠加上之前计算的平行光：    
![](https://i.bmp.ovh/imgs/2021/09/de95dcd853761181.png)

最后我们把 Wrap-Diffuse、Specular-BlinnPhong 等效果叠加上去看看整体效果。
当然，散射颜色也可以定义一个变量来控制，方便美术调整效果。

在有平行光、无点光源的情况下的背面和正面：  
![](https://s3.bmp.ovh/imgs/2021/09/e1b9742197ad9da5.png)![](https://s3.bmp.ovh/imgs/2021/09/52891c5b3ebb6185.png)

在无平行光、有点光源的情况下：  
![](https://s3.bmp.ovh/imgs/2021/09/b98ba045bd1b5b55.png)

在有平行光、有点光源的情况下（颜色太杂乱了...）：  
![sss4.png](https://i.loli.net/2021/09/11/Ko6IJQnzLi2APeR.png)

## 厚度图
吸收（Absorption）是模拟半透明材质的最重要特性之一。
光线在物质中传播得越远，它被散射和吸收得就越厉害。
为了模拟这种效果，我们需要测量光在物质中传播的距离，并相应地对其进行衰减。

可以在下图中看到具有相同入射角的三种不同光线,穿过物体的长度却截然不同。

![quicker.png](https://i.loli.net/2021/09/11/Zq1K6BUcwgnYtPh.png)

这里我们就采用外部局部厚度图来模拟该现象，当然，该方法在物理上来说并不准确，但是可以比较简单快速的模拟出这种效果。

烘焙厚度图可以用Substance Painter
或者用Unity的插件：Mesh Materializer把厚度信息存储在顶点色里面。

厚度图输出来是这样（这里换了个简单的模型，之前那个模型厚度烘焙有点问题-.-）：   
![sssTt.png](https://i.loli.net/2021/09/11/3lcY7ebkfpquZrO.png)

最后用厚度值乘上次表面散射值，就能得到最终效果：
![sssT2.png](https://i.loli.net/2021/09/11/VJUyIqxR2W746Yj.png)
![sssT.png](https://i.loli.net/2021/09/11/F7uJHKSCXMUdPNE.png)


最后奉上完整代码：
```c
/*
* @Descripttion: 次表面散射
* @Author: lichanglong
* @Date: 2021-08-20 18:21:10
 * @FilePath: \LearnUnityShader\Assets\Scenes\SubsurfaceScattering\FastSSSTutorial.shader
*/
Shader "lcl/SubsurfaceScattering/FastSSSTutorial" {
    Properties{
        _MainTex ("Texture", 2D) = "white" {}
        _BaseColor("Base Color",Color) = (1,1,1,1)
        _Specular("Specular Color",Color) = (1,1,1,1)
        [PowerSlider()]_Gloss("Gloss",Range(1,200)) = 10
        
        [Main(sss,_,3)] _group ("SubsurfaceScattering", float) = 1
        [Tex(sss)]_ThicknessTex ("Thickness Tex", 2D) = "white" {}
        [Sub(sss)]_ThicknessPower ("ThicknessPower", Range(0,10)) = 1

        [Sub(sss)][HDR]_ScatterColor ("Scatter Color", Color) = (1,1,1,1)
        [Sub(sss)]_WrapValue ("WrapValue", Range(0,1)) = 0.0
        [Title(sss, Back SSS Factor)]
        [Sub(sss)]_DistortionBack ("Back Distortion", Range(0,1)) = 1.0
        [Sub(sss)]_PowerBack ("Back Power", Range(0,10)) = 1.0
        [Sub(sss)]_ScaleBack ("Back Scale", Range(0,1)) = 1.0

        // 是否开启计算点光源
        [SubToggle(sss, __)] _CALCULATE_POINTLIGHT ("Calculate Point Light", float) = 0
    }
    SubShader {
        Pass{
            Tags { "LightMode"="Forwardbase" }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            // #pragma enable_d3d11_debug_symbols
            #pragma multi_compile _ _CALCULATE_POINTLIGHT_ON 

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            sampler2D _MainTex,_ThicknessTex;
            float4 _MainTex_ST;
            fixed4 _BaseColor;
            half _Gloss;
            float3 _Specular;
            
            float4 _ScatterColor;
            float _DistortionBack;
            float _PowerBack;
            float _ScaleBack;
            
            float _ThicknessPower;
            float _WrapValue;
            float _ScatterWidth;

            // float  _RimPower;
            // float _RimIntensity;
            struct a2v {
                float4 vertex : POSITION;
                float3 normal: NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f{
                float4 position:SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalDir: TEXCOORD1;
                float3 worldPos: TEXCOORD2;
                float3 viewDir: TEXCOORD3;
                float3 lightDir: TEXCOORD4;
            };

            v2f vert(a2v v){
                v2f o;
                o.position = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = mul (unity_ObjectToWorld, v.vertex);
                o.normalDir = UnityObjectToWorldNormal (v.normal);
                o.viewDir = UnityWorldSpaceViewDir(o.worldPos);
                o.lightDir = UnityWorldSpaceLightDir(o.worldPos);
                return o;
            };
            
            // 计算SSS
            inline float SubsurfaceScattering (float3 V, float3 L, float3 N, float distortion,float power,float scale)
            {
                // float3 H = normalize(L + N * distortion);
                float3 H = L + N * distortion;
                float I = pow(saturate(dot(V, -H)), power) * scale;
                return I;
            }
            
            // 计算点光源SSS（参考UnityCG.cginc 中的Shade4PointLights）
            float3 CalculatePointLightSSS (
            float4 lightPosX, float4 lightPosY, float4 lightPosZ,
            float3 lightColor0, float3 lightColor1, float3 lightColor2, float3 lightColor3,
            float4 lightAttenSq,float3 pos,float3 N,float3 V)
            {
                // to light vectors
                float4 toLightX = lightPosX - pos.x;
                float4 toLightY = lightPosY - pos.y;
                float4 toLightZ = lightPosZ - pos.z;
                // squared lengths
                float4 lengthSq = 0;
                lengthSq += toLightX * toLightX;
                lengthSq += toLightY * toLightY;
                lengthSq += toLightZ * toLightZ;
                // don't produce NaNs if some vertex position overlaps with the light
                lengthSq = max(lengthSq, 0.000001);

                // NdotL
                float4 ndotl = 0;
                ndotl += toLightX * N.x;
                ndotl += toLightY * N.y;
                ndotl += toLightZ * N.z;
                // correct NdotL
                float4 corr = rsqrt(lengthSq);
                ndotl = max (float4(0,0,0,0), ndotl * corr);
                
                float4 atten = 1.0 / (1.0 + lengthSq * lightAttenSq);
                float4 diff = ndotl * atten;
                
                float3 pointLightDir0 = normalize(float3(toLightX[0],toLightY[0],toLightZ[0]));
                float pointSSS0 = SubsurfaceScattering(V,pointLightDir0,N,_DistortionBack,_PowerBack,_ScaleBack)*3;

                float3 pointLightDir1 = normalize(float3(toLightX[1],toLightY[1],toLightZ[1]));
                float pointSSS1 = SubsurfaceScattering(V,pointLightDir1,N,_DistortionBack,_PowerBack,_ScaleBack)*3;

                float3 pointLightDir2 = normalize(float3(toLightX[2],toLightY[2],toLightZ[2]));
                float pointSSS2 = SubsurfaceScattering(V,pointLightDir2,N,_DistortionBack,_PowerBack,_ScaleBack)*3;

                float3 pointLightDir3 = normalize(float3(toLightX[3],toLightY[3],toLightZ[3]));
                float pointSSS3 = SubsurfaceScattering(V,pointLightDir3,N,_DistortionBack,_PowerBack,_ScaleBack)*3;

                // final color
                float3 col = 0;
                // col += lightColor0 * diff.x;
                // col += lightColor1 * diff.y;
                // col += lightColor2 * diff.z;
                // col += lightColor3 * diff.w;
                col += lightColor0 * atten.x * (pointSSS0+ndotl.x);
                col += lightColor1 * atten.y * (pointSSS1+ndotl.y);
                col += lightColor2 * atten.z * (pointSSS2+ndotl.z);
                col += lightColor3 * atten.w * (pointSSS3+ndotl.w);
                
                return col;
            }

            fixed4 frag(v2f i): SV_TARGET{
                fixed4 col = tex2D(_MainTex, i.uv) * _BaseColor;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                fixed3 lightColor = _LightColor0.rgb;
                float3 N = normalize(i.normalDir);
                float3 V = normalize(i.viewDir);
                float3 L = normalize(i.lightDir);
                float NdotL = dot(N, L);
                float3 H = normalize(L + V);
                float NdotH = dot(N, H);
                float NdotV = dot(N, V);

                float thickness = tex2D(_ThicknessTex, i.uv).r * _ThicknessPower;
                // -----------------------------SSS-----------------------------
                // 快速模拟次表面散射
                float3 sss = SubsurfaceScattering(V,L,N,_DistortionBack,_PowerBack,_ScaleBack) * lightColor * _ScatterColor * thickness;

                // -----------------------------Wrap Lighting-----------------------------
                // float wrap_diffuse = pow(dot(N,L)*_WrapValue+(1-_WrapValue),2) * col;
                float wrap_diffuse = max(0, (NdotL + _WrapValue) / (1 + _WrapValue));
                // float scatter = smoothstep(0.0, _ScatterWidth, wrap_diffuse) * smoothstep(_ScatterWidth * 2.0, _ScatterWidth,wrap_diffuse);
                
                // -----------------------------Diffuse-----------------------------
                // float diffuse = lightColor * (max(0, NdotL)*0.5+0.5) * col;
                // float diffuse = lightColor * (max(0, NdotL)) * col;
                float3 diffuse = lightColor * wrap_diffuse  * col;

                // --------------------------Specular-BlinnPhong-----------------------------
                fixed3 specular = lightColor * pow(max(0,NdotH),_Gloss) * _Specular;
                
                // -----------------------------Rim-----------------------------
                // float rim = 1.0 - max(0, NdotV);
                // return rim;

                // -----------------------------Point Light SSS-----------------------------
                fixed3 pointColor = fixed3(0,0,0);
                // 计算点光源
                #ifdef _CALCULATE_POINTLIGHT_ON
                    pointColor = CalculatePointLightSSS(unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                    unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
                    unity_4LightAtten0,i.worldPos,N,V) * thickness;
                #endif

                float3 resCol = diffuse + sss + pointColor + specular;

                return fixed4(resCol,1);
                
            };
            
            ENDCG
        }
      
    }
    FallBack "Diffuse"
}
```

# 参考
[fast-subsurface-scattering](https://www.alanzucconi.com/2017/08/30/fast-subsurface-scattering-2/)      
[https://www.patreon.com/posts/subsurface-write-20905461](https://www.patreon.com/posts/subsurface-write-20905461)      
[https://zhuanlan.zhihu.com/p/42433792](https://zhuanlan.zhihu.com/p/42433792)      
[https://zhuanlan.zhihu.com/p/21247702](https://zhuanlan.zhihu.com/p/21247702)      
[https://zhuanlan.zhihu.com/p/36499291](https://zhuanlan.zhihu.com/p/36499291)      
[http://walkingfat.com](http://walkingfat.com/simple-subsurface-scatterting-for-mobile-%ef%bc%88%e4%b8%80%ef%bc%89%e9%80%9a%e9%80%8f%e6%9d%90%e8%b4%a8%e7%9a%84%e6%ac%a1%e8%a1%a8%e9%9d%a2%e6%95%a3%e5%b0%84/)      
[https://zhuanlan.zhihu.com/p/27842876](https://zhuanlan.zhihu.com/p/27842876)      