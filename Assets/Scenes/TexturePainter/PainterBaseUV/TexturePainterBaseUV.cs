

using UnityEngine;
using System.Collections;
using UnityEditor;
using System.Collections.Generic;
using System;
using System.IO;

public enum PainterDrawModel
{
    Add,
    Sub,
}

[ExecuteInEditMode]
public class TexturePainterBaseUV : MonoBehaviour
{
    private PainterDrawModel _drawModel = PainterDrawModel.Add;
    public PainterDrawModel drawModel
    {
        get
        {
            return _drawModel;
        }
        set
        {
            _drawModel = value;
        }
    }

    public Color brushColor = Color.red;
    [Range(0, 1)]
    public float brushSize = 0.2f;
    public float brushStrength = 1.0f;
    public float brushHardness = 0.5f;

    private Material drawMaterial;

    private RenderTexture currentTexture;
    private RenderTexture tempTexture;
    private RenderTexture compositeTexture;

    private int TextureSize = 1024;
    private bool isDraw;
    public Vector3 mousePos;
    public MeshRenderer render;
    private Material material;
    private Texture texture;

    void OnEnable()
    {
        Init();
        Selection.selectionChanged += SelectionChangedCallback;
    }
    void OnDisable()
    {
        Selection.selectionChanged -= SelectionChangedCallback;
        ClearResource();
        material.mainTexture = texture;
    }

    public void Init()
    {
        render = GetComponent<MeshRenderer>();
        material = render.sharedMaterial;
        texture = material.mainTexture;
        CreateDrawMaterial();
    }

    private void SelectionChangedCallback()
    {
        if (Selection.activeGameObject && Selection.activeGameObject.GetComponent<TexturePainterBaseUV>())
            HideUnityTools();
        else
            ShowUnityTools();
    }


    void CreateDrawMaterial()
    {
        drawMaterial = GetDrawMaterial();
        var compRT = GetCompositeTexture();
        Graphics.Blit(texture, compRT);
        material.mainTexture = compRT;
    }

    public Material GetDrawMaterial()
    {
        if (drawMaterial == null)
            drawMaterial = new Material(Shader.Find("lcl/Painter/DrawShaderUV"));
        return drawMaterial;
    }
    private RenderTexture GetTempTexture()
    {
        if (!tempTexture)
            tempTexture = CreateRT();
        return tempTexture;
    }

    public RenderTexture GetCurrentTexture()
    {
        if (!currentTexture)
            currentTexture = CreateRT();
        return currentTexture;
    }

    private RenderTexture GetCompositeTexture()
    {
        if (!compositeTexture)
            compositeTexture = CreateRT();
        return compositeTexture;
    }

     public Texture GetSourceTexture()
    {
        return texture;
    }

    public void HideUnityTools()
    {
        Tools.hidden = true;
    }
    public void ShowUnityTools()
    {
        Tools.hidden = false;
    }

    public RenderTexture CreateRT()
    {
        RenderTexture rt = RenderTexture.GetTemporary(TextureSize, TextureSize, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Default);
        return rt;
    }

    public void DrawAt(bool draw)
    {
        if (drawMaterial == null)
        {
            Debug.LogError("drawMat is null");
            return;
        }
        var currentRT = GetCurrentTexture();
        var tempRT = GetTempTexture();
        drawMaterial.SetColor("_BrushColor", brushColor);
        drawMaterial.SetFloat("_BrushSize", brushSize);
        drawMaterial.SetFloat("_BrushStrength", brushStrength);
        drawMaterial.SetFloat("_BrushHardness", brushHardness);
        drawMaterial.SetVector("_Mouse", mousePos);

        if (draw)
        {
            int pass = drawModel == PainterDrawModel.Add ? 0 : 1;
            Graphics.Blit(tempRT, currentRT, drawMaterial, pass);
            Graphics.Blit(currentRT, tempRT);

            // 原图和Mask混合
            drawMaterial.SetTexture("_MainTex", tempRT);
            drawMaterial.SetTexture("_SourceTex", texture);
            Graphics.Blit(tempRT, GetCompositeTexture(), drawMaterial, 3);
        }
        else
        {
            drawMaterial.SetTexture("_MainTex", tempRT);
            drawMaterial.SetTexture("_SourceTex", texture);
            Graphics.Blit(tempRT, GetCompositeTexture(), drawMaterial, 2);
        }
    }

    public void DrawEmpty()
    {
        var currentRT = GetCurrentTexture();
        var tempRT = GetTempTexture();
        Graphics.Blit(tempRT, currentRT);
    }

    public void SetMousePos(Vector3 pos)
    {
        mousePos = pos;
    }
    public void SetBrushInfo(float size, float strength, float hardness, Color markColor)
    {
        brushSize = size;
        brushStrength = strength;
        brushHardness = hardness;
        brushColor = markColor;
    }


    // 清除临时创建的资源
    public void ClearResource()
    {
        DestroyImmediate(drawMaterial);
        drawMaterial = null;
        ReleaseTexture();
    }
    // 清除绘制的内容
    public void ClearPaint()
    {
        ReleaseTexture();
        material.mainTexture = texture;
        CreateDrawMaterial();
    }

    public void ReleaseTexture()
    {
        if (currentTexture)
            currentTexture.Release();
        if (tempTexture)
            tempTexture.Release();
        currentTexture = null;
        tempTexture = null;
    }

    public float CheckBrushParm(float value)
    {
        return Mathf.Min(1, Mathf.Max(value, 0));
    }

    public void SaveRenderTextureToPng(string path)
    {
        LcLTools.SaveRenderTextureToTexture(GetCompositeTexture(), path);
        var assetsPath = LcLTools.AssetsRelativePath(path);
        if (assetsPath != null)
        {
            AssetDatabase.ImportAsset(assetsPath);
        }
        Debug.Log("Saved to " + path);
    }
}