using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
public class CommandDrawMesh : MonoBehaviour
{
    public Material mat;
    public Mesh mesh;
    public Transform trs;
    CommandBuffer buf;
    private void OnEnable()
    {
        buf = new CommandBuffer();
        Camera.main.AddCommandBuffer(CameraEvent.AfterSkybox, buf);
    }

    private void Update()
    {
        buf.Clear();
        var xform = Matrix4x4.TRS(trs.position, trs.rotation, trs.localScale);
        buf.DrawMesh(mesh, xform, mat);
        Graphics.ExecuteCommandBuffer(buf);
    }

    private void OnDisable()
    {
        Camera.main.RemoveCommandBuffer(CameraEvent.AfterSkybox, buf);
    }

}
