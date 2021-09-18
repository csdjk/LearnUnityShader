using UnityEngine;
using System.Collections;

public class ShapeOutline : MonoBehaviour {

    public Camera objectCamera = null;
    public Color outlineColor = Color.green;
    Camera mainCamera;
    RenderTexture depthTexture;
    RenderTexture occlusionTexture;
    RenderTexture strechTexture;

    // Use this for initialization
    void Start()
    {
        mainCamera = Camera.main;
        mainCamera.depthTextureMode = DepthTextureMode.Depth;
        objectCamera.depthTextureMode = DepthTextureMode.None;
        objectCamera.cullingMask = 1 << LayerMask.NameToLayer("Outline");
        objectCamera.fieldOfView = mainCamera.fieldOfView;
        objectCamera.clearFlags = CameraClearFlags.Color;
        objectCamera.projectionMatrix = mainCamera.projectionMatrix;
        objectCamera.nearClipPlane = mainCamera.nearClipPlane;
        objectCamera.farClipPlane = mainCamera.farClipPlane;
        objectCamera.aspect = mainCamera.aspect;
        objectCamera.orthographic = false;
        objectCamera.enabled = false;
    }

    void OnRenderImage(RenderTexture srcTex, RenderTexture dstTex)
    {
        depthTexture = RenderTexture.GetTemporary(Screen.width, Screen.height, 24, RenderTextureFormat.Depth);
        occlusionTexture = RenderTexture.GetTemporary(Screen.width, Screen.height, 0);
        strechTexture = RenderTexture.GetTemporary(Screen.width, Screen.height, 0);

        objectCamera.targetTexture = depthTexture;
        objectCamera.RenderWithShader(Shader.Find("ShapeOutline/Depth"), string.Empty);

        Material mat = new Material(Shader.Find("ShapeOutline/Occlusion"));
        mat.SetColor("_OutlineColor", outlineColor);
        Graphics.Blit(depthTexture, occlusionTexture, mat);

        mat = new Material(Shader.Find("ShapeOutline/StrechOcclusion"));
        mat.SetColor("_OutlineColor", outlineColor);
        Graphics.Blit(occlusionTexture, strechTexture, mat);

        mat = new Material(Shader.Find("ShapeOutline/Mix"));
        mat.SetColor("_OutlineColor", outlineColor);
        mat.SetTexture("_occlusionTex", occlusionTexture);
        mat.SetTexture("_strechTex", strechTexture);
        Graphics.Blit(srcTex, dstTex, mat);

        RenderTexture.ReleaseTemporary(depthTexture);
        RenderTexture.ReleaseTemporary(occlusionTexture);
        RenderTexture.ReleaseTemporary(strechTexture);

    }
}