using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 积雪填充
/// </summary>
public class SnowFall : MonoBehaviour
{
    public Shader snowFallShader;
    private Material snowFallMat;
    private MeshRenderer meshRenderer;
    [Range(0.001f, 0.1f)]
    public float flakeAmount = 0;
    [Range(0f, 1f)]
    public float flakeOpacity = 0;
    void Start()
    {
        meshRenderer = GetComponent<MeshRenderer>();
        // Shader snowFallShader = Shader.Find("lcl/SnowGround/SnowFall");
        snowFallMat = new Material(snowFallShader);
    }

    // Update is called once per frame
    private RenderTexture rt1;
    void Update()
    {
        snowFallMat.SetFloat("_FlakeAmount", flakeAmount);
        snowFallMat.SetFloat("_FlakeOpacity", flakeOpacity);
        RenderTexture snow = (RenderTexture)meshRenderer.material.GetTexture("_MaskTex");
        RenderTexture temp = RenderTexture.GetTemporary(snow.width, snow.height, 0, RenderTextureFormat.ARGBFloat);
        Graphics.Blit(snow, temp, snowFallMat);
        Graphics.Blit(temp, snow);

        rt1 = snow;
        RenderTexture.ReleaseTemporary(temp);
    }

    private void OnGUI()
    {
        GUI.DrawTexture(new Rect(Screen.width-256, 0, 256, 256), rt1, ScaleMode.ScaleToFit, false, 1);
    }
}
