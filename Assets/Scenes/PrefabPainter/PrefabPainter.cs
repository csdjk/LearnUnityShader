using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEngine.UIElements;
using System.Linq;
using UnityEditor.UIElements;
using Random = UnityEngine.Random;
using System.IO;

public class PrefabPainter : EditorWindow
{
    static Color BrushNoneInnerColor = new Color(0f, 0f, 1f, 0.05f);
    static Color BrushNoneOuterColor = new Color(0f, 0f, 1f, 1f);
    static Color BrushAddInnerColor = new Color(0f, 1f, 0f, 0.05f);
    static Color BrushAddOuterColor = new Color(0f, 1f, 0f, 1f);
    static Color BrushRemoveInnerColor = new Color(1f, 0f, 0f, 0.05f);
    static Color BrushRemoveOuterColor = new Color(1f, 0f, 0f, 1f);
    static Color DropAreaBackgroundColor = new Color(0.8f, 0.8f, 0.8f, 1f);
    const int textureSize = 100;
    private Button clearButton;
    static List<GameObject> prefabList = new List<GameObject>();
    static ObjectField parentField;
    VisualElement prefabsBox;
    VisualElement paramsBox;
    static Slider brushSizeSlider;
    VisualElement selectPrefabItem;
    static Slider overlapSlider;

    static SliderInt densitySlider;
    static ToggleMinMaxSlider scaleRangeX;
    static ToggleMinMaxSlider scaleRangeY;
    static ToggleMinMaxSlider scaleRangeZ;
    static Toggle rotateToMatchSurface;
    static ToggleMinMaxSlider rotationRangeX;
    static ToggleMinMaxSlider rotationRangeY;
    static ToggleMinMaxSlider rotationRangeZ;
    VisualElement sceneViewRoot;
    static LayerMaskField layerMask;
    Dictionary<string, int> infoCountMap = new Dictionary<string, int>();
    const float _mouseWheelBrushSizeMultiplier = 0.01f;
    string keywordTips = "添加Prefab：鼠标左键    移除Prefab：Shift + 鼠标左键 \n调整笔刷大小：Shift + 鼠标中键滚轮   调整数量：Ctrl + 鼠标中键滚轮";
    string infoTips;
    private Button editButton;

    [MenuItem("LcLTools/PrefabPainter %g", false, 0)]
    static void OpenWindow()
    {
        PrefabPainter window = GetWindow<PrefabPainter>();
        window.titleContent = new GUIContent("Grass Painter");
        window.minSize = new Vector2(450, 450);
        window.Show();
        window.Focus();
    }

    void OnEnable()
    {
        // SceneView.duringSceneGui += OnSceneGUI;
    }

