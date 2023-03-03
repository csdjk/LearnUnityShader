using UnityEngine;
using System.Collections;

//-----------------------------【边缘检测】-----------------------------
public class EdgeDetection : PostEffectsBase
{
    static readonly string shaderName = "lcl/learnShader3/002_EdgeDetection";

    public Shader edgeDetectShader;

    [Range(0.0f, 1.0f)]
    public float edgesOnly = 0.0f;
    public Color edgeColor = Color.black;

    public Color backgroundColor = Color.white;
    void OnEnable()
    {
        shader = Shader.Find(shaderName);
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null)
        {
            material.SetFloat("_EdgeOnly", edgesOnly);
            material.SetColor("_EdgeColor", edgeColor);
            material.SetColor("_BackgroundColor", backgroundColor);
            Graphics.Blit(src, dest, material);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
