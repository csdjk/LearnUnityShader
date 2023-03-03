using System;
using System.Collections.Generic;
using System.IO;
using Microsoft.Win32;
using UnityEditor;
using UnityEngine;
namespace LcLTools
{
    public class LcLEditorUtilities
    {
        // 保存RenderTexture
        public static void SaveRenderTextureToTexture(RenderTexture rt, string path)
        {
            RenderTexture.active = rt;
            Texture2D tex = new Texture2D(rt.width, rt.height, TextureFormat.RGB24, false);
            tex.ReadPixels(new Rect(0, 0, rt.width, rt.height), 0, 0);
            RenderTexture.active = null;

            byte[] bytes;
            bytes = tex.EncodeToPNG();

            System.IO.File.WriteAllBytes(path, bytes);
            AssetDatabase.ImportAsset(path);
            Debug.Log("Saved to " + path);
        }

        /// <summary>
        /// 加载纹理,相对路径
        /// </summary>
        /// <param name="path"></param>
        /// <returns></returns>
        public static Texture2D LoadTexture(string path)
        {
            return AssetDatabase.LoadAssetAtPath<Texture2D>(path);
        }

        // path : 
        /// <summary>
        /// 加载纹理,绝对路径
        /// </summary>
        /// <param name="path"></param>
        /// <returns></returns>
        public static Texture2D LoadTextureAbsolutePath(string path)
        {
            Texture2D tex = null;
            byte[] fileData;
            string filePath = path;
            if (File.Exists(filePath))
            {
                fileData = File.ReadAllBytes(filePath);
                tex = new Texture2D(1024, 1024);
                tex.LoadImage(fileData);
                return tex;
            }

            return null;
        }

        /// <summary>
        /// 根据预设名称获取绝对路径
        /// </summary>
        /// <param name="go"></param>
        /// <returns></returns>
        public static string GetAssetAbsolutePath(UnityEngine.Object go)
        {
            if (go == null) return "";
            string str = Application.dataPath.Replace("Assets", "");
            string path = AssetDatabase.GetAssetPath(go);
            string dir_path = System.IO.Path.GetFullPath(str + path);
            return dir_path;
        }

        /// <summary>
        /// 获取当前选中的第一个物体路径
        /// </summary>
        public static string GetSelectionAssetPath()
        {
            return GetAssetAbsolutePath(Selection.objects[0]);
        }

        /// <summary>
        /// 获取当前选择的所有物体路径
        /// </summary>
        public static List<string> GetSelectionAssetPaths()
        {
            if (Selection.objects.Length == 0)
            {
                return null;
            }
            List<string> paths = new List<string>();
            foreach (var item in Selection.objects)
            {
                paths.Add(GetAssetAbsolutePath(item));
            }
            return paths;
        }


        public static bool GetApplicationByStartMenu(string appName, out string appPath)
        {
            appPath = null;
            /// %AppData%\Microsoft\Windows\Start Menu\Programs
            string startMenuPath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.StartMenu), "Programs");
            /// %ProgramData%\Microsoft\Windows\Start Menu\Programs
            string allStartMenuPath = Path.Combine(Environment.GetEnvironmentVariable("ALLUSERSPROFILE"), "Microsoft\\Windows\\Start Menu\\Programs");

            var appList = FileSystem.GetAllFilePath(startMenuPath, "*.lnk");
            appList.AddRange(FileSystem.GetAllFilePath(allStartMenuPath, "*.lnk"));

            appName = appName.ToLower();
            foreach (var path in appList)
            {
                if (Path.GetFileNameWithoutExtension(path).ToLower().Contains(appName))
                {
                    appPath = path;
                    return true;
                }
            }
            return false;
        }

        /// <summary>
        /// 获取应用程序路径
        /// </summary>
        /// <param name="appName"></param>
        /// <returns></returns>
        // public static string GetApplicationPath(string appName)
        // {
        //     List<RegistryKey> RegistryKeys = new List<RegistryKey>();
        //     RegistryKeys.Add(Registry.ClassesRoot);
        //     RegistryKeys.Add(Registry.CurrentConfig);
        //     RegistryKeys.Add(Registry.CurrentUser);
        //     RegistryKeys.Add(Registry.LocalMachine);
        //     RegistryKeys.Add(Registry.PerformanceData);
        //     RegistryKeys.Add(Registry.Users);
        //     string SubKeyName = @"SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\" + appName;

        //     foreach (RegistryKey registrykey in RegistryKeys)
        //     {
        //         using (RegistryKey subkey = registrykey.OpenSubKey(SubKeyName, false))
        //         {
        //             if (subkey == null)
        //                 return "";

        //             object path = subkey.GetValue("Path");

        //             if (path != null)
        //                 return (string)path;
        //         }
        //     }
        //     return "";
        // }

        /// <summary>
        /// 查找安装的软件
        /// %ProgramData%\Microsoft\Windows\Start Menu\Programs
        /// %AppData%\Microsoft\Windows\Start Menu\Programs
        /// </summary>
        /// <param name="appName"> 软件名称</param>
        /// <param name="appPath "> 安装路径</param>
        /// <returns> true or false </returns>
        public static bool GetApplicationPath(string appName, out string appPath)
        {
            appPath = null;
            List<RegistryKey> RegistryKeys = new List<RegistryKey>();
            RegistryKeys.Add(Registry.ClassesRoot);
            RegistryKeys.Add(Registry.CurrentConfig);
            RegistryKeys.Add(Registry.CurrentUser);
            RegistryKeys.Add(Registry.LocalMachine);
            RegistryKeys.Add(Registry.PerformanceData);
            RegistryKeys.Add(Registry.Users);
            Dictionary<string, string> softwares = new Dictionary<string, string>();
            string SubKeyName = @"Software\Microsoft\Windows\CurrentVersion\Uninstall";
            foreach (RegistryKey registrykey in RegistryKeys)
            {
                using (RegistryKey registryKey1 = registrykey.OpenSubKey(SubKeyName, false))
                {
                    if (registryKey1 == null) // 判断对象不存在
                        continue;
                    if (registryKey1.GetSubKeyNames() == null)
                        continue;
                    string[] KeyNames = registryKey1.GetSubKeyNames();
                    foreach (string KeyName in KeyNames)// 遍历子项名称的字符串数组
                    {
                        using (RegistryKey RegistryKey2 = registryKey1.OpenSubKey(KeyName, false)) // 遍历子项节点
                        {
                            if (RegistryKey2 == null)
                                continue;
                            string name = RegistryKey2.GetValue("DisplayName", "").ToString(); // 获取软件名
                            string InstallLocation = RegistryKey2.GetValue("InstallLocation", "").ToString(); // 获取安装路径
                            if (!string.IsNullOrEmpty(InstallLocation) && !string.IsNullOrEmpty(name))
                            {
                                if (!softwares.ContainsKey(name))
                                    softwares.Add(name, InstallLocation);
                            }
                        }
                    }
                }
            }
            if (softwares.Count <= 0)
                return false;
            foreach (string name in softwares.Keys)
            {
                if (name.Contains(appName))
                {
                    appPath = softwares[name];
                    return true;
                }
            }
            return false;
        }
    }
}