using System;
using System.Linq;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityToolbarExtender;

namespace LcLTools
{
    [InitializeOnLoad]
    public class OpenSceneTools
    {
        static List<GUIContent> sceneList = new List<GUIContent>();
        static List<string> scenePathList = new List<string>();
        static string[] scenesPath;
        static string[] scenesBuildPath;
        static int selectedSceneIndex;
        static float width = 150f;

        static OpenSceneTools()
        {
            ToolbarExtender.LeftToolbarGUI.Add(OnToolbarGUI);
        }

        static void OnToolbarGUI()
        {
            RefreshScenesList();
            GUILayout.FlexibleSpace();
            selectedSceneIndex = EditorGUILayout.Popup(selectedSceneIndex, sceneList.ToArray(), GUILayout.Width(width));

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
            path = path.Replace(".unity", "");
            return Path.GetFileName(path);
        }
    }
}
