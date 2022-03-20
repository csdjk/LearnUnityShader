using UnityEditor;
using UnityEngine;

[ExecuteInEditMode]
public class GraphicsTest : MonoBehaviour
{
    public Mesh mesh;
    public Material material;
    public Shader shader;

    private RenderTexture runTimeTexture;
    private RenderTexture paintedTexture;
    private int width = 1024;
    private int height = 1024;


    void OnEnable()
    {
        Material material = new Material(shader);
        runTimeTexture = RenderTexture.GetTemporary(width, height);
        paintedTexture = RenderTexture.GetTemporary(width, height);

    }
    void Update()
    {
        Graphics.SetRenderTarget(runTimeTexture);
        Graphics.DrawMesh(mesh, Vector3.zero, Quaternion.identity, material, 0);
        Graphics.Blit(runTimeTexture, paintedTexture);
    }

    private void OnDisable()
    {
        runTimeTexture.Release();
        paintedTexture.Release();
    }

    private void OnGUI()
    {
        GUI.DrawTexture(new Rect(0, 0, 256, 256), paintedTexture, ScaleMode.ScaleToFit, false, 1);
    }
}