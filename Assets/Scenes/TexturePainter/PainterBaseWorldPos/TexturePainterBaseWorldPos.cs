

using UnityEngine;
using System.Collections;
using UnityEditor;
using System.Collections.Generic;
using System;
using System.IO;
using UnityEngine.Rendering;
using LcLTools;

[ExecuteInEditMode]
[RequireComponent(typeof(MeshCollider))]
public class TexturePainterBaseWorldPos : MonoBehaviour
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
            SwitchDrawModel();
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
                _drawMaterial = new Material(Shader.Find("lcl/Painter/DrawShaderWorldPos"));
            return _drawMaterial;
        }
        set
        {
            _drawMaterial = value;
        }
    }
    private Material _landMarkMaterial;
    private Material landMarkMaterial
    {
        get
        {
            if (_landMarkMaterial == null)
                _landMarkMaterial = new Material(Shader.Find("lcl/Painter/MarkIlsands"));
            return _landMarkMaterial;
        }
        set
        {
            _landMarkMaterial = value;
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


    private Material brushMarkMaterial;

    private GameObject _brushMark;
    private GameObject brushMark
    {
        get
        {
            if (!_brushMark)
            {
                _brushMark = GameObject.CreatePrimitive(PrimitiveType.Sphere);
                _brushMark.GetComponent<SphereCollider>().enabled = false;
                if (!brushMarkMaterial)
                    brushMarkMaterial = new Material(Shader.Find("lcl/Painter/BrushShader"));
                _brushMark.GetComponent<Renderer>().material = brushMarkMaterial;
                _brushMark.hideFlags = HideFlags.HideInHierarchy;
            }
            return _brushMark;
        }
        set
        {
            _brushMark = value;
        }
    }



    private Material brushMarkMaterial2;
    private GameObject _brushMark2;
    private GameObject brushMark2
    {
        get
        {
            if (!_brushMark2)
            {
                _brushMark2 = GameObject.CreatePrimitive(PrimitiveType.Sphere);
                _brushMark2.GetComponent<SphereCollider>().enabled = false;
                if (!brushMarkMaterial2)
                    brushMarkMaterial2 = new Material(Shader.Find("lcl/Painter/BrushShader"));
                _brushMark2.GetComponent<Renderer>().material = brushMarkMaterial2;
                _brushMark2.hideFlags = HideFlags.HideInHierarchy;
            }
            return _brushMark2;
        }
        set
        {
            _brushMark2 = value;
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
    private Mesh mesh;
    private Material material;
    private CommandBuffer commandBuffer;
    private RenderTexture landMarkRT;
    private CommandBuffer commandBufferLand;

    void OnEnable()
    {
        Init();
        Selection.selectionChanged += SelectionChangedCallback;
    }
    void OnDisable()
    {
        Selection.selectionChanged -= SelectionChangedCallback;
        material.mainTexture = texture;
        ClearResource();
        ShowUnityTools();
    }

    public void Init()
    {
        render = GetComponent<MeshRenderer>();
        mesh = GetComponent<MeshFilter>().sharedMesh;
        material = render.sharedMaterial;
        texture = material.mainTexture;
        SetDrawTexture();
        SwitchDrawModel();
    }

    private void SwitchDrawModel()
    {
        RemoveCommandBuffer();
        // Graphics.SetRenderTarget(currentTexture);
        // GL.Clear(false, true, Color.white);
        // Graphics.SetRenderTarget(tempTexture);
        // GL.Clear(false, true, Color.white);

        int pass = drawModel == PainterDrawModel.Add ? 0 : 1;
        commandBuffer = new CommandBuffer();
        commandBuffer.name = "TexturePainter";
        commandBuffer.SetRenderTarget(currentTexture);
        commandBuffer.DrawMesh(mesh, Matrix4x4.identity, drawMaterial, 0, pass);

        // 标记
        landMarkRT = CreateRT();
        commandBufferLand = new CommandBuffer();
        commandBufferLand.name = "LandMark";
        commandBufferLand.SetRenderTarget(landMarkRT);
        commandBufferLand.DrawMesh(mesh, Matrix4x4.identity, landMarkMaterial);
        // 修复边缘裂痕
        drawMaterial.SetTexture("_IlsandMap", landMarkRT);
        drawMaterial.SetTexture("_MainTex", currentTexture);
        commandBufferLand.Blit(currentTexture, tempTexture, drawMaterial, 3);


        // 原图和Mask混合
        drawMaterial.SetTexture("_MainTex", tempTexture);
        drawMaterial.SetTexture("_SourceTex", texture);
        commandBuffer.Blit(tempTexture, compositeTexture, drawMaterial, 2);


        Camera.main.AddCommandBuffer(CameraEvent.AfterDepthTexture, commandBufferLand);
        Camera.main.AddCommandBuffer(CameraEvent.AfterDepthTexture, commandBuffer);
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
        material.mainTexture = compositeTexture;
        Graphics.Blit(texture, compositeTexture);
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

    public void DrawAt()
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
        drawMaterial.SetMatrix("mesh_Object2World", transform.localToWorldMatrix);
    }
    public void SetMouseState(bool v)
    {
        drawMaterial.SetFloat("_IsDraw", v ? 1 : 0);
    }
    public void ShowBrushMark()
    {
        brushMark.SetActive(true);
        brushMark2.SetActive(true);
        brushMark.transform.position = mousePos;
        brushMark2.transform.position = mousePos;
    }
    public void HideBrushMark()
    {
        brushMark.SetActive(false);
        brushMark2.SetActive(false);
    }

    public void DrawEmpty()
    {
        Graphics.Blit(tempTexture, currentTexture);
    }

    public void SetMousePos(Vector3 pos)
    {
        mousePos = pos;
    }
    public void SetBrushInfo(float size, float strength, float hardness, Color color)
    {
        brushSize = size;
        brushStrength = strength;
        brushHardness = hardness;
        brushColor = color;

        brushMark.transform.localScale = new Vector3(size, size, size) * 2;
        brushMarkMaterial.SetColor("_Color", color);

        brushMark2.transform.localScale = new Vector3(size, size, size);
        brushMarkMaterial2.SetColor("_Color", new Color(1 - color.r, 1 - color.g, 1 - color.b));
    }


    // 清除临时创建的资源
    public void ClearResource()
    {
        DestroyImmediate(drawMaterial);
        DestroyImmediate(landMarkMaterial);
        drawMaterial = null;
        landMarkMaterial = null;

        if (brushMark)
            DestroyImmediate(brushMark);
        if (brushMark2)
            DestroyImmediate(brushMark2);

        RemoveCommandBuffer();
        ReleaseTexture();
    }



    // 清除绘制的内容
    public void ClearPaint()
    {
        ReleaseTexture();
        material.mainTexture = texture;
        SetDrawTexture();
        SwitchDrawModel();
    }

    public void RemoveCommandBuffer()
    {
        if (commandBuffer != null)
            Camera.main.RemoveCommandBuffer(CameraEvent.AfterDepthTexture, commandBuffer);
        if (commandBufferLand != null)
            Camera.main.RemoveCommandBuffer(CameraEvent.AfterDepthTexture, commandBufferLand);
    }

    public void ReleaseTexture()
    {
        if (currentTexture)
            currentTexture.Release();
        if (tempTexture)
            tempTexture.Release();
        if (landMarkRT)
            landMarkRT.Release();
        currentTexture = null;
        currentTexture = null;
        landMarkRT = null;
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

    private void OnGUI()
    {
        // GUI.DrawTexture(new Rect(0, 0, 256, 256), TempRT2, ScaleMode.ScaleToFit, false, 1);
    }
}