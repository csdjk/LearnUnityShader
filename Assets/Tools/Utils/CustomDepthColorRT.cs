using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Serialization;

/// <summary>
/// 自定义深度图和屏幕ColorRT
/// </summary>
[ExecuteAlways]
public class CustomDepthColorRT : MonoBehaviour
{
    private static readonly int colorTexPID = Shader.PropertyToID("_ScreenColorRT");
    private static readonly int depthTexPID = Shader.PropertyToID("_ScreenDepthRT");
    private Camera mainCamera;
    private CommandBuffer cmd;

    void OnEnable()
    {
        mainCamera = GetComponent<Camera>();
        if (mainCamera == null)
        {
            mainCamera = Camera.main;
        }
        InitCommandBuffer();
        mainCamera.AddCommandBuffer(CameraEvent.AfterForwardOpaque, cmd);

    }
    void OnDisable()
    {
        mainCamera.RemoveCommandBuffer(CameraEvent.AfterForwardOpaque, cmd);
        cmd.Release();
        cmd = null;
    }

    private void InitCommandBuffer()
    {
        cmd = new CommandBuffer() { name = "CustomDepthColorRT" };

        cmd.GetTemporaryRT(colorTexPID, Screen.width, Screen.height, 16);
        cmd.Blit(BuiltinRenderTextureType.Depth, colorTexPID);
        cmd.SetGlobalTexture(colorTexPID, colorTexPID);

        // cmd.SetGlobalTexture(colorTexPID, BuiltinRenderTextureType.CurrentActive);
        // ssrpCmd.SetGlobalTexture(colorTexPID, BuiltinRenderTextureType.CameraTarget);
        // cmd.SetGlobalTexture(depthTexPID, BuiltinRenderTextureType.Depth);
    }
}