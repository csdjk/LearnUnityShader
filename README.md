# Learn Unity Shader

学习 UnityShader 过程中的一些 Demo 记录。

大致分为两部分：

- 《Unity Shader 入门精要》里的一些 Shader 实现。
- 学习 Shader 过程中的一些效果实现及拓展。

**Unity Version：2021.3.11f1**

# 入门精要 Shader

## [基础光照（Lambert、半 Lambert、Phong、BlinnPhong 等） 透明度测试、透明度混合](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/LearnShader/LearnShader1)

![learnShader1.png](https://i.loli.net/2020/03/11/4rBM2lRtoyCQhve.png)

## [广告牌（Board）](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/LearnShader/LearnShader2/Board)

[![4dNIP0.gif](https://z3.ax1x.com/2021/09/23/4dNIP0.gif)](https://imgtu.com/i/4dNIP0)

## [反射、折射、菲涅尔](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/LearnShader/LearnShader2/Refraction_Reflection_Fresnel)

[![4JXjSK.png](https://z3.ax1x.com/2021/09/21/4JXjSK.png)](https://imgtu.com/i/4JXjSK)

## [Alpha Test 和 Shadow](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/LearnShader/LearnShader2/ForwardRendering)

[![4JXvQO.png](https://z3.ax1x.com/2021/09/21/4JXvQO.png)](https://imgtu.com/i/4JXvQO)

## [序列帧动画](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/LearnShader/LearnShader2/ImageSquenceAnim)

[![4JjCTA.gif](https://z3.ax1x.com/2021/09/21/4JjCTA.gif)](https://imgtu.com/i/4JjCTA)

## [UV 动画](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/LearnShader/LearnShader2/uvAnimation)

[![4JjiFI.gif](https://z3.ax1x.com/2021/09/21/4JjiFI.gif)](https://imgtu.com/i/4JjiFI)

## [亮度,饱和度,对比度调整](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/LearnShader/LearnShader3)

| ![4JjFYt](https://z3.ax1x.com/2021/09/21/4JXxyD.png) | ![4JjFYt](https://z3.ax1x.com/2021/09/21/4JjFYt.png) |
| :--------------------------------------------------: | :--------------------------------------------------: |
|                        处理后                        |                         原图                         |

## [边缘检测及提取](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/LearnShader/LearnShader3)

| ![4JjFYt](https://z3.ax1x.com/2021/09/21/4JXzOe.png) | ![4JjFYt](https://z3.ax1x.com/2021/09/21/4JjpeH.png) |
| :--------------------------------------------------: | :--------------------------------------------------: |
|                     在原图上叠加                     |                       边缘提取                       |

## [高斯模糊](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/LearnShader/LearnShader3)

| ![4JjFYt](https://z3.ax1x.com/2021/09/21/4Jj9wd.png) | ![4JjFYt](https://z3.ax1x.com/2021/09/21/4JjFYt.png) |
| :--------------------------------------------------: | :--------------------------------------------------: |
|                       高斯模糊                       |                         原图                         |

## [运动模糊](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/LearnShader/LearnShader3)

[![4dU6F1.gif](https://z3.ax1x.com/2021/09/23/4dU6F1.gif)](https://imgtu.com/i/4dU6F1)

# 动画模拟

## [绳子（质点弹簧系统）](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/AnimationSimulation/MassSpringSystem)

[![4aBg6f.gif](https://z3.ax1x.com/2021/09/23/4aBg6f.gif)](https://imgtu.com/i/4aBg6f)

## [布料模拟（质点弹簧系统）](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/AnimationSimulation/ClothSimulate)

[![4aB2X8.gif](https://z3.ax1x.com/2021/09/23/4aB2X8.gif)](https://imgtu.com/i/4aB2X8)

## [Bezier Mesh](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/Graphics/BezierMesh)

![BezierMesh.gif](https://s2.loli.net/2023/03/27/kmGIL1z6lHZyASu.gif)

# CommandBuffer

## [局部后处理](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/CommandBuffer/CommandBufferStencil)

[![4aBH10.png](https://z3.ax1x.com/2021/09/23/4aBH10.png)](https://imgtu.com/i/4aBH10)

## [景深](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/CommandBuffer/CommandBufferDepthFiled)

[![4aBqXT.png](https://z3.ax1x.com/2021/09/23/4aBqXT.png)](https://imgtu.com/i/4aBqXT)

## [自定义烘焙](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/CommandBuffer/CommandBufferBakeTexture)

这里简单的对 mainTex 做了马赛克处理

烘焙前 - 烘焙后
[![q0hJyV.png](https://s1.ax1x.com/2022/03/27/q0hJyV.png)](https://imgtu.com/i/q0hJyV)
[![q0hYLT.png](https://s1.ax1x.com/2022/03/27/q0hYLT.png)](https://imgtu.com/i/q0hYLT)

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

# GPU Instance

## [草地渲染](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/GPUInstance/GrassSimulation)

[![4daUAA.gif](https://z3.ax1x.com/2021/09/23/4daUAA.gif)](https://imgtu.com/i/4daUAA)

# 后处理特效

## [坏电视效果](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/ScreenEffect/BadTV)

![badTV.gif](https://i.loli.net/2021/09/25/tAhlB4FCD6kaGWS.gif)
![badTV2.gif](https://i.loli.net/2021/09/25/9GqIONPJYjo1KUv.gif)

## [Bloom](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/ScreenEffect/Bloom)

| ![Bloom.png](https://i.loli.net/2021/09/25/xVeZh7LyajuDBwm.png) | ![Bloom2.png](https://i.loli.net/2021/09/25/d1rZk6AVfUYonRg.png) |
| :-------------------------------------------------------------: | :--------------------------------------------------------------: |
|                              原图                               |                              Bloom                               |

## [模糊](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/ScreenEffect/BoxBlur)

|                       ![sed.png](https://i.loli.net/2021/09/25/F1vSltjnTQ4Mu3G.png)                       |                    ![boxBlur.png](https://i.loli.net/2021/09/25/2cHnvEaR1F5DZ8M.png)                    |
| :-------------------------------------------------------------------------------------------------------: | :-----------------------------------------------------------------------------------------------------: |
|                                                   原图                                                    |  [均值模糊](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/ScreenEffect/BoxBlur)   |
|                    ![GaussBlur.png](https://i.loli.net/2021/09/25/MLubJFH5rZpcKOU.png)                    |                  ![RadialBlur.png](https://i.loli.net/2021/09/25/Jt5PTUuv8sKhRWN.png)                   |
| [高斯模糊](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/ScreenEffect/GaussianBlur) | [径向模糊](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/ScreenEffect/RadialBlur) |

## [Mask](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/ScreenEffect/Mask)

![mask.gif](https://i.loli.net/2021/09/25/ehRoYlnxKu3UQgr.gif)
![mask2.gif](https://i.loli.net/2021/09/25/ifPOyvLWwMGneFz.gif)

## [描边](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/ScreenEffect/OutLine)

![outline.gif](https://i.loli.net/2021/09/25/Sn7bxNTDIj4soUC.gif)

## [波纹](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/ScreenEffect/WaterWave)

![Wave.gif](https://i.loli.net/2021/09/25/KsaAQL7fuwc2RtM.gif)

## [放大镜](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/ScreenEffect/Zoom)

![zoom.gif](https://i.loli.net/2021/09/25/ibnV1oy4jvCFUTR.gif)

# UI Shader

## [老照片风格](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/Shader2D/UI-OldPhoto)

[![LI5hZD.png](https://s1.ax1x.com/2022/04/25/LI5hZD.png)](https://imgtu.com/i/LI5hZD)

## [径向溶解](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/Shader2D/UI-Disolve)

[![LI54de.gif](https://s1.ax1x.com/2022/04/25/LI54de.gif)](https://imgtu.com/i/LI54de)

# 其他 Shader

## [各向异性](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/Anisotropy)

[![vi5J2Q.png](https://s1.ax1x.com/2022/07/30/vi5J2Q.png)](https://imgtu.com/i/vi5J2Q)

## [玻璃](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/OtherShader/Glass)

<!-- [![4aBj74.gif](https://z3.ax1x.com/2021/09/23/4aBj74.gif)](https://imgtu.com/i/4aBj74) -->

[![jX8DVx.png](https://s1.ax1x.com/2022/07/23/jX8DVx.png)](https://imgtu.com/i/jX8DVx)

## [溶解](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/OtherShader/Dissolve)

![Dissolve](https://i.loli.net/2021/09/25/pEn7sqwlfXzS5mx.gif)
![Dissolve2](https://i.loli.net/2021/09/25/uspf8a4QtUF12wi.gif)

## [翻书](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/OtherShader/FlipBook)

![FlipBook](https://i.loli.net/2021/09/25/5Yl8DBRQuP3ITtA.gif)

## [Flow Map](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/OtherShader/FlowMap)

[![qOameU.gif](https://s1.ax1x.com/2022/04/05/qOameU.gif)](https://imgtu.com/i/qOameU)

## [能量球](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/OtherShader/EnergyBall)

![energyBall](https://i.loli.net/2021/09/25/ihgdEHMuLa5UvNz.gif)

## [液体瓶](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/OtherShader/WaterBottle)

[![IylgRs.gif](https://z3.ax1x.com/2021/11/13/IylgRs.gif)](https://imgtu.com/i/IylgRs)

## [三维映射](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/TriplanarMapping)

![triplanarMapX.png](https://s2.loli.net/2022/07/31/SMOVfuk6X1TswaE.png)
![triplanarMapXZ.png](https://s2.loli.net/2022/07/31/7diyOYB6lhn84Lu.png)

## [InteriorMapping](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/InteriorMapping)

### [InteriorMapping - CubeMap](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/InteriorMapping)

![interiorMappingCubemap.gif](https://s2.loli.net/2022/08/20/TsapkJdGrm346Iy.gif)

### [InteriorMapping - 2D Atlas](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/InteriorMapping)

![interiorMapping2D.gif](https://s2.loli.net/2022/08/20/KHgirLY9QdjETnI.gif)
[![vsYR9f.png](https://s1.ax1x.com/2022/08/20/vsYR9f.png)](https://imgse.com/i/vsYR9f)
[![vsYW38.png](https://s1.ax1x.com/2022/08/20/vsYW38.png)](https://imgse.com/i/vsYW38)

## [Mask](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/Mask)

### [Box Mask](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/Mask/BoxMask)

[![vstKUI.png](https://s1.ax1x.com/2022/08/20/vstKUI.png)](https://imgse.com/i/vstKUI)

### [Sphere Mask](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/Mask/SphereMask)

[![vstuVA.png](https://s1.ax1x.com/2022/08/20/vstuVA.png)](https://imgse.com/i/vstuVA)

### [2D Mask](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/Mask/BoxMask)

[![vstM5t.png](https://s1.ax1x.com/2022/08/20/vstM5t.png)](https://imgse.com/i/vstM5t)

# 描边

## [基于 Fresnel 的边缘光](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/OutLine/Fresnel)

![](https://i.loli.net/2021/09/25/z7NeQHyoMpVWG1u.gif)

## [基于法线扩张的描边](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/OutLine/NormalExpansion)

左边是 **先渲染正面后渲染描边**、右边 **先渲染描边后渲染正面**

![](https://i.loli.net/2021/09/25/v4ax2WU1ZVBobmI.gif)

## [基于法线扩张的遮挡描边](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/OutLine/NormalExpansion_Shield)

![](https://i.loli.net/2021/09/25/HsYQZTzvXefai9G.gif)

## [基于后处理的描边](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/OutLine/PostProcess)

![](https://i.loli.net/2021/09/25/pwmqVCnBAUdevbK.gif)

## [基于后处理的遮挡描边](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/OutLine/PostProcess_DepthShield)

![](https://i.loli.net/2021/09/25/ktj7dUKq4ShgA1v.gif)

## [边缘检测](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/OutLine/EdgeDetection)

![](https://i.loli.net/2021/09/25/svAFTCwRzQkS7yL.gif)

## [笔刷 - 基于 UV 坐标](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/TexturePainter/PainterBaseUV)

[![qBasoT.gif](https://s1.ax1x.com/2022/03/27/qBasoT.gif)](https://imgtu.com/i/qBasoT)

## [笔刷 - 基于世界坐标](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/TexturePainter/PainterBaseWorldPos)

[![qBa6FU.gif](https://s1.ax1x.com/2022/03/27/qBa6FU.gif)](https://imgtu.com/i/qBa6FU)

## [薄膜干涉（镭射布料）](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/FilmInterference)

[![qBBW4K.png](https://s1.ax1x.com/2022/03/27/qBBW4K.png)](https://imgtu.com/i/qBBW4K)
[![qBBh9O.png](https://s1.ax1x.com/2022/03/27/qBBh9O.png)](https://imgtu.com/i/qBBh9O)

# 曲面细分着色器

## [雪地交互](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/TessellShader/SnowGround2)

![snowGround.gif](https://i.loli.net/2021/09/29/Rgcj8oLVNPJaHvw.gif)

# 次表面散射

## [通透材质](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/SubsurfaceScattering/FastSSS)

![sss](https://i.loli.net/2021/09/30/Lhx9WRwPtbkz7f4.png)

![sss2](https://i.loli.net/2021/09/30/oqzGQMcjkNiaYu5.png)

## [屏幕空间次表面散射](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/SubsurfaceScattering/ScreenSpaceSSS)

左边：开启 SSS、右边：关闭 SSS

![sssss](https://i.loli.net/2021/09/30/fxju3NVpwlOHzy4.png)

## [球面高斯-次表面散射(SG-SSS)](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/PBR/PBR_SSS)

[![jHmtot.png](https://s1.ax1x.com/2022/07/20/jHmtot.png)](https://imgtu.com/i/jHmtot)

# 卡通渲染

## [卡通着色（色阶）](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/ToonShading/ColorGradation)

![ColorGradation4](https://i.loli.net/2021/10/10/k9ga2B3NMGYdhqx.png)

## [简易的卡通水](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/ToonShading/CartoonWater)

![water](https://i.loli.net/2021/09/30/JPqcE2fnxrKsVRT.gif)

# 角色渲染

## [简易的角色渲染](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/Character/Character)

![simpleCharacter.png](https://s2.loli.net/2022/07/31/OkyMFHv4Ylc9LtG.png)
![simpleCharacter.gif](https://s2.loli.net/2022/07/31/C9Ln2RmTVNGheZg.gif)

# PBR

## [自定义 PBR](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/PBR/PBR_Custom)

**左边：自定义 PBR，右边：Unity 的 PBR**
[![50Eeot.png](https://z3.ax1x.com/2021/10/19/50Eeot.png)](https://imgtu.com/i/50Eeot)
[![50ElQg.gif](https://z3.ax1x.com/2021/10/19/50ElQg.gif)](https://imgtu.com/i/50ElQg)

[![50E0lF.png](https://z3.ax1x.com/2021/10/19/50E0lF.png)](https://imgtu.com/i/50E0lF)
[![50EBy4.png](https://z3.ax1x.com/2021/10/19/50EBy4.png)](https://imgtu.com/i/50EBy4)

## [PBR-各向异性](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/PBR/PBR_Anisotropy)

[![jHm8Ld.png](https://s1.ax1x.com/2022/07/20/jHm8Ld.png)](https://imgtu.com/i/jHm8Ld)

## [PBR-皮肤(SG-SSS)](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/PBR/PBR_SSS)

[![jHm1Qe.png](https://s1.ax1x.com/2022/07/20/jHm1Qe.png)](https://imgtu.com/i/jHm1Qe)

# Water

## [水体交互](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/Water/Water_InteractionParticle)

[![IyMzX6.gif](https://z3.ax1x.com/2021/11/13/IyMzX6.gif)](https://imgtu.com/i/IyMzX6)

# 阴影（Shadow Mapping）

## [Shadow Map](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/Shadows/CustomShadowMap)

[![oDHete.png](https://s4.ax1x.com/2021/12/05/oDHete.png)](https://imgtu.com/i/oDHete)

## [PCF](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/Shadows/CustomShadowMap)

[![oDHupd.png](https://s4.ax1x.com/2021/12/05/oDHupd.png)](https://imgtu.com/i/oDHupd)

## [PCF(PoissonDisk)](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/Shadows/CustomShadowMap)

[![oDHZkD.png](https://s4.ax1x.com/2021/12/05/oDHZkD.png)](https://imgtu.com/i/oDHZkD)

## [PCSS](https://github.com/csdjk/LearnUnityShader/tree/master/Assets/Scenes/Shadows/CustomShadowMap)

[![oDHmfH.png](https://s4.ax1x.com/2021/12/05/oDHmfH.png)](https://imgtu.com/i/oDHmfH)
