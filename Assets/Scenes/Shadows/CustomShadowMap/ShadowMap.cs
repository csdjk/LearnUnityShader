using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum ShadowResolution
{
    [InspectorName("512")]
    Low = 512,
    [InspectorName("1024")]
    Normal = 1024,
    [InspectorName("2048")]
    Height = 2048,
}

public enum ShadowType
{
    [InspectorName("Simple")]
    SHADOW_SIMPLE,

    [InspectorName("PCF")]
    SHADOW_PCF,

    [InspectorName("PCF(POISSON_DISK)")]
    SHADOW_PCF_POISSON_DISK,

    [InspectorName("PCSS")]
    SHADOW_PCSS,

    [InspectorName("ESM")]
    SHADOW_ESM,

    [InspectorName("VSM")]
    SHADOW_VSM,
}
[ExecuteInEditMode]
public class ShadowMap : MonoBehaviour
{
    public LayerMask shadowLayers = 1;
    public ShadowType shadowType = ShadowType.SHADOW_SIMPLE;

    public ShadowResolution resolution = ShadowResolution.Normal;
    [Range(0, 10)]
    public float filterStride = 1.0f;
    [Range(0, 1)]
    public float shadowStrength = 1.0f;

    [Range(0, 1)]
    public float bias = 0.0001f;
    [Range(0, 10)]
    public float lightWidth = 1.0f;

    // ------------------ESM Parameters------------
    [Range(0, 100)]
    public float expConst = 1.0f;
    [Range(0.2f, 3.0f)]
    public float blurRadius = 1.0f;
    [Range(1, 8)]
    public int downSample = 2;
    [Range(0, 4)]
    public int iteration = 1;
    // ------------------ESM------------

    // ------------------VSM Parameters------------

    [Range(0, 1f)]
    public float lightLeakBias = 1;
    [Range(0, 0.01f)]
    public float varianceBias = 0.0001f;

    // ------------------VSM------------



    private Shader shadowMapCreatorShader;
    private LayerMask shadowLayersCache;
    private ShadowResolution resolutionCache;
    private GameObject shadowLightGo;
    private RenderTexture shadowMapRT;
    private Camera lightCamera;
    private Material gaussBlurMat;

    void OnEnable()
    {

        Clean();
        CreateShadowCamera();
    }

    void OnDisable()
    {
        Clean();
    }

    void Clean()
    {
        for (int i = 0; i < transform.childCount; i++)
        {
            DestroyImmediate(transform.GetChild(0).gameObject);
        }
        RenderTexture.ReleaseTemporary(shadowMapRT);
    }


    void Update()
    {
        if (!shadowLayersCache.Equals(shadowLayers))
        {
            lightCamera.cullingMask = shadowLayers;
            shadowLayersCache = shadowLayers;
        }
        if (!resolutionCache.Equals(resolution))
        {
            lightCamera.targetTexture = CreateRenderTexture(lightCamera);
            resolutionCache = resolution;
        }

        Matrix4x4 projectionMatrix = GL.GetGPUProjectionMatrix(lightCamera.projectionMatrix, false);
        Shader.SetGlobalMatrix("_gWorldToShadow", projectionMatrix * lightCamera.worldToCameraMatrix);
        // 
        Shader.SetGlobalFloat("_gShadowStrength", shadowStrength);
        Shader.SetGlobalFloat("_gShadow_bias", bias);
        Shader.SetGlobalFloat("_gFilterStride", filterStride);
        Shader.SetGlobalFloat("_gLightWidth", lightWidth);
        Shader.SetGlobalFloat("_gExpConst", expConst);
        Shader.SetGlobalFloat("_gLightLeakBias", lightLeakBias);
        Shader.SetGlobalFloat("_gVarianceBias", varianceBias);

        if (shadowType == ShadowType.SHADOW_ESM || shadowType == ShadowType.SHADOW_VSM)
            GaussBlur(shadowMapRT);
        else
            Shader.SetGlobalTexture("_gShadowMapTexture", shadowMapRT);

        // 阴影类型
        string shadowTypeName = Enum.GetName(typeof(ShadowType), shadowType);
        foreach (var type in Enum.GetNames(typeof(ShadowType)))
        {
            if (type == shadowTypeName)
                Shader.EnableKeyword(type);
            else
                Shader.DisableKeyword(type);
        }
    }

    public void CreateShadowCamera()
    {
        shadowLightGo = new GameObject("Shadow Camera");
        shadowLightGo.transform.parent = transform;
        shadowLightGo.transform.localPosition = Vector3.zero;
        shadowLightGo.transform.localScale = Vector3.zero;
        shadowLightGo.transform.localEulerAngles = Vector3.zero;

        lightCamera = shadowLightGo.AddComponent<Camera>();
        lightCamera.backgroundColor = Color.white;
        lightCamera.clearFlags = CameraClearFlags.SolidColor;
        lightCamera.orthographic = true;
        lightCamera.orthographicSize = 10f;
        lightCamera.nearClipPlane = 0.3f;
        lightCamera.farClipPlane = 100;
        lightCamera.cullingMask = shadowLayers;
        lightCamera.targetTexture = CreateRenderTexture(lightCamera);

        if (shadowMapCreatorShader == null)
            shadowMapCreatorShader = Shader.Find("lcl/Shadows/CustomShadowMap/ShadowMapCreator");
        lightCamera.SetReplacementShader(shadowMapCreatorShader, "");
        return;
    }

    private RenderTexture CreateRenderTexture(Camera cam)
    {
        if (shadowMapRT)
        {
            RenderTexture.ReleaseTemporary(shadowMapRT);
            shadowMapRT = null;
        }

        RenderTextureFormat rtFormat = RenderTextureFormat.ARGB32;
        if (!SystemInfo.SupportsRenderTextureFormat(rtFormat))
            rtFormat = RenderTextureFormat.Default;

        var resolutionValue = (int)resolution;
        shadowMapRT = RenderTexture.GetTemporary(resolutionValue, resolutionValue, 64, rtFormat);
        shadowMapRT.hideFlags = HideFlags.DontSave;

        Shader.SetGlobalTexture("_gShadowMapTexture", shadowMapRT);
        return shadowMapRT;
    }

    void GaussBlur(RenderTexture targetTexure)
    {
        if (targetTexure == null)
            return;

        if (gaussBlurMat == null)
        {
            gaussBlurMat = CreateGaussBlurMaterial();
        }
        RenderTexture rt1 = RenderTexture.GetTemporary(targetTexure.width >> downSample, targetTexure.height >> downSample, 0, targetTexure.format);
        RenderTexture rt2 = RenderTexture.GetTemporary(targetTexure.width >> downSample, targetTexure.height >> downSample, 0, targetTexure.format);

        Graphics.Blit(targetTexure, rt1);

        for (int i = 0; i < iteration; i++)
        {
            gaussBlurMat.SetVector("_offsets", new Vector4(0, blurRadius, 0, 0));
            Graphics.Blit(rt1, rt2, gaussBlurMat);
            gaussBlurMat.SetVector("_offsets", new Vector4(blurRadius, 0, 0, 0));
            Graphics.Blit(rt2, rt1, gaussBlurMat);
        }
        Shader.SetGlobalTexture("_gShadowMapTexture", rt1);

        RenderTexture.ReleaseTemporary(rt1);
        RenderTexture.ReleaseTemporary(rt2);
    }

    Material CreateGaussBlurMaterial()
    {
        var material = new Material(Shader.Find("lcl/screenEffect/gaussBlur"));
        material.hideFlags = HideFlags.DontSave;
        return material;
    }

    private void OnGUI()
    {
        GUI.DrawTexture(new Rect(0, 0, 128, 128), shadowMapRT, ScaleMode.ScaleToFit, false, 1);
    }
}
