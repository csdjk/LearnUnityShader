using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ShadowMap : MonoBehaviour
{

    public LayerMask shadowLayers;

    public int resolution = 512;

    [Range(0, 1)]
    public float shadowStrength = 0.5f;

    private Shader shadowMapCreatorShader;
    private LayerMask shadowLayersCache;
    private int resolutionCache;
    private GameObject shadowLightGo;
    private RenderTexture shadowMapRT;
    private Camera lightCamera;

    private void OnEnable()
    {

        if (shadowMapCreatorShader == null)
            shadowMapCreatorShader = Shader.Find("lcl/Shadows/CustomShadowMap/ShadowMapCreator");
        CreateShadowCamera();
    }

    void OnDisable()
    {
        shadowMapCreatorShader = null;
        GameObject.DestroyImmediate(shadowLightGo);
        shadowMapRT.Release();
        shadowMapRT = null;
        shadowLightGo = null;
    }

    void Update()
    {
        if (shadowLayersCache != shadowLayers)
        {

            lightCamera.cullingMask = shadowLayers;
            shadowLayersCache = shadowLayers;
        }
        if (resolutionCache != resolution)
        {
            lightCamera.targetTexture = CreateRenderTexture(lightCamera);
            resolutionCache = resolution;
        }


        lightCamera.RenderWithShader(shadowMapCreatorShader, "");
        Matrix4x4 projectionMatrix = GL.GetGPUProjectionMatrix(lightCamera.projectionMatrix, false);
        Shader.SetGlobalMatrix("_gWorldToShadow", projectionMatrix * lightCamera.worldToCameraMatrix);
        Shader.SetGlobalFloat("_gShadowStrength", shadowStrength);
    }


    public void CreateShadowCamera()
    {
        if (shadowLightGo)
            return;

        shadowLightGo = new GameObject("Shadow Camera");
        shadowLightGo.transform.parent = transform;
        shadowLightGo.transform.localPosition = Vector3.zero;
        shadowLightGo.transform.localScale = Vector3.zero;
        shadowLightGo.transform.localEulerAngles = Vector3.zero;

        lightCamera = shadowLightGo.AddComponent<Camera>();
        lightCamera.backgroundColor = Color.white;
        lightCamera.clearFlags = CameraClearFlags.SolidColor;
        lightCamera.orthographic = true;
        lightCamera.orthographicSize = 6f;
        lightCamera.nearClipPlane = 0.3f;
        lightCamera.farClipPlane = 20;
        lightCamera.enabled = false;
        lightCamera.cullingMask = shadowLayers;
        lightCamera.targetTexture = CreateRenderTexture(lightCamera);

        return;
    }

    private RenderTexture CreateRenderTexture(Camera cam)
    {
        if (shadowMapRT)
        {
            shadowMapRT.Release();
            shadowMapRT = null;
        }

        RenderTextureFormat rtFormat = RenderTextureFormat.ARGB32;
        if (!SystemInfo.SupportsRenderTextureFormat(rtFormat))
            rtFormat = RenderTextureFormat.Default;

        shadowMapRT = new RenderTexture(resolution, resolution, 24, rtFormat);
        shadowMapRT.hideFlags = HideFlags.DontSave;

        Shader.SetGlobalTexture("_gShadowMapTexture", shadowMapRT);

        return shadowMapRT;
    }

    private void OnGUI()
    {
        GUI.DrawTexture(new Rect(0, 0, 128, 128), shadowMapRT, ScaleMode.ScaleToFit, false, 1);
    }
}
