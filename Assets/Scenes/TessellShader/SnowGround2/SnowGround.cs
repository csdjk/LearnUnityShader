using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 雪地脚本
/// </summary>
[ExecuteInEditMode]
[RequireComponent(typeof(MeshRenderer))]
public class SnowGround : MonoBehaviour
{
    //模糊半径  
    [Header("模糊半径")]
    [Range(0.2f, 10.0f)]
    public float blurRadius = 1.0f;
    //降采样次数
    [Header("降采样次数")]
    [Range(1, 8)]
    public int downSample = 1;
    //迭代次数  
    [Header("迭代次数")]
    [Range(0, 4)]
    public int iteration = 1;

    public Camera drawCamera;
    private Material drawMaterial;
    private RenderTexture targetRT;
    private RenderTexture curTex;
    private RenderTexture prevTex;
    void Start()
    {
        InitDrawCamera();

        // Render Texture
        targetRT = new RenderTexture(1024, 1024, 0, RenderTextureFormat.ARGBFloat);
        drawCamera.targetTexture = targetRT;
        // 纯色shader
        Shader purecolorShader = Shader.Find("lcl/Common/PureColor");
        drawCamera.SetReplacementShader(purecolorShader, "");
        // VP 矩阵
        Matrix4x4 ProjectionMatrix = GL.GetGPUProjectionMatrix(drawCamera.projectionMatrix, true);
        Matrix4x4 ViewMatrix = drawCamera.worldToCameraMatrix;
        Matrix4x4 VP_Matrix = ProjectionMatrix * ViewMatrix;


        prevTex = new RenderTexture(1024, 1024, 0, RenderTextureFormat.ARGBFloat);
        curTex = new RenderTexture(1024, 1024, 0, RenderTextureFormat.ARGBFloat);
        var groundMat = GetComponent<MeshRenderer>().sharedMaterial;
        groundMat.SetTexture("_MaskTex", curTex);
        groundMat.SetMatrix("_GroundCameraMatrixVP", VP_Matrix);


        // 叠加
        Shader drawShader = Shader.Find("lcl/SnowGround/PathDrawing");
        drawMaterial = new Material(drawShader);
    }



    /// <summary>
    /// 初始化路径捕捉Camera
    /// </summary>
    void InitDrawCamera()
    {
        drawCamera = transform.GetComponentInChildren<Camera>();
        if (drawCamera == null)
        {
            drawCamera = new GameObject("drawCamera").AddComponent<Camera>();
            drawCamera.transform.parent = transform;
        }
        drawCamera.transform.localPosition = Vector3.down;
        drawCamera.transform.localEulerAngles = Vector3.left * 90;
        drawCamera.orthographic = true;
        // drawCamera.orthographicSize = 15;
        drawCamera.backgroundColor = Color.black;
        drawCamera.cullingMask = 1 << LayerMask.NameToLayer("Player");
        drawCamera.clearFlags = CameraClearFlags.SolidColor;
        var distance = Vector3.Distance(drawCamera.transform.position, transform.position);
        drawCamera.farClipPlane = distance + 0.1f;
    }


    void Update()
    {
        RenderTexture temp = RenderTexture.GetTemporary(targetRT.width, targetRT.height, 0, RenderTextureFormat.ARGBFloat);
        drawMaterial.SetTexture("_PrevTex", prevTex);
        Graphics.Blit(targetRT, temp);
        Graphics.Blit(temp, curTex, drawMaterial, 0);

        // 存储当前帧tex
        Graphics.Blit(curTex, prevTex);

        //模糊处理（box）
        for (int i = 0; i < iteration; i++)
        {
            drawMaterial.SetFloat("_BlurRadius", blurRadius);
            Graphics.Blit(curTex, temp, drawMaterial, 1);
            Graphics.Blit(temp, curTex, drawMaterial, 1);
        }

        RenderTexture.ReleaseTemporary(temp);

    }
    // private void OnGUI()
    // {
    //     GUI.DrawTexture(new Rect(0, 0, 320, 180), curTex, ScaleMode.ScaleToFit, false, 1);
    // }
}
