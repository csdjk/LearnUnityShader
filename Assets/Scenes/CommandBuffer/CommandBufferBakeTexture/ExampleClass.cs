using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
// Attach this script to a Camera
public class ExampleClass : MonoBehaviour
{
    public Mesh mesh;
    public Material mat;
    public void OnPostRender()
    {
        Graphics.SetRenderTarget(runTimeTexture);

        // set first shader pass of the material
        mat.SetPass(0);
        // draw mesh at the origin
        Graphics.DrawMeshNow(mesh, Vector3.zero, Quaternion.identity);
        Graphics.Blit(runTimeTexture, paintedTexture);

    }

    private RenderTexture runTimeTexture;
    private RenderTexture paintedTexture;
    private int width = 1024;
    private int height = 1024;


    void OnEnable()
    {
        runTimeTexture = RenderTexture.GetTemporary(width, height);
        paintedTexture = RenderTexture.GetTemporary(width, height);

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