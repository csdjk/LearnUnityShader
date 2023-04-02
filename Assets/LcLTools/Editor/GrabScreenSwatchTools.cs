using System;
using System.Linq;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityToolbarExtender;
using UnityEngine.UIElements;
using System.Reflection;

public class GrabScreenSwatchTools : EditorWindow
{
    private static Texture m_Texture;

    [MenuItem("LcLTools/GrabScreen")]
    public static void ShowWindow()
    {
        m_Texture = GrabScreenSwatch(new Rect(0, 0, Screen.currentResolution.width, Screen.currentResolution.height));
        GrabScreenSwatchTools window = EditorWindow.GetWindow<GrabScreenSwatchTools>();
        window.Show();
    }

    private void OnEnable()
    {
    }

    private void OnGUI()
    {
        if (GUILayout.Button("Capture"))
        {
            DestroyImmediate(m_Texture);
            m_Texture = GrabScreenSwatch(position);
        }
        GUI.DrawTexture(new Rect(0, 0, position.width, position.height), m_Texture, ScaleMode.ScaleToFit, true, 1f);
    }

    public static Texture GrabScreenSwatch(Rect rect)
    {
        int width = (int)rect.width;
        int height = (int)rect.height;
        int x = (int)rect.x;
        int y = (int)rect.y;
        Vector2 position = new Vector2(x, y);

        Color[] pixels = UnityEditorInternal.InternalEditorUtility.ReadScreenPixel(position, width, height);

        Texture2D texture = new Texture2D(width, height);
        texture.SetPixels(pixels);
        texture.Apply();

        return texture;
    }
}