    void OnDestroy()
    {
        SceneView.duringSceneGui -= OnSceneGUI;
    }
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.LeftShift))
        {
            SceneView.duringSceneGui -= OnSceneGUI;
            SceneView.duringSceneGui += OnSceneGUI;
            Debug.Log("Down");
        }
        if (Input.GetKeyUp(KeyCode.LeftShift))
        {
            Debug.Log("Up");
            SceneView.duringSceneGui -= OnSceneGUI;
        }
    }

    public void CreateGUI()
    {
        VisualElement root = rootVisualElement;
        root.styleSheets.Add(AssetDatabase.LoadAssetAtPath<StyleSheet>("Assets/Scenes/PrefabPainter/prefabPainter.uss"));

        var title = new Label("Prefab List");
        root.Add(title);

        //----------------------------------------------预制体列表----------------------------------------------
        prefabsBox = new VisualElement();
        prefabsBox.AddToClassList("container-box");
        prefabsBox.AddToClassList("drop-area");
        UpdatePrefabList();
        root.Add(prefabsBox);
        prefabsBox.RegisterCallback<DragEnterEvent>(OnDragEnterEvent);
        prefabsBox.RegisterCallback<DragLeaveEvent>(OnDragLeaveEvent);
        prefabsBox.RegisterCallback<DragUpdatedEvent>(OnDragUpdatedEvent);
        prefabsBox.RegisterCallback<DragPerformEvent>(OnDragPerformEvent);


        //----------------------------------------------参数列表----------------------------------------------
        paramsBox = new VisualElement();
        paramsBox.AddToClassList("container-box");

        var box = new VisualElement();
        box.AddToClassList("box1");
        if (layerMask == null) layerMask = new LayerMaskField("Layer") { value = 1 };
        layerMask.AddToClassList("some-styled-field");
        layerMask.value = layerMask.value;
        box.Add(layerMask);

        if (parentField == null) parentField = new ObjectField("父节点") { objectType = typeof(GameObject) };
        box.Add(parentField);

        if (brushSizeSlider == null) brushSizeSlider = new Slider("笔刷大小") { value = 1, showInputField = true, lowValue = 0, highValue = 100 };
        box.Add(brushSizeSlider);

        if (densitySlider == null) densitySlider = new SliderInt("生成数量") { value = 5, showInputField = true, lowValue = 1, highValue = 100 };
        box.Add(densitySlider);

        if (overlapSlider == null) overlapSlider = new Slider("重叠最小范围") { value = 0.1f, showInputField = true, lowValue = 0, highValue = 1 };
        box.Add(overlapSlider);
        paramsBox.Add(box);

        // 缩放Slider
        box = new VisualElement();
        box.AddToClassList("box1");
        if (scaleRangeX == null) scaleRangeX = new ToggleMinMaxSlider("随机缩放 X", new Vector2(0.5f, 1.5f), new Vector2(0, 5));
        if (scaleRangeY == null) scaleRangeY = new ToggleMinMaxSlider("随机缩放 Y", new Vector2(0.5f, 1.5f), new Vector2(0, 5));
        if (scaleRangeZ == null) scaleRangeZ = new ToggleMinMaxSlider("随机缩放 Z", new Vector2(0.5f, 1.5f), new Vector2(0, 5));
        box.Add(scaleRangeX);
        box.Add(scaleRangeY);
        box.Add(scaleRangeZ);
        paramsBox.Add(box);


        // 随机旋转
        box = new VisualElement();
        box.AddToClassList("box1");
        if (rotateToMatchSurface == null) rotateToMatchSurface = new Toggle("朝向匹配法线") { value = true };
        if (rotationRangeX == null) rotationRangeX = new ToggleMinMaxSlider("随机旋转 X", new Vector2(0, 360), new Vector2(0, 360));
        if (rotationRangeY == null) rotationRangeY = new ToggleMinMaxSlider("随机旋转 Y", new Vector2(0, 360), new Vector2(0, 360), true);
        if (rotationRangeZ == null) rotationRangeZ = new ToggleMinMaxSlider("随机旋转 Z", new Vector2(0, 360), new Vector2(0, 360));
        box.Add(rotateToMatchSurface);
        box.Add(rotationRangeX);
        box.Add(rotationRangeY);
        box.Add(rotationRangeZ);
        paramsBox.Add(box);

        root.Add(paramsBox);
        //----------------------------------------------Button----------------------------------------------
        editButton = new Button() { text = "编辑" };
        editButton.AddToClassList("button");
        editButton.RegisterCallback<ClickEvent>(OnEditClickEvent);
        editButton.userData = false;
        root.Add(editButton);


        // var button = new Button() { text = "保存数据" };
        // button.AddToClassList("button");
        // button.RegisterCallback<ClickEvent>(SaveGrassData);
        // root.Add(button);


        clearButton = new Button(Clean) { text = "清空预制体" };
        clearButton.AddToClassList("button");
        root.Add(clearButton);
    }

    private void Clean()
    {
        prefabList.Clear();
        prefabsBox.Clear();
    }
    private void OnEditClickEvent(ClickEvent evt)
    {
        editButton.userData = !(bool)editButton.userData;
        bool isEdit = (bool)editButton.userData;
        if (isEdit)
        {
            SceneView.duringSceneGui += OnSceneGUI;
            editButton.AddToClassList("edit-bottom");
        }
        else
        {
            SceneView.duringSceneGui -= OnSceneGUI;
            editButton.RemoveFromClassList("edit-bottom");
        }
    }

    void OnDragUpdatedEvent(DragUpdatedEvent e)
    {
        DragAndDrop.visualMode = DragAndDropVisualMode.Copy;
    }

    void OnDragEnterEvent(DragEnterEvent e)
    {
        prefabsBox.AddToClassList("drag-over");
    }
    void OnDragLeaveEvent(DragLeaveEvent e)
    {
        prefabsBox.RemoveFromClassList("drag-over");
    }
    void OnDragPerformEvent(DragPerformEvent e)
    {
        prefabsBox.RemoveFromClassList("drag-over");
        DragAndDrop.AcceptDrag();
        foreach (var obj in DragAndDrop.objectReferences)
        {
            prefabList.Add(obj as GameObject);
        }
        UpdatePrefabList();
    }

    VisualElement CreatePrefabItem(GameObject go)
    {
        var item = new VisualElement();
        item.AddToClassList("prefab-item");
        item.RegisterCallback<ClickEvent>(OnPrefabClickEvent);
        item.userData = go;

        var image = new Image();
        image.AddToClassList("prefab-image");
        image.scaleMode = ScaleMode.ScaleToFit;
        image.image = GetPrefabPreview(go);
        item.Add(image);

        var name = new Label(go.name);
        image.AddToClassList("prefab-name");
        item.Add(name);
        return item;
    }

    void OnPrefabClickEvent(ClickEvent evt)
    {
        if (selectPrefabItem != null)
            selectPrefabItem.RemoveFromClassList("select-item");

        selectPrefabItem = evt.currentTarget as VisualElement;
        selectPrefabItem.AddToClassList("select-item");
        EditorGUIUtility.PingObject(selectPrefabItem.userData as GameObject);
    }

    void UpdatePrefabList()
    {
        prefabsBox.Clear();
        if (prefabList.Count == 0)
        {
            var tips = new Label("拖拽预制体到该区域");
            tips.AddToClassList("tips");
            prefabsBox.Add(tips);
        }
        foreach (var item in prefabList)
        {
            prefabsBox.Add(CreatePrefabItem(item));
        }
    }

    static Texture2D GetPrefabPreview(GameObject go)
    {
        var path = AssetDatabase.GetAssetPath(go);
        var editor = Editor.CreateEditor(go);
        Texture2D tex = editor.RenderStaticPreview(path, null, textureSize, textureSize);
        DestroyImmediate(editor);
        return tex;
    }

    private void RandomCreatePrefabs(RaycastHit hit)
    {
        var count = densitySlider.value;
        var size = brushSizeSlider.value;
        var position = hit.point;
        // if (count == 1)
        // {
        //     AddPrefab(hit);
        //     return;
        // }
        for (int i = 0; i < count; i++)
        {
            Ray ray = HandleUtility.GUIPointToWorldRay(Event.current.mousePosition);
            int randCount = 0;
            while (randCount <= 10)
            {
                var newRay = ray;
                newRay.origin = ray.origin + new Vector3(Random.insideUnitSphere.x * size, Random.insideUnitSphere.y * size, Random.insideUnitSphere.z * size);
                RaycastHit newHit;
                if (Physics.Raycast(newRay, out newHit, 999999, layerMask.value))
                {
                    randCount++;
                    float dist = Vector3.Distance(position, newHit.point);
                    // 过滤超过笔刷范围的情况
                    if (dist > brushSizeSlider.value)
                        continue;
                    // 过滤和其他prefab非常近的情况
                    var parent = parentField.value as GameObject;
                    bool isPass = true;
                    if (parent != null)
                    {
                        foreach (Transform item in parent.transform)
                        {
                            dist = Vector3.Distance(item.position, newHit.point);
                            if (dist <= overlapSlider.value)
                            {
                                isPass = false;
                                break;
                            }
                        }
                    }
                    if (isPass)
                    {
                        AddPrefab(newHit);
                        break;
                    }
                }
            }
        }
    }

    void AddPrefab(RaycastHit hit)
    {
        if (selectPrefabItem == null)
            return;
        var prefab = selectPrefabItem.userData as GameObject;
        if (prefab)
        {
            GameObject instance = PrefabUtility.InstantiatePrefab(prefab) as GameObject;
            var parent = parentField.value as GameObject;

            var newScale = instance.transform.localScale;
            if (scaleRangeX.Active)
                newScale.x = Random.Range(scaleRangeX.minValue, scaleRangeX.maxValue);
            if (scaleRangeY.Active)
                newScale.y = Random.Range(scaleRangeY.minValue, scaleRangeY.maxValue);
            if (scaleRangeZ.Active)
                newScale.z = Random.Range(scaleRangeZ.minValue, scaleRangeZ.maxValue);


            var newRotation = instance.transform.rotation.eulerAngles;
            if (rotationRangeX.Active)
                newRotation.x = Random.Range(rotationRangeX.minValue, rotationRangeX.maxValue);
            if (rotationRangeY.Active)
                newRotation.y = Random.Range(rotationRangeY.minValue, rotationRangeY.maxValue);
            if (rotationRangeZ.Active)
                newRotation.z = Random.Range(rotationRangeZ.minValue, rotationRangeZ.maxValue);

            instance.transform.position = hit.point;
            instance.transform.localScale = newScale;
            // instance.transform.rotation = Quaternion.Euler(newRotation);
            if (rotateToMatchSurface.value)
                instance.transform.rotation = Quaternion.FromToRotation(Vector3.up, hit.normal) * Quaternion.Euler(newRotation);
            else
                instance.transform.rotation = Quaternion.Euler(newRotation);


            if (!parent)
            {
                parent = new GameObject(prefab.name + "List");
                parentField.value = parent;
            }
            instance.transform.parent = parent.transform;

        }
    }

    public void RemovePrefabs(Vector3 position)
    {
        var container = parentField.value as GameObject;
        if (container == null)
            return;


        List<Transform> removeList = new List<Transform>();

        foreach (Transform transform in container.transform)
        {
            float dist = Vector3.Distance(position, transform.transform.position);

            if (dist <= brushSizeSlider.value)
            {
                removeList.Add(transform);
            }

        }
        foreach (Transform transform in removeList)
        {
            DestroyImmediate(transform.gameObject);
        }
    }


    void OnSceneGUI(SceneView sceneView)
    {

        var currentEvent = Event.current;
        HandleUtility.AddDefaultControl(GUIUtility.GetControlID(FocusType.Keyboard));
        // Tools.hidden = false;

        Ray ray = HandleUtility.GUIPointToWorldRay(Event.current.mousePosition);
        RaycastHit hit;
        var selectGo = Selection.activeObject as GameObject;
        // if (selectGo && Physics.Raycast(ray, out hit, 999999, layerMask.value) && selectGo.transform == hit.transform)
        if (Physics.Raycast(ray, out hit, 999999, layerMask.value))
        {
            // Tools.hidden = true;
            HandleUtility.AddDefaultControl(GUIUtility.GetControlID(FocusType.Passive));

            var size = brushSizeSlider.value;
            var position = hit.point;
            var normal = hit.normal;

            var innerColor = BrushAddInnerColor;
            var outerColor = BrushAddOuterColor;
            if (currentEvent.shift)
            {
                innerColor = BrushRemoveInnerColor;
                outerColor = BrushRemoveOuterColor;
            }

            // inner disc
            Handles.color = innerColor;
            Handles.DrawSolidDisc(position, normal, size);

            // outer circle
            Handles.color = outerColor;
            Handles.DrawWireDisc(position, normal, size);

            // center line / normal
            float lineLength = size * 0.5f;
            Vector3 lineStart = position;
            Vector3 lineEnd = position + normal * lineLength;
            Handles.DrawLine(lineStart, lineEnd);
            if ((currentEvent.type == EventType.MouseDrag || currentEvent.type == EventType.MouseDown) && Event.current.button == 0)
            {
                if (currentEvent.shift)
                {
                    RemovePrefabs(position);
                }
                else
                {
                    RandomCreatePrefabs(hit);
                }
                Event.current.Use();
            }




            if (currentEvent.type == EventType.ScrollWheel && currentEvent.shift)
            {
                brushSizeSlider.value -= currentEvent.delta.y * _mouseWheelBrushSizeMultiplier;
                currentEvent.Use();
            }
            else if (currentEvent.type == EventType.ScrollWheel && currentEvent.control)
            {
                densitySlider.value += (int)currentEvent.delta.y;
                currentEvent.Use();
            }
        }
        else
        {
            // Tools.hidden = false;
        }
        DrawTipsInfo();
        SceneView.RepaintAll();
    }



    public void DrawTipsInfo()
    {
        float windowWidth = Screen.width;
        float windowHeight = Screen.height;
        float panelWidth = 500;
        float panelHeight = 100;
        float panelX = windowWidth * 0.5f - panelWidth * 0.5f;
        float panelY = windowHeight - panelHeight;

        GUIStyle labelStyle = new GUIStyle(EditorStyles.boldLabel);
        labelStyle.alignment = TextAnchor.MiddleCenter;
        labelStyle.normal.textColor = Color.white;
        // 快捷键提示
        Rect infoRect = new Rect(panelX, panelY, panelWidth, panelHeight);
        GUILayout.BeginArea(infoRect, GUI.skin.box);
        {
            EditorGUILayout.BeginVertical();
            {
                GUILayout.Label(keywordTips, labelStyle);

                if (Selection.activeGameObject == null)
                    GUILayout.Label("需要选中物体", labelStyle);
            }
            EditorGUILayout.EndVertical();
        }
        GUILayout.EndArea();


        // info
        var parent = parentField.value as GameObject;
        if (parent == null) return;
        infoRect = new Rect(Screen.width - 300, Screen.height - 150, 300, 150);
        labelStyle = new GUIStyle(EditorStyles.boldLabel);
        labelStyle.alignment = TextAnchor.MiddleLeft;
        labelStyle.normal.textColor = Color.green;
        GUILayout.BeginArea(infoRect, GUI.skin.box);
        {
            EditorGUILayout.BeginVertical();
            {
                infoCountMap.Clear();
                foreach (Transform child in parent.transform)
                {
                    if (infoCountMap.ContainsKey(child.name))
                        infoCountMap[child.name]++;
                    else
                        infoCountMap[child.name] = 0;
                }
                foreach (var item in prefabList)
                {
                    int count = 0;
                    infoCountMap.TryGetValue(item.name, out count);
                    GUILayout.Label(item.name + ": " + count, labelStyle);
                }
            }
            EditorGUILayout.EndVertical();
        }
        GUILayout.EndArea();
    }


    // public void SaveGrassData(ClickEvent evt)
    // {
    //     var parent = parentField.value as GameObject;
    //     if (parent == null) return;
    //     List<Matrix4x4> data = new List<Matrix4x4>();
    //     foreach (Transform grass in parent.transform)
    //     {
    //         data.Add(grass.localToWorldMatrix);
    //     }
    //     var json = JsonUtility.ToJson(new JsonListWrapper<Matrix4x4>(data));
    //     var path = Application.dataPath + "/LiChangLong/Grass/Grass.json";
    //     File.WriteAllText(path, json);
    //     AssetDatabase.Refresh();
    // }
}


