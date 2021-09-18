using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class DepthShieldOutline : MonoBehaviour
{

    public Camera objectCamera = null;
    public Color outlineColor = Color.green;
    public Shader outlineShader;
    //模糊半径  
    [Header("模糊半径")]
    [Range(0.2f, 10.0f)]
    public float BlurRadius = 1.0f;
    //降采样次数
    [Header("降采样次数")]
    [Range(1, 8)]
    public int downSample = 2;
    //迭代次数  
    [Header("迭代次数")]
    [Range(0, 4)]
    public int iteration = 1;

    private Camera mainCamera;
    private RenderTexture depthTexture;
    private Material outlineMaterial;


    // Use this for initialization
    void Start()
    {
        mainCamera = Camera.main;
        mainCamera.depthTextureMode = DepthTextureMode.Depth;
        objectCamera.depthTextureMode = DepthTextureMode.Depth;

        outlineMaterial = new Material(outlineShader);
        createPurecolorRenderTexture();
    }

    private void createPurecolorRenderTexture()
    {
        // objectCamera.cullingMask = 1 << LayerMask.NameToLayer ("Player");
        depthTexture = RenderTexture.GetTemporary(Screen.width, Screen.height, 24, RenderTextureFormat.ARGBHalf, RenderTextureReadWrite.Default, 8);
        // objectCamera.targetTexture = depthTexture;
        // objectCamera.RenderWithShader(Shader.Find("lcl/DepthShieldOutline/ObjectDepth"), "");
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
        Graphics.Blit(srcTex, dstTex, outlineMaterial, 0);


        // Graphics.Blit(srcTex, temp1, outlineMaterial, 0);

        // // 模糊处理
        // for (int i = 0; i < iteration; i++)
        // {
        //     outlineMaterial.SetFloat("_BlurRadius", BlurRadius);
        //     Graphics.Blit(temp1, temp2, outlineMaterial, 1);
        //     Graphics.Blit(temp2, temp1, outlineMaterial, 1);
        // }

        // outlineMaterial.SetTexture("_BlurTex", temp1);
        // Graphics.Blit(srcTex, dstTex, outlineMaterial, 2);


        RenderTexture.ReleaseTemporary(temp1);
        RenderTexture.ReleaseTemporary(temp2);
    }

    //  private void OnGUI() {
    //     GUI.DrawTexture(new Rect(0,0,256,256),depthTexture,ScaleMode.ScaleToFit,false,1);
    // }
}