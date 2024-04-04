using System.Collections;
using UnityEngine;
using UnityEditor;

public class JumpFlooding : MonoBehaviour
{
    enum Channels
    {
        R, G, B, A
    }

    public Texture inputTexture;
    public ComputeShader computeShader;
    public float updateTime;
    public MeshRenderer meshRenderer;
    public bool useGrayScale = false;

    private RenderTexture[] renderTextures;

    private static void EnsureArray<T>(ref T[] array, int size, T initialValue = default(T))
    {
        if (array == null || array.Length != size)
        {
            array = new T[size];
            for (int i = 0; i != size; i++)
                array[i] = initialValue;
        }
    }

    private static void EnsureRenderTexture(ref RenderTexture rt, RenderTextureDescriptor descriptor, string RTName)
    {
        if (rt != null && (rt.width != descriptor.width || rt.height != descriptor.height))
        {
            RenderTexture.ReleaseTemporary(rt);
            rt = null;
        }

        if (rt == null)
        {
            RenderTextureDescriptor desc = descriptor;
            desc.depthBufferBits = 0;
            desc.msaaSamples = 1;
            rt = RenderTexture.GetTemporary(desc);
            rt.name = RTName;
            if (!rt.IsCreated()) rt.Create();
        }
    }

    public static void EnsureRT(ref RenderTexture[] rts, RenderTextureDescriptor descriptor)
    {
        EnsureArray(ref rts, 2);
        EnsureRenderTexture(ref rts[0], descriptor, "Froxel Tex One");
        EnsureRenderTexture(ref rts[1], descriptor, "Froxel Tex Two");
    }

    public void Calculate()
    {
        StartCoroutine(CalculateCoroutine());
    }

    public void CopyUV(Texture texture, RenderTexture renderTexture, uint channel)
    {
        int kernel = computeShader.FindKernel("CopyUVMain");
        computeShader.GetKernelThreadGroupSizes(kernel, out uint x, out uint y, out uint z);
        Vector3Int dispatchCounts = new Vector3Int(Mathf.CeilToInt((float)inputTexture.width / x),
                                                    Mathf.CeilToInt((float)inputTexture.height / y),
                                                    1);
        computeShader.SetTexture(kernel, "_InputTexture", texture);
        computeShader.SetTexture(kernel, "_OutputTexture", renderTexture);
        computeShader.SetVector("_TextureSize", new Vector4(texture.width, texture.height, 1.0f / texture.width, 1.0f / texture.height));
        computeShader.SetFloat("_Channel", (float)channel);
        computeShader.Dispatch(kernel, dispatchCounts.x, dispatchCounts.y, dispatchCounts.z);
    }

    public void JFA(RenderTexture one, RenderTexture two, Vector2Int step, bool reverse)
    {
        int kernel = computeShader.FindKernel("JFAMain");
        computeShader.GetKernelThreadGroupSizes(kernel, out uint x, out uint y, out uint z);
        Vector3Int dispatchCounts = new Vector3Int(Mathf.CeilToInt((float)inputTexture.width / x),
                                                    Mathf.CeilToInt((float)inputTexture.height / y),
                                                    1);
        if (reverse)
        {
            computeShader.SetTexture(kernel, "_InputTexture", two);
            computeShader.SetTexture(kernel, "_OutputTexture", one);
        }
        else
        {
            computeShader.SetTexture(kernel, "_InputTexture", one);
            computeShader.SetTexture(kernel, "_OutputTexture", two);
        }
        computeShader.SetVector("_TextureSize", new Vector4(inputTexture.width, inputTexture.height, 1.0f / inputTexture.width, 1.0f / inputTexture.height));
        computeShader.SetVector("_Step", (Vector2)step);
        computeShader.Dispatch(kernel, dispatchCounts.x, dispatchCounts.y, dispatchCounts.z);
    }

    public void Compose(RenderTexture one, RenderTexture two, Texture texture, uint channel, bool reverse)
    {
        int kernel = computeShader.FindKernel("ComposeMain");
        computeShader.GetKernelThreadGroupSizes(kernel, out uint x, out uint y, out uint z);
        Vector3Int dispatchCounts = new Vector3Int(Mathf.CeilToInt((float)inputTexture.width / x),
                                                    Mathf.CeilToInt((float)inputTexture.height / y),
                                                    1);
        if (reverse)
        {
            computeShader.SetTexture(kernel, "_InputTexture", two);
            computeShader.SetTexture(kernel, "_OutputTexture", one);
        }
        else
        {
            computeShader.SetTexture(kernel, "_InputTexture", one);
            computeShader.SetTexture(kernel, "_OutputTexture", two);
        }
        computeShader.SetTexture(kernel, "_OriginalTexture", texture);
        computeShader.SetFloat("_Channel", (float)channel);
#if UNITY_2020_2_OR_NEWER
        if (useGrayScale)
        {
            computeShader.EnableKeyword("_USE_GRAYSCALE");
        }
        else
        {
            computeShader.DisableKeyword("_USE_GRAYSCALE");
        }
#endif
        computeShader.Dispatch(kernel, dispatchCounts.x, dispatchCounts.y, dispatchCounts.z);
    }

