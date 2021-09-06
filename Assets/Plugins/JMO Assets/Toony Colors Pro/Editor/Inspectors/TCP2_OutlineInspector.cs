// Toony Colors Pro+Mobile 2
// (c) 2014-2020 Jean Moreno

//#define SHOW_DEFAULT_INSPECTOR

using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;
using ToonyColorsPro.Utilities;

// Custom Inspector when using the Outline Only shaders

public class TCP2_OutlineInspector : MaterialEditor
{
	//Properties
	private Material targetMaterial { get { return target as Material; } }
	private Shader mCurrentShader;
	private bool mIsOutlineBlending;
	private bool mShaderModel2;

	//--------------------------------------------------------------------------------------------------

	public override void OnEnable()
	{
		mCurrentShader = targetMaterial.shader;
		UpdateFeaturesFromShader();
		base.OnEnable();
	}

	public override void OnDisable()
	{
		base.OnDisable();
	}

	private void UpdateFeaturesFromShader()
	{
		if(targetMaterial != null && targetMaterial.shader != null)
		{
			var name = targetMaterial.shader.name;
			mIsOutlineBlending = name.ToLowerInvariant().Contains("blended");
			mShaderModel2 = name.ToLowerInvariant().Contains("sm2");
		}
	}

	public override void OnInspectorGUI()
	{
		if(!isVisible)
		{
			return;
		}

#if SHOW_DEFAULT_INSPECTOR
		base.OnInspectorGUI();
		return;
#else

		//Detect if Shader has changed
		if(targetMaterial.shader != mCurrentShader)
		{
			mCurrentShader = targetMaterial.shader;
		}

		UpdateFeaturesFromShader();

		//Get material keywords
		var keywordsList = new List<string>(targetMaterial.shaderKeywords);
		var updateKeywords = false;

		//Header
		TCP2_GUI.HeaderBig("TOONY COLORS PRO 2 - Outlines Only");
		TCP2_GUI.Separator();

		//Iterate Shader properties
		serializedObject.Update();
		var mShader = serializedObject.FindProperty("m_Shader");
		if(isVisible && !mShader.hasMultipleDifferentValues && mShader.objectReferenceValue != null)
		{
			EditorGUIUtility.labelWidth = Utils.ScreenWidthRetina - 120f;
			EditorGUIUtility.fieldWidth = 64f;

			EditorGUI.BeginChangeCheck();

			var props = GetMaterialProperties(targets);

			//UNFILTERED PARAMETERS ==============================================================
			
			if(ShowFilteredProperties(null, props, false))
			{
				TCP2_GUI.Separator();
			}

			//FILTERED PARAMETERS ================================================================

			//Outline Type ---------------------------------------------------------------------------
			ShowFilteredProperties("#OUTLINE#", props, false);
			if(!mShaderModel2)
			{
				var texturedOutline = Utils.ShaderKeywordToggle("TCP2_OUTLINE_TEXTURED", "Outline Color from Texture", "If enabled, outline will take an averaged color from the main texture multiplied by Outline Color", keywordsList, ref updateKeywords);
				if(texturedOutline)
				{
					ShowFilteredProperties("#OUTLINETEX#", props);
				}
			}

			Utils.ShaderKeywordToggle("TCP2_OUTLINE_CONST_SIZE", "Constant Size Outline", "If enabled, outline will have a constant size independently from camera distance", keywordsList, ref updateKeywords);
			if( Utils.ShaderKeywordToggle("TCP2_ZSMOOTH_ON", "Correct Z Artefacts", "Enable the outline z-correction to try to hide artefacts from complex models", keywordsList, ref updateKeywords) )
			{
				ShowFilteredProperties("#OUTLINEZ#", props);
			}
			
			//Smoothed Normals -----------------------------------------------------------------------
			TCP2_GUI.Header("OUTLINE NORMALS", "Defines where to take the vertex normals from to draw the outline.\nChange this when using a smoothed mesh to fill the gaps shown in hard-edged meshes.");
			Utils.ShaderKeywordRadio(null, new[]{"TCP2_NONE", "TCP2_COLORS_AS_NORMALS", "TCP2_TANGENT_AS_NORMALS", "TCP2_UV2_AS_NORMALS"}, new[]
			{
				new GUIContent("Regular", "Use regular vertex normals"),
				new GUIContent("Vertex Colors", "Use vertex colors as normals (with smoothed mesh)"),
				new GUIContent("Tangents", "Use tangents as normals (with smoothed mesh)"),
				new GUIContent("UV2", "Use second texture coordinates as normals (with smoothed mesh)")
			},
			keywordsList, ref updateKeywords);

			//Outline Blending -----------------------------------------------------------------------

			if(mIsOutlineBlending)
			{
				var blendProps = GetFilteredProperties("#BLEND#", props);

				if(blendProps.Length != 2)
				{
					EditorGUILayout.HelpBox("Couldn't find Blending properties!", MessageType.Error);
				}
				else
				{
					TCP2_GUI.Header("OUTLINE BLENDING", "BLENDING EXAMPLES:\nAlpha Transparency: SrcAlpha / OneMinusSrcAlpha\nMultiply: DstColor / Zero\nAdd: One / One\nSoft Add: OneMinusDstColor / One");

					var blendSrc = (BlendMode)blendProps[0].floatValue;
					var blendDst = (BlendMode)blendProps[1].floatValue;

					EditorGUI.BeginChangeCheck();
					var f = EditorGUIUtility.fieldWidth;
					var l = EditorGUIUtility.labelWidth;
					EditorGUIUtility.fieldWidth = 110f;
					EditorGUIUtility.labelWidth -= Mathf.Abs(f - EditorGUIUtility.fieldWidth);
					blendSrc = (BlendMode)EditorGUILayout.EnumPopup("Source Factor", blendSrc);
					blendDst = (BlendMode)EditorGUILayout.EnumPopup("Destination Factor", blendDst);
					EditorGUIUtility.fieldWidth = f;
					EditorGUIUtility.labelWidth = l;
					if(EditorGUI.EndChangeCheck())
					{
						blendProps[0].floatValue = (float)blendSrc;
						blendProps[1].floatValue = (float)blendDst;
					}
				}
			}

			TCP2_GUI.Separator();

			//--------------------------------------------------------------------------------------

			if(EditorGUI.EndChangeCheck())
			{
				PropertiesChanged();
			}
		}

		//Update Keywords
		if(updateKeywords)
		{
			if(targets != null && targets.Length > 0)
			{
				foreach(var t in targets)
				{
					(t as Material).shaderKeywords = keywordsList.ToArray();
					EditorUtility.SetDirty(t);
				}
			}
			else
			{
				targetMaterial.shaderKeywords = keywordsList.ToArray();
				EditorUtility.SetDirty(targetMaterial);
			}
		}
#endif
	}

