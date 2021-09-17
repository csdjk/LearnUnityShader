using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class SnowGround : MonoBehaviour
{
    private Camera drawCamera;
    public Transform ground;

    private Material drawMat;
    private RenderTexture targetRT;
    private RenderTexture curTex;
    private RenderTexture prevTex;
    void Start()
    {
        drawCamera = transform.GetComponent<Camera>();
        // Render Texture
        targetRT = new RenderTexture(1024, 1024, 0, RenderTextureFormat.ARGBFloat);
        drawCamera.targetTexture = targetRT;
        // 纯色shader
        Shader purecolorShader = Shader.Find("lcl/Common/PureColor");
        drawCamera.SetReplacementShader(purecolorShader, "RenderType");
        // VP 矩阵
        Matrix4x4 ProjectionMatrix = GL.GetGPUProjectionMatrix(drawCamera.projectionMatrix, true);
        Matrix4x4 ViewMatrix = drawCamera.worldToCameraMatrix;
        Matrix4x4 VP_Matrix = ProjectionMatrix * ViewMatrix;


        prevTex = new RenderTexture(1024, 1024, 0, RenderTextureFormat.ARGBFloat);
        curTex = new RenderTexture(1024, 1024, 0, RenderTextureFormat.ARGBFloat);
        var groundMat = ground.GetComponent<MeshRenderer>().sharedMaterial;
        groundMat.SetTexture("_MaskTex", curTex);
        groundMat.SetMatrix("_GroundCameraMatrixVP", VP_Matrix);


        // 叠加
        Shader addShader = Shader.Find("lcl/SnowGround/AddTexture");
        drawMat = new Material(addShader);


        SetCameraPos();
    }

    // 计算camera到平面的距离
    void SetCameraPos(){
        var distance = Vector3.Distance(drawCamera.transform.position,ground.position);
        Debug.Log(distance);
        drawCamera.farClipPlane = distance;
    }



    void Update()
    {
        RenderTexture temp = RenderTexture.GetTemporary(targetRT.width, targetRT.height, 0, RenderTextureFormat.ARGBFloat);
        drawMat.SetTexture("_PrevTex", prevTex);
        Graphics.Blit(targetRT, temp);
        Graphics.Blit(temp, curTex,drawMat);
        RenderTexture.ReleaseTemporary(temp);

        // 存储当前帧tex
        Graphics.Blit(curTex, prevTex);
    }
    private void OnGUI()
    {
        GUI.DrawTexture(new Rect(0, 0, 256, 256), curTex, ScaleMode.ScaleToFit, false, 1);
    }
}