    public void Visualize(RenderTexture one, RenderTexture two, bool reverse)
    {
        MaterialPropertyBlock mpb = new MaterialPropertyBlock();
        mpb.SetTexture("_MainTex", reverse ? two : one);
        meshRenderer.SetPropertyBlock(mpb);
    }

    static public void SaveToTexture(string name, RenderTexture renderTexture, bool alphaIsTransparency)
    {
        RenderTexture currentRT = RenderTexture.active;
        RenderTexture.active = renderTexture;
        Texture2D texture2D = new Texture2D(renderTexture.width, renderTexture.height, TextureFormat.RGBAFloat, false);
        texture2D.ReadPixels(new Rect(0, 0, renderTexture.width, renderTexture.height), 0, 0);
        RenderTexture.active = currentRT;

        System.IO.Directory.CreateDirectory("Assets/JumpFlooding/");
        byte[] bytes = texture2D.EncodeToEXR();
        string path = "Assets/JumpFlooding/" + name + ".exr";
        System.IO.File.WriteAllBytes(path, bytes);

        TextureImporter importer = (TextureImporter)AssetImporter.GetAtPath(path);
        if (importer != null)
        {
            importer.alphaIsTransparency = alphaIsTransparency;
            importer.sRGBTexture = false;
            importer.mipmapEnabled = false;
            AssetDatabase.ImportAsset(path);
        }

        Debug.Log("Saved to " + path);
        AssetDatabase.Refresh();
    }


    IEnumerator CalculateCoroutine()
    {
        RenderTextureDescriptor desc = new RenderTextureDescriptor
        {
            width = inputTexture.width,
            height = inputTexture.height,
            volumeDepth = 1,
            msaaSamples = 1,
            graphicsFormat = UnityEngine.Experimental.Rendering.GraphicsFormat.R16G16B16A16_SFloat,
            enableRandomWrite = true,
            dimension = UnityEngine.Rendering.TextureDimension.Tex2D,
            sRGB = false
        };

        EnsureRT(ref renderTextures, desc);
        RenderTexture rtOne = renderTextures[0];
        RenderTexture rtTwo = renderTextures[1];

        CopyUV(inputTexture, rtOne, (uint)Channels.A);

        yield return new WaitForSeconds(updateTime);

        Shader.DisableKeyword("RENDERTEXTURE_UPSIDE_DOWN");
        Vector2Int step = new Vector2Int((inputTexture.width + 1) >> 1, (inputTexture.height + 1) >> 1);
        bool reverse = false;

        do
        {
            Debug.Log(step);
            JFA(rtOne, rtTwo, step, reverse);
            reverse = !reverse;
            Visualize(rtOne, rtTwo, reverse);
            step = new Vector2Int((step.x + 1) >> 1, (step.y + 1) >> 1);
            yield return new WaitForSeconds(updateTime);
        } while (step.x > 1 || step.y > 1);

        Debug.Log(new Vector2Int(1, 1));
        JFA(rtOne, rtTwo, new Vector2Int(1, 1), reverse);
        reverse = !reverse;
        Visualize(rtOne, rtTwo, reverse);
        yield return new WaitForSeconds(updateTime);

        Debug.Log(new Vector2Int(1, 1));
        JFA(rtOne, rtTwo, new Vector2Int(1, 1), reverse);
        reverse = !reverse;
        Visualize(rtOne, rtTwo, reverse);
        yield return new WaitForSeconds(updateTime);

        Compose(rtOne, rtTwo, inputTexture, (uint)Channels.A, reverse);
        reverse = !reverse;
        Shader.EnableKeyword("RENDERTEXTURE_UPSIDE_DOWN");
        Visualize(rtOne, rtTwo, reverse);

        SaveToTexture("WhatIsThis", reverse ? rtTwo : rtOne, false);
    }
}

[CustomEditor(typeof(JumpFlooding))]
public class JumpFloodingEditor : Editor
{
    private JumpFlooding jumpFlooding;

    private void OnEnable()
    {
        jumpFlooding = (JumpFlooding)target;
    }

    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        using (new EditorGUI.DisabledGroupScope(!Application.isPlaying))
        {
            if (GUILayout.Button("Calculate SDF", GUILayout.Height(30)))
            {
                jumpFlooding.Calculate();
            }
        }
    }
}
