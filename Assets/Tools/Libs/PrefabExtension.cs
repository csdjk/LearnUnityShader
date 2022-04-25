using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
#if UNITY_EDITOR

static public class PrefabExtension
{
    [MenuItem("CONTEXT/Transform/SavePrefab")]
    static public void SavePrefab()
    {
        var go = Selection.activeGameObject;
        string prefabPath = GetPrefabAssetPath(go);
        if (prefabPath == null) return;
        
        if (prefabPath.EndsWith(".prefab") == false) return;
        bool succes;
        // PrefabUtility.SaveAsPrefabAsset(go, prefabPath, out succes);
        PrefabUtility.SaveAsPrefabAssetAndConnect(go,prefabPath,InteractionMode.UserAction,out succes);
        if (succes)
        {
            Debug.LogError("prefab保存成功：" + prefabPath);
        }
        else
        {
            Debug.LogError("prefab保存失败：" + prefabPath);
        }
    }

    // 快捷键 保存预设 crtl + alt + s
    [MenuItem("LCLTools/CustomKeys/SavePrefab %&s")]
    static public void QuickSavePrefab()
    {
        if(!EditorApplication.isPlaying){
            SavePrefab();
        }
    }

    /// <summary>
    /// 获取预制体资源路径。
    /// </summary>
    /// <param name="gameObject"></param>
    /// <returns></returns>
    public static string GetPrefabAssetPath(GameObject gameObject)
    {
        // Project中的Prefab是Asset不是Instance
        if (UnityEditor.PrefabUtility.IsPartOfPrefabAsset(gameObject))
        {
            // 预制体资源就是自身
            return UnityEditor.AssetDatabase.GetAssetPath(gameObject);
        }

        // Scene中的Prefab Instance是Instance不是Asset
        if (UnityEditor.PrefabUtility.IsPartOfPrefabInstance(gameObject))
        {
            // 获取预制体资源
            var prefabAsset = UnityEditor.PrefabUtility.GetCorrespondingObjectFromOriginalSource(gameObject);
            return UnityEditor.AssetDatabase.GetAssetPath(prefabAsset);
        }

        // PrefabMode中的GameObject既不是Instance也不是Asset
        var prefabStage = UnityEditor.Experimental.SceneManagement.PrefabStageUtility.GetPrefabStage(gameObject);
        if (prefabStage != null)
        {
            // 预制体资源：prefabAsset = prefabStage.prefabContentsRoot
            return prefabStage.prefabAssetPath;
        }

        // 不是预制体
        return null;
    }

}
#endif