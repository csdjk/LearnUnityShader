using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ProjectionMatrix : SimplePostEffectsBase
{
    public Camera mCamera;
    public Renderer render;
    void Start()
    {
        if (mCamera == null)
            mCamera = transform.GetComponent<Camera>();
        // mCamera = Camera.main;


    }

    // private void Update()
    // {
    //     Matrix4x4 ProjectionMatrix = GL.GetGPUProjectionMatrix(mCamera.projectionMatrix, true);
    //     // Matrix4x4 ProjectionMatrix = mCamera.projectionMatrix;
    //     Matrix4x4 ViewMatrix = mCamera.worldToCameraMatrix;
    //     Matrix4x4 VP_Matrix = ProjectionMatrix * ViewMatrix;
    //     Debug.Log(VP_Matrix);
    //     render.material.SetMatrix("_ProjectionMatx",VP_Matrix);
    // }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (_Material)
        {
            Matrix4x4 ProjectionMatrix = GL.GetGPUProjectionMatrix(mCamera.projectionMatrix, true);
            // Matrix4x4 ProjectionMatrix = mCamera.projectionMatrix;
            Matrix4x4 ViewMatrix = mCamera.worldToCameraMatrix;
            Matrix4x4 VP_Matrix = ProjectionMatrix * ViewMatrix;

            Debug.Log("ViewMatrix:");
            Debug.Log(ProjectionMatrix);
            Debug.Log(ViewMatrix);
            Debug.Log(VP_Matrix);
            // Matrix4x4 unity_MatrixVP1 = new Matrix4x4(
            //     new Vector4(2, 0, 0, 0),
            //     new Vector4(0, 2, 0, 0),
            //     new Vector4(0, 0, 0.0099f, 0),
            //     new Vector4(-1, -1f, 0.99f, 1)
            // );
            Shader.SetGlobalMatrix("_ProjectionMatx", VP_Matrix);

            Graphics.Blit(source, destination, _Material);
        }
    }
}
