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

namespace LcLTools
{

    public class SceneListWindow : EditorWindow
    {
        static List<GUIContent> sceneList = new List<GUIContent>();
        // instance
        public static EditorWindow instance;
        public static void ShowWindow()
        {
            if (instance != null)
            {
                instance.Close();
                instance = null;
            }
            instance = EditorWindow.GetWindow(typeof(SceneListWindow));
        }

        void OnGUI()
        {
            // DrawSceneList();
        }

        public void OnEnable()
        {

            var root = this.rootVisualElement;

            var list = new List<string>() { "Item 1", "Item 2", "Item 3" };
            var listView = new ListView(list, 20, () => new Label(), (element, index) =>
            {
                (element as Label).text = list[index];
            });
            root.Add(listView);
        }
        // public void OnLostFocus()
        // {
        //     if (instance != null)
        //     {
        //         instance.Close();
        //         instance = null;
        //     }
        // }

        //draw sceneList item
        // static void DrawSceneList()
        // {
        //     for (int i = 0; i < sceneList.Count; ++i)
        //     {
        //         if (GUILayout.Button(sceneList[i], GUILayout.Width(width)))
        //         {
        //             if (EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo())
        //             {
        //                 EditorSceneManager.OpenScene(scenesPath[i]);
        //             }
        //         }
        //     }
        // }
    }


    [InitializeOnLoad]
    public class OpenSceneTools
    {
        static List<GUIContent> sceneList = new List<GUIContent>();
        static List<string> scenePathList = new List<string>();
        static string[] scenesPath;
        static string[] scenesBuildPath;
        static int selectedSceneIndex;
        static float width = 350f;
        static Vector3 scrollPosition = Vector3.zero;
        static OpenSceneTools()
        {
            ToolbarExtender.LeftToolbarGUI.Add(OnToolbarGUI);
        }

        static void OnToolbarGUI()
        {
            RefreshScenesList();
            GUILayout.FlexibleSpace();

            selectedSceneIndex = EditorGUILayout.Popup(selectedSceneIndex, sceneList.ToArray(), GUILayout.Width(width));
      
            // if (GUILayout.Button("SceneList", GUILayout.Width(100)))
            // {
            //     SceneListWindow.ShowWindow();
            // }
           

            if (GUI.changed && 0 <= selectedSceneIndex && selectedSceneIndex < sceneList.Count)
            {
                if (EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo())
                {
                    EditorSceneManager.OpenScene(scenesPath[selectedSceneIndex]);
                }
            }
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
                // string name = (scenesPath[i]);

                if (activeScene.name == name)
                {
                    selectedSceneIndex = i;
                }


                GUIContent content = new GUIContent(name, EditorGUIUtility.FindTexture("BuildSettings.Editor.Small"), "Select Scene");
                sceneList.Add(content);
                scenePathList.Add(scenesPath[i]);
            }
        }

        static string GetSceneName(string path)
        {
            // path = path.Replace(".unity", "");
            // return Path.GetFileName(path);
            path = path.Replace("Assets/Scenes/", "");
            return path;
        }
    }
}
