using System.Collections.Generic;
using UnityEngine;
using System.Collections;
using UnityEditor;
using System;
using System.IO;
using System.Threading;

#if UNITY_EDITOR
namespace LcLTools
{
    public class FileSyncTools : Editor
    {
        public static string modelProjectPath = "F:\\UnityProjects\\Work\\APPModelProject";
        public static string clientProjectPath = "F:\\UnityProjects\\Work\\APPGameUnity";

        public static List<string> excludeFiles = new List<string>(){
        "DodAssetProcessor"
    };

        [MenuItem("Assets/LcL Sync Files/To LcLTools", false, 1)]
        private static void SyncLcLToolsFiles()
        {
            if (!Tips(modelProjectPath))
            {
                return;
            }
            ForeachSelectObjs((obj) =>
            {
                SyncFiles(obj, modelProjectPath);
            });
        }


        [MenuItem("Assets/LcL Sync Files/To Model Project", false, 1)]
        private static void SyncFilesToEffect()
        {
            if (!Tips(modelProjectPath))
            {
                return;
            }
            ForeachSelectObjs((obj) =>
           {
               SyncFiles(obj, modelProjectPath);
           });
        }

        [MenuItem("Assets/LcL Sync Files/To Client Project", false, 1)]
        private static void SyncClientFiles()
        {
            if (!Tips(clientProjectPath))
            {
                return;
            }

            ForeachSelectObjs((obj) =>
            {
                SyncFiles(obj, clientProjectPath);
            });
        }

        [MenuItem("Assets/LcL Sync Files/To All Project", false, 1)]
        private static void SyncFilesAll()
        {
            if (!Tips(modelProjectPath + "和" + clientProjectPath))
            {
                return;
            }

            ForeachSelectObjs((obj) =>
            {
                SyncFiles(obj, modelProjectPath);
                SyncFiles(obj, clientProjectPath);
            });
        }
        // 提示框
        private static bool Tips(string path)
        {
            if (Selection.objects.Length == 0)
            {
                return false;
            }
            var file = Selection.objects[0];
            return EditorUtility.DisplayDialog("同步文件", $"复制文件{file.name}到:{path}", "Yes", "No");
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
                    if (excludeFiles.Contains(Path.GetFileNameWithoutExtension(fileName)))
                    {
                        return;
                    }
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
}
#endif
