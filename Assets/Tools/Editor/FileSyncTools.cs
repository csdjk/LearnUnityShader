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
    public static string URPProjectPath = "E:\\UnityProject\\LiChangLong\\LearnURP";
    public static string PipeProjectPath = "E:\\UnityProject\\LiChangLong\\LcL-RenderPipeline";


    [MenuItem("Assets/Sync Files/To All Project")]
    private static void SyncFilesAll()
    {
        ForeachSelectObjs((obj) =>
      {
          SyncFiles(obj, URPProjectPath);
          SyncFiles(obj, PipeProjectPath);
      });
    }

    [MenuItem("Assets/Sync Files/To URP Project")]
    private static void SyncFilesToURP()
    {
        ForeachSelectObjs((obj) =>
       {
           SyncFiles(obj, URPProjectPath);
       });
    }


    [MenuItem("Assets/Sync Files/To LcLRenderPipeline Files")]
    private static void SyncFilesToPipe()
    {
        ForeachSelectObjs((obj) =>
        {
            SyncFiles(obj, PipeProjectPath);
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
