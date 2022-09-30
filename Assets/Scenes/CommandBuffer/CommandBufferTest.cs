using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
public sealed class CommandBufferTest : MonoBehaviour
{

    public Transform trans;
    public Mesh mesh;
    public Material material;
    private Camera mainCamera;
    private CommandBuffer buffer;

    private void OnEnable()
    {
        mainCamera = GetComponent<Camera>();
        buffer = new CommandBuffer();
        mainCamera.AddCommandBuffer(CameraEvent.AfterForwardOpaque, buffer);
    }
    private void OnDisable()
    {
        if (buffer != null)
        {
            mainCamera.RemoveCommandBuffer(CameraEvent.AfterForwardOpaque, buffer);
        }
    }
    void Update()
    {
        var xform = Matrix4x4.TRS(trans.position, trans.rotation, trans.localScale);
        buffer.Clear();
        buffer.DrawMesh(mesh, xform, material);
    }
}