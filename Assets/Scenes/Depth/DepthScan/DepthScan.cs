using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class DepthScan : PostEffectsBase
{
    [Range(0.0f, 1.0f)]
    public float scanValue = 0.05f;
    [Range(0.0f, 0.1f)]
    public float scanLineWidth = 0.02f;
    [Range(0.0f, 10.0f)]
    public float scanLightStrength = 10.0f;
    public Color scanLineColor = Color.white;
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material == null)
        {
            Graphics.Blit(source, destination);
        }
        else
        {
            //限制一下最大值，最小值
            float lerpValue = Mathf.Min(0.95f, 1 - scanValue);
            if (lerpValue < 0.0005f)
                lerpValue = 1;

            //此处可以一个vec4传进去优化
            material.SetFloat("_ScanValue", lerpValue);
            material.SetFloat("_ScanLineWidth", scanLineWidth);
            material.SetFloat("_ScanLightStrength", scanLightStrength);
            material.SetColor("_ScanLineColor", scanLineColor);
            Graphics.Blit(source, destination, material);
        }
    }
}
