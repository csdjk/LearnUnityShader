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

    [MenuItem("MyTools/CustomKeys/快速定位到Lua %l")]
    static void QuickPositioningLua()
    {
        var assetObj = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>("Assets/ToLua/Lua");
        EditorGUIUtility.PingObject(assetObj);
    }


    [MenuItem("MyTools/CustomKeys/快速定位到GUI %g")]
    static void QuickPositioningGUI()
    {
        var assetObj = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>("Assets/Resources/GUI");
        EditorGUIUtility.PingObject(assetObj);
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

    [MenuItem("MyTools/CustomKeys/隐藏显示Object #a")]
    static void QuickSetActive()
    {
        var go = Selection.activeGameObject;
        if(go == null) return;
        go.SetActive(!go.activeSelf); 
    }
}
