using UnityEngine;
using UnityEditor;
public class SaveRenderTextureToFile
{
    [MenuItem("Assets/Save RenderTexture to file")]
    public static void SaveRTToFile()
    {
        RenderTexture rt = Selection.activeObject as RenderTexture;

        RenderTexture.active = rt;
        Texture2D tex = new Texture2D(rt.width, rt.height, TextureFormat.RGB24, false);
        tex.ReadPixels(new Rect(0, 0, rt.width, rt.height), 0, 0);
        RenderTexture.active = null;

        byte[] bytes;
        bytes = tex.EncodeToPNG();

        string path = AssetDatabase.GetAssetPath(rt) + ".png";
        System.IO.File.WriteAllBytes(path, bytes);
        AssetDatabase.ImportAsset(path);
        Debug.Log("Saved to " + path);
    }
}