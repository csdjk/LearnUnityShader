using System.IO;
using UnityEngine;
using UnityEditor;
using System;
using LcLTools;

[CustomEditor(typeof(TexturePainterBaseWorldPos))]
public class TexturePaintBaseWorldPosEditor : Editor
{
    TexturePainterBaseWorldPos painter;
    private Color brushColor = Color.red;
    private float brushSize = 0.1f;
    private float brushStrength = 1f;
    private float brushHardness = 0.02f;


    private Event _currentEvent;
    private const float _mouseWheelBrushSizeMultiplier = 0.01f;

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
        painter = target as TexturePainterBaseWorldPos;
        GUI.DrawTexture(r, painter.currentTexture, ScaleMode.ScaleToFit, false);
        

        // float halfWidth = r.width / 2;
        // float size = Mathf.Min(halfWidth, r.height);

        // // Texture1
        // float rectx = r.x + halfWidth / 2 - size / 2;
        // float recty = r.y + r.height / 2 - size / 2;
        // Rect rect = new Rect(rectx, recty, size, size);
        // GUI.DrawTexture(rect, painter.texture, ScaleMode.ScaleToFit, false);

        // // Texture2
        // float rectx2 = r.x + halfWidth + halfWidth / 2 - size / 2;
        // float recty2 = r.y + r.height / 2 - size / 2;
        // Rect rect2 = new Rect(rectx2, recty2, size, size);
        // GUI.DrawTexture(rect2, painter.currentTexture, ScaleMode.ScaleToFit, false);
    }

    // Inspector 
    public override void OnInspectorGUI()
    {
        painter = target as TexturePainterBaseWorldPos;
        DrawBrushInfoGUI();
        DrawButtonGUI();
    }

    void OnSceneGUI()
    {
        _currentEvent = Event.current;
        painter = target as TexturePainterBaseWorldPos;
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
            painter.SetMousePos(hitpoint);

            painter.ShowBrushMark();
            // Handles.color = Color.red;
            // Vector3 endPt = hit.point + (Vector3.Normalize(hit.normal) * brushSize);
            // Handles.DrawAAPolyLine(2f, new Vector3[] { hit.point, endPt });
            // Handles.CircleHandleCap(0, hitpoint, Quaternion.FromToRotation(Vector3.forward, hit.normal), brushSize,EventType.Repaint);

            if ((_currentEvent.type == EventType.MouseDrag || _currentEvent.type == EventType.MouseDown) && Event.current.button == 0)
            {
                painter.SetMouseState(true);
                painter.DrawAt();
            }
            else
            {
                painter.SetMouseState(false);
            }

            if (_currentEvent.type == EventType.ScrollWheel && _currentEvent.shift)
            {
                brushSize -= _currentEvent.delta.y * _mouseWheelBrushSizeMultiplier;
                brushSize = painter.CheckBrushParm(brushSize);
                _currentEvent.Use();
            }
            else if (_currentEvent.type == EventType.ScrollWheel && _currentEvent.control)
            {
                brushHardness += _currentEvent.delta.y * _mouseWheelBrushSizeMultiplier;
                brushHardness = painter.CheckBrushParm(brushHardness);
                _currentEvent.Use();
            }
            else if (_currentEvent.type == EventType.ScrollWheel && _currentEvent.alt)
            {
                brushStrength += _currentEvent.delta.y * 0.2f;
                brushStrength = Mathf.Max(brushStrength, 0);
                _currentEvent.Use();
            }
        }
        else
        {
            painter.HideBrushMark();
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
                var tex = painter.texture;
                string path = AssetDatabase.GetAssetPath(tex);
                if (path.Equals(String.Empty))
                {
                    path = Application.dataPath;
                }
                else
                {
                    path = Path.GetDirectoryName(path);
                }

                path = EditorUtility.SaveFilePanel("Save Texture", path, tex ? tex.name : "", "png");
                if (!path.Equals(String.Empty))
                {
                    LcLEditorUtilities.SaveRenderTextureToTexture(painter.compositeTexture, path);
                    // painter.SaveRenderTextureToPng(path);
                }
            }
        }
        EditorGUILayout.EndHorizontal();
    }
    public void DrawBrushInfoGUI()
    {
        PainterDrawModel drawModel = (PainterDrawModel)EditorGUILayout.EnumPopup("Draw Model", painter.drawModel);
        if (painter.drawModel != drawModel)
        {
            painter.drawModel = drawModel;
        }
        brushColor = EditorGUILayout.ColorField("Brush Mark Color", brushColor);
        brushSize = EditorGUILayout.Slider("Brush Size", brushSize, 0, 5);
        brushStrength = EditorGUILayout.Slider("Brush Strength", brushStrength, 0, 50);
        brushHardness = EditorGUILayout.Slider("Brush Hardness", brushHardness, 0, 1);
    }

    [MenuItem("GameObject/Add Texture Painter Base WorldPos", false, 0)]
    static void AddTerrainPainter()
    {
        var selectGo = Selection.activeGameObject;
        if (selectGo)
        {
            if (selectGo.GetComponent<MeshRenderer>())
            {
                if (selectGo.GetComponent<TexturePainterBaseWorldPos>())
                {
                    Debug.LogWarning("该对象已有Painter组件!!!");
                }
                else
                {
                    selectGo.AddComponent<TexturePainterBaseWorldPos>();
                }
            }
            else
            {
                Debug.LogWarning("该对象必须有MeshRenderer组件!!!");
            }
        }
    }
}
