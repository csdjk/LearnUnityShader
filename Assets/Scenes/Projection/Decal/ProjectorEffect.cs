using System.Collections;
using System.Collections.Generic;
using UnityEngine;
 
[ExecuteInEditMode]
public class ProjectorEffect : MonoBehaviour
{
 
    private Camera projectorCam = null;
    public Material projectorMaterial = null;
 
 
    private void Awake()
    {
        projectorCam = GetComponent<Camera>();
    }
 
    private void Update()
    {
        var projectionMatrix = projectorCam.projectionMatrix;
        projectionMatrix = GL.GetGPUProjectionMatrix(projectionMatrix, false);
        var viewMatirx = projectorCam.worldToCameraMatrix;
        var vpMatrix = projectionMatrix * viewMatirx;
        projectorMaterial.SetMatrix("_ProjectorVPMatrix", vpMatrix);
    }
 
 
}