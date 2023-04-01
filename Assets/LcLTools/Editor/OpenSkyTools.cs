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
    public class SkyListWindow : EditorWindow
    {
        static string path = "Assets/SkyBox";
        static Texture sceneIcon;
        static EditorWindow instance;
        static int row = 6;
        static float itemSize = 120;
        static float margin = 2;
        static float padding = 5;

        static int count;
        public static void ShowWindow()
        {
            if (instance != null)
            {
                instance.Close();
                instance = null;
            }
            instance = EditorWindow.GetWindow(typeof(SkyListWindow));
            instance.titleContent = new GUIContent("Scene List");

            float itemTotalSize = itemSize + margin * 2 + padding * 2 + 2;
            int col = Mathf.CeilToInt((float)count / row);
            float totalWidth = itemTotalSize * col;
            float totalHeight = itemTotalSize * row;
            Vector2 temp = GUIUtility.GUIToScreenPoint(new Vector2(Event.current.mousePosition.x, Event.current.mousePosition.y));

            instance.position = new Rect(temp.x - totalWidth / 2, temp.y + 20, totalWidth, totalHeight);
            instance.Show();
        }



        public void OnEnable()
        {
            sceneIcon = EditorGUIUtility.IconContent("SceneAsset Icon").image;
            // RefreshScenesList();

            var root = this.rootVisualElement;
            ScrollView scrollView = new ScrollView();
            GroupBox groupBox = new GroupBox();
            groupBox.style.flexDirection = FlexDirection.Row;
            groupBox.style.alignItems = Align.Center;
            groupBox.style.flexWrap = Wrap.Wrap;
            groupBox.style.justifyContent = Justify.Center;
            string[] materialGuids = AssetDatabase.FindAssets("t:Material", new[] { path });

            foreach (string guid in materialGuids)
            {
                string assetPath = AssetDatabase.GUIDToAssetPath(guid);
                Material material = AssetDatabase.LoadAssetAtPath<Material>(assetPath);
                var shaderName = material.shader?.name.ToLower();
                if (shaderName.Contains("sky") || shaderName.Contains("cubemap"))
                {
                    var box = BindItem(material.name, assetPath, material);
                    groupBox.Add(box);

                }
            }
            count = groupBox.childCount;
            scrollView.Add(groupBox);
            root.Add(scrollView);
        }


        static VisualElement BindItem(string name, string path, Material material)
        {
            var box = new Button(() =>
            {
                Debug.Log("click" + name);
                EditorGUIUtility.PingObject(material);
                // set skybox
                RenderSettings.skybox = material;

            });
            box.style.flexDirection = FlexDirection.Column;
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

            box.style.width = itemSize;
            box.style.unityTextAlign = TextAnchor.MiddleLeft;
            box.tooltip = path;

            Image image = new Image();
            image.style.flexShrink = 0;
            image.style.width = 100;
            image.style.height = 100;
            image.image = AssetPreview.GetAssetPreview(material);
            box.Add(image);

            Label label = new Label(name);
            label.style.flexGrow = 1.0f;
            label.style.alignItems = Align.Center;
            label.style.marginTop = 5;
            box.Add(label);
            return box;
        }


        void Update()
        {
            if (SkyListWindow.focusedWindow != GetWindow(typeof(SkyListWindow)))
            {
                this.Close();
            }
        }
    }


    [InitializeOnLoad]
    public class OpenSkyTools
    {

        static OpenSkyTools()
        {
            ToolbarExtender.LeftToolbarGUI.Add(OnToolbarGUI);
        }

        static void OnToolbarGUI()
        {
            // GUILayout.FlexibleSpace();
            GUILayout.Space(10);
            var currentScene = RenderSettings.skybox.name;
            float width = 30 + currentScene.Length * 8;
            width = Mathf.Clamp(width, 100, 1000);
            var style = new GUIStyle(EditorStyles.toolbarButton);
            style.alignment = TextAnchor.MiddleCenter;
            var sceneIcon = EditorGUIUtility.IconContent("Skybox Icon").image;

            if (GUILayout.Button(new GUIContent(currentScene, sceneIcon), style, GUILayout.Width(width)))
            {
                SkyListWindow.ShowWindow();
            }
        }
    }
}
