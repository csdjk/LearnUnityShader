using UnityEngine;
public class RadialBlur : PostEffectsBase
{
    static readonly string shaderName = "lcl/screenEffect/RadialBlur";
    //模糊程度
    [Range(0, 0.05f)]
    public float blurFactor = 0.0f;
    //模糊中心（0-1）屏幕空间，默认为中心点
    public Vector2 blurCenter = new Vector2(0.5f, 0.5f);

    void OnEnable()
    {
        shader = Shader.Find(shaderName);
    }
    // 后期处理
    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material)
        {
            material.SetFloat("_BlurFactor", blurFactor);
            material.SetVector("_BlurCenter", blurCenter);
            Graphics.Blit(source, destination, material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }

}