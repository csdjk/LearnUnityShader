using UnityEngine;
using UnityEngine.Rendering;

/// <summary>
/// 通过CommandBuffer提取通过模板测试的图片，进行局部后处理
/// </summary>
[RequireComponent(typeof(Camera))]
public class OutlineStencil : MonoBehaviour
{

    [SerializeField]
    private Shader _shader;

    private void Awake()
    {
        Initialize();
    }

    private void Initialize()
    {
        var camera = GetComponent<Camera>();
        var material = new Material(_shader);

        var commandBuffer = new CommandBuffer();
        commandBuffer.name = "outline";

        //将当前的渲染结果复制到RenderTexture
        int cameraTarget = Shader.PropertyToID("_CameraTarget");
        commandBuffer.GetTemporaryRT(cameraTarget, -1, -1);
        commandBuffer.Blit(BuiltinRenderTextureType.CameraTarget, cameraTarget);
        // 
        int maskTex = Shader.PropertyToID("_MaskTex");
		commandBuffer.GetTemporaryRT (maskTex, -1, -1);

        // 经过模板测试渲染到摄像机目标纹理
        // commandBuffer.Blit(cameraTarget, maskTex, material);

        // commandBuffer.Blit(maskTex, BuiltinRenderTextureType.CameraTarget);

        commandBuffer.Blit(cameraTarget, BuiltinRenderTextureType.CameraTarget, material);

        // 释放
        commandBuffer.ReleaseTemporaryRT(cameraTarget);
        //后处理前执行
        camera.AddCommandBuffer(CameraEvent.BeforeImageEffects, commandBuffer);
    }



}