/// <summary>
/// 景深 - CommandBuffer - 在后处理之后渲染
/// 在摄像机挂一个模糊后处理的脚步，然后通过CommandBuffer把不需要模糊的对象丢在后处理之后渲染
/// </summary>
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
public class CommandBufferDepthFiled : MonoBehaviour
{
    private CommandBuffer commandBuffer = null;
    private Renderer targetRenderer = null;

    void OnEnable()
    {
        targetRenderer = this.GetComponentInChildren<Renderer>();
        if (targetRenderer)
        {
            commandBuffer = new CommandBuffer();
            commandBuffer.DrawRenderer(targetRenderer, targetRenderer.sharedMaterial);
            //直接加入相机的CommandBuffer事件队列中,
            Camera.main.AddCommandBuffer(CameraEvent.AfterImageEffects, commandBuffer);
            targetRenderer.enabled = false;
        }
    }

    void OnDisable()
    {
        if (commandBuffer != null)
        {
            //移除事件，清理资源
            Camera.main.RemoveCommandBuffer(CameraEvent.AfterImageEffects, commandBuffer);
            commandBuffer.Release();
            commandBuffer = null;
        }
        if (targetRenderer != null)
        {
            targetRenderer.enabled = true;
        }
    }
}