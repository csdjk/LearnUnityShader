# Learn Unity Shader

学习UnityShader过程中的一些Demo记录。

大致分为3部分：
- 《Unity Shader入门精要》里的一些Shader实现。
- 学习Shader过程中的一些效果实现及拓展。
- ShaderToy上的一些特效。

# 入门精要Shader：
## [基础光照（Lambert、半Lambert、Phong、BlinnPhong等） 透明度测试、透明度混合](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/LearnShader/LearnShader1)
![learnShader1.png](https://i.loli.net/2020/03/11/4rBM2lRtoyCQhve.png)

## [广告牌（Board）](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/LearnShader/LearnShader2/Board)
[![4dNIP0.gif](https://z3.ax1x.com/2021/09/23/4dNIP0.gif)](https://imgtu.com/i/4dNIP0)
## [反射、折射、菲涅尔](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/LearnShader/LearnShader2/Refraction_Reflection_Fresnel)
[![4JXjSK.png](https://z3.ax1x.com/2021/09/21/4JXjSK.png)](https://imgtu.com/i/4JXjSK)
## [Alpha Test和Shadow](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/LearnShader/LearnShader2/ForwardRendering)
[![4JXvQO.png](https://z3.ax1x.com/2021/09/21/4JXvQO.png)](https://imgtu.com/i/4JXvQO)
## [序列帧动画](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/LearnShader/LearnShader2/ImageSquenceAnim)
[![4JjCTA.gif](https://z3.ax1x.com/2021/09/21/4JjCTA.gif)](https://imgtu.com/i/4JjCTA)
## [UV动画](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/LearnShader/LearnShader2/uvAnimation)
[![4JjiFI.gif](https://z3.ax1x.com/2021/09/21/4JjiFI.gif)](https://imgtu.com/i/4JjiFI)

## [亮度,饱和度,对比度调整](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/LearnShader/LearnShader3)
| ![4JjFYt](https://z3.ax1x.com/2021/09/21/4JXxyD.png) | ![4JjFYt](https://z3.ax1x.com/2021/09/21/4JjFYt.png) |
|:---:|:---:|
| 处理后 | 原图 |

## [边缘检测及提取](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/LearnShader/LearnShader3)
| ![4JjFYt](https://z3.ax1x.com/2021/09/21/4JXzOe.png) | ![4JjFYt](https://z3.ax1x.com/2021/09/21/4JjpeH.png) |
|:---:|:---:|
| 在原图上叠加 | 边缘提取 |

## [高斯模糊](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/LearnShader/LearnShader3)
| ![4JjFYt](https://z3.ax1x.com/2021/09/21/4Jj9wd.png) | ![4JjFYt](https://z3.ax1x.com/2021/09/21/4JjFYt.png) |
|:---:|:---:|
| 高斯模糊 | 原图 |

## [运动模糊](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/LearnShader/LearnShader3)
[![4dU6F1.gif](https://z3.ax1x.com/2021/09/23/4dU6F1.gif)](https://imgtu.com/i/4dU6F1)


# 动画模拟

## [绳子（质点弹簧系统）](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/AnimationSimulation/MassSpringSystem)

[![4aBg6f.gif](https://z3.ax1x.com/2021/09/23/4aBg6f.gif)](https://imgtu.com/i/4aBg6f)
## [布料模拟（质点弹簧系统）](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/AnimationSimulation/ClothSimulate)
[![4aB2X8.gif](https://z3.ax1x.com/2021/09/23/4aB2X8.gif)](https://imgtu.com/i/4aB2X8)



# CommandBuffer
## [局部后处理](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/CommandBuffer/CommandBufferStencil)
[![4aBH10.png](https://z3.ax1x.com/2021/09/23/4aBH10.png)](https://imgtu.com/i/4aBH10)

## [景深](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/CommandBuffer/CommandBufferDepthFiled)
[![4aBqXT.png](https://z3.ax1x.com/2021/09/23/4aBqXT.png)](https://imgtu.com/i/4aBqXT)


# Depth
## [深度图](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/Depth/2_DepthTexture)
[![4aDShR.png](https://z3.ax1x.com/2021/09/23/4aDShR.png)](https://imgtu.com/i/4aDShR)

## [扫描光线](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/Depth/DepthScan)
[![4aBbcV.gif](https://z3.ax1x.com/2021/09/23/4aBbcV.gif)](https://imgtu.com/i/4aBbcV)

# 几何着色器的基本应用
## [点图元和线图元](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/GeometryShader/Base)
[![4aBOnU.png](https://z3.ax1x.com/2021/09/23/4aBOnU.png)](https://imgtu.com/i/4aBOnU)

## [粒子爆炸](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/GeometryShader/Example)
[![4aBXBF.gif](https://z3.ax1x.com/2021/09/23/4aBXBF.gif)](https://imgtu.com/i/4aBXBF)


# 其他着色器
## 玻璃
[![4aBj74.gif](https://z3.ax1x.com/2021/09/23/4aBj74.gif)](https://imgtu.com/i/4aBj74)


# GPU Instance
## [草地渲染](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/GPUInstance/GrassSimulation)
[![4daUAA.gif](https://z3.ax1x.com/2021/09/23/4daUAA.gif)](https://imgtu.com/i/4daUAA)



# 后处理特效
## [坏电视效果](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/ScreenEffect/BadTV)


[![40IDJI.gif](https://z3.ax1x.com/2021/09/24/40IDJI.gif)](https://imgtu.com/i/40IDJI)
[![40IBFA.gif](https://z3.ax1x.com/2021/09/24/40IBFA.gif)](https://imgtu.com/i/40IBFA)
## [Bloom](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/ScreenEffect/Bloom)

| ![40I3J1.png](https://z3.ax1x.com/2021/09/24/40I3J1.png) | ![40I8Rx.png](https://z3.ax1x.com/2021/09/24/40I8Rx.png)|
|:---:|:---:|
| 原图 | Bloom |


## [模糊](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/ScreenEffect/BoxBlur)
| ![原图](https://z3.ax1x.com/2021/09/24/40INLD.png) | ![boxBlur](https://z3.ax1x.com/2021/09/24/40oGkj.png) |
|:---:|:---:|
| 原图 | [均值模糊](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/ScreenEffect/BoxBlur)  | 
|![GaussianBlur](https://z3.ax1x.com/2021/09/24/40o37Q.png)|![RadialBlur](https://z3.ax1x.com/2021/09/24/40ItsO.png)|
[高斯模糊](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/ScreenEffect/GaussianBlur)  | [径向模糊](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/ScreenEffect/RadialBlur) |

## [Mask](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/ScreenEffect/Mask)
[![40IYQK.gif](https://z3.ax1x.com/2021/09/24/40IYQK.gif)](https://imgtu.com/i/40IYQK)
[![40Iaee.gif](https://z3.ax1x.com/2021/09/24/40Iaee.gif)](https://imgtu.com/i/40Iaee)
## [描边](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/ScreenEffect/OutLine)

[![40IGz6.gif](https://z3.ax1x.com/2021/09/24/40IGz6.gif)](https://imgtu.com/i/40IGz6)

## [波纹](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/ScreenEffect/WaterWave)
[![40IddH.gif](https://z3.ax1x.com/2021/09/24/40IddH.gif)](https://imgtu.com/i/40IddH)
## [放大镜](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/ScreenEffect/Zoom)
[![40Iwod.gif](https://z3.ax1x.com/2021/09/24/40Iwod.gif)](https://imgtu.com/i/40Iwod)