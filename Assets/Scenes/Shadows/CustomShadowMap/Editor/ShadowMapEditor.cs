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
    private SerializedProperty expConst;
    private SerializedProperty blurRadius;
    private SerializedProperty downSample;
    private SerializedProperty iteration;
    private SerializedProperty lightLeakBias;
    private SerializedProperty varianceBias;


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
        expConst = shadowMapScript.FindProperty("expConst");
        blurRadius = shadowMapScript.FindProperty("blurRadius");
        downSample = shadowMapScript.FindProperty("downSample");
        iteration = shadowMapScript.FindProperty("iteration");
        lightLeakBias = shadowMapScript.FindProperty("lightLeakBias");
        varianceBias = shadowMapScript.FindProperty("varianceBias");
    }
    public override void OnInspectorGUI()
    {
        shadowMapScript.Update();
        EditorGUILayout.PropertyField(shadowLayers);
        EditorGUILayout.PropertyField(shadowType);
        EditorGUILayout.PropertyField(resolution);
        EditorGUILayout.PropertyField(shadowStrength);

        var typeIndex = shadowType.enumValueIndex;
        if (typeIndex == (int)ShadowType.SHADOW_SIMPLE)
        {
            EditorGUILayout.PropertyField(bias);
        }
        else if (typeIndex == (int)ShadowType.SHADOW_PCF || typeIndex == (int)ShadowType.SHADOW_PCF_POISSON_DISK)
        {
            EditorGUILayout.PropertyField(bias);
            EditorGUILayout.PropertyField(filterStride);
        }
        else if (typeIndex == (int)ShadowType.SHADOW_PCSS)
        {
            EditorGUILayout.PropertyField(bias);
            EditorGUILayout.PropertyField(filterStride);
            EditorGUILayout.PropertyField(lightWidth);
        }
        else if (typeIndex == (int)ShadowType.SHADOW_ESM)
        {
            EditorGUILayout.PropertyField(expConst);
            EditorGUILayout.PropertyField(blurRadius);
            EditorGUILayout.PropertyField(downSample);
            EditorGUILayout.PropertyField(iteration);
        }
        else if (typeIndex == (int)ShadowType.SHADOW_VSM)
        {
            EditorGUILayout.PropertyField(lightLeakBias);
            EditorGUILayout.PropertyField(varianceBias);
            EditorGUILayout.PropertyField(blurRadius);
            EditorGUILayout.PropertyField(downSample);
            EditorGUILayout.PropertyField(iteration);
        }
        // EditorGUILayout.PropertyField(shadowMapCreatorShader);
        shadowMapScript.ApplyModifiedProperties();
    }
}