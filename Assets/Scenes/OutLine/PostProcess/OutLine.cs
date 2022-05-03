using System.Collections;
using UnityEngine;

//编辑状态下也运行  
[ExecuteInEditMode]
//继承自PostEffectsbase
public class OutLine : PostEffectsBase
{
    //主相机
    private Camera mainCamera = null;
    //渲染纹理
    private RenderTexture renderTexture = null;
    private Material _material = null;

    /// 辅助摄像机  
    public Camera outlineCamera;
    // 纯色shader
    public Shader purecolorShader;
    //描边处理的shader
    public Shader shader;
    //迭代次数
    [Range(0, 4)]
    public int iterations = 3;
    //模糊扩散范围
    [Range(0.2f, 3.0f)]
    public float blurSpread = 0.6f;
    private int downSample = 1;
    public Color outlineColor = new Color(1, 1, 1, 1);
    [Header("描边强度")]
    [Range(0.2f, 10.0f)]
    public float outlinePower = 2;
    public Material outlineMaterial
    {
        get
        {
            _material = CheckShaderAndCreateMaterial(shader, _material);
            return _material;
        }
    }

    void Awake()
    {
        mainCamera = GetComponent<Camera>();
        if (mainCamera == null)
            return;
        createPurecolorRenderTexture();
    }

    // ---------------------------【创建一个RenderTexture】---------------------------
    private void createPurecolorRenderTexture()
    {
        outlineCamera.cullingMask = 1 << LayerMask.NameToLayer("Player");
        int width = outlineCamera.pixelWidth >> downSample;
        int height = outlineCamera.pixelHeight >> downSample;
        renderTexture = RenderTexture.GetTemporary(width, height, 0);
    }

    // ---------------------------【渲染之前调用】---------------------------
    private void OnPreRender()
    {
        if (outlineCamera.enabled)
        {
            //设置创建好的RenderTexture
            outlineCamera.targetTexture = renderTexture;
            //渲染了一张纯色RenderTexture
            outlineCamera.RenderWithShader(purecolorShader, "");
        }
    }
    //-------------------------------------【OnRenderImage函数】------------------------------------    
    // 说明：此函数在当完成所有渲染图片后被调用，用来渲染图片后期效果
    //--------------------------------------------------------------------------------------------------------  
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        int rtW = source.width >> downSample;
        int rtH = source.height >> downSample;
        var temp1 = RenderTexture.GetTemporary(rtW, rtH, 0);
        var temp2 = RenderTexture.GetTemporary(rtW, rtH, 0);
        // 高斯模糊处理
        Graphics.Blit(renderTexture, temp1);
        for (int i = 0; i < iterations; i++)
        {
            outlineMaterial.SetFloat("_BlurSize", 1.0f + i * blurSpread);
            //垂直高斯模糊
            Graphics.Blit(temp1, temp2, outlineMaterial, 0);
            //水平高斯模糊
            Graphics.Blit(temp2, temp1, outlineMaterial, 1);
        }
        //用模糊图和原始图计算出轮廓图
        outlineMaterial.SetColor("_OutlineColor", outlineColor);
        outlineMaterial.SetFloat("_OutlinePower", outlinePower);
        outlineMaterial.SetTexture("_BlurTex", temp1);
        outlineMaterial.SetTexture("_SrcTex", renderTexture);
        Graphics.Blit(source, destination, outlineMaterial, 2);

        RenderTexture.ReleaseTemporary(temp1);
        RenderTexture.ReleaseTemporary(temp2);
    }
}