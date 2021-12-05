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
}
[ExecuteInEditMode]
public class ShadowMap : MonoBehaviour
{
    public LayerMask shadowLayers = 1;
    public ShadowType shadowType = ShadowType.SHADOW_SIMPLE;

    public ShadowResolution resolution = ShadowResolution.Normal;
    [Range(1, 50)]
    public float filterStride = 1.0f;

    [Range(0, 1)]
    public float shadowStrength = 1.0f;

    [Range(0, 1)]
    public float bias = 0.0001f;
    [Range(0, 10)]
    public float lightWidth = 1.0f;


    private Shader shadowMapCreatorShader;
    private LayerMask shadowLayersCache;
    private ShadowResolution resolutionCache;
    private GameObject shadowLightGo;
    private RenderTexture shadowMapRT;
    private Camera lightCamera;

    // Vector4 fract(Vector4 v)
    // {
    //     var zhengx = Mathf.Floor(v.x);
    //     var zhengy = Mathf.Floor(v.y);
    //     var zhengz = Mathf.Floor(v.z);
    //     var zhengw = Mathf.Floor(v.w);
    //     return new Vector4(v.x % zhengx, v.y % zhengy, v.z % zhengz, v.w % zhengw);
    // }

    // Vector4 pack(float depth)
    // {
    //     // 使用rgba 4字节共32位来存储z值,1个字节精度为1/10
    //     // Vector4 bitShift = new Vector4(1.0f, 256.0f, 256.0f * 256.0f, 256.0f * 256.0f * 256.0f);
    //     // Vector4 bitMask = new Vector4(1.0f / 256.0f, 1.0f / 256.0f, 1.0f / 256.0f, 0.0f);
    //     // // gl_FragCoord:片元的坐标,fract():返回数值的小数部分
    //     // Vector4 rgbaDepth = fract(depth * bitShift); //计算每个点的z值
    //     // // rgbaDepth -= rgbaDepth.gbaa * bitMask; // Cut off the value which do not fit in 8 bits

    //     // Vector4 gbaa = new Vector4(rgbaDepth.y * bitMask.x, rgbaDepth.z * bitMask.y, rgbaDepth.w * bitMask.z, rgbaDepth.w * bitMask.w);

    //     // rgbaDepth.x -= gbaa.x;
    //     // rgbaDepth.y -= gbaa.y;
    //     // rgbaDepth.z -= gbaa.z;
    //     // rgbaDepth.w -= gbaa.w;

    //     var tow256 = 256.0f * 256.0f;
    //     var three256 = 256.0f * 256.0f * 256.0f;
    //     var foure256 = 256.0f * 256.0f * 256.0f * 256.0f;
    //     Vector4 rgbaDepth = new Vector4();
    //     rgbaDepth.x = 1 / depth - 1 / (depth * tow256);//R
    //     rgbaDepth.y = 1 / (depth * 255) - 1 / (depth * three256);//G
    //     rgbaDepth.z = 1 / (depth * tow256) - 1 / (depth * foure256);//B
    //     rgbaDepth.w = 1 / (depth * three256) - 1 / (depth * foure256);//A
    //     return rgbaDepth;
    // }
    // float unpack(Vector4 rgbaDepth)
    // {
    //     Vector4 bitShift = new Vector4(1.0f, 1.0f / 256.0f, 1.0f / (256.0f * 256.0f), 1.0f / (256.0f * 256.0f * 256.0f));
    //     return Vector4.Dot(rgbaDepth, bitShift);
    // }


    // void Start()
    // {
    //     Debug.Log(pack(2.1987f));
    //     Debug.Log(unpack(pack(2.1987f)));
    // }

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
        

        // 阴影类型
        string shadowTypeName = Enum.GetName(typeof(ShadowType), shadowType);
        Shader.EnableKeyword(shadowTypeName);
        if (shadowType == ShadowType.SHADOW_SIMPLE)
        {
            Shader.DisableKeyword("SHADOW_PCF");
            Shader.DisableKeyword("SHADOW_PCF_POISSON_DISK");
            Shader.DisableKeyword("SHADOW_PCSS");
        }
        else if (shadowType == ShadowType.SHADOW_PCF)
        {
            Shader.DisableKeyword("SHADOW_SIMPLE");
            Shader.DisableKeyword("SHADOW_PCF_POISSON_DISK");
            Shader.DisableKeyword("SHADOW_PCSS");
        }
        else if (shadowType == ShadowType.SHADOW_PCF_POISSON_DISK)
        {
            Shader.DisableKeyword("SHADOW_SIMPLE");
            Shader.DisableKeyword("SHADOW_PCF");
            Shader.DisableKeyword("SHADOW_PCSS");
        }
        else if (shadowType == ShadowType.SHADOW_PCSS)
        {
            Shader.DisableKeyword("SHADOW_SIMPLE");
            Shader.DisableKeyword("SHADOW_PCF");
            Shader.DisableKeyword("SHADOW_PCF_POISSON_DISK");
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
        shadowMapRT = RenderTexture.GetTemporary(resolutionValue, resolutionValue, 24, rtFormat);
        shadowMapRT.hideFlags = HideFlags.DontSave;

        Shader.SetGlobalTexture("_gShadowMapTexture", shadowMapRT);
        return shadowMapRT;
    }

    private void OnGUI()
    {
        GUI.DrawTexture(new Rect(0, 0, 128, 128), shadowMapRT, ScaleMode.ScaleToFit, false, 1);
    }
}
