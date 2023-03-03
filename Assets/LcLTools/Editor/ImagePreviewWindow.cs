
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
namespace LcLTools
{
    public class ImagePreviewWindow : EditorWindow
    {
        private RenderTexture image;

        private static ImagePreviewWindow instance = null;

        public static Vector2 size = new Vector2(512, 512);
        private Action onVideoWindowClosed = null;

        void Update()
        {
            if (EditorWindow.focusedWindow != this)
            {
                onVideoWindowClosed?.Invoke();
                this.Close();
            }
        }

        public static void ShowPic(RenderTexture tex, Action onVideoWindowClose = null)
        {
            var window = (ImagePreviewWindow)ScriptableObject.CreateInstance<ImagePreviewWindow>();
            window.name = "Mask预览";
            window.image = tex;
            window.maxSize = window.minSize = size + new Vector2(20, 30);

            int x = (Screen.currentResolution.width - (int)size.x) / 2;
            int y = (Screen.currentResolution.height - (int)size.y) / 2;
            window.position = new Rect(x, y, size.x, size.y);

            window.titleContent = new GUIContent("ImageWindow");
            window.ShowPopup();
            window.Focus();
            instance = window;
            instance.onVideoWindowClosed = onVideoWindowClose;
        }


        private void OnDestroy()
        {
            image = null;
        }

        private void OnGUI()
        {
            if (image != null)
            {
                EditorGUI.DrawTextureTransparent(new Rect(0, 0, size.x, size.y), image, ScaleMode.ScaleToFit);
            }
        }
    }
}