	//--------------------------------------------------------------------------------------------------
	// Properties GUI

	private bool ShowFilteredProperties(string filter, MaterialProperty[] properties, bool indent = true)
	{
		if(indent)
			EditorGUI.indentLevel++;

		var propertiesShown = false;
		foreach(var p in properties)
			propertiesShown |= ShaderMaterialPropertyImpl(p, filter);

		if(indent)
			EditorGUI.indentLevel--;

		return propertiesShown;
	}

	private MaterialProperty[] GetFilteredProperties(string filter, MaterialProperty[] properties, bool indent = true)
	{
		var propList = new List<MaterialProperty>();

		foreach(var p in properties)
		{
			if(p.displayName.Contains(filter))
				propList.Add(p);
		}

		return propList.ToArray();
	}

	private bool ShaderMaterialPropertyImpl(MaterialProperty property, string filter = null)
	{
		//Filter
		var displayName = property.displayName;
		if(filter != null)
		{
			if(!displayName.Contains(filter))
				return false;

			displayName = displayName.Remove(displayName.IndexOf(filter), filter.Length+1);
		}
		else if(displayName.Contains("#"))
		{
			return false;
		}

		//GUI
		switch(property.type)
		{
		case MaterialProperty.PropType.Color:
			ColorProperty(property, displayName);
			break;

		case MaterialProperty.PropType.Float:
			FloatProperty(property, displayName);
			break;

		case MaterialProperty.PropType.Range:
			EditorGUILayout.BeginHorizontal();
			
			//Add float field to Range parameters
#if UNITY_4 || UNITY_4_3 || UNITY_4_5 || UNITY_4_6
			float value = RangeProperty(property, displayName);
			Rect r = GUILayoutUtility.GetLastRect();
			r.x = r.width - 160f;
			r.width = 65f;
			value = EditorGUI.FloatField(r, value);
			if(property.floatValue != value)
			{
				property.floatValue = value;
			}
#else
			RangeProperty(property, displayName);
#endif
			EditorGUILayout.EndHorizontal();
			break;

		case MaterialProperty.PropType.Texture:
			TextureProperty(property, displayName);
			break;

		case MaterialProperty.PropType.Vector:
			VectorProperty(property, displayName);
			break;

		default:
			EditorGUILayout.LabelField("Unknown Material Property Type: " + property.type);
			break;
		}

		return true;
	}
}
