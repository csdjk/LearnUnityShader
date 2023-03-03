using UnityEditor;
using System;
using UnityEngine;
#if UNITY_EDITOR
namespace LcLTools
{
    public class EditorGUILayoutTools
    {
        public static float RowSpace = 15;
        public static float HeadSpace = 20;
        // 水平布局
        public static void Horizontal(Action func)
        {
            GUILayout.Space(RowSpace);

            EditorGUILayout.BeginHorizontal();
            {
                GUILayout.Space(HeadSpace);
                func();
                GUILayout.Space(HeadSpace);

            }
            EditorGUILayout.EndHorizontal();
        }
        /// 绘制领域 
        public static void DrawField<T>(string title, ref T value, Func<T, T> func, Action<T> changeHandler)
        {
            GUILayout.Space(RowSpace);
            EditorGUILayout.BeginHorizontal();
            {
                GUILayout.Space(HeadSpace);
                GUILayout.Label(title);

                T preValue = value;

                value = func(value);

                GUILayout.Space(HeadSpace);
                if (value != null && !value.Equals(preValue))
                {
                    changeHandler(value);
                }
            }
            EditorGUILayout.EndHorizontal();
        }

        // 绘制 float 输入框
        public static void DrawFloatField(string title, ref float value, Action<float> changeHandler)
        {

            DrawField(title, ref value, (v) =>
            {
                return EditorGUILayout.FloatField(v);
            }, changeHandler);
        }
        // 
        public static void DrawSliderField(string title, ref float value, float max, Action<float> changeHandler)
        {
            DrawField(title, ref value, (v) =>
            {
                return EditorGUILayout.Slider(v, 0, max);
            }, changeHandler);
        }


        // 
        public static void DrawObjectField<T>(string title, ref T value, Type type, Action<T> changeHandler) where T : UnityEngine.Object
        {
            DrawField(title, ref value, (v) =>
            {
                return EditorGUILayout.ObjectField(v, type, true) as T;
            }, changeHandler);
        }

        // // 绘制 下拉列表 UI
        // public static void DrawEnumPopup<T>(string title, ref T value, Action<T> changeHandler) where T : Enum
        // {
        //     DrawField(title, ref value, (v) =>
        //    {
        //        return (T)EditorGUILayout.EnumPopup(v);
        //    },changeHandler);
        // }

        // 绘制 下拉列表 UI
        public static void DrawPopup(string title, ref int selectIndex, string[] list, Action<string> changeHandler)
        {
            DrawField(title, ref selectIndex, (v) =>
            {
                return EditorGUILayout.Popup(v, list, "ToolbarPopup");
            }, (v) =>
            {
                changeHandler(list[v]);
            });
        }

        public static void DrawColorField(string title, ref Color value, Action<Color> changeHandler)
        {
            DrawField(title, ref value, (v) =>
            {
                return EditorGUILayout.ColorField(v);
            }, changeHandler);
        }
        // 
        public static void DrawGradientField(string title, ref Gradient value, Action<Gradient> changeHandler)
        {
            DrawField(title, ref value, (v) =>
            {
                return EditorGUILayout.GradientField(v);
            }, (v) => { });
            // 因为Gradient 不好比较 就直接执行了
            changeHandler(value);
        }

        public static void DrawTextField(string title, ref string value, Action<string> changeHandler)
        {
            DrawField(title, ref value, (v) =>
            {
                return EditorGUILayout.TextField(v);
            }, changeHandler);
        }

        // 绘制文件路径(支持拖拽)
        public static void DrawPathField(string title, ref string value, bool isFullPath, Action<string> changeHandler)
        {
            GUI.SetNextControlName(title);//设置下一个控件的名字
            Rect pathRect = new Rect();
            DrawField(title, ref value, (v) =>
            {
                pathRect = EditorGUILayout.GetControlRect();
                return EditorGUI.TextField(pathRect, v);
            }, changeHandler);
            //拖入窗口未松开鼠标
            if (Event.current.type == EventType.DragUpdated)
            {
                DragAndDrop.visualMode = DragAndDropVisualMode.Generic;//改变鼠标外观
                if (pathRect.Contains(Event.current.mousePosition))
                    GUI.FocusControl(title);
            }
            //拖入窗口并松开鼠标
            else if (Event.current.type == EventType.DragExited)
            {
                if (pathRect.Contains(Event.current.mousePosition))
                {
                    value = DragAndDrop.paths[0];
                    if (isFullPath && value.StartsWith("Assets"))
                    {
                        value = Application.dataPath + value.Replace("Assets", string.Empty);
                    }

                    GUI.FocusControl(null);// 取消焦点(不然GUI不会刷新)
                    changeHandler(value);
                }
            }
        }
    }
}
#endif