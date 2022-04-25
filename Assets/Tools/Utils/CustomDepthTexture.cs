using UnityEngine;
using UnityEngine.Rendering;

// 自定义DepthTexture，drawcall不翻倍
// https://zhuanlan.zhihu.com/p/61563576
[ExecuteInEditMode]
public class CustomDepthTexture : MonoBehaviour
{
    private RenderTexture depthRT;
    private RenderTexture colorRT;
    private RenderTexture depthTex;

    private CommandBuffer _cbDepth = null;

    private Camera _Camera = null;

    private void Awake()
    {
        _Camera = Camera.main;

        depthRT = new RenderTexture(_Camera.pixelWidth, _Camera.pixelHeight, 24, RenderTextureFormat.Depth);
        depthRT.name = "MainDepthBuffer";
        colorRT = new RenderTexture(_Camera.pixelWidth, _Camera.pixelHeight, 0, RenderTextureFormat.RGB111110Float);
        colorRT.name = "MainColorBuffer";

        int Width = _Camera.pixelWidth;
        int Height = _Camera.pixelHeight;

        depthTex = new RenderTexture(Width, Height, 0, RenderTextureFormat.RHalf);
        depthTex.name = "SceneDepthTex";

        _cbDepth = new CommandBuffer();
        _cbDepth.name = "CommandBuffer_DepthBuffer";
        _cbDepth.Blit(depthRT.depthBuffer, depthTex.colorBuffer);
        _Camera.AddCommandBuffer(CameraEvent.AfterForwardOpaque, _cbDepth);

    }

    private void Update()
    {
        Shader.SetGlobalTexture("_LastDepthTexture", depthTex);
    }

    void OnPreRender()
    {
        _Camera.SetTargetBuffers(colorRT.colorBuffer, depthRT.depthBuffer);
    }

    private void OnPostRender()
    {
        //目前的机制不需要这次拷贝
        Graphics.Blit(colorRT, (RenderTexture)null);
    }
}