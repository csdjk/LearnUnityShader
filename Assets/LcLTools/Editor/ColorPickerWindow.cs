using UnityEditor;
using UnityEngine;
namespace LcLTools
{
    public class ColorPickerWindow : EditorWindow
    {
        [MenuItem("LcLTools/ColorPicker")]
        public static void ShowWindow()
        {
            EditorWindow.GetWindow<ColorPickerWindow>("ColorPicker");
        }

        private string _colorLuminance = "1";

        private string _colorHex = "FFFFFFFF";
        private string _colorRGB = "1f, 1f, 1f, 1f";
        private string _colorRGB32 = "255, 255, 255, 255";
        private string _colorHSV = "100, 100, 100, 100";
        private Color _color = new Color(1, 1, 1, 1);

        void OnGUI()
        {

            EditorGUILayout.TextField("Luminance:", _colorLuminance);
            EditorGUILayout.TextField("Hex:", _colorHex);
            EditorGUILayout.TextField("RGB:", _colorRGB);
            EditorGUILayout.TextField("RGB32:", _colorRGB32);
            EditorGUILayout.TextField("HSV:", _colorHSV);

            Color tempColorValue = EditorGUILayout.ColorField(_color);

            if (tempColorValue != _color)
            {
                _color = tempColorValue;
                UpdateColor();
                this.Repaint();
            }
        }

        private void OnSceneGUI()
        {
            Color tempColorValue = EditorGUILayout.ColorField(_color);
        }

        private float Luminance(Color color)
        {
            return 0.2125f * color.r + 0.7154f * color.g + 0.0721f * color.b;
        }
        /// <summary>
        /// 更新颜色值
        /// </summary>
        private void UpdateColor()
        {
            _colorHex = ColorUtility.ToHtmlStringRGBA(_color);

            _colorRGB = string.Format("{0}, {1}, {2}, {3}", _color.r, _color.g, _color.b, _color.a);

            Color32 color32 = _color;
            _colorRGB32 = string.Format("{0}, {1}, {2}, {3}", color32.r, color32.g, color32.b, color32.a);

            float h, s, v;
            Color.RGBToHSV(_color, out h, out s, out v);
            _colorHSV = string.Format("{0}, {1}, {2}", h, s, v);
            _colorLuminance = Luminance(_color).ToString();
        }
    }
}