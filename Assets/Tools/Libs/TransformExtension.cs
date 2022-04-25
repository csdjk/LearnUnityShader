
using System.Text;
using UnityEngine;

public static class TransformExtension
{
    public static string GetPath(this Transform go)
    {
        if(go == null) return "";
        StringBuilder tempPath = new StringBuilder(go.name);
        Transform tempTra = go;
        string g = "/";
        while (tempTra.parent != null)
        {
            tempTra = tempTra.parent;
            tempPath.Insert(0, tempTra.name + g);
        }
        return tempPath.ToString();
    }
}