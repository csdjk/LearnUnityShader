using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SnowNoise : MonoBehaviour
{
    public Shader snowFallShader;
    private Material snowFallMat;
    private MeshRenderer meshRenderer;
    [Range(0.001f, 0.1f)]
    public float flakeAmount;
    [Range(0f, 1f)]
    public float flakeOpacity;
    void Start()
    {
        meshRenderer = GetComponent<MeshRenderer>();
        snowFallMat = new Material(snowFallShader);
    }

    // Update is called once per frame
    void Update()
    {
        snowFallMat.SetFloat("_FlakeAmount", flakeAmount);
        snowFallMat.SetFloat("_FlakeOpacity", flakeOpacity);
        RenderTexture snow = (RenderTexture)meshRenderer.material.GetTexture("_MaskTex");
        RenderTexture temp = RenderTexture.GetTemporary(snow.width, snow.height, 0, RenderTextureFormat.ARGBFloat);
        Graphics.Blit(snow, temp, snowFallMat);
        Graphics.Blit(temp, snow);
        // meshRenderer.material.SetTexture("_Splat",snow);
        RenderTexture.ReleaseTemporary(temp);
    }
}
