using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEngine;
using UnityEngine.Rendering;
// using UnityEngine.Rendering.Universal;
using UnityEngine.SceneManagement;
#if UNITY_EDITOR
using UnityEditor;
#endif

namespace LcLTools
{
    enum LodLevel
    {
        LOD100 = 100,
        LOD200 = 200,
        LOD300 = 300,
    }
    [ExecuteAlways, RequireComponent(typeof(Camera)), AddComponentMenu("LcLTools/LcLTest", 0)]
    public class LcLTest : MonoBehaviour
    {
        //---------------------------GUI-------------------------------------
        public Vector2 uiBoxSize = new Vector2(600, 250);
        [Range(10, 200)]
        public float buttonHeight = 50;
        [Range(10, 100)]
        public int fontSize = 25;
        private Rect uiBoxRect = new Rect(0, 0, 0, 0);
        //---------------------------GUI-------------------------------------
        public Camera m_camera;

        [Range(100, 300)]
        public int lodLevel = 300;


        [Header("场景跳转列表")]
        public string[] sceneList;

        [Header("单选切换对象")]
        public GameObject[] singleList;
        [Header("显示隐藏切换对象")]
        public GameObject[] toggleList;
        private GUIStyle enableStyle;
        private GUIStyle disableStyle;

        private int grassIndex = 0;
        private Bloom bloomV;
        private bool isTest;
        private bool isCutoff;

        void OnEnable()
        {
            if (m_camera == null)
            {
                m_camera = GetComponent<Camera>();
            }
#if UNITY_EDITOR
            sceneList = EditorBuildSettings.scenes
                         .Where(scene => scene.enabled)
                         .Select(scene => Path.GetFileNameWithoutExtension(scene.path))
                         .ToArray();
#endif
        }

        void OnDisable()
        {

        }

        public GUIStyle GetStyle(bool value)
        {
            return value ? enableStyle : disableStyle;
        }
        public bool Button(string name, bool active = false)
        {
            return GUILayout.Button(name, GetStyle(active), GUILayout.Height(buttonHeight));
        }
       

        public void SRPSwitch()
        {
            GraphicsSettings.useScriptableRenderPipelineBatching = !GraphicsSettings.useScriptableRenderPipelineBatching;
        }

    
        public void GotoScene(int index)
        {
            SceneManager.LoadScene(index);
        }

        public void SingleGoSwitch(GameObject value)
        {
            foreach (var item in singleList)
            {
                item.SetActive(item == value);
            }
        }

        public void HideSingleList()
        {
            foreach (var item in singleList)
            {
                item.SetActive(false);
            }
        }

        public void ToggleListSwitch(GameObject go)
        {
            go.SetActive(!go.activeSelf);
        }
        public void HideToggleList()
        {
            foreach (var item in toggleList)
            {
                item.SetActive(false);
            }
        }

        public void SwitchKeyword(bool value, string keyword)
        {
            if (value)
            {
                Shader.EnableKeyword(keyword);
            }
            else
            {
                Shader.DisableKeyword(keyword);
            }
        }

        private Vector2Int screen = new Vector2Int(Screen.width, Screen.height);
        public void ChangeResolution(int v)
        {
            switch (v)
            {
                case 0:
                    Screen.SetResolution(screen.x, screen.y, true);
                    break;
                case 1:
                    Screen.SetResolution(screen.x / 2, screen.y / 2, true);
                    break;
            }
        }

        public string GetSRPState()
        {
            return GraphicsSettings.useScriptableRenderPipelineBatching ? "SRP(ing...)" : "SRP";
        }
        void OnValidate()
        {
            Shader.globalMaximumLOD = lodLevel;
        }


        bool isInit = true;
        void OnGUI()
        {
            if (isInit)
            {
                isInit = false;
                uiBoxRect.x = Screen.width - uiBoxSize.x;
                uiBoxRect.y = Screen.height - uiBoxSize.y;
                enableStyle = new GUIStyle(GUI.skin.button);
                disableStyle = new GUIStyle(GUI.skin.button);
                enableStyle.normal.textColor = Color.green;
                enableStyle.hover.textColor = Color.green;
                enableStyle.fontSize = fontSize;
                disableStyle.normal.textColor = Color.white;
                disableStyle.fontSize = fontSize;
            }

            uiBoxRect = GUI.Window(1, uiBoxRect, WindowCallBack, "");
            uiBoxRect.width = uiBoxSize.x;
            uiBoxRect.height = uiBoxSize.y;
        }

        private void WindowCallBack(int windowID)
        {
            GUI.skin.button.fontSize = fontSize;
            GUI.skin.label.fontSize = fontSize;
            GUI.skin.label.alignment = TextAnchor.MiddleCenter;
            GUI.backgroundColor = new Color(0, 0, 0, 0.5f);

            GUILayout.BeginHorizontal();
            {

                // 单选开关切换
                if (singleList != null)
                {
                    GUILayout.BeginVertical();
                    {
                        foreach (var item in singleList)
                        {
                            if (item)
                            {
                                if (Button(item.name, item.activeSelf))
                                {
                                    SingleGoSwitch(item);
                                }
                            }
                        }
                        if (Button("Hide All", false))
                        {
                            HideSingleList();
                        }
                    }
                    GUILayout.EndVertical();
                }
                // 多选开关
                if (toggleList != null)
                {
                    GUILayout.BeginVertical();
                    {
                        foreach (var item in toggleList)
                        {
                            if (item)
                            {
                                if (Button(item.name, item.activeSelf))
                                {
                                    ToggleListSwitch(item);
                                }
                            }
                        }
                        if (Button("Hide All", false))
                        {
                            HideToggleList();
                        }
                    }
                    GUILayout.EndVertical();
                }

                // Scene List
                if (sceneList != null)
                {
                    GUILayout.BeginVertical();
                    {
                        Button("Scene List");
                        for (int i = 0; i < sceneList.Length; i++)
                        {
                            var scene = sceneList[i];
                            if (Button(scene))
                            {
                                GotoScene(i);
                            }
                        }
                    }
                    GUILayout.EndVertical();
                }
                // 

                GUILayout.BeginVertical();
                {
                    // if (Button(GetBloomFeatureState()))
                    // {
                    //     BloomFeatureSwitch();
                    // }
                    // if (Button("BloomV", bloomV && bloomV.active))
                    // {
                    //     BloomVolumeSwitch();
                    // }
                    // if (Button(GetTonemappingState()))
                    // {
                    //     ACESSwitch();
                    // }
                 
                    // if (Button("TEST", isTest))
                    // {
                    //     isTest = !isTest;
                    //     SwitchKeyword(isTest, "_TEST");
                    // }
                    // if (Button("CUTOFF", isCutoff))
                    // {
                    //     isCutoff = !isCutoff;
                    //     SwitchKeyword(isCutoff, "_CUTOFF");
                    // }

                }
                GUILayout.EndVertical();

                GUILayout.BeginVertical();
                {
                    GUILayout.Space(10);
                    foreach (LodLevel lod in Enum.GetValues(typeof(LodLevel)))
                    {
                        if (Button(lod.ToString(), Shader.globalMaximumLOD == (int)lod))
                        {
                            Shader.globalMaximumLOD = (int)lod;
                        }
                    }
                    if (Button(GetSRPState()))
                    {
                        SRPSwitch();
                    }

                }
                GUILayout.EndVertical();
            }
            GUILayout.EndHorizontal();

            GUI.DragWindow(new Rect(0, 0, Screen.width, Screen.height));

        }
    }
}
