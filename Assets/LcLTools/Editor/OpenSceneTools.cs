using System;
using System.Linq;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityToolbarExtender;
using UnityEngine.UIElements;
using System.Reflection;

namespace LcLTools
{
   
    public class SceneListWindow : EditorWindow
    {
        static Texture sceneIcon;
        static Toggle toggle;
        static float toggleHeight = 30;
        static string[] scenesPath;
        static string[] scenesBuildPath;
        public static EditorWindow instance;
        static int count;
        static int maxRow = 30;
        static Vector2 itemSize = new Vector2(200, 30);
        static Color defaultColor = new Color(0.345f, 0.345f, 0.345f, 1f);
        static Color selectColor = new Color(0.088f, 0.447f, 0.07f, 1f);

        public static void ShowWindow()
        {
            if (toggle != null && toggle.value)
            {
                return;
            }
            if (instance != null)
            {
                instance.Close();
                instance = null;
            }
            instance = EditorWindow.GetWindow(typeof(SceneListWindow));
            instance.titleContent = new GUIContent("Scene List");

            float itemTotalSizeX = itemSize.x + margin * 2;
            float itemTotalSizeY = itemSize.y + margin * 2;

            int col = Mathf.CeilToInt((float)count / maxRow);
            int row = Mathf.CeilToInt((float)count / col);
            float totalWidth = 10 + itemTotalSizeX * col;
            float totalHeight = 10 + toggleHeight + itemTotalSizeY * (count < row ? count : row);
            Vector2 temp = GUIUtility.GUIToScreenPoint(new Vector2(Event.current.mousePosition.x, Event.current.mousePosition.y));


            instance.position = new Rect(temp.x - totalWidth / 2, temp.y + 15, totalWidth, totalHeight);
            instance.Show();
        }

        public void OnEnable()
        {
            sceneIcon = EditorGUIUtility.IconContent("SceneAsset Icon").image;
            var root = this.rootVisualElement;

            // create toggle
            toggle = new Toggle("固定窗口");
            toggle.style.fontSize = 20;
            toggle.style.alignSelf = Align.Center;
            toggle.style.unityTextAlign = TextAnchor.MiddleCenter;
            toggle.style.height = toggleHeight;
            // set toggle margin zreo
            toggle.style.marginTop = 0;
            toggle.style.marginBottom = 0;
            toggle.style.marginLeft = 0;
            toggle.style.marginRight = 0;
            toggle.Children().First().style.minWidth = 0;


            root.Add(toggle);


            ScrollView scrollView = new ScrollView();
            GroupBox groupBox = new GroupBox();
            groupBox.style.flexDirection = FlexDirection.Row;
            groupBox.style.alignItems = Align.Center;
            groupBox.style.flexWrap = Wrap.Wrap;
            groupBox.style.justifyContent = Justify.Center;
            groupBox.style.paddingTop = 0;
            groupBox.style.paddingBottom = 0;
            groupBox.style.paddingLeft = 0;
            groupBox.style.paddingRight = 0;

            Scene activeScene = SceneManager.GetActiveScene();

            string[] sceneGuids = AssetDatabase.FindAssets("t:scene", new string[] { "Assets" });
            foreach (var sceneGuid in sceneGuids)
            {
                var scenesPath = AssetDatabase.GUIDToAssetPath(sceneGuid);
                string name = GetSceneName(scenesPath);
                var box = BindItem(name, scenesPath);
                groupBox.Add(box);

                if (activeScene.path == scenesPath)
                {
                    SelectButton(box);
                }
            }
            count = groupBox.childCount;

            scrollView.Add(groupBox);
            root.Add(scrollView);
        }


        static float margin = 2;
        static float padding = 5;
        static Button selectedButton;
        static Button BindItem(string name, string path)
        {
            var box = new Button();
            box.RegisterCallback<ClickEvent>((e) =>
            {
                if (EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo())
                {
                    EditorSceneManager.OpenScene(path);
                    SelectButton(e.target as Button);
                }
                e.StopPropagation();
            });
            box.style.backgroundColor = defaultColor;
            box.style.flexDirection = FlexDirection.Row;
            box.style.alignItems = Align.Center;
            box.style.paddingLeft = padding;
            box.style.paddingRight = padding;
            box.style.paddingTop = padding;
            box.style.paddingBottom = padding;
            // set margin
            box.style.marginLeft = margin;
            box.style.marginRight = margin;
            box.style.marginTop = margin;
            box.style.marginBottom = margin;

            box.style.width = itemSize.x;
            box.style.height = itemSize.y;
            box.style.unityTextAlign = TextAnchor.MiddleLeft;
            box.tooltip = path;

            Image icon = new Image();
            icon.style.flexShrink = 0;
            icon.style.width = 16;
            icon.style.height = 16;
            icon.style.marginRight = 5;
            icon.image = sceneIcon;
            box.Add(icon);

            Label label = new Label();
            label.style.flexGrow = 1.0f;
            label.style.alignItems = Align.Center;
            label.text = name;
            // label.style.width = Length.Percent(100);
            box.Add(label);

            return box;
        }

        // create select button function
        static void SelectButton(Button button)
        {
            if (selectedButton != null) selectedButton.style.backgroundColor = defaultColor;
            selectedButton = button;
            selectedButton.style.backgroundColor = selectColor;
        }

        static string GetSceneName(string path)
        {
            path = path.Replace(".unity", "");
            return Path.GetFileName(path);
        }

        void Update()
        {
            if (Application.isPlaying)
            {
                toggle.value = true;
                return;
            }

            if (toggle.value) return;

            if (SceneListWindow.focusedWindow != GetWindow(typeof(SceneListWindow)))
            {
                this.Close();
            }
        }

        // On close events
        void OnDestroy()
        {
            instance = null;
            toggle = null;
        }
    }


    [InitializeOnLoad]
    public class OpenSceneTools
    {

        static OpenSceneTools()
        {
            ToolbarExtender.LeftToolbarGUI.Add(OnToolbarGUI);

        }

        static void OnToolbarGUI()
        {
            GUILayout.FlexibleSpace();
            var currentScene = EditorSceneManager.GetActiveScene().name;
            float width = 30 + currentScene.Length * 8;
            width = Mathf.Clamp(width, 100, 1000);
            var style = new GUIStyle(EditorStyles.toolbarButton);
            style.alignment = TextAnchor.MiddleCenter;
            var sceneIcon = EditorGUIUtility.IconContent("SceneAsset Icon").image;

            if (GUILayout.Button(new GUIContent(currentScene, sceneIcon), style, GUILayout.Width(width)))
            {
                SceneListWindow.ShowWindow();
            }
        }
    }
}
