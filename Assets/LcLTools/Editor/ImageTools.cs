using System.Collections.Generic;
/**
 *  本类是在Unity中直接调用SVN命令做相应的操作
 *  使用方法：右击project面板中的物体
 *  如果操作没有执行，检查计算机环境有没有配置svn路径
 *  选择svn 命令 相应的选项
 */
using UnityEngine;
using System.Collections;
using UnityEditor;
using System;
using System.IO;
using System.Threading;
using System.Diagnostics;
using Debug = UnityEngine.Debug;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;

namespace LcLTools
{
#if UNITY_EDITOR

    public class ImageTools : Editor
    {
        /// <summary>
        /// PS打开图片
        /// </summary>
        [MenuItem("Assets/LcL Open Image By PS", false, 2)]
        public static void OpenImage()
        {
            var path = String.Join(" ", LcLEditorUtilities.GetSelectionAssetPaths().ToArray());
            InvokeExe("Photoshop.exe", path);
        }

        [MenuItem("Assets/LcL Open Model By Houdini", false, 2)]
        public static void OpenModel()
        {
            string appPath;
            if (LcLEditorUtilities.GetApplicationByStartMenu("houdini", out appPath))
            {
                Debug.Log(appPath);
                var path = String.Join(" ", LcLEditorUtilities.GetSelectionAssetPaths().ToArray());
                InvokeExe(appPath, path);
            }
        }

        /// <summary>
        /// 调用Exe
        /// </summary>
        private static void InvokeExe(string exe, string arguments)
        {
            UnityEngine.Debug.Log(arguments);
            AssetDatabase.Refresh();
            new Thread(new ThreadStart(() =>
            {
                try
                {
                    Process p = new Process();
                    p.StartInfo.FileName = exe;
                    // 多个参数用空格隔开
                    p.StartInfo.Arguments = arguments;
                    p.Start(); //启动程序
                    p.WaitForExit();//等待程序执行完退出进程
                    p.Close();
                }
                catch (Exception e)
                {
                    Console.WriteLine(e.Message);
                }
            })).Start();
        }
    }
#endif
}
