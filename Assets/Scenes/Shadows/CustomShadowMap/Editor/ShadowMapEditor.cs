using System;
using UnityEngine;
using UnityEditor;

// 自定义Editor
[CustomEditor(typeof(ShadowMap))]
public class ShadowMapEditor : Editor
{

    private SerializedObject shadowMapScript;

    private SerializedProperty shadowLayers;
    private SerializedProperty shadowType;
    private SerializedProperty bias;
    private SerializedProperty resolution;
    private SerializedProperty filterStride;
    private SerializedProperty shadowStrength;
    private SerializedProperty lightWidth;

    void OnEnable()
    {
        shadowMapScript = new SerializedObject(target);
        shadowLayers = shadowMapScript.FindProperty("shadowLayers");
        shadowType = shadowMapScript.FindProperty("shadowType");
        resolution = shadowMapScript.FindProperty("resolution");
        filterStride = shadowMapScript.FindProperty("filterStride");
        shadowStrength = shadowMapScript.FindProperty("shadowStrength");
        bias = shadowMapScript.FindProperty("bias");
        lightWidth = shadowMapScript.FindProperty("lightWidth");
    }
    public override void OnInspectorGUI()
    {
        shadowMapScript.Update();
        EditorGUILayout.PropertyField(shadowLayers);
        EditorGUILayout.PropertyField(shadowType);
        EditorGUILayout.PropertyField(resolution);
        EditorGUILayout.PropertyField(shadowStrength);
        EditorGUILayout.PropertyField(bias);
        // PCF or PCSS
        if (shadowType.enumValueIndex != 0)
        {
            EditorGUILayout.PropertyField(filterStride);
            // PCSS
            if (shadowType.enumValueIndex == 3)
            {
                EditorGUILayout.PropertyField(lightWidth);
            }
        }

        // EditorGUILayout.PropertyField(shadowMapCreatorShader);
        shadowMapScript.ApplyModifiedProperties();
    }
}