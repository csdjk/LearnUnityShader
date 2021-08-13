using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ProjectionMatrix : SimplePostEffectsBase
{
    public Camera myCamera;
    void Start()
    {
        if (myCamera == null)
            myCamera = transform.GetComponent<Camera>();
            // myCamera = Camera.main;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (_Material)
        {
            Matrix4x4 proj = GL.GetGPUProjectionMatrix(myCamera.projectionMatrix, false);
            // proj *= myCamera.worldToCameraMatrix;

            // _Material.SetMatrix("_ProjectionMatx", proj);
            Shader.SetGlobalMatrix("_ProjectionMatx", proj);
            
            Graphics.Blit(source, destination, _Material);
        }
    }
}
