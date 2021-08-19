// Description: 从深度图构建世界坐标，逆矩阵方式
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ReconstructPositionInvMatrix2 : MonoBehaviour
{
    public Shader reconstructPositionShader;
    private Material postEffectMat = null;
    private Camera currentCamera = null;

    void Awake()
    {
        currentCamera = GetComponent<Camera>();
    }

    void OnEnable()
    {
        if (postEffectMat == null)
            postEffectMat = new Material(reconstructPositionShader);
        currentCamera.depthTextureMode |= DepthTextureMode.Depth;
    }

    void OnDisable()
    {
        currentCamera.depthTextureMode &= ~DepthTextureMode.Depth;
        postEffectMat = null;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (postEffectMat == null)
        {
            Graphics.Blit(source, destination);
        }
        else
        {
            Matrix4x4 ProjectionMatrix = GL.GetGPUProjectionMatrix(currentCamera.projectionMatrix, true);
            postEffectMat.SetMatrix("_InverseProjectionMatrix", currentCamera.projectionMatrix.inverse);
            Graphics.Blit(source, destination, postEffectMat);
        }
    }
}