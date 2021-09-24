using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class DepthShieldOutline : MonoBehaviour
{
    public Camera objectCamera = null;
    public Color outlineColor = Color.green;
    [Header("描边强度")]
    [Range(0.2f, 10.0f)]
    public float outlinePower = 2;

    //模糊半径  
    [Header("模糊半径")]
    [Range(0.2f, 10.0f)]
    public float BlurRadius = 1.0f;
    // //降采样次数
    // [Header("降采样次数")]
    // [Range(1, 8)]
    // public int downSample = 2;
    //迭代次数  
    [Header("迭代次数")]
    [Range(0, 4)]
    public int iteration = 1;
    private Camera mainCamera;
    private RenderTexture depthTexture;
    private Material outlineMaterial;

    void Start()
    {
        mainCamera = Camera.main;
        mainCamera.depthTextureMode = DepthTextureMode.Depth;

        outlineMaterial = new Material(Shader.Find("lcl/Depth/Depth_OutlineShader"));
        SetObjectCamera();
    }

    private void SetObjectCamera()
    {
        objectCamera.CopyFrom(mainCamera);
        // objectCamera.cullingMask = 1 << LayerMask.NameToLayer("Player");
        objectCamera.cullingMask = (1 << LayerMask.NameToLayer("PostProcessing")) | (1 << LayerMask.NameToLayer("Player"));
        objectCamera.depth -= 1;
        objectCamera.backgroundColor = Color.white;
        objectCamera.enabled = false;
        objectCamera.clearFlags = CameraClearFlags.SolidColor;
        // 注意这里 抗锯齿一定要和场景深度图抗锯齿一致
        depthTexture = RenderTexture.GetTemporary(Screen.width, Screen.height, 24, RenderTextureFormat.ARGBHalf, RenderTextureReadWrite.Default, 1);
    }

    private void OnPreRender()
    {
        objectCamera.targetTexture = depthTexture;
        objectCamera.RenderWithShader(Shader.Find("lcl/DepthShieldOutline/ObjectDepth"), "");
    }

    void OnRenderImage(RenderTexture srcTex, RenderTexture dstTex)
    {
        var temp1 = RenderTexture.GetTemporary(Screen.width, Screen.height, 0);
        var temp2 = RenderTexture.GetTemporary(Screen.width, Screen.height, 0);
        // 物体深度图
        outlineMaterial.SetTexture("_ObjectDepthTex", depthTexture);
        // Graphics.Blit(srcTex, dstTex, outlineMaterial, 0);
        // Graphics.Blit(depthTexture, dstTex);

        Graphics.Blit(srcTex, temp1, outlineMaterial, 0);
        //模糊处理
        for (int i = 0; i < iteration; i++)
        {
            outlineMaterial.SetFloat("_BlurRadius", BlurRadius);
            Graphics.Blit(temp1, temp2, outlineMaterial, 1);
            Graphics.Blit(temp2, temp1, outlineMaterial, 1);
        }
        outlineMaterial.SetTexture("_BlurTex", temp1);
        outlineMaterial.SetColor("_OutlineColor", outlineColor);
        outlineMaterial.SetFloat("_OutlinePower", outlinePower);
        Graphics.Blit(srcTex, dstTex, outlineMaterial, 2);

        RenderTexture.ReleaseTemporary(temp1);
        RenderTexture.ReleaseTemporary(temp2);
    }


}