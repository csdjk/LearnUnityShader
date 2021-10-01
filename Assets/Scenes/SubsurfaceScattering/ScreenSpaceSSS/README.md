
# Unity Shader - 屏幕空间次表面散射

# 前言
在上篇文章中我们简单实现了一个[伪次表面散射模拟](https://zhuanlan.zhihu.com/p/409370107)效果，这次我们就基于**屏幕空间模糊**的方式来模拟皮肤的次表面渲染。

# 实现

**大致流程：**

1. 提取次表面散射对象Mask遮罩。
2. 高斯模糊处理 + Mask遮罩。
3. 最后和原图叠加。

![https://pic1.zhimg.com/80](https://pic1.zhimg.com/80/v2-bf25c2a200a061a9c55615fb958b721c_720w.jpg)


## 1.提取皮肤遮罩

这里为了简单方便，直接采用Command Buffer提取需要次表面散射的对象Mask遮罩。
注意这里用了一个纯色Shader处理

C# 代码：
```csharp
// 纯色Shader
Shader purecolorShader = Shader.Find("lcl/Common/PureColor");
// Shader purecolorShader = Shader.Find("lcl/Common/VertexColor");

if (purecolorMaterial == null)
    purecolorMaterial = new Material(purecolorShader);

if (maskTexture == null)
    maskTexture = RenderTexture.GetTemporary(Screen.width, Screen.height, 16, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Default, 4);

commandBuffer = new CommandBuffer();
commandBuffer.SetRenderTarget(maskTexture);
commandBuffer.ClearRenderTarget(true, true, Color.black);
for (var i = 0; i < targetObjects.Length; i++)
{
    Renderer[] renderers = targetObjects[i].GetComponentsInChildren<Renderer>();
    foreach (Renderer r in renderers)
        commandBuffer.DrawRenderer(r, purecolorMaterial);
}
```

**原图：**
![origin](https://i.loli.net/2021/09/30/ir1hyzHlqcW4nJk.png)

**提取结果：**

![mask](https://i.loli.net/2021/09/30/ElYHRcJ4zoNZj8U.png)



## 2.高斯模糊后处理

高斯模糊具体可以看之前的一篇文章：[Unity Shader - 均值模糊和高斯模糊](https://blog.csdn.net/qq_28299311/article/details/103980498)

**模糊效果：**

![blur](https://i.loli.net/2021/09/30/ZxNHzOrQDtciyYa.png)

然后乘上Mask遮罩：

```c
//对模糊处理后的图进行uv采样
fixed4 blurCol = tex2D(_BlurTex, i.uv);
// mask遮罩
fixed4 maskCol = tex2D(_MaskTex, i.uv);
blurCol *= maskCol;
```

![mask_blur](https://i.loli.net/2021/09/30/zmjs4vkbecp25Vn.png)


## 3.叠加原图

最后叠加上原图：

```c
//对原图进行uv采样
fixed4 srcCol = tex2D(_MainTex, i.uv);
//对模糊处理后的图进行uv采样
fixed4 blurCol = tex2D(_BlurTex, i.uv);
// mask遮罩
fixed4 maskCol = tex2D(_MaskTex, i.uv);
blurCol *= maskCol;
float fac = 1-pow(saturate(max(max(srcCol.r, srcCol.g), srcCol.b) * 1), 0.5);
// float fac = fixed4(1,0.2,0,0);

return srcCol + blurCol * _SSSColor * _ScatteringStrenth * fac;
```

| ![origin](https://i.loli.net/2021/09/30/ir1hyzHlqcW4nJk.png) | ![sss](https://i.loli.net/2021/09/30/6EzbY51Z4Ju2lem.png) |
|:---:|:---:|
| 原图 | SSS |


## 4.厚度

吸收（Absorption）是模拟半透明材质的最重要特性之一。
光线在物质中传播得越远，它被散射和吸收得就越厉害。
为了模拟这种效果，我们需要测量光在物质中传播的距离，并相应地对其进行衰减。

可以在下图中看到具有相同入射角的三种不同光线,穿过物体的长度却截然不同。

![quicker.png](https://i.loli.net/2021/09/11/Zq1K6BUcwgnYtPh.png)

这里我们就采用外部局部厚度图来模拟该现象，当然，该方法在物理上来说并不准确，但是可以比较简单快速的模拟出这种效果。

烘焙厚度图可以用Substance Painter
或者用Unity的插件：Mesh Materializer把厚度信息存储在顶点色里面。


**这里我是直接把厚度信息存储在顶点色里面，输出厚度信息如下：**

这里取反了一下，越亮的地方，散射越强。

![thickness](https://i.loli.net/2021/09/30/75L6zFTktHDMnlJ.png)

**最终效果：**

左边：开启SSS、右边：关闭SSS

![sssss](https://i.loli.net/2021/09/30/fxju3NVpwlOHzy4.png)

工程源码：[https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/SubsurfaceScattering/ScreenSpaceSSS](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/SubsurfaceScattering/ScreenSpaceSSS)

# 参考

[https://zhuanlan.zhihu.com/p/42433792](https://zhuanlan.zhihu.com/p/42433792)