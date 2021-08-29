// ---------------------------【SSSSS】---------------------------
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
public class GaussBlurSSS : PostEffectsBase
{
    private RenderTexture renderTexture = null;
    private CommandBuffer commandBuffer = null;
    private Material _material = null;
    private Material purecolorMaterial;

    public Color sssColor = new Color(1, 0.2f, 0, 0);

    [Header("强度")]
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

    public Material material
    {
        get
        {
            // _material = CheckShaderAndCreateMaterial(gaussianBlurShader, _material);
            return _material;
        }
    }
    //-----------------------------------------【Start()函数】---------------------------------------------    
    void Start()
    {
        //找到当前的Shader文件  
        // gaussianBlurShader = Shader.Find("lcl/SubsurfaceScattering/ScreenSpaceSSS/ScreenSpaceSSS");
    }

    //-------------------------------------【OnRenderImage函数】------------------------------------    
    // 说明：此函数在当完成所有渲染图片后被调用，用来渲染图片后期效果
    //--------------------------------------------------------------------------------------------------------  
    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material)
        {
            //申请RenderTexture，RT的分辨率按照downSample降低  
            RenderTexture rt1 = RenderTexture.GetTemporary(source.width >> downSample, source.height >> downSample, 0, source.format);
            RenderTexture rt2 = RenderTexture.GetTemporary(source.width >> downSample, source.height >> downSample, 0, source.format);

            //直接将原图拷贝到降分辨率的RT上  
            Graphics.Blit(source, rt1);

            //进行迭代高斯模糊  
            for (int i = 0; i < iteration; i++)
            {
                //垂直高斯模糊
                material.SetVector("_offsets", new Vector4(0, blurRadius, 0, 0));
                Graphics.Blit(rt1, rt2, material, 0);
                //水平高斯模糊
                material.SetVector("_offsets", new Vector4(blurRadius, 0, 0, 0));
                Graphics.Blit(rt2, rt1, material, 0);
            }

            material.SetTexture("_BlurTex", rt1);
            material.SetFloat("_ScatteringStrenth", scatteringStrenth);
            material.SetColor("_SSSColor", sssColor);

            //将结果输出  
            Graphics.Blit(source, destination, material, 1);

            //释放申请的RenderBuffer
            RenderTexture.ReleaseTemporary(rt1);
            RenderTexture.ReleaseTemporary(rt2);
        }
    }
}