using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
public class CommandBufferBakeTexture : MonoBehaviour
{
    private RenderTexture runTimeTexture;
    private RenderTexture paintedTexture;
    private CommandBuffer commandBuffer;
    private int width = 1024;
    private int height = 1024;
    public Mesh mesh;
    public Shader shader;

    void OnEnable()
    {
        Material material = new Material(shader);
        runTimeTexture = RenderTexture.GetTemporary(width, height);
        paintedTexture = RenderTexture.GetTemporary(width, height);

        commandBuffer = new CommandBuffer();
        commandBuffer.name = "TexturePainting";
        commandBuffer.SetRenderTarget(runTimeTexture);
        commandBuffer.DrawMesh(mesh, Matrix4x4.identity, material);
        commandBuffer.Blit(runTimeTexture, paintedTexture);
        Camera.main.AddCommandBuffer(CameraEvent.AfterDepthTexture, commandBuffer);

        // Graphics.SetRenderTarget(runTimeTexture);
        // Graphics.DrawMesh(mesh, Vector3.zero, Quaternion.identity, material, 0);
        // Graphics.Blit(runTimeTexture, paintedTexture);
    }


    private void OnDisable()
    {
        runTimeTexture.Release();
        paintedTexture.Release();
        Camera.main.RemoveCommandBuffer(CameraEvent.AfterDepthTexture, commandBuffer);
        commandBuffer.Release();
    }
    private void OnGUI()
    {
        GUI.DrawTexture(new Rect(0, 0, 256, 256), paintedTexture, ScaleMode.ScaleToFit, false, 1);
    }
}
