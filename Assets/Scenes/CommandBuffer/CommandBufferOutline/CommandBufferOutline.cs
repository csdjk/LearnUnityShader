/// <summary>
/// 描边 - CommandBuffer
/// </summary>
using System.Collections;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;

//编辑状态下也运行  
[ExecuteInEditMode]
//继承自PostEffectsbase
public class CommandBufferOutline : PostEffectsBase
{
    private RenderTexture renderTexture = null;
    private CommandBuffer commandBuffer = null;
    private Material _material = null;
    private Material purecolorMaterial;

    // 纯色shader
    [Header("纯色Shader")]
    public Shader purecolorShader;
   
    //迭代次数
    [Range(0, 4)]
    public int iterations = 3;
    //模糊扩散范围
    [Range(0.2f, 3.0f)]
    public float blurSpread = 0.6f;
    private int downSample = 1;
    public Color outlineColor = new Color(1, 1, 1, 1);

    // 目标对象
    public GameObject[] targetObjects = null;
    void OnEnable()
    {
        if (purecolorShader == null)
            return;
        if (purecolorMaterial == null)
            purecolorMaterial = new Material(purecolorShader);


        if (renderTexture == null)
            renderTexture = RenderTexture.GetTemporary(Screen.width >> downSample, Screen.height >> downSample, 0,RenderTextureFormat.Default,RenderTextureReadWrite.Default,4);

        //创建描边prepass的command buffer
        commandBuffer = new CommandBuffer();
        commandBuffer.SetRenderTarget(renderTexture);
        commandBuffer.ClearRenderTarget(true, true, Color.black);

        for (var i = 0; i < targetObjects.Length; i++)
        {
            Renderer[] renderers = targetObjects[i].GetComponentsInChildren<Renderer>();
            foreach (Renderer r in renderers)
                commandBuffer.DrawRenderer(r, purecolorMaterial);
        }

    }

    void OnDisable()
    {
        if (renderTexture)
        {
            RenderTexture.ReleaseTemporary(renderTexture);
            renderTexture = null;
        }
        if (purecolorMaterial)
        {
            DestroyImmediate(purecolorMaterial);
            purecolorMaterial = null;
        }
        if (commandBuffer != null)
        {
            commandBuffer.Release();
            commandBuffer = null;
        }
    }


    //-------------------------------------【OnRenderImage函数】------------------------------------    
    // 说明：此函数在当完成所有渲染图片后被调用，用来渲染图片后期效果
    //--------------------------------------------------------------------------------------------------------  
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (!material || !renderTexture || commandBuffer == null)
        {
            Graphics.Blit(source, destination);
            return;
        }
        // 执行Command Buffer
        Graphics.ExecuteCommandBuffer(commandBuffer);

        int rtW = source.width >> downSample;
        int rtH = source.height >> downSample;
        var temp1 = RenderTexture.GetTemporary(rtW, rtH, 0);
        var temp2 = RenderTexture.GetTemporary(rtW, rtH, 0);
        // 高斯模糊处理
        Graphics.Blit(renderTexture, temp1);
        for (int i = 0; i < iterations; i++)
        {
            material.SetFloat("_BlurSize", 1.0f + i * blurSpread);
            //垂直高斯模糊
            Graphics.Blit(temp1, temp2, material, 0);
            //水平高斯模糊
            Graphics.Blit(temp2, temp1, material, 1);
        }
        //用模糊图和原始图计算出轮廓图
        material.SetColor("_OutlineColor", outlineColor);
        material.SetTexture("_BlurTex", temp1);
        material.SetTexture("_SrcTex", renderTexture);
        Graphics.Blit(source, destination, material, 2);

        RenderTexture.ReleaseTemporary(temp1);
        RenderTexture.ReleaseTemporary(temp2);
    }
}