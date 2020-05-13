using System.Collections;
using UnityEngine;
// ---------------------------【Bloom 全屏泛光后期】---------------------------
//编辑状态下也运行  
[ExecuteInEditMode]
public class Bloom : PostEffectsBase
{
    public Shader bloomShader;
    private Material mMaterial;
    //bloom处理的shader
    public Material material
    {
        get
        {
            mMaterial = CheckShaderAndCreateMaterial(bloomShader, mMaterial);
            return mMaterial;
        }
    }
    //迭代次数
    [Range(0, 4)]
    public int iterations = 3;

    //模糊扩散范围
    [Range(0.2f, 3.0f)]
    public float blurSpread = 0.6f;
    // 降频
    private int downSample = 1;

    // 亮度阙值
    [Range(-1.0f, 1.0f)]
    public float luminanceThreshold = 0.6f;
    // bloom 颜色值
    public Color bloomColor = new Color(1, 1, 1, 1);

    void Awake()
    {
        bloomShader = Shader.Find("lcl/screenEffect/Bloom");
    }

    //-------------------------------------【OnRenderImage函数】------------------------------------    
    // 说明：此函数在当完成所有渲染图片后被调用，用来渲染图片后期效果
    //--------------------------------------------------------------------------------------------------------  
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material)
        {
            int rtW = source.width >> downSample;
            int rtH = source.height >> downSample;
            RenderTexture texture1 = RenderTexture.GetTemporary(rtW, rtH, 0);
            RenderTexture texture2 = RenderTexture.GetTemporary(rtW, rtH, 0);
            // 亮度提取
            material.SetFloat("_LuminanceThreshold", luminanceThreshold);
            
            Graphics.Blit(source, texture1, material, 0);

            // 高斯模糊
            for (int i = 0; i < iterations; i++)
            {
                //垂直高斯模糊
                material.SetVector("_offsets", new Vector4(0, 1.0f + i * blurSpread, 0, 0));
                Graphics.Blit(texture1, texture2, material, 1);
                //水平高斯模糊
                material.SetVector("_offsets", new Vector4(1.0f + i * blurSpread, 0, 0, 0));
                Graphics.Blit(texture2, texture1, material, 1);
            }
            //用模糊图和原始图计算出轮廓图
            material.SetColor("_BloomColor", bloomColor);
            material.SetTexture("_BlurTex", texture1);
            Graphics.Blit(source, destination, material, 2);
        }
    }
}