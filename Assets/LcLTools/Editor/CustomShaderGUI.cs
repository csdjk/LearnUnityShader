/*** 
 * @Descripttion: 
 * @Author: lichanglong
 * @Date: 2021-08-13 18:51:12
 * @FilePath: \LearnUnityShader\Assets\Editor\ShaderGUI.cs
 */
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.Text.RegularExpressions;
using UnityEngine.Rendering;
using System;
 
//自定义效果-单行显示图片
internal class SingleLineDrawer : MaterialPropertyDrawer
{
    public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor)
    {
        editor.TexturePropertySingleLine(label, prop);
    }
    public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
    {
        return 0;
    }
}
//自定义效果-折行显示图片
internal class FoldoutDrawer : MaterialPropertyDrawer
{
    bool showPosition;
    public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor)
    {
        showPosition = EditorGUILayout.Foldout(showPosition, label);
        prop.floatValue = Convert.ToSingle(showPosition);
    }
    public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
    {
        return 0;
    }
}
 
public class CustomShaderGUI : ShaderGUI
{
 
    public class MaterialData
    {
        public MaterialProperty prop;
        public bool indentLevel = false;
    }
    static Dictionary<string, MaterialProperty> s_MaterialProperty = new Dictionary<string, MaterialProperty>();
    static List<MaterialData> s_List = new List<MaterialData>();
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        Shader shader = (materialEditor.target as Material).shader;
        s_List.Clear();
        s_MaterialProperty.Clear();
        for (int i = 0; i < properties.Length; i++)
        {
            var propertie = properties[i];
            s_MaterialProperty[propertie.name] = propertie;
            s_List.Add(new MaterialData() { prop = propertie, indentLevel = false });
            var attributes = shader.GetPropertyAttributes(i);
            foreach (var item in attributes)
            {
                if (item.StartsWith("if"))
                {
                    Match match = Regex.Match(item, @"(\w+)\s*\((.*)\)");
                    if (match.Success)
                    {
                        var name = match.Groups[2].Value.Trim();
                        if (s_MaterialProperty.TryGetValue(name, out var a))
                        {
                            if (a.floatValue == 0f) {
                                //如果有if标签，并且Foldout没有展开不进行绘制
                                s_List.RemoveAt(s_List.Count - 1); 
                                break;
                            }
                            else
                                s_List[s_List.Count - 1].indentLevel = true;
                        }
                    }
                }
            }
        }
 
 
        /*如果不需要展开子节点像右缩进，可以直接调用base方法
         base.OnGUI(materialEditor, s_List.ToArray());*/
 
        PropertiesDefaultGUI(materialEditor, s_List);
    }
    private static int s_ControlHash = "EditorTextField".GetHashCode();
    public void PropertiesDefaultGUI(MaterialEditor materialEditor, List<MaterialData> props)
    {
        var f = materialEditor.GetType().GetField("m_InfoMessage", System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.NonPublic);
        if (f != null)
        {
            string m_InfoMessage = (string)f.GetValue(materialEditor);
            materialEditor.SetDefaultGUIWidths();
            if (m_InfoMessage != null)
            {
                EditorGUILayout.HelpBox(m_InfoMessage, MessageType.Info);
            }
            else
            {
                GUIUtility.GetControlID(s_ControlHash, FocusType.Passive, new Rect(0f, 0f, 0f, 0f));
            }
        }
        for (int i = 0; i < props.Count; i++)
        {
            MaterialProperty prop = props[i].prop;
            bool indentLevel = props[i].indentLevel;
            if ((prop.flags & (MaterialProperty.PropFlags.HideInInspector | MaterialProperty.PropFlags.PerRendererData)) == MaterialProperty.PropFlags.None)
            {
                float propertyHeight = materialEditor.GetPropertyHeight(prop, prop.displayName);
                Rect controlRect = EditorGUILayout.GetControlRect(true, propertyHeight, EditorStyles.layerMaskField);
                if(indentLevel) EditorGUI.indentLevel++;
                materialEditor.ShaderProperty(controlRect, prop, prop.displayName);
                if (indentLevel) EditorGUI.indentLevel--;
            }
        }
        EditorGUILayout.Space();
        EditorGUILayout.Space();
        if (SupportedRenderingFeatures.active.editableMaterialRenderQueue)
        {
            materialEditor.RenderQueueField();
        }
        materialEditor.EnableInstancingField();
        materialEditor.DoubleSidedGIField();
    }
 
}
 