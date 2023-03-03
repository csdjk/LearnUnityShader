using System.IO;
using UnityEngine;
using UnityEditor;
using System;
using LcLTools;

[CustomEditor(typeof(CommandBufferBakeTexture))]
public class BakeTextureEditor : Editor
{

    // 预览面板
    public override bool HasPreviewGUI()
    {
        return true;
    }
    public override void OnPreviewGUI(Rect r, GUIStyle background)
    {
        var baker = target as CommandBufferBakeTexture;
        if (baker.commandBuffer == null)
            return;
        // GUI.DrawTexture(r, baker.runTimeTexture, ScaleMode.ScaleToFit, false);

        float halfWidth = r.width / 2;
        float size = Mathf.Min(halfWidth, r.height);

        // Texture1
        float rectx = r.x + halfWidth / 2 - size / 2;
        float recty = r.y + r.height / 2 - size / 2;
        Rect rect = new Rect(rectx, recty, size, size);
        GUI.DrawTexture(rect, baker.material.mainTexture, ScaleMode.ScaleToFit, false);

        // Texture2
        float rectx2 = r.x + halfWidth + halfWidth / 2 - size / 2;
        float recty2 = r.y + r.height / 2 - size / 2;
        Rect rect2 = new Rect(rectx2, recty2, size, size);
        GUI.DrawTexture(rect2, baker.fixedEdgeTexture, ScaleMode.ScaleToFit, false);
    }

    // Inspector 
    public override void OnInspectorGUI()
    {
        var baker = target as CommandBufferBakeTexture;
        base.DrawDefaultInspector();
        if (GUILayout.Button("Bake"))
        {
            var tex = baker.fixedEdgeTexture;
            string path = Application.dataPath + "/Scenes/CommandBuffer/CommandBufferBakeTexture/";

            path = EditorUtility.SaveFilePanel("Save Texture", path, tex ? tex.name : "", "png");
            if (!path.Equals(String.Empty))
            {
                LcLEditorUtilities.SaveRenderTextureToTexture(tex, path);
                var assetsPath = LcLUtility.AssetsRelativePath(path);
                if (assetsPath != null)
                {
                    AssetDatabase.ImportAsset(assetsPath);
                }
            }
        }

    }

}
