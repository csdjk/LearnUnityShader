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

        static List<string> sceneList = new List<string>();
        static List<string> scenePathList = new List<string>();
        static string[] scenesPath;
        static string[] scenesBuildPath;
        public static EditorWindow instance;
        static int row = 30;
        static Vector2 itemSize = new Vector2(200, 30);
        public static void ShowWindow()
        {
            if (instance != null)
            {
                instance.Close();
                instance = null;
            }
            instance = EditorWindow.GetWindow(typeof(SceneListWindow));
            instance.titleContent = new GUIContent("Scene List");

            // int numRows = Mathf.CeilToInt((float)sceneList.Count / row);
            // int totalWidth = 60 + 250 * numRows;
            // int totalHeight = 25 * row;

            float itemTotalSizeX = itemSize.x + margin * 2 + padding * 2 + 2;
            float itemTotalSizeY = itemSize.y + 2;

            int col = Mathf.CeilToInt((float)sceneList.Count / row);
            float totalWidth = itemTotalSizeX * col;
            float totalHeight = itemTotalSizeY * row;
            Vector2 temp = GUIUtility.GUIToScreenPoint(new Vector2(Event.current.mousePosition.x, Event.current.mousePosition.y));

            instance.position = new Rect(temp.x - totalWidth / 2, temp.y + 20, totalWidth, totalHeight);
            instance.Show();
        }


        public void OnEnable()
        {
            sceneIcon = EditorGUIUtility.IconContent("SceneAsset Icon").image;
            RefreshScenesList();

            var root = this.rootVisualElement;
            ScrollView scrollView = new ScrollView();
            GroupBox groupBox = new GroupBox();
            groupBox.style.flexDirection = FlexDirection.Row;
            groupBox.style.alignItems = Align.Center;
            groupBox.style.flexWrap = Wrap.Wrap;
            groupBox.style.justifyContent = Justify.Center;
            for (int i = 0; i < sceneList.Count; i++)
            {
                var box = BindItem(sceneList[i], scenesPath[i]);
                groupBox.Add(box);
            }
            scrollView.Add(groupBox);
            root.Add(scrollView);
        }


        static float margin = 2;
        static float padding = 5;
        static VisualElement BindItem(string name, string path)
        {
            var box = new Button(() =>
            {
                if (EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo())
                {
                    EditorSceneManager.OpenScene(path);
                }
            });
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


        static void RefreshScenesList()
        {
            sceneList.Clear();
            scenePathList.Clear();
            string[] sceneGuids = AssetDatabase.FindAssets("t:scene", new string[] { "Assets" });
            scenesPath = new string[sceneGuids.Length];
            for (int i = 0; i < scenesPath.Length; ++i)
            {
                scenesPath[i] = AssetDatabase.GUIDToAssetPath(sceneGuids[i]);
            }

            Scene activeScene = SceneManager.GetActiveScene();

            for (int i = 0; i < scenesPath.Length; ++i)
            {
                string name = GetSceneName(scenesPath[i]);
                sceneList.Add(name);
                scenePathList.Add(scenesPath[i]);
            }
        }

        static string GetSceneName(string path)
        {
            path = path.Replace(".unity", "");
            return Path.GetFileName(path);
        }

        void Update()
        {
            if (SceneListWindow.focusedWindow != GetWindow(typeof(SceneListWindow)))
            {
                this.Close();
            }
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
