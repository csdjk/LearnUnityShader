using System.Collections;
using UnityEngine;

/// <summary>
/// Bloom 移动端优化版
/// </summary>
[ExecuteInEditMode, ImageEffectAllowedInSceneView]
public class BloomMobile : PostEffectsBase
{
    public Shader bloomShader;
    private Material mMaterial;
    public Material material
    {
        get
        {
            mMaterial = CheckShaderAndCreateMaterial(bloomShader, mMaterial);
            return mMaterial;
        }
    }
    //迭代次数
    [Range(0, 10)]
    public int iterations = 5;

    [Range(0.0f, 10.0f)]
    public float threshold = 1;

    //模糊扩散范围
    [Range(0.2f, 5f)]
    public float blurAmount = 0.6f;

    [Range(0f, 10f)]
    public float bloomIntensity = 1f;


    [Range(0, 1)]
    public float softThreshold = 0.5f;

    public Color bloomColor = new Color(1, 1, 1, 1);


    RenderTexture[] textures = new RenderTexture[10];

    void Awake()
    {
        bloomShader = Shader.Find("lcl/screenEffect/BloomMobile");
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material)
        {
            int width = source.width / 2;
            int height = source.height / 2;
            RenderTextureFormat format = source.format;

            float knee = threshold * softThreshold;
            Vector4 filter;
            filter.x = threshold;
            filter.y = filter.x - knee;
            filter.z = 2f * knee;
            filter.w = 0.25f / (knee + 0.00001f);
            material.SetVector("_Filter", filter);
            material.SetFloat("_BloomAmount", bloomIntensity);
            material.SetFloat("_BlurAmount", blurAmount);

            RenderTexture currentDestination = textures[0] = RenderTexture.GetTemporary(width, height, 0, format);
            Graphics.Blit(source, currentDestination, material, 0);
            RenderTexture currentSource = currentDestination;

            // 降采样
            for (int i = 1; i < iterations; i++)
            {
                width /= 2;
                height /= 2;
                if (height < 2)
                {
                    break;
                }
                currentDestination = textures[i] = RenderTexture.GetTemporary(width, height, 0, format);
                Graphics.Blit(currentSource, currentDestination, material, 1);
                currentSource = currentDestination;
            }
            material.SetFloat("_BlurAmount", blurAmount * 0.5f);
            for (int i = iterations - 2; i >= 0; i--)
            {
                currentDestination = textures[i];
                textures[i] = null;

                Graphics.Blit(currentSource, currentDestination, material, 2);
                RenderTexture.ReleaseTemporary(currentSource);
                currentSource = currentDestination;
            }
            Graphics.Blit(currentSource, destination);

            // 合成Bloom
            material.SetColor("_BloomColor", bloomColor);
            material.SetTexture("_BlurTex", currentSource);
            Graphics.Blit(source, destination, material, 3);
            RenderTexture.ReleaseTemporary(currentSource);
        }
    }
}