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
        static Toggle toggle;
        static float toggleHeight = 30;
        static Texture sceneIcon;
        static EditorWindow instance;
        static int maxRow = 6;
        static Vector2 itemSize = new Vector2(120, 132);
        static float margin = 2;
        static float padding = 5;
        static Button selectedButton;

        static int count;
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
            instance = EditorWindow.GetWindow(typeof(SkyListWindow));
            instance.titleContent = new GUIContent("Sky List");

            float itemTotalSizeX = itemSize.x + margin * 2;
            float itemTotalSizeY = itemSize.y + margin * 2;

            int col = Mathf.CeilToInt((float)count / maxRow);
            int row = Mathf.CeilToInt((float)count / col);
            float totalWidth = 10 + itemTotalSizeX * col;
            float totalHeight = 10 + itemTotalSizeY * (count < row ? count : row);
            Vector2 temp = GUIUtility.GUIToScreenPoint(new Vector2(Event.current.mousePosition.x, Event.current.mousePosition.y));

            instance.position = new Rect(temp.x - totalWidth / 2, temp.y + 20, totalWidth, totalHeight);
            instance.Show();
        }



        public void OnEnable()
        {
            sceneIcon = EditorGUIUtility.IconContent("SceneAsset Icon").image;

            var root = this.rootVisualElement;

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


            // 
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
            string[] materialGuids = AssetDatabase.FindAssets("t:Material", new[] { path });
            string skyPath = RenderSettings.skybox != null ? AssetDatabase.GetAssetPath(RenderSettings.skybox) : "";

            imageDic.Clear();
            foreach (string guid in materialGuids)
            {
                string assetPath = AssetDatabase.GUIDToAssetPath(guid);
                Material material = AssetDatabase.LoadAssetAtPath<Material>(assetPath);
                var shaderName = material.shader?.name.ToLower();
                if (shaderName.Contains("sky") || shaderName.Contains("cubemap"))
                {
                    var box = BindItem(material.name, assetPath, material);
                    groupBox.Add(box);
                    if (skyPath == assetPath)
                    {
                        SelectButton(box);
                    }
                }
            }
            count = groupBox.childCount;
            scrollView.Add(groupBox);
            root.Add(scrollView);
        }

        // 创建一个字典，用于存储所有的Image 
        static Dictionary<Image, Material> imageDic = new Dictionary<Image, Material>();
        static Button BindItem(string name, string path, Material material)
        {
            var box = new Button(() =>
            {
                EditorGUIUtility.PingObject(material);
                RenderSettings.skybox = material;
            });
            // register mouse enter event
            box.RegisterCallback<ClickEvent>((e) =>
            {
                EditorGUIUtility.PingObject(material);
                RenderSettings.skybox = material;
                SelectButton(e.target as Button);
                e.StopPropagation();
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

            box.style.width = itemSize.x;
            box.style.height = itemSize.y;
            box.style.unityTextAlign = TextAnchor.MiddleLeft;
            box.tooltip = path;

            Image image = new Image();
            image.style.flexShrink = 0;
            image.style.width = 100;
            image.style.height = 100;
            image.image = AssetPreview.GetAssetPreview(material);
            box.Add(image);
            imageDic.Add(image, material);

            Label label = new Label(name);
            label.style.flexGrow = 1.0f;
            label.style.alignItems = Align.Center;
            label.style.marginTop = 5;
            box.Add(label);
            return box;
        }
        static void SelectButton(Button button)
        {
            if (selectedButton != null) selectedButton.style.backgroundColor = defaultColor;
            selectedButton = button;
            selectedButton.style.backgroundColor = selectColor;
        }

        void Update()
        {
            foreach (var item in imageDic)
            {
                if (item.Key.image == null)
                {
                    item.Key.image = AssetPreview.GetAssetPreview(item.Value);
                }
            }

            if (Application.isPlaying)
            {
                toggle.value = true;
                return;
            }
            if (toggle.value) return;

            if (SkyListWindow.focusedWindow != GetWindow(typeof(SkyListWindow)))
            {
                this.Close();
            }
        }

        void OnDestroy()
        {
            instance = null;
            toggle = null;
        }
    }


    [InitializeOnLoad]
    public class OpenSkyTools
    {

        static OpenSkyTools()
        {
            ToolbarExtender.RightToolbarGUI.Add(OnToolbarGUI);
        }

        static void OnToolbarGUI()
        {
            var currentSkyName = RenderSettings.skybox ? RenderSettings.skybox.name : "No Sky";
            float width = 30 + currentSkyName.Length * 8;
            width = Mathf.Clamp(width, 100, 1000);
            var style = new GUIStyle(EditorStyles.toolbarButton);
            style.alignment = TextAnchor.MiddleCenter;
            var icon = EditorGUIUtility.IconContent("Skybox Icon").image;

            if (GUILayout.Button(new GUIContent(currentSkyName, icon), style, GUILayout.Width(width)))
            {
                SkyListWindow.ShowWindow();
            }
        }
    }
}
