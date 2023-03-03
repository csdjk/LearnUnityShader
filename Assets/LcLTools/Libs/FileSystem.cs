using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEngine;
namespace LcLTools
{
    public class FileSystem
    {

        /// <summary>
        /// 
        /// </summary>
        /// <param name="path">路径</param>
        /// <param name="searchPattern">
        /// *.* : 所有文件
        /// <returns></returns>
        public static List<string> GetFiles(string path, string searchPattern = "*.*")
        {
            var list = new List<string>();
            GetPath(path, list, searchPattern);
            return list;
        }

        private static void GetPath(string path, List<string> list, string searchPattern)
        {
            if (File.Exists(path))
            {
                list.Add(path);
                return;
            }

            DirectoryInfo dir = new DirectoryInfo(path);
            // 文件
            FileInfo[] fil = dir.GetFiles(searchPattern);
            // 目录
            DirectoryInfo[] dii = dir.GetDirectories();

            var dirName = dir.Name;

            foreach (FileInfo f in fil)
            {
                list.Add(f.FullName);//添加文件的路径到列表
            }
            //获取子文件夹内的文件列表
            foreach (DirectoryInfo d in dii)
            {
                GetPath(d.FullName, list, searchPattern);
            }
        }


        /// <summary>
        /// 获取所有文件路径
        /// </summary>
        /// <param name="path"></param>
        /// <param name="searchPattern"></param>
        /// <returns></returns>
        public static List<string> GetAllFilePath(string path, string searchPattern)
        {
            var list = new List<string>();
            GetAllFilePath(path, list, searchPattern);
            return list;
        }
        private static void GetAllFilePath(string path, List<string> list, string searchPattern)
        {
            var fils = Directory.GetFiles(path, searchPattern);
            list.AddRange(fils);
            var dirList = Directory.GetDirectories(path);
            foreach (var dir in dirList)
            {
                //获取子文件夹内的文件列表
                if (Directory.Exists(dir))
                {
                    GetAllFilePath(dir, list, searchPattern);
                }
            }
        }

        // 获取所有文件
        public static void GetAllFileByPath(string path, ref List<FileInfo> res, string searchPattern)
        {
            DirectoryInfo dir = new DirectoryInfo(path);
            // 文件
            FileInfo[] fil = dir.GetFiles(searchPattern);
            // 目录
            DirectoryInfo[] dii = dir.GetDirectories();
            // 遍历当前文件夹下的所有文件
            foreach (FileInfo f in fil)
            {
                res.Add(f);
            }
            //获取子文件夹内的文件列表
            foreach (DirectoryInfo d in dii)
            {
                GetAllFileByPath(d.FullName, ref res, searchPattern);
            }
        }


        public static void GetAllFileByPath(string path, Action<FileInfo> func, string searchPattern)
        {
            DirectoryInfo dir = new DirectoryInfo(path);
            // 文件
            FileInfo[] fil = dir.GetFiles(searchPattern);
            // 目录
            DirectoryInfo[] dii = dir.GetDirectories();
            // 遍历当前文件夹下的所有文件
            foreach (FileInfo f in fil)
            {
                func(f);
            }
            //获取子文件夹内的文件列表
            foreach (DirectoryInfo d in dii)
            {
                GetAllFileByPath(d.FullName, func, searchPattern);
            }
        }



        // 写入文件
        public static void WriteFile(string path, Action<StreamWriter> func)
        {
            // 存在就先删除
            if (File.Exists(path))
                File.Delete(path);
            // 写入
            using (StreamWriter file = new StreamWriter(path, true))
            {
                func(file);
            }
        }
        // 读取文件
        public static void ReadeFile(string path, Action<StreamReader> func)
        {
            if (!File.Exists(path))
                return;
            using (StreamReader file = new StreamReader(path, Encoding.Default))
            {
                func(file);
            }
        }
    }
}
