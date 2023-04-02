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
        public static string learnUnityShaderPath = "E:\\LiChangLong\\LearnUnityShader";
        public static string learnURPPath = "E:\\LiChangLong\\LearnURP";
        public static string lclRenderPipelinePath = "E:\\LiChangLong\\LcL-RenderPipeline";

        public static List<string> excludeFiles = new List<string>() { };

        [MenuItem("Assets/LcL Sync Files/To LearnUnityShader", false, 1)]
        private static void SyncFilesToLearnShader()
        {
            if (!Tips(learnUnityShaderPath))
            {
                return;
            }
            ForeachSelectObjs((obj) =>
           {
               SyncFiles(obj, learnUnityShaderPath);
           });
        }

        [MenuItem("Assets/LcL Sync Files/To LearnURP", false, 1)]
        private static void SyncFilesToLearnURP()
        {
            if (!Tips(learnURPPath))
            {
                return;
            }
            ForeachSelectObjs((obj) =>
           {
               SyncFiles(obj, learnURPPath);
           });
        }

        [MenuItem("Assets/LcL Sync Files/To RenderPipeline", false, 1)]
        private static void SyncFilesToRenderPipeline()
        {
            if (!Tips(lclRenderPipelinePath))
            {
                return;
            }

            ForeachSelectObjs((obj) =>
            {
                SyncFiles(obj, lclRenderPipelinePath);
            });
        }

        [MenuItem("Assets/LcL Sync Files/To All Project", false, 1)]
        private static void SyncFilesAll()
        {
            if (!Tips(learnURPPath + "和" + lclRenderPipelinePath))
            {
                return;
            }

            ForeachSelectObjs((obj) =>
            {
                SyncFiles(obj, learnURPPath);
                SyncFiles(obj, lclRenderPipelinePath);
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
