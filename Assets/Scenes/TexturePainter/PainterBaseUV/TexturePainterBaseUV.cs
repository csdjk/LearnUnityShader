

using UnityEngine;
using System.Collections;
using UnityEditor;
using System.Collections.Generic;
using System;
using System.IO;
using LcLTools;

public enum PainterDrawModel
{
    Add,
    Sub,
}

[ExecuteInEditMode]
[RequireComponent(typeof(MeshCollider))]
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

    private Material _drawMaterial;
    private Material drawMaterial
    {
        get
        {
            if (_drawMaterial == null)
                _drawMaterial = new Material(Shader.Find("lcl/Painter/DrawShaderUV"));
            return _drawMaterial;
        }
        set
        {
            _drawMaterial = value;
        }
    }


    private RenderTexture _currentTexture;
    public RenderTexture currentTexture
    {
        get
        {
            if (!_currentTexture)
                _currentTexture = CreateRT();
            return _currentTexture;
        }
        set
        {
            _currentTexture = value;
        }
    }

    private RenderTexture _tempTexture;
    private RenderTexture tempTexture
    {
        get
        {
            if (!_tempTexture)
                _tempTexture = CreateRT();
            return _tempTexture;
        }
        set
        {
            _currentTexture = value;
        }
    }

    private RenderTexture _compositeTexture;
    private RenderTexture compositeTexture
    {
        get
        {
            if (!_compositeTexture)
                _compositeTexture = CreateRT();
            return _compositeTexture;
        }
        set
        {
            _currentTexture = value;
        }
    }

    private Texture _texture;
    public Texture texture
    {
        get
        {
            if (_texture == null)
            {
                _texture = CreateRT();
            }
            return _texture;
        }
        set
        {
            _texture = value;
        }
    }
    private int TextureSize = 1024;
    private bool isDraw;
    public Vector3 mousePos;
    public MeshRenderer render;
    private Material material;


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
        ShowUnityTools();
    }

    public void Init()
    {
        render = GetComponent<MeshRenderer>();
        material = render.sharedMaterial;
        texture = material.mainTexture;
        SetDrawTexture();
    }

    private void SelectionChangedCallback()
    {
        if (Selection.activeGameObject && Selection.activeGameObject.GetComponent<TexturePainterBaseUV>())
            HideUnityTools();
        else
            ShowUnityTools();
    }


    void SetDrawTexture()
    {
        Graphics.Blit(texture, compositeTexture);
        material.mainTexture = compositeTexture;
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
        drawMaterial.SetColor("_BrushColor", brushColor);
        drawMaterial.SetFloat("_BrushSize", brushSize);
        drawMaterial.SetFloat("_BrushStrength", brushStrength);
        drawMaterial.SetFloat("_BrushHardness", brushHardness);
        drawMaterial.SetVector("_Mouse", mousePos);

        if (draw)
        {
            int pass = drawModel == PainterDrawModel.Add ? 0 : 1;
            Graphics.Blit(tempTexture, currentTexture, drawMaterial, pass);
            Graphics.Blit(currentTexture, tempTexture);

            // 原图和Mask混合
            drawMaterial.SetTexture("_MainTex", tempTexture);
            drawMaterial.SetTexture("_SourceTex", texture);
            Graphics.Blit(tempTexture, compositeTexture, drawMaterial, 3);
        }
        else
        {
            drawMaterial.SetTexture("_MainTex", tempTexture);
            drawMaterial.SetTexture("_SourceTex", texture);
            Graphics.Blit(tempTexture, compositeTexture, drawMaterial, 2);
        }
    }

    public void DrawEmpty()
    {
        Graphics.Blit(tempTexture, compositeTexture);
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
        SetDrawTexture();
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
        LcLUtility.SaveRenderTextureToTexture(compositeTexture, path);
        var assetsPath = LcLUtility.AssetsRelativePath(path);
        if (assetsPath != null)
        {
            AssetDatabase.ImportAsset(assetsPath);
        }
        Debug.Log("Saved to " + path);
    }
}