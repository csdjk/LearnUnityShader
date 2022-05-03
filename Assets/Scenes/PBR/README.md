
简单记录一下PBR相关的公式及实现代码，方便后面自己复制粘贴 ^-^。

当然这些公式都是在各个文章和引擎源码复制粘贴而来的，仅供参考。ヾ(•ω•`。)

# PBR

PBR 由直接光照和间接光照组成。

判断一种PBR光照模型是否是基于物理的，必须满足以下三个条件：
- 基于微平面(Microfacet)的表面模型。
- 能量守恒。
- 应用基于物理的BRDF。

## 渲染方程(The Rendering Equation)：

$$L _ { 0 } = L _ { e } + \int _ { Ω } f _ { r } \cdot L _ { i } \cdot ( w _ { i } \cdot n ) \cdot d w _ { i }$$


- $L _ { o }$ ：p点的出射光亮度。   
- $L _ { e }$ ：p点发出的光亮度。
- $f _ { r }$ ：p点入射方向到出射方向光的反射比例，即BxDF，一般为BRDF。
- $L _ { i }$ ：p点入射光亮度。
- $( w _ { i } \cdot n )$ ：入射角带来的入射光衰减，其实就是$( l \cdot n )$
- $\int _ { Ω } ... d w _ { i }$ ：入射方向半球的积分（可以理解为无穷小的累加和）。

---
## 反射方程(The Reflectance Equation)：
在实时渲染中，我们常用的反射方程(The Reflectance Equation)，则是渲染方程的简化的版本。

$$L _ { o } = \int _ { Ω } f _ { r } \cdot L _ { i } \cdot ( w _ { i } \cdot n ) \cdot d w _ { i }$$

**带入BRDF公式：**

$$L _ { o } = \int _ { Ω } ( k_ { d } \frac { c } { \pi } + k _ { s } \frac { D ( h ) F ( v , h ) G ( l , v , h ) } { 4 ( n \cdot l ) ( n \cdot v ) }) \cdot L _ { i } \cdot ( w _ { i } \cdot n ) \cdot d w _ { i }$$

其中F菲涅尔描述了光被反射的比例，代表了反射方程的ks，两者可以合并，所以最终的反射方程为:

$$
L _ { o } = \int _ { Ω } ( k_ { d } \frac { c } { \pi } +  \frac { D ( h ) F ( v , h ) G ( l , v , h ) } { 4 ( n \cdot l ) ( n \cdot v ) }) \cdot L _ { i } \cdot ( w _ { i } \cdot n ) \cdot d w _ { i }
$$

---
## BRDF：

BRDF也就是渲染方程中的$f _ { r }$

反射由**漫反射**和**高光反射**组成

$$
f _ { r } = f _ { d i ff }  + f _ { s p e c }
$$
- $f_{diff}$：漫反射BRDF
- $f_{spec}$：高光反射BRDF

$$
f _ { r } =  k_ { d } \frac { c } { \pi } + k _ { s } \frac { D ( h ) F ( v , h ) G ( l , v , h ) } { 4 ( n \cdot l ) ( n \cdot v ) }
$$

- $k_d$：漫反射比例
- $k_s$：高光反射比例

$k_d = 1 - k_s$

### 1.漫反射BRDF模型（Diffuse BRDF）

![image](https://pic1.zhimg.com/80/v2-f5d714fe568aa8799992c18fb3ebbeb0_720w.jpg)

Diffuse BRDF可以分为传统型和基于物理型两大类。其中，传统型主要是众所周知的Lambert。

#### Lambert Diffuse：

$$f_{diff} = \frac { c } { \pi }
$$

#### Disney Diffuse：

迪士尼开发的漫反射经验模型方程：

$$f _ { diff } ( l , v ) = \frac { baseColor } { \pi } ( 1 + ( F _ { D90 } - 1 ) ( 1 - n \cdot l ) ^ { 5 } ) ( 1 + ( F _ { D90 } - 1 ) ( 1 - n \cdot v )^ { 5 } )
$$

$$
F _ { D 90 } = 0.5 + 2 r o u g h n e s s ( h \cdot l ) ^ { 2 }
$$

- $baseColor$：固有色。   
- $roughness$：粗糙度。
- $n$：法线。
- $l$：光照方向。
- $h$：半角向量。

**Shader代码：**

```c
 half DisneyDiffuse(half NdotV, half NdotL, half LdotH, half roughness,half3 baseColor)
{
    half fd90 = 0.5 + 2 * LdotH * LdotH * roughness;
    // Two schlick fresnel term
    half lightScatter   = (1 + (fd90 - 1) * Pow5(1 - NdotL));
    half viewScatter    = (1 + (fd90 - 1) * Pow5(1 - NdotV));
    return ( baseColor / UNITY_PI) * lightScatter * viewScatter;
}

```

### 2.高光反射BRDF模型（Specular BRDF）

![image](https://pic3.zhimg.com/80/v2-2c5740a2ebc71a8ddaa84d0cbfdfdad2_720w.jpg)

#### Cook-Torrance BRDF
$$f _ { s p e c }( l , v ) = \frac { D ( h ) F ( v , h ) G ( l , v , h ) } { 4 ( n \cdot l ) ( n \cdot v ) }

$$

- **D(h)** : 法线分布函数 （Normal Distribution Function），描述微面元法线分布的概率，即正确朝向的法线的浓度。即具有正确朝向，能够将来自l的光反射到v的表面点的相对于表面面积的浓度。
- **F(l,h)** : 菲涅尔方程（Fresnel Equation），描述不同的表面角下表面所反射的光线所占的比率。
- **G(l,v,h)** : 几何函数（Geometry Function），描述微平面自成阴影的属性，即m = h的未被遮蔽的表面点的百分比。
- **分母 4(n·l)(n·v）**：校正因子（correctionfactor），作为微观几何的局部空间和整个宏观表面的局部空间之间变换的微平面量的校正。

#### D 法线分布函数（Normal Distribution Function, NDF）

理论上来说，在微观层面上，材质表面的微平面只有当这微平面的法线和半角向量相等的时候，才能产生反射，其余微平面不产生反射，应该被剔除，这个剔除就可以使用D项来剔除。

![image](https://pic3.zhimg.com/80/v2-3c82f81d480750970bcc281d425c7de6_720w.jpg)

仅m = h的表面点的朝向才会将光线l反射到视线v的方向，其他表面点对BRDF没有贡献

**业界较为主流的法线分布函数是GGX:**

$$D _ { GGX } ( h ) = \frac { \alpha ^ { 2 } } { \pi ( ( n \cdot h ) ^ { 2 } ( \alpha ^ { 2 } - 1 ) + 1 ) ^ { 2 } }
$$
- $\alpha$：等于roughness，粗糙度

Shader代码：

```c
float D_GGX_TR (float NdotH, float roughness)
{
    float a2 = roughness * roughness;
    NdotH  = max(NdotH, 0.0);
    float NdotH2 = NdotH*NdotH;
    float denom  = (NdotH2 * (a2 - 1.0) + 1.0);
    denom  = UNITY_PI * denom * denom;
    denom = max(denom,0.001); //防止分母为0
    return a2 / denom;
}
```

**Generalized-Trowbridge-Reitz（GTR）**

允许控制NDF的形状，特别是分布的尾部：

$$D _ { G T R } ( m ) = \frac { c } { ( 1 + ( n \cdot m ) ^ { 2 } ( \alpha ^ { 2 } - 1 ) ) ^ { \gamma } }
$$

γ参数用于控制尾部形状。 当γ= 2时，GTR等同于GGX。 随着γ的值减小，分布的尾部变得更长。而随着γ值的增加，分布的尾部变得更短。

![image](https://pic1.zhimg.com/80/v2-05b7abecb2c7a497f57ab208f4c67084_720w.jpg)

Shader代码：
```
float D_GTR1(float NdotH, float roughness)
{
    float a2 = roughness * roughness;
    float cos2th = NdotH * NdotH;
    float den = (1.0 + (a2 - 1.0) * cos2th);

    return(a2 - 1.0) / (UNITY_PI * log(a2) * den);
}

float D_GTR2(float NdotH, float roughness)
{
    float a2 = roughness * roughness;
    float cos2th = NdotH * NdotH;
    float den = (1.0 + (a2 - 1.0) * cos2th);

    return a2 / (UNITY_PI * den * den);
}
```


#### G 几何函数（Geometry Function）

几何函数从统计学上近似的求得了微平面间相互遮蔽的比率，这种相互遮蔽会损耗光线的能量。    
几何函数采用一个材料的粗糙度参数作为输入参数，粗糙度较高的表面其微平面间相互遮蔽的概率就越高

![image](https://pic4.zhimg.com/80/v2-2d2e65565a7def1a941f4b3728ffc08b_720w.jpg)

目前较为常用的是分离遮蔽阴影（Separable Masking and Shadowing Function）。  

该形式将几何项G分为两个独立的部分：光线方向（light）和视线方向（view），并对两者用相同的分布函数来描述  

这里采用Schlick-GGX：

$$
k = \frac { \alpha } { 2 }
$$
$$
\alpha = ( \frac { roughness + 1 } { 2 } ) ^ { 2 }
$$
$$
G _ { 1 } ( v ) = \frac { ( n \cdot v ) } { ( n \cdot v ) ( 1 - k ) + k }
$$
$$

G ( 1 , v , h ) = G _ { 1 } ( 1 ) G _ { 1 } ( v )
$$

**Shader代码：**

```c
float GeometrySchlickGGX(float NdotV, float k)
{
    float nom   = NdotV;
    float denom = NdotV * (1.0 - k) + k;

    return nom / denom;
}

float GeometrySmith(float3 N, float3 V, float3 L, float k)
{
    float NdotV = max(dot(N, V), 0.0);
    float NdotL = max(dot(N, L), 0.0);
    float ggx1 = GeometrySchlickGGX(NdotV, k);
    float ggx2 = GeometrySchlickGGX(NdotL, k);

    return ggx1 * ggx2;
}
```
#### F 菲涅尔函数 (Fresnel Function)

一般采用Schlick的Fresnel近似：
$$F _ {Schlick} ( v , h ) = F _ { 0 } + ( 1 - F _ { 0 } ) ( 1 - ( v \cdot h ) ) ^ { 5 }

F _ { 0 } = ( \frac { n - 1 } { n + 1 } ) ^ { 2 }
$$

- $n$：折射率

在Shader中，$F_0$这个参数是根据金属度(Metallic)从0.04到Albedo的插值得到：`float3 F0 = lerp(0.04, Albedo, Metallic)`

金属度越高，$F_0$与Albedo越接近，反之$F_0$会与0.04趋近

**Shader代码：**
```c
float3 F_Schlick(float HdotV, float3 F0)
{
    return F0 + (1 - F0) * pow(1 - HdotV , 5.0));
}
```

# 效果：

左边：自定义PBR，右边：Unity的PBR

[![50Eeot.png](https://z3.ax1x.com/2021/10/19/50Eeot.png)](https://imgtu.com/i/50Eeot)
[![50ElQg.gif](https://z3.ax1x.com/2021/10/19/50ElQg.gif)](https://imgtu.com/i/50ElQg)

源码地址：[https://github.com/csdjk/LearnUnityShader](https://github.com/csdjk/LearnUnityShader)

# 参考

[【基于物理的渲染（PBR）白皮书】（一） 开篇：PBR核心知识体系总结与概览](https://zhuanlan.zhihu.com/p/53086060)    
[【基于物理的渲染（PBR）白皮书】（二） PBR核心理论与渲染光学原理总结](https://zhuanlan.zhihu.com/p/60977923)   
[【基于物理的渲染（PBR）白皮书】（三）迪士尼原则的BRDF与BSDF相关总结](https://zhuanlan.zhihu.com/p/60977923)    
[PBR理论 - LearnOpenGL CN](https://learnopengl-cn.github.io/07%20PBR/01%20Theory/)     
[草履虫都能看懂的PBR讲解（迫真）](https://zhuanlan.zhihu.com/p/137013668)   
[猴子都能看懂的PBR](https://zhuanlan.zhihu.com/p/33464301)  
[光照模型 PBR - 知乎](https://zhuanlan.zhihu.com/p/272553650)