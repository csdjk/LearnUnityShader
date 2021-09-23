using UnityEngine;
using UnityEngine.Rendering;

/// <summary>
/// 通过CommandBuffer提取通过模板测试的图片，进行局部后处理
/// </summary>
[RequireComponent(typeof(Camera))]
public class CommandBufferStencil : MonoBehaviour
{

    public Shader shader;

    private void Awake()
    {
        Initialize();
    }

    private void Initialize()
    {
        var camera = GetComponent<Camera>();
        var material = new Material(shader);

        var commandBuffer = new CommandBuffer();
        commandBuffer.name = "mosaic";

        //暂时将当前的渲染结果复制到RenderTexture
        int tempTextureIdentifier = Shader.PropertyToID("_PostEffect");
        commandBuffer.GetTemporaryRT(tempTextureIdentifier, -1, -1);
        commandBuffer.Blit(BuiltinRenderTextureType.CameraTarget, tempTextureIdentifier);
        // 经过模板测试渲染到摄像机目标纹理
        commandBuffer.Blit(tempTextureIdentifier, BuiltinRenderTextureType.CameraTarget, material);
        // 释放
        commandBuffer.ReleaseTemporaryRT(tempTextureIdentifier);
        //后处理前执行
        camera.AddCommandBuffer(CameraEvent.BeforeImageEffects, commandBuffer);
    }
}