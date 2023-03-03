using System;
// ---------------------------【SSSSS】---------------------------
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
public class ScreenSpaceSSS : PostEffectsBase
{
    private RenderTexture maskTexture = null;
    private CommandBuffer commandBuffer = null;
    private Material purecolorMaterial;

    [Header("散射颜色")]
    public Color sssColor = new Color(1, 0.2f, 0, 0);

    [Header("散射强度")]
    [Range(0, 5)]
    public float scatteringStrenth = 1;
    //模糊半径  
    [Header("模糊半径")]
    [Range(0.2f, 3.0f)]
    public float blurRadius = 1.0f;
    //降采样次数  
    [Header("降采样次数")]
    [Range(1, 8)]
    public int downSample = 2;
    //迭代次数  
    [Header("迭代次数")]
    [Range(0, 4)]
    public int iteration = 1;

    // 目标对象
    public GameObject[] targetObjects = null;


    //-----------------------------------------【Start()函数】---------------------------------------------    
    void OnEnable()
    {
        shader = Shader.Find("lcl/SubsurfaceScattering/ScreenSpaceSSS/ScreenSpaceSSS");
        
        // Shader purecolorShader = Shader.Find("lcl/Common/PureColor");
        Shader purecolorShader = Shader.Find("lcl/Common/VertexColor");

        if (purecolorMaterial == null)
            purecolorMaterial = new Material(purecolorShader);

        if (maskTexture == null)
            maskTexture = RenderTexture.GetTemporary(Screen.width, Screen.height, 16, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Default, 4);

        commandBuffer = new CommandBuffer();
        commandBuffer.SetRenderTarget(maskTexture);
        commandBuffer.ClearRenderTarget(true, true, Color.black);
        for (var i = 0; i < targetObjects.Length; i++)
        {
            Renderer[] renderers = targetObjects[i].GetComponentsInChildren<Renderer>();
            foreach (Renderer r in renderers){
                commandBuffer.DrawRenderer(r, purecolorMaterial);
                // commandBuffer.DrawRenderer(r, r.sharedMaterial);
            }
        }
        // commandBuffer.ResolveAntiAliasedSurface(renderTexture,renderTexture);

    }

    void OnDisable()
    {
        if (maskTexture)
        {
            RenderTexture.ReleaseTemporary(maskTexture);
            maskTexture = null;
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

    // 此函数在当完成所有渲染图片后被调用，用来渲染图片后期效果
    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (!material || !maskTexture || commandBuffer == null)
        {
            Graphics.Blit(source, destination);
            return;
        }
        Graphics.ExecuteCommandBuffer(commandBuffer);

        //申请RenderTexture，RT的分辨率按照downSample降低  
        RenderTexture rt1 = RenderTexture.GetTemporary(source.width >> downSample, source.height >> downSample, 0, source.format);
        RenderTexture rt2 = RenderTexture.GetTemporary(source.width >> downSample, source.height >> downSample, 0, source.format);
        // 高斯模糊处理
        Graphics.Blit(source, rt1);
        //进行迭代高斯模糊  
        for (int i = 0; i < iteration; i++)
        {
            material.SetFloat("_BlurSize", 1.0f + i * blurRadius);
            //垂直高斯模糊
            Graphics.Blit(rt1, rt2, material, 0);
            //水平高斯模糊
            Graphics.Blit(rt2, rt1, material, 1);
        }

        material.SetTexture("_MaskTex", maskTexture);
        material.SetTexture("_BlurTex", rt1);
        material.SetFloat("_ScatteringStrenth", scatteringStrenth);
        material.SetColor("_SSSColor", sssColor);
        Graphics.Blit(source, destination, material, 2);

        //释放申请的RenderBuffer
        RenderTexture.ReleaseTemporary(rt1);
        RenderTexture.ReleaseTemporary(rt2);
    }
}