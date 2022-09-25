using UnityEditor;
using UnityEngine;

internal class LightDir : MaterialPropertyDrawer
{
    float height = 16;
    bool isEditor = false;
    bool starEditor = true;
    GameObject selectGameObj;
    public Quaternion rot = Quaternion.identity;
    MaterialProperty m_prop;
    static bool IsPropertyTypeSuitable(MaterialProperty prop)
    {
        return prop.type == MaterialProperty.PropType.Vector;
    }
    public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
    {
        //如果不是Vector类型，则把unity的默认警告框的高度40
        if (!IsPropertyTypeSuitable(prop))
        {
            return 40f;
        }
        height = EditorGUI.GetPropertyHeight(SerializedPropertyType.Vector3, new GUIContent(label));
        return height;
    }
    public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor)
    {
        //如果不是Vector类型，则显示一个警告框
        if (!IsPropertyTypeSuitable(prop))
        {
            GUIContent c = EditorGUIUtility.TrTextContent("LightDir used on a non-Vector property: " + prop.name, EditorGUIUtility.IconContent("console.erroricon").image);
            EditorGUI.LabelField(position, c, EditorStyles.helpBox);
            return;
        }

        EditorGUI.BeginChangeCheck();

        float oldLabelWidth = EditorGUIUtility.labelWidth;
        EditorGUIUtility.labelWidth = 0f;

        Color oldColor = GUI.color;
        if (isEditor) GUI.color = Color.green;

        //绘制属性
        Rect VectorRect = new Rect(position)
        {
            width = position.width - 68f
        };
        Vector3 value = EditorGUI.Vector4Field(VectorRect, label, prop.vectorValue);
        //绘制开关
        Rect ToggleRect = new Rect(position)
        {
            x = position.xMax - 64f,
            y = position.y,
            width = 60f,
            height = 18
        };
        isEditor = GUI.Toggle(ToggleRect, isEditor, "Edit", "Button");
        if (isEditor)
        {
            if (starEditor)
            {
                m_prop = prop;
                InitSceneGUI(value);
            }
        }
        else
        {
            if (!starEditor)
            {
                ClearSceneGUI();
            }
        }

        GUI.color = oldColor;
        EditorGUIUtility.labelWidth = oldLabelWidth;
        if (EditorGUI.EndChangeCheck())
        {
            prop.vectorValue = new Vector4(value.x, value.y, value.z);
        }

    }
    void InitSceneGUI(Vector3 value)
    {
        Tools.current = Tool.None;
        selectGameObj = Selection.activeGameObject;
        if (selectGameObj == null)
        {
            return;
        }
        Vector3 worldDir = selectGameObj.transform.rotation * value;
        rot = Quaternion.FromToRotation(Vector3.forward, worldDir);
        SceneView.duringSceneGui += OnSceneGUI;
        starEditor = false;
    }
    void ClearSceneGUI()
    {

        SceneView.duringSceneGui -= OnSceneGUI;
        m_prop = null;
        selectGameObj = null;
        starEditor = true;
    }

    void OnSceneGUI(SceneView sceneView)
    {
        if (Selection.activeGameObject != selectGameObj)
        {
            ClearSceneGUI();
            isEditor = false;
            return;
        }

        Vector3 pos = selectGameObj.transform.position;

        rot = Handles.RotationHandle(rot, pos);
        Vector3 newLocalDir = Quaternion.Inverse(selectGameObj.transform.rotation) * rot * Vector3.forward;

        m_prop.vectorValue = new Vector4(newLocalDir.x, newLocalDir.y, newLocalDir.z);

        Handles.color = Color.green;
        Handles.ConeHandleCap(0, pos, rot, HandleUtility.GetHandleSize(pos), EventType.Repaint);
    }
}