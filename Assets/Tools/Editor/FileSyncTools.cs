using System.Collections.Generic;
using UnityEngine;
using System.Collections;
using UnityEditor;
using System;
using System.IO;
using System.Threading;

#if UNITY_EDITOR

public class FileSyncTools : Editor
{
    public static string modelProjectPath = "F:\\UnityProjects\\Work\\APPModelProject";
    public static string clientProjectPath = "F:\\UnityProjects\\Work\\APPGameUnity";
    public static string lclProjectPath = "F:\\UnityProjects\\Work\\APPGameUnity";


    [MenuItem("Assets/Sync Files/Sync Files To All Project")]
    private static void SyncFilesAll()
    {
        ForeachSelectObjs((obj) =>
      {
          SyncFiles(obj, modelProjectPath);
          SyncFiles(obj, clientProjectPath);
      });
    }

    [MenuItem("Assets/Sync Files/Sync Files To Model Project")]
    private static void SyncFilesToEffect()
    {
        ForeachSelectObjs((obj) =>
       {
           SyncFiles(obj, modelProjectPath);
       });
    }

    [MenuItem("Assets/Sync Files/Sync Files To Client Project")]
    private static void SyncClientFiles()
    {
        ForeachSelectObjs((obj) =>
        {
            SyncFiles(obj, clientProjectPath);
        });
    }

    [MenuItem("Assets/Sync Files/Sync LcLTools Files")]
    private static void SyncLcLToolsFiles()
    {
        ForeachSelectObjs((obj) =>
        {
            SyncFilesAndDeleteOldFile(obj, modelProjectPath);
        });
    }

    private static void ForeachSelectObjs(Action<UnityEngine.Object> func)
    {
        if (Selection.objects.Length == 0)
        {
            return;
        }
        List<string> paths = new List<string>();
        foreach (var item in Selection.objects)
        {
            func(item);
        }
    }

    private static void SyncFiles(UnityEngine.Object go, string targetPath)
    {
        if (go == null) { return; }
        string assetPath = AssetDatabase.GetAssetPath(go);
        string currentPath = Application.dataPath.Replace("Assets", "");
        string filePath = Path.Combine(currentPath, assetPath);
        string destFile = Path.Combine(targetPath, assetPath);
        if (File.Exists(filePath))
        {
            Debug.Log("-----------------文件同步成功-----------------");
            Debug.Log("<color='#59D700'>" + filePath + " </color> \n => <color='#CAD600'>" + destFile + "</color>");
            File.Copy(filePath, destFile, true);
        }
        else if (Directory.Exists(filePath))
        {
            string[] files = Directory.GetFiles(filePath);
            foreach (string s in files)
            {
                var fileName = Path.GetFileName(s);
                var source = Path.Combine(filePath, fileName);
                var target = Path.Combine(destFile, fileName);
                Debug.Log("-----------------文件同步成功-----------------");
                Debug.Log("<color='#59D700'>" + source + " </color> \n => <color='#CAD600'>" + target + "</color>");
                File.Copy(source, target, true);
            }
        }
    }

    private static void SyncFilesAndDeleteOldFile(UnityEngine.Object go, string targetPath)
    {
        if (go == null) { return; }
        string assetPath = AssetDatabase.GetAssetPath(go);
        string currentPath = Application.dataPath.Replace("Assets", "");
        string filePath = Path.Combine(currentPath, assetPath);
        string destFile = Path.Combine(targetPath, assetPath.Replace(Path.GetFileName(assetPath), String.Empty));
        CopyFileDirectory(filePath, destFile);
    }

    public static void CopyFileDirectory(string sourceDirectory, string targetDirectory)
    {
        try
        {
            var fileName = Path.GetFileName(sourceDirectory);
            if (Directory.Exists(sourceDirectory))
            {
                if (!Directory.Exists(targetDirectory + "\\" + fileName))
                {
                    Directory.CreateDirectory(targetDirectory + "\\" + fileName);
                }
                DirectoryInfo dir = new DirectoryInfo(sourceDirectory);
                FileSystemInfo[] fileinfo = dir.GetFileSystemInfos();
                foreach (FileSystemInfo i in fileinfo)
                {
                    CopyFileDirectory(i.FullName, targetDirectory + "\\" + fileName);
                }
            }
            else
            {
                Debug.Log("-----------------文件同步成功-----------------");
                Debug.Log("<color='#59D700'>" + sourceDirectory + " </color> \n => <color='#CAD600'>" + targetDirectory + "\\" + fileName + "</color>");
                File.Copy(sourceDirectory, targetDirectory + "\\" + fileName, true);
            }
        }
        catch (Exception ex)
        {
            Debug.Log("复制文件出现异常" + ex.Message);
        }
    }
}
#endif
