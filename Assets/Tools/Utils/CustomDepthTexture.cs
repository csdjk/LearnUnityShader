using UnityEngine;
using UnityEngine.Rendering;

/// <summary>
/// 自定义场景深度图、Color
/// </summary>
[ExecuteInEditMode]
public class CustomDepthTexture : MonoBehaviour
{
    private RenderTexture depthRT;
    public RenderTexture colorRT;
    private RenderTexture depthTex;
    private RenderTexture colorTex;

    private CommandBuffer _cbDepth = null;

    private Camera _camera = null;

    private void OnEnable()
    {
        InitCommandBuffer();
    }


    private void InitCommandBuffer()
    {
        _camera = transform.GetComponent<Camera>();
        if (_cbDepth != null)
        {
            return;
        }
        int width = _camera.pixelWidth;
        int height = _camera.pixelHeight;
        depthRT = new RenderTexture(width, height, 24, RenderTextureFormat.Depth);
        colorRT = new RenderTexture(width, height, 0, RenderTextureFormat.RGB111110Float);


        depthTex = new RenderTexture(width, height, 0, RenderTextureFormat.R16);
        colorTex = new RenderTexture(width, height, 0, RenderTextureFormat.ARGB32);

        _cbDepth = new CommandBuffer();
        _cbDepth.name = "CommandBuffer_DepthBuffer";
        _cbDepth.Blit(depthRT.depthBuffer, depthTex.colorBuffer);
        _cbDepth.Blit(colorRT.colorBuffer, colorTex.colorBuffer);

        _camera.AddCommandBuffer(CameraEvent.AfterForwardOpaque, _cbDepth);
    }

    private void Update()
    {
        Shader.SetGlobalTexture("_ScreenDepthTex", depthTex);
        Shader.SetGlobalTexture("_ScreenColorTex", colorTex);
    }

    void OnPreRender()
    {
        if (colorRT && depthRT)
        {
            _camera.SetTargetBuffers(colorRT.colorBuffer, depthRT.depthBuffer);
        }
    }

    // void OnRenderImage(RenderTexture src, RenderTexture dest)
    // {
    //     Graphics.Blit(colorRT, dest);
    // }
    // private void OnGUI()
    // {
    //     GUI.DrawTexture(new Rect(0, 0, 256, 256), colorRT, ScaleMode.ScaleToFit, false, 1);
    // }

    void OnDisable()
    {
        ClearRT();
    }
    void ClearRT()
    {
        if (depthRT)
        {
            depthRT.Release();
        }
        if (colorRT)
        {
            colorRT.Release();
        }
        if (depthTex)
        {
            depthTex.Release();
        }
        if (_cbDepth != null)
        {
            _camera.RemoveCommandBuffer(CameraEvent.AfterForwardOpaque, _cbDepth);
        }
    }
}