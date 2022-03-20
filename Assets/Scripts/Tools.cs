using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

public static class Tools
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

        // string path = AssetDatabase.GetAssetPath(rt) + ".png";
        System.IO.File.WriteAllBytes(path, bytes);
        AssetDatabase.ImportAsset(path);
        Debug.Log("Saved to " + path);
    }

    // 加载纹理，工程路径
    // path : "Assets/Texture/Mask.png"
    public static Texture2D LoadTexture(string path)
    {
        return AssetDatabase.LoadAssetAtPath<Texture2D>(path);
    }

    // 加载纹理，全路径
    // path : "E:/UnityProject/Assets/Texture/Mask.png"
    public static Texture2D LoadTextureAllPath(string path)
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
}
