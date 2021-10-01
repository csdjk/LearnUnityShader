
# 屏幕空间次表面散射

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

由于光线照射到物体

**厚度：**

![thickness](https://i.loli.net/2021/09/30/75L6zFTktHDMnlJ.png)



# 参考

[https://zhuanlan.zhihu.com/p/42433792](https://zhuanlan.zhihu.com/p/42433792)