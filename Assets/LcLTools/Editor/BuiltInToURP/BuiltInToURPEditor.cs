using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEngine.UIElements;
using System.Linq;
using UnityEditor.UIElements;
using Random = UnityEngine.Random;
using System.IO;
using System.Text.RegularExpressions;

namespace LcLTools
{
    public class BuiltInToURPEditor : EditorWindow
    {
        static string stylePath = "Assets/LiChangLong/LcLTools/Editor/BuiltInToURP/BuiltInToURPEditor.uss";

        static List<GameObject> prefabList = new List<GameObject>();
        static ObjectField parentField;
        static ScrollView m_FileContainer;

        private Button editButton;


        [MenuItem("LcLTools/BuiltIn-To-URP", false, 1000)]
        static void OpenWindow()
        {
            BuiltInToURPEditor window = GetWindow<BuiltInToURPEditor>();
            window.titleContent = new GUIContent("BuiltIn To URP");
            window.minSize = new Vector2(450, 450);
            window.Show();
            window.Focus();
        }

        void OnEnable()
        {
        }


        public void CreateGUI()
        {
            VisualElement root = rootVisualElement;
            root.styleSheets.Add(AssetDatabase.LoadAssetAtPath<StyleSheet>(stylePath));

            var title = new Label("Shader文件列表");
            root.Add(title);

            m_FileContainer = new ScrollView();
            m_FileContainer.verticalScrollerVisibility = ScrollerVisibility.Auto;
            root.Add(m_FileContainer);

            AddFileField();
            //----------------------------------------------Button----------------------------------------------
            editButton = new Button() { text = "转换" };
            editButton.AddToClassList("button");
            editButton.RegisterCallback<ClickEvent>(OnConvertClickEvent);
            editButton.userData = false;
            root.Add(editButton);
        }

        void AddFileField()
        {
            var box = new Box();
            box.AddToClassList("item");
            var file = new ObjectField("File") { objectType = typeof(Object) };
            file.AddToClassList("item-field");
            box.Add(file);
            var button = new Button() { text = "-" };
            button.AddToClassList("item-button");
            box.Add(button);
            m_FileContainer.Add(box);
        }

        private void Clean()
        {
            prefabList.Clear();
            m_FileContainer.Clear();
        }
        // 转换
        private void OnConvertClickEvent(ClickEvent evt)
        {
            var list = m_FileContainer.Children();
            foreach (var item in list)
            {
                var value = (item.ElementAt(0) as ObjectField).value;
                if (value)
                {
                    var path = AssetDatabase.GetAssetPath(value);
                    path = LcLUtility.AssetsRelativeToAbsolutePath(path);
                    var files = FileSystem.GetFiles(path, "*.shader");

                    BuildInToURPTool.ReplaceShaderByPath(files, () =>
                    {
                        Debug.Log("替换完成");
                    });

                    // var str = "half4 distortColor = tex2D(_DisortTex, TRANSFORM_TEX(distortUV, _DisortTex));";

                    // str = Regex.Replace(str, @"tex2D\(([^,]*),(.*);", "SAMPLE_TEXTURE2D($1,sampler$1,$2;");
                    // Debug.Log(str);
                }
            }

        }

        void UpdatePrefabList()
        {

        }

    }
}

