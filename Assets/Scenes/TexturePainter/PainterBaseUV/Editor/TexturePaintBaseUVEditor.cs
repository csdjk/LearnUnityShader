using System.IO;
using UnityEngine;
using UnityEditor;
using System;

[CustomEditor(typeof(TexturePainterBaseUV))]
public class TexturePaintBaseUVEditor : Editor
{
    TexturePainterBaseUV painter;
    private Color brushColor = Color.red;
    private float brushSize = 0.1f;
    private float brushStrength = 1f;
    private float brushHardness = 0.02f;


    private Event _currentEvent;
    private const float _mouseWheelBrushSizeMultiplier = 0.001f;

    // window
    private const string _toolsLabel = "Painter";
    private const float _buttonHeight = 22;
    private float painterWindowWidth = 350;
    private float painterWindowHeight = 100;

    // 预览面板
    public override bool HasPreviewGUI()
    {
        return true;
    }
    public override void OnPreviewGUI(Rect r, GUIStyle background)
    {
        painter = target as TexturePainterBaseUV;
        var tex = painter.GetCurrentTexture();
        GUI.DrawTexture(r, tex, ScaleMode.ScaleToFit, false);
    }

    // Inspector 
    public override void OnInspectorGUI()
    {
        painter = target as TexturePainterBaseUV;
        DrawBrushInfoGUI();
        DrawButtonGUI();
    }

    void OnSceneGUI()
    {
        _currentEvent = Event.current;
        painter = target as TexturePainterBaseUV;
        if (painter == null)
            return;
        if (!painter.isActiveAndEnabled)
            return;

        painter.HideUnityTools();
        Handles.BeginGUI();
        {
            Rect labelRect = new Rect(Screen.width - painterWindowWidth - 10, Screen.height - painterWindowHeight - 110, painterWindowWidth, painterWindowHeight);

            GUILayout.Window(2, labelRect, (id) =>
            {
                PainterDrawModel drawModel = (PainterDrawModel)EditorGUILayout.EnumPopup("Draw Model", painter.drawModel);
                if (painter.drawModel != drawModel)
                {
                    painter.drawModel = drawModel;
                }
                DrawBrushInfoGUI();
                DrawButtonGUI();
            }, "Painter Window");
        }
        Handles.EndGUI();


        HandleUtility.AddDefaultControl(GUIUtility.GetControlID(FocusType.Keyboard));
        // Draw
        Vector2 mousePosition = Event.current.mousePosition;
        Ray ray = HandleUtility.GUIPointToWorldRay(mousePosition);

        RaycastHit hit;
        if (Physics.Raycast(ray, out hit))
        {
            HandleUtility.AddDefaultControl(GUIUtility.GetControlID(FocusType.Passive));
            Vector3 hitpoint = hit.point;
            Vector3 hitnormal = hit.normal;
            Vector3 hituv = hit.textureCoord;
            painter.SetBrushInfo(brushSize, brushStrength, brushHardness, brushColor);
            painter.SetMousePos(hituv);

            if ((_currentEvent.type == EventType.MouseDrag || _currentEvent.type == EventType.MouseDown) && Event.current.button == 0)
            {
                painter.DrawAt(true);
            }
            if (_currentEvent.type == EventType.MouseMove)
            {
                painter.DrawAt(false);
            }

            if (_currentEvent.type == EventType.ScrollWheel && _currentEvent.shift)
            {
                brushSize -= _currentEvent.delta.y * _mouseWheelBrushSizeMultiplier;
                brushSize = painter.CheckBrushParm(brushSize);
                painter.DrawAt(false);
                _currentEvent.Use();
            }
            else if (_currentEvent.type == EventType.ScrollWheel && _currentEvent.control)
            {
                brushHardness += _currentEvent.delta.y * _mouseWheelBrushSizeMultiplier;
                brushHardness = painter.CheckBrushParm(brushHardness);
                painter.DrawAt(false);
                _currentEvent.Use();
            }
            else if (_currentEvent.type == EventType.ScrollWheel && _currentEvent.alt)
            {
                brushStrength += _currentEvent.delta.y * 0.2f;
                brushStrength = Mathf.Max(brushStrength, 0);
                painter.DrawAt(false);
                _currentEvent.Use();
            }
        }
        else
        {
            if (_currentEvent.type == EventType.MouseMove)
            {
                painter.DrawEmpty();
            }
        }

        SceneView.RepaintAll();
    }


    public void DrawButtonGUI()
    {
        EditorGUILayout.BeginHorizontal();
        {
            if (GUILayout.Button("Clear"))
            {
                if (EditorUtility.DisplayDialog("Clear", "该操作会清空当前所绘制内容!", "OK", "Cancel"))
                    painter.ClearPaint();
            }
            if (GUILayout.Button("Save"))
            {
                string path = AssetDatabase.GetAssetPath(painter.GetSourceTexture());
                path = Path.GetDirectoryName(path);
                path = EditorUtility.SaveFilePanel("Save Texture", path, painter.GetSourceTexture().name,"png");
                if (!path.Equals(String.Empty))
                {
                    painter.SaveRenderTextureToPng(path);
                }
            }
        }
        EditorGUILayout.EndHorizontal();
    }
    public void DrawBrushInfoGUI()
    {
        brushColor = EditorGUILayout.ColorField("Brush Mark Color", brushColor);
        brushSize = EditorGUILayout.Slider("Brush Size", brushSize, 0, 1);
        brushStrength = EditorGUILayout.Slider("Brush Strength", brushStrength, 0, 50);
        brushHardness = EditorGUILayout.Slider("Brush Hardness", brushHardness, 0, 1);
    }

    [MenuItem("GameObject/Add Terrain Painter", false, 0)]
    static void AddTerrainPainter()
    {
        var selectGo = Selection.activeGameObject;
        if (selectGo)
        {
            if (selectGo.GetComponent<MeshRenderer>())
            {
                if (selectGo.GetComponent<TexturePainterBaseUV>())
                {
                    Debug.LogWarning("该对象已有Painter组件!!!");
                }
                else
                {
                    selectGo.AddComponent<TexturePainterBaseUV>();
                }
            }
            else
            {
                Debug.LogWarning("该对象必须有MeshRenderer组件!!!");
            }
        }
    }
}
