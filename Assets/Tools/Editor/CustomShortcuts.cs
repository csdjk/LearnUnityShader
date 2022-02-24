/*
 * @Descripttion: 自定义快捷键
 * @Author: lichanglong
 * @Date: 2020-12-18 11:33:56
 */

using System;
using System.Reflection;
using UnityEditor;
using UnityEngine;

/// <summary>
/// 自定义快捷键
/// </summary>
public class CustomShortcuts
{
    [MenuItem("MyTools/CustomKeys/播放 _F3")]
    static void EditorPlayCommand()
    {
        EditorApplication.isPlaying = !EditorApplication.isPlaying;
    }

    [MenuItem("MyTools/CustomKeys/暂停 _F4")]
    static void EditorPauseCommand()
    {
        EditorApplication.isPaused = !EditorApplication.isPaused;
    }

    // ---------------------【Ctrl + ...】--------------------------
    [MenuItem("MyTools/CustomKeys/快速定位到Model %m")]
    static void QuickPositioningModel()
    {
        var assetObj = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>("Assets/Models");
        EditorGUIUtility.PingObject(assetObj);
    }

    [MenuItem("MyTools/CustomKeys/重置Position #r")]
    static void QuickResetPosition()
    {
        var trsArr = Selection.transforms;
        if (trsArr == null) return;
        foreach (var trs in trsArr)
        {
            trs.localPosition = Vector3.zero;
        }
    }

    // ---------------------【Shift + ...】--------------------------
    [MenuItem("MyTools/CustomKeys/隐藏显示Object #a")]
    static void QuickSetActive()
    {
        // var go = Selection.activeGameObject;

        var trsArr = Selection.transforms;
        if (trsArr == null) return;
        foreach (var trs in trsArr)
        {
            trs.gameObject.SetActive(!trs.gameObject.activeSelf);
        }
    }

    static MethodInfo clearMethod = null;
    [MenuItem("MyTools/CustomKeys/清空日志 #c")]
    public static void ClearConsole()
    {
        if (clearMethod == null)
        {
            Type log = typeof(EditorWindow).Assembly.GetType("UnityEditor.LogEntries");
            clearMethod = log.GetMethod("Clear");
        }
        clearMethod.Invoke(null, null);
    }



    // ---------------------【Hierarchy】--------------------------

    // 实例化自定义模型
    static void CreateCustomModel(string path)
    {
        var assetObj = AssetDatabase.LoadAssetAtPath<GameObject>(path);
        GameObject go = PrefabUtility.InstantiatePrefab(assetObj) as GameObject;
        PrefabUtility.UnpackPrefabInstance(go, PrefabUnpackMode.Completely, InteractionMode.AutomatedAction);

        var selectGo = Selection.activeGameObject;
        int index = 0;
        if (selectGo && go)
        {
            go.transform.parent = selectGo.transform;
            index = selectGo.transform.childCount;
        }
        else
        {
            var m_Scene = UnityEngine.SceneManagement.SceneManager.GetActiveScene();
            var list = m_Scene.GetRootGameObjects();
            index = list.Length;
        }

        go.transform.SetSiblingIndex(index);
    }

    [MenuItem("GameObject/CreateCustomModel/Jan", false, 0)]
    static void CreateJan()
    {
        CreateCustomModel("Assets/Models/Jan/Jan_Fight_Idle.prefab");
    }
    [MenuItem("GameObject/CreateCustomModel/2B", false, 0)]
    static void Create2B()
    {
        CreateCustomModel("Assets/Models/NieRAutomata/2B_Run/2b_run.fbx");
    }
    [MenuItem("GameObject/CreateCustomModel/Omega", false, 0)]
    static void CreateFortniteOmega()
    {
        CreateCustomModel("Assets/Models/FortniteOmega/Omega.prefab");
    }
    [MenuItem("GameObject/CreateCustomModel/RobotKyle", false, 0)]
    static void CreateRobotKyle()
    {
        CreateCustomModel("Assets/Models/RobotKyle/RobotKyle.fbx");
    }

    [MenuItem("GameObject/CreateCustomModel/Other/BunnyLow", false, 0)]
    static void CreateBunnyLow()
    {
        CreateCustomModel("Assets/Models/Other/BunnyLow.obj");
    }
    [MenuItem("GameObject/CreateCustomModel/Other/Dragon", false, 0)]
    static void CreateDragon()
    {
        CreateCustomModel("Assets/Models/Other/Dragon.obj");
    }

    [MenuItem("GameObject/CreateCustomModel/Other/Knot", false, 0)]
    static void CreateKnot()
    {
        CreateCustomModel("Assets/Models/Other/Knot.FBX");
    }
    [MenuItem("GameObject/CreateCustomModel/Other/Teapot", false, 0)]
    static void CreateTeapot()
    {
        CreateCustomModel("Assets/Models/Other/Teapot.FBX");
    }
    [MenuItem("GameObject/CreateCustomModel/Other/Sphere1", false, 0)]
    static void CreateSphere1()
    {
        CreateCustomModel("Assets/Models/Other/sphere1.obj");
    }
    [MenuItem("GameObject/CreateCustomModel/Other/Sphere2", false, 0)]
    static void CreateSphere2()
    {
        CreateCustomModel("Assets/Models/Other/sphere2.FBX");
    }
    // end

}
