// https://blog.csdn.net/puppet_master/article/details/54000951

using System.Collections;
using UnityEngine;

//编辑状态下也运行
[ExecuteInEditMode]
//继承自PostEffectsbase
public class OutLine_c : PostEffectsBase
{
    //主相机
    private Camera mainCamera = null;
    //渲染纹理
    private RenderTexture renderTexture = null;
    /// 辅助摄像机  
    public Camera outlineCamera;
    public LayerMask outlineLayer;

    // 纯色shader
    public Shader purecolorShader;
    //迭代次数
    [Range(0, 4)]
    public int iterations = 3;
    // Blur spread for each iteration - larger value means more blur
    //模糊扩散范围
    [Range(0.2f, 3.0f)]
    public float blurSpread = 0.6f;
    private int downSample = 1;
    public Color outlineColor = new Color(1, 1, 1, 1);

   

    void Awake()
    {
        mainCamera = GetComponent<Camera>();
        if (mainCamera == null)
            return;
        createPurecolorRenderTexture();
    }

    private void createPurecolorRenderTexture()
    {
        outlineCamera.cullingMask = outlineLayer;
        int width = outlineCamera.pixelWidth >> downSample;
        int height = outlineCamera.pixelHeight >> downSample;
        renderTexture = RenderTexture.GetTemporary(width, height, 0);
    }

    private void OnPreRender()
    {
        if (outlineCamera.enabled)
        {
            outlineCamera.targetTexture = renderTexture;
            outlineCamera.RenderWithShader(purecolorShader, ""); //渲染了一张纯色RT
        }
    }
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        int rtW = source.width >> downSample;
        int rtH = source.height >> downSample;
        var temp1 = RenderTexture.GetTemporary(rtW, rtH, 0);
        var temp2 = RenderTexture.GetTemporary(rtW, rtH, 0);
        // 高斯模糊处理
        Graphics.Blit(renderTexture, temp1);
        for (int i = 0; i < iterations; i++)
        {
            //垂直高斯模糊
            material.SetVector("_offsets", new Vector4(0, 1.0f + i * blurSpread, 0, 0));
            Graphics.Blit(temp1, temp2, material, 0);
            //水平高斯模糊
            material.SetVector("_offsets", new Vector4(1.0f + i * blurSpread, 1, 0, 0));
            Graphics.Blit(temp2, temp1, material, 0);
        }
        //用模糊图和原始图计算出轮廓图
        material.SetColor("_OutlineColor", outlineColor);
        material.SetTexture("_BlurTex", temp1);
        material.SetTexture("_SrcTex", renderTexture);
        Graphics.Blit(source, destination, material, 1);

        RenderTexture.ReleaseTemporary(temp1);
        RenderTexture.ReleaseTemporary(temp2);
    }
}