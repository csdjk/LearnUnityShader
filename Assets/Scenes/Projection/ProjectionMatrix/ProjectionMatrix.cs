using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ProjectionMatrix : SimplePostEffectsBase
{
    public Camera mCamera;
    public Renderer render;
    void Start()
    {
        if (mCamera == null)
            mCamera = transform.GetComponent<Camera>();
    }

    private void Update()
    {
        Matrix4x4 ProjectionMatrix = GL.GetGPUProjectionMatrix(mCamera.projectionMatrix, true);
        // Matrix4x4 ProjectionMatrix = mCamera.projectionMatrix;
        Matrix4x4 ViewMatrix = mCamera.worldToCameraMatrix;
        Matrix4x4 VP_Matrix = ProjectionMatrix * ViewMatrix;
        Debug.Log(VP_Matrix);
        render.material.SetMatrix("_CameraMatxVP",VP_Matrix);
    }
  
}
