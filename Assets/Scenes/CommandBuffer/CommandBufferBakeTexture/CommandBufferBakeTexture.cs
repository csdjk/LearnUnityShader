using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
public class CommandBufferBakeTexture : MonoBehaviour
{
    public Mesh mesh;
    public Material material;
    public Material fixedMaterial;
    [Range(0, 500)]
    public float pixelNum = 100;
    public Color color = Color.red;
    private CommandBuffer commandBuffer;
    private int width = 1024;
    private int height = 1024;
    public RenderTexture runTimeTexture;
    public RenderTexture fixedEdgeTexture;

    void OnEnable()
    {
        runTimeTexture = RenderTexture.GetTemporary(width, height);
        fixedEdgeTexture = RenderTexture.GetTemporary(width, height);

        commandBuffer = new CommandBuffer();
        commandBuffer.name = "BakeTexture";
        commandBuffer.SetRenderTarget(runTimeTexture);
        commandBuffer.DrawMesh(mesh, Matrix4x4.identity, material);

        fixedMaterial.SetTexture("_MainTex", runTimeTexture);
        commandBuffer.Blit(runTimeTexture, fixedEdgeTexture, fixedMaterial);

        Camera.main.AddCommandBuffer(CameraEvent.AfterDepthTexture, commandBuffer);
    }

    void Update()
    {
        if (material)
        {
            material.SetFloat("_PixelNumber", pixelNum);
            material.SetColor("_Color", color);
        }

    }

    private void OnDisable()
    {
        runTimeTexture.Release();
        fixedEdgeTexture.Release();
        Camera.main.RemoveCommandBuffer(CameraEvent.AfterDepthTexture, commandBuffer);
        commandBuffer.Release();
    }
    // private void OnGUI()
    // {
    //     GUI.DrawTexture(new Rect(0, 0, 256, 256), runTimeTexture, ScaleMode.ScaleToFit, false, 1);
    // }
}
