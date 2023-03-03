using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace LcLTools
{
    [System.Serializable]
    public class JsonListWrapper<T>
    {
        public List<T> list;
        public JsonListWrapper(List<T> list) => this.list = list;
    }

    public static class LcLUtility
    {
        /// <summary>
        /// 三角形内随机采样
        /// </summary>
        /// <param name="A"></param>
        /// <param name="B"></param>
        /// <param name="C"></param>
        /// <returns></returns>
        public static Vector3 RandomTriangle(Vector3 A, Vector3 B, Vector3 C)
        {
            // 重心坐标
            float randomX = Random.Range(0, 1f);
            float randomY = Random.Range(0, 1 - randomX);
            float randomZ = 1 - randomX - randomY;
            return A * randomX + B * randomY + C * randomZ;
        }

        /// <summary>
        /// 计算三角形面积
        /// </summary>
        /// <param name="A"></param>
        /// <param name="B"></param>
        /// <param name="C"></param>
        /// <returns></returns>
        public static float CalculateTriangleArea(Vector3 A, Vector3 B, Vector3 C)
        {
            var AB = B - A;
            var AC = C - A;
            // cosA
            var CosTheta = Vector3.Dot(AB.normalized, AC.normalized);
            var SinTheta = 1 - CosTheta;

            // S = 1／2 ab sinθ
            return 0.5f * AB.magnitude * AC.magnitude * SinTheta;
        }

        /// <summary>
        /// 计算法向量
        /// </summary>
        /// <param name="p1"></param>
        /// <param name="p2"></param>
        /// <param name="p3"></param>
        /// <returns></returns>
        public static Vector3 CalculateTriangleNormal(Vector3 p1, Vector3 p2, Vector3 p3)
        {
            var vx = p2 - p1;
            var vy = p3 - p1;
            return Vector3.Cross(vx, vy);
        }


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

        // 绝对路径转Unity工程相对路径
        public static string AssetsRelativePath(string absolutePath)
        {

            if (absolutePath.StartsWith(Application.dataPath))
            {
                return "Assets" + absolutePath.Substring(Application.dataPath.Length);
            }
            else
            {
                absolutePath = absolutePath.Replace('\\', '/');
                if (absolutePath.StartsWith(Application.dataPath))
                {
                    return "Assets" + absolutePath.Substring(Application.dataPath.Length);
                }
                Debug.LogWarning("Full path does not contain the current project's Assets folder");
                return null;
            }
        }
        /// <summary>
        /// 相对路径转绝对路径
        /// </summary>
        /// <param name="absolutePath"></param>
        /// <returns></returns>
        public static string AssetsRelativeToAbsolutePath(string path)
        {
            return Application.dataPath + path.Substring(6);
        }
    }
}
