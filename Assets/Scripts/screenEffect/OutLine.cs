using System.Collections;
using UnityEngine;

//编辑状态下也运行  
[ExecuteInEditMode]
//继承自PostEffectsbase
public class OutLine : PostEffectsBase {
    //主相机
    private Camera mainCamera = null;
    //渲染纹理
    private RenderTexture renderTexture = null;
    private Material _material = null;

    /// 辅助摄像机  
    public Camera outlineCamera;
    // 纯色shader
    public Shader purecolorShader;
    //描边处理的shader
    public Shader shader;
    //迭代次数
    [Range (0, 4)]
    public int iterations = 3;
    // Blur spread for each iteration - larger value means more blur
    //模糊扩散范围
    [Range (0.2f, 3.0f)]
    public float blurSpread = 0.6f;
    private int downSample = 1;
    public Color outlineColor = new Color(1,1,1,1);

    public Material outlineMaterial {
        get {
            _material = CheckShaderAndCreateMaterial (shader, _material);
            return _material;
        }
    }

    void Awake () {
        mainCamera = GetComponent<Camera> ();
        if (mainCamera == null)
            return;
        createPurecolorRenderTexture ();
    }

    private void createPurecolorRenderTexture () {
        outlineCamera.cullingMask = 1 << LayerMask.NameToLayer ("Player");
        int width = outlineCamera.pixelWidth >> downSample;
        int height = outlineCamera.pixelHeight >> downSample;
        renderTexture = RenderTexture.GetTemporary (width, height, 0);
    }

    private void OnPreRender () {
        if (outlineCamera.enabled) {
            outlineCamera.targetTexture = renderTexture;
            outlineCamera.RenderWithShader (purecolorShader, ""); //渲染了一张纯色RT
        }
    }
    private void OnRenderImage (RenderTexture source, RenderTexture destination) {
        int rtW = source.width >> downSample;
        int rtH = source.height >> downSample;
        var temp1 = RenderTexture.GetTemporary (rtW, rtH, 0);
        var temp2 = RenderTexture.GetTemporary (rtW, rtH, 0);
        // 高斯模糊处理
        Graphics.Blit (renderTexture, temp1);
        for (int i = 0; i < iterations; i++) {
            outlineMaterial.SetFloat ("_BlurSize", 1.0f + i * blurSpread);
            //垂直高斯模糊
            Graphics.Blit (temp1, temp2, outlineMaterial, 0);
            //水平高斯模糊
            Graphics.Blit (temp2, temp1, outlineMaterial, 1);
        }
        //用模糊图和原始图计算出轮廓图
        outlineMaterial.SetColor("_OutlineColor", outlineColor);
        outlineMaterial.SetTexture ("_BlurTex", temp1);
        outlineMaterial.SetTexture ("_SrcTex", renderTexture);
        Graphics.Blit (source, destination, outlineMaterial, 2);

    }
}