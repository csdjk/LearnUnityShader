using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class DepthScan : SimplePostEffectsBase
{
    [Range(0.0f, 1.0f)]
    public float scanValue = 0.05f;
    [Range(0.0f, 0.5f)]
    public float scanLineWidth = 0.02f;
    [Range(0.0f, 10.0f)]
    public float scanLightStrength = 10.0f;
    public Color scanLineColor = Color.white;
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (_Material == null)
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
            _Material.SetFloat("_ScanValue", lerpValue);
            _Material.SetFloat("_ScanLineWidth", scanLineWidth);
            _Material.SetFloat("_ScanLightStrength", scanLightStrength);
            _Material.SetColor("_ScanLineColor", scanLineColor);
            Graphics.Blit(source, destination, _Material);
        }
    }
}
