using UnityEngine;
using UnityEditor;
using UnityEngine.UIElements;
using System.Linq;
using System;
using System.IO;
using UnityEditor.UIElements;

namespace LcLTools
{

    enum ImageFormat
    {
        PNG,
        TGA,
    }
    enum MsaaScale
    {
        None = 1,
        X2 = 2,
        X4 = 4,
        X8 = 8,
    }
    public class ScreenshotEditor : EditorWindow
    {
        static float marginSize = 5;

        static Vector2IntField textureSizeField;
        static ObjectField cameraField;
        static EnumField textureFormatField;
        static EnumField msaaScaleField;
        static TextField pathField;

        private static Vector2Int textureSize = Vector2Int.one * 1024;
        private static ImageFormat textureFormat = ImageFormat.PNG;
        private static MsaaScale msaaScale = MsaaScale.X8;
        private static string path = "Assets/Screenshot/screenshot.png";

        [MenuItem("LcLTools/截图工具", false, 1000)]
        static void OpenWindow()
        {
            ScreenshotEditor window = GetWindow<ScreenshotEditor>();
            window.wantsMouseMove = false;
            window.titleContent = new GUIContent("截图工具");
            window.Show();
            window.Focus();
        }


        public void CreateGUI()
        {
            VisualElement root = rootVisualElement;


            if (cameraField == null) cameraField = new ObjectField("Render Camera") { objectType = typeof(Camera), value = Camera.main };
            cameraField.style.marginLeft = marginSize;
            cameraField.style.marginRight = marginSize;
            cameraField.style.marginBottom = marginSize;
            cameraField.style.marginTop = marginSize;
            root.Add(cameraField);

            if (textureSizeField == null) textureSizeField = new Vector2IntField("图片大小") { value = textureSize };
            textureSizeField.style.marginLeft = marginSize;
            textureSizeField.style.marginRight = marginSize;
            textureSizeField.style.marginBottom = marginSize;
            textureSizeField.style.marginTop = marginSize;
            root.Add(textureSizeField);

            if (textureFormatField == null) textureFormatField = new EnumField(textureFormat) { label = "图片格式" };
            textureFormatField.style.marginLeft = marginSize;
            textureFormatField.style.marginRight = marginSize;
            textureFormatField.style.marginBottom = marginSize;
            textureFormatField.style.marginTop = marginSize;
            root.Add(textureFormatField);

            if (msaaScaleField == null) msaaScaleField = new EnumField(msaaScale) { label = "抗锯齿(MSAA)" };
            msaaScaleField.style.marginLeft = marginSize;
            msaaScaleField.style.marginRight = marginSize;
            msaaScaleField.style.marginBottom = marginSize;
            msaaScaleField.style.marginTop = marginSize;
            root.Add(msaaScaleField);


            var box = new VisualElement();
            {
                box.style.flexDirection = FlexDirection.Row;
                box.style.marginLeft = marginSize;
                box.style.marginRight = marginSize;
                box.style.marginBottom = marginSize;
                box.style.marginTop = marginSize;
                if (pathField == null) pathField = new TextField("保存路径") { value = path };
                pathField.style.flexGrow = 0.9f;
                box.Add(pathField);

                var pathButton = new Button(OpenFile)
                {
                    text = "..."
                };
                pathButton.style.flexGrow = 0.1f;
                box.Add(pathButton);
            }
            root.Add(box);


            var button = new Button(RenderCameraToFile)
            {
                text = "保存为图片 (Ctrl+Q)"
            };
            button.style.height = 30;
            button.style.marginLeft = 10;
            button.style.marginRight = 10;
            button.style.marginBottom = 10;
            button.style.marginTop = 10;
            root.Add(button);
        }

        public void OpenFile()
        {
            string file = EditorUtility.OpenFolderPanel("选择文件夹", Application.dataPath, "");
            if (file != "")
            {
                pathField.value = $"{file}/screenshot.png";
            }
            Debug.Log(file);
        }
        void OnDestroy()
        {
        }

        [MenuItem("LcLTools/渲染截图 %q")]
        public static void RenderCameraToFile()
        {
            Camera camera = cameraField?.value as Camera;
            if (camera == null)
            {
                camera = Selection.activeGameObject.GetComponent<Camera>();
            }
            var size = textureSizeField?.value == null ? textureSize : textureSizeField.value;

            RenderTexture rt = new RenderTexture(size.x, size.y, 24, RenderTextureFormat.ARGB32, RenderTextureReadWrite.sRGB);
            // 抗锯齿
            int msaa = msaaScaleField?.value == null ? (int)msaaScale : (int)(MsaaScale)msaaScaleField.value;
            rt.antiAliasing = msaa;
            RenderTexture rtTemp = new RenderTexture(size.x * msaa, size.y * msaa, 24, RenderTextureFormat.ARGB32, RenderTextureReadWrite.sRGB);
            Graphics.Blit(rtTemp, rt);


            RenderTexture oldRT = camera.targetTexture;
            camera.targetTexture = rt;
            camera.Render();
            camera.targetTexture = oldRT;

            RenderTexture.active = rt;
            Texture2D tex = new Texture2D(rt.width, rt.height, TextureFormat.ARGB32, false);
            tex.ReadPixels(new Rect(0, 0, rt.width, rt.height), 0, 0);
            tex.Apply();
            RenderTexture.active = null;

            ImageFormat format = textureFormatField?.value == null ? textureFormat : (ImageFormat)textureFormatField.value;
            string filePath = pathField?.value == null ? path : pathField.value;

            byte[] bytes;
            switch (format)
            {
                case ImageFormat.PNG:
                    filePath = filePath.Replace(Path.GetExtension(filePath), ".png");
                    bytes = tex.EncodeToPNG();
                    break;
                case ImageFormat.TGA:
                    filePath = filePath.Replace(Path.GetExtension(filePath), ".tga");
                    bytes = tex.EncodeToTGA();
                    break;
                default:
                    bytes = tex.EncodeToJPG();
                    break;
            }


            var folder = Path.GetDirectoryName(filePath);
            if (!Directory.Exists(folder))
            {
                Directory.CreateDirectory(folder);
            }

            File.WriteAllBytes(filePath, bytes);
            AssetDatabase.ImportAsset(filePath);
            AssetDatabase.Refresh();
            Debug.Log("Saved to " + filePath);
            // 防止内存泄漏
            DestroyImmediate(tex);
        }
    }
}