class ToggleMinMaxSlider : MinMaxSlider
{
    public bool Active
    {
        get
        {
            return activeToggle.value;
        }
        set
        {
            activeToggle.value = value;
        }
    }
    private Toggle activeToggle;
    private FloatField minValueField;
    private FloatField maxValueField;
    private VisualElement sliderElement;

    public ToggleMinMaxSlider(string label, Vector2 defaultValue, Vector2 range, bool active = false) : base(label)
    {
        this.value = defaultValue;
        this.lowLimit = range.x;
        this.highLimit = range.y;
        activeToggle = new Toggle() { value = active };
        minValueField = new FloatField() { value = defaultValue.x };
        minValueField.AddToClassList("min-max-slider-input");
        maxValueField = new FloatField() { value = defaultValue.y };
        maxValueField.AddToClassList("min-max-slider-input");

        this.Insert(1, activeToggle);
        this.Insert(2, minValueField);
        this.Add(maxValueField);
        sliderElement = this.ElementAt(3);
        SetActive(active);

        activeToggle.RegisterCallback<ChangeEvent<bool>>((evt) =>
        {
            SetActive(evt.newValue);
        });
        maxValueField.RegisterCallback<ChangeEvent<float>>((evt) =>
        {
            this.maxValue = evt.newValue;
        });
        minValueField.RegisterCallback<ChangeEvent<float>>((evt) =>
        {
            this.minValue = evt.newValue;
        });
        this.RegisterCallback<ChangeEvent<Vector2>>((evt) =>
        {
            minValueField.value = evt.newValue.x;
            maxValueField.value = evt.newValue.y;
        });
    }

    private void SetActive(bool v)
    {
        minValueField.SetEnabled(v);
        sliderElement.SetEnabled(v);
        maxValueField.SetEnabled(v);
    }
}
