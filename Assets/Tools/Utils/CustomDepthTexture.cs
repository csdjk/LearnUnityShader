using UnityEngine;
using UnityEngine.Rendering;

/// <summary>
/// 自定义场景深度图、Color
/// </summary>
[ExecuteAlways, RequireComponent(typeof(Camera))]
public class CustomDepthTexture : MonoBehaviour
{
    private static readonly int colorTexPID = Shader.PropertyToID("_ScreenColorRT");
    private static readonly int depthTexPID = Shader.PropertyToID("_ScreenDepthRT");
    private RenderTexture depthRT;
    private RenderTexture colorRT;
    private RenderTexture depthTex;
    private RenderTexture colorTex;

    private CommandBuffer depthCommandBuffer = null;

    private Camera mainCamera = null;

    private void OnEnable()
    {
        InitCommandBuffer();
    }

    private void InitCommandBuffer()
    {
        mainCamera = transform.GetComponent<Camera>();
        mainCamera.allowMSAA = false;
        int width = mainCamera.pixelWidth;
        int height = mainCamera.pixelHeight;

        depthRT = RenderTexture.GetTemporary(width, height, 24, RenderTextureFormat.Depth);
        colorRT = RenderTexture.GetTemporary(width, height, 0, RenderTextureFormat.RGB111110Float);


        depthTex = RenderTexture.GetTemporary(width, height, 0, RenderTextureFormat.R16);
        colorTex = RenderTexture.GetTemporary(width, height, 0, RenderTextureFormat.ARGB32);

        // depthRT = new RenderTexture(width, height, 24, RenderTextureFormat.Depth);
        // colorRT = new RenderTexture(width, height, 0, RenderTextureFormat.RGB111110Float);


        // depthTex = new RenderTexture(width, height, 0, RenderTextureFormat.R16);
        // colorTex = new RenderTexture(width, height, 0, RenderTextureFormat.ARGB32);


        depthCommandBuffer = new CommandBuffer()
        {
            name = "CustomDepthColorBuffer"
        };
        depthCommandBuffer.Blit(depthRT.depthBuffer, depthTex.colorBuffer);
        depthCommandBuffer.Blit(BuiltinRenderTextureType.CurrentActive, colorTex);
        // _cbDepth.Blit(colorRT.colorBuffer, colorTex.colorBuffer);

        mainCamera.AddCommandBuffer(CameraEvent.AfterForwardOpaque, depthCommandBuffer);

        Shader.SetGlobalTexture(depthTexPID, depthTex);
        Shader.SetGlobalTexture(colorTexPID, colorTex);
    }

    // void Update()
    // {
    //     Shader.SetGlobalTexture(depthTexPID, depthTex);
    //     Shader.SetGlobalTexture(colorTexPID, colorTex);
    // }

    void OnPreRender()
    {
        if (colorRT && depthRT)
        {
            mainCamera.SetTargetBuffers(colorRT.colorBuffer, depthRT.depthBuffer);
        }
    }

    void OnPostRender()
    {
        mainCamera.targetTexture = null;
    }


    void OnDisable()
    {
        ClearRT();
    }
    void ClearRT()
    {
        RenderTexture.ReleaseTemporary(depthRT);
        RenderTexture.ReleaseTemporary(colorRT);
        RenderTexture.ReleaseTemporary(depthTex);
        RenderTexture.ReleaseTemporary(depthTex);
        mainCamera.RemoveCommandBuffer(CameraEvent.AfterForwardOpaque, depthCommandBuffer);
        depthCommandBuffer = null;
    }
}