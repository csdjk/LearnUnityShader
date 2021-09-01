/*** 
 * @Descripttion: 
 * @Author: lichanglong
 * @Date: 2021-09-01 16:58:02
 * @FilePath: \LearnUnityShader\Assets\Scenes\ToonShading\OutLine\Stencil\OutlineStencilPostProcess.cs
 */

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OutlineStencilPostProcess : MonoBehaviour
{

    //用于后处理描边的材质
    public Material OutlinePostProcessByStencilMat;
    //用于提取出纯颜色形式的 StencilBuffer 的材质
    public Material StencilProcessMat;
    //屏幕图像的渲染纹理
    private RenderTexture cameraRenderTexture;
    //纯颜色形式的 StencilBuffer
    private RenderTexture stencilBufferToColor;

    private Camera mainCamera;
    void Start()
    {
        mainCamera = GameObject.FindWithTag("MainCamera").GetComponent<Camera>();

        //创建一个深度缓冲区中的位数是 24 位的渲染纹理，（可选 0，16，24；但只有 24 位具有模板缓冲区）
        cameraRenderTexture = new RenderTexture(Screen.width, Screen.height, 24);

        //因为无法直接获得 Stencil Buffer，
        //将 renderTexture 中的被 Stencil 标记的像素转换成一张纯颜色的渲染纹理
        stencilBufferToColor = new RenderTexture(Screen.width, Screen.height, 24);

        OutlinePostProcessByStencilMat.SetTexture("_StencilBufferToColor", stencilBufferToColor);
    }

    void OnPreRender()
    {
        //将摄像机的渲染结果传到 cameraRenderTexture 中
        mainCamera.targetTexture = cameraRenderTexture;
    }

    void OnPostRender()
    {
        //null 意味着 camera 渲染结果直接交付给 FramBuffer
        mainCamera.targetTexture = null;

        //设置 Graphics 的渲染操作目标为 stencilBufferToColor
        //即 Graphics 的 activeColorBuffer 和 activeDepthBuffer 都是 stencilBufferToColor 里的
        Graphics.SetRenderTarget(stencilBufferToColor);

        //清除 stencilBufferToColor 里的颜色和深度缓冲区内容，并设置默认颜色为（0，0，0，0）
        GL.Clear(true, true, new Color(0, 0, 0, 0));

        //设置 Graphics 的渲染操作目标
        //即 Graphics 的 activeColorBuffer 是 stencilBufferToColor 的 ColorBuffer
        //Graphics 的 activeDepthBuffer 是 cameraRenderTexture 的 depthBuffer
        Graphics.SetRenderTarget(stencilBufferToColor.colorBuffer, cameraRenderTexture.depthBuffer);

        //提取出纯颜色形式的 StencilBuffer:
        //将 cameraRenderTexture 通过 StencilProcessMat 材质提取出到 Graphics.activeColorBuffer
        //即提取到 stencilBufferToColor 中
        Graphics.Blit(cameraRenderTexture, StencilProcessMat);

        //将 cameraRenderTexture 通过 OutlinePostProcessMat 材质
        //并与材质中的 _StencilBufferToColor 进行边缘检测操作
        //最后输出到 FrameBuffer(null 意味着直接交付给 FramBuffer)
        Graphics.Blit(cameraRenderTexture, null as RenderTexture, OutlinePostProcessByStencilMat);
    }
}