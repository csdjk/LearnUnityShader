// Toony Colors Pro+Mobile 2
// (c) 2014-2020 Jean Moreno

//Enable this to display the default Inspector (in case the custom Inspector is broken)
//#define SHOW_DEFAULT_INSPECTOR

//Enable this to show Debug info
//#define DEBUG_INFO

using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;
using ToonyColorsPro.Utilities;
using ToonyColorsPro.Legacy;

// Custom Unified Inspector that will select the correct shaders depending on the settings defined.

public class TCP2_MaterialInspector : ShaderGUI
{
	//Constants
	private const string BASE_SHADER_PATH = "Toony Colors Pro 2/Legacy/";
	private const string VARIANT_SHADER_PATH = "Hidden/Toony Colors Pro 2/Variants/";
	private const string BASE_SHADER_NAME = "Desktop";
	private const string BASE_SHADER_NAME_MOB = "Mobile";
	
	//Properties
	private Material targetMaterial { get { return (mMaterialEditor == null) ? null : mMaterialEditor.target as Material; } }
	private MaterialEditor mMaterialEditor;
	private List<string> mShaderFeatures;
	private bool isGeneratedShader;
	private bool isMobileShader;
	private bool mJustChangedShader;
	private string mVariantError;

	//Shader Variants 
	private List<string> ShaderVariants = new List<string>
	{
		"Specular",
		"Reflection",
		"Matcap",
		"Rim",
		"RimOutline",
		"Outline",
		"OutlineBlending",
		"Sketch",
		"Alpha",
		"Cutout"
	};
	private List<bool> ShaderVariantsEnabled = new List<bool>
	{
		false,
		false,
		false,
		false,
		false,
		false,
		false,
		false,
		false,
		false
	};

	//--------------------------------------------------------------------------------------------------

	public override void AssignNewShaderToMaterial (Material material, Shader oldShader, Shader newShader)
	{
		base.AssignNewShaderToMaterial (material, oldShader, newShader);

		//Detect if User Shader (from Shader Generator)
		isGeneratedShader = false;
		mShaderFeatures = null;
		var shaderImporter = ShaderImporter.GetAtPath(AssetDatabase.GetAssetPath(newShader)) as ShaderImporter;
		if(shaderImporter != null)
		{
			TCP2_ShaderGeneratorUtils.ParseUserData(shaderImporter, out mShaderFeatures);
			if(mShaderFeatures.Count > 0 && mShaderFeatures[0] == "USER")
			{
				isGeneratedShader = true;
			}
		}
	}

	private void UpdateFeaturesFromShader()
	{
		if(targetMaterial != null && targetMaterial.shader != null)
		{
			var name = targetMaterial.shader.name;
			if(name.Contains("Mobile"))
				isMobileShader = true;
			else
				isMobileShader = false;
			var nameFeatures = new List<string>(name.Split(' '));
			for(var i = 0; i < ShaderVariants.Count; i++)
			{
				ShaderVariantsEnabled[i] = nameFeatures.Contains(ShaderVariants[i]);
			}
			//Get flags for compiled shader to hide certain parts of the UI
			var shaderImporter = ShaderImporter.GetAtPath(AssetDatabase.GetAssetPath(targetMaterial.shader)) as ShaderImporter;
			if(shaderImporter != null)
			{
//				mShaderFeatures = new List<string>(shaderImporter.userData.Split(new string[]{","}, System.StringSplitOptions.RemoveEmptyEntries));
				TCP2_ShaderGeneratorUtils.ParseUserData(shaderImporter, out mShaderFeatures);
				if(mShaderFeatures.Count > 0 && mShaderFeatures[0] == "USER")
				{
					isGeneratedShader = true;
				}
			}
		}
	}

	public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
	{
		mMaterialEditor = materialEditor;

#if SHOW_DEFAULT_INSPECTOR
		base.OnGUI();
		return;
#else

		if(mJustChangedShader && Event.current != null)
		{
			mJustChangedShader = false;
			mVariantError = null;
			SceneView.RepaintAll();
			materialEditor.Repaint();
			return;
		}

		UpdateFeaturesFromShader();

		//Get material keywords
		var keywordsList = new List<string>(targetMaterial.shaderKeywords);
		var updateKeywords = false;
		var updateVariant = false;
		
		//Header
		EditorGUILayout.BeginHorizontal();
		TCP2_GUI.HeaderBig("TOONY COLORS PRO 2 - INSPECTOR");
		if(isGeneratedShader && TCP2_GUI.Button(TCP2_GUI.CogIcon, "O", "Open in Shader Generator"))
		{
			if(targetMaterial.shader != null)
			{
				TCP2_ShaderGenerator.OpenWithShader(targetMaterial.shader);
			}
		}
		TCP2_GUI.HelpButton("Unified Shader");
		EditorGUILayout.EndHorizontal();
		TCP2_GUI.Separator();

		if(!string.IsNullOrEmpty(mVariantError))
		{
			EditorGUILayout.HelpBox(mVariantError, MessageType.Error);

			EditorGUILayout.HelpBox("Some of the shaders are packed to avoid super long loading times when you import Toony Colors Pro 2 into Unity.\n\n"+
			                        "You can unpack them by category in the menu:\n\"Tools > Toony Colors Pro 2 > Unpack Shaders > ...\"",
			                        MessageType.Info);
		}

		//Iterate Shader properties
		materialEditor.serializedObject.Update();
		var mShader = materialEditor.serializedObject.FindProperty("m_Shader");
		if(materialEditor.isVisible && !mShader.hasMultipleDifferentValues && mShader.objectReferenceValue != null)
		{
			//Retina display fix
			EditorGUIUtility.labelWidth = Utils.ScreenWidthRetina - 120f;
			EditorGUIUtility.fieldWidth = 64f;

			EditorGUI.BeginChangeCheck();

			var props = properties;

			//UNFILTERED PARAMETERS ==============================================================

			TCP2_GUI.HeaderAndHelp("BASE", "Base Properties");
			if(ShowFilteredProperties(null, props))
			{
				if(!isGeneratedShader)
					Utils.ShaderKeywordToggle("TCP2_DISABLE_WRAPPED_LIGHT", "Disable Wrapped Lighting", "Disable wrapped lighting, reducing intensity received from lights", keywordsList, ref updateKeywords, "Disable Wrapped Lighting");

				TCP2_GUI.Separator();
			}

			//FILTERED PARAMETERS ================================================================

			//RAMP TYPE --------------------------------------------------------------------------

			if(CategoryFilter("TEXTURE_RAMP"))
			{
				if(isGeneratedShader)
				{
					ShowFilteredProperties("#RAMPT#", props);
				}
				else
				{
					if( Utils.ShaderKeywordToggle("TCP2_RAMPTEXT", "Texture Toon Ramp", "Make the toon ramp based on a texture", keywordsList, ref updateKeywords, "Ramp Style") )
					{
						ShowFilteredProperties("#RAMPT#", props);
					}
					else
					{
						ShowFilteredProperties("#RAMPF#", props);
					}
				}
			}
			else
			{
				ShowFilteredProperties("#RAMPF#", props);
			}

			TCP2_GUI.Separator();
			
			//BUMP/NORMAL MAPPING ----------------------------------------------------------------

			if(CategoryFilter("BUMP"))
			{
				if(isGeneratedShader)
				{
					TCP2_GUI.HeaderAndHelp("BUMP/NORMAL MAPPING", "Normal/Bump map");

					ShowFilteredProperties("#NORM#", props);
					ShowFilteredProperties("#PLLX#", props);
				}
				else
				{
					if( Utils.ShaderKeywordToggle("TCP2_BUMP", "BUMP/NORMAL MAPPING", "Enable bump mapping using normal maps", keywordsList, ref updateKeywords, "Normal/Bump map") )
					{
						ShowFilteredProperties("#NORM#", props);
					}
				}

				TCP2_GUI.Separator();
			}

			//SPECULAR ---------------------------------------------------------------------------

			if(CategoryFilter("SPECULAR", "SPECULAR_ANISOTROPIC"))
			{
				if(isGeneratedShader)
				{
					TCP2_GUI.HeaderAndHelp("SPECULAR", "Specular");
					ShowFilteredProperties("#SPEC#", props);
					if(HasFlags("SPECULAR_ANISOTROPIC"))
						ShowFilteredProperties("#SPECA#", props);
					if(HasFlags("SPECULAR_TOON"))
						ShowFilteredProperties("#SPECT#", props);
				}
				else
				{
					var specular = Utils.HasKeywords(keywordsList, "TCP2_SPEC", "TCP2_SPEC_TOON");
					Utils.ShaderVariantUpdate("Specular", ShaderVariants, ShaderVariantsEnabled, specular, ref updateVariant);

					specular |= Utils.ShaderKeywordRadio("SPECULAR", new[]{"TCP2_SPEC_OFF","TCP2_SPEC","TCP2_SPEC_TOON"}, new[]
					{
						new GUIContent("Off", "No Specular"),
						new GUIContent("Regular", "Default Blinn-Phong Specular"),
						new GUIContent("Cartoon", "Specular with smoothness control")
					},
					keywordsList, ref updateKeywords);

					if( specular )
					{
						ShowFilteredProperties("#SPEC#", props);

						var specr = Utils.HasKeywords(keywordsList, "TCP2_SPEC_TOON");
						if(specr)
						{
							ShowFilteredProperties("#SPECT#", props);
						}
					}
				}

				TCP2_GUI.Separator();
			}

			//REFLECTION -------------------------------------------------------------------------
			
			if(CategoryFilter("REFLECTION") && !isMobileShader)
			{
				if(isGeneratedShader)
				{
					TCP2_GUI.HeaderAndHelp("REFLECTION", "Reflection");
					
					ShowFilteredProperties("#REFL#", props);
#if UNITY_5
					if(HasFlags("U5_REFLPROBE"))
						ShowFilteredProperties("#REFL_U5#", props);
#endif
					if(HasFlags("REFL_COLOR"))
						ShowFilteredProperties("#REFLC#", props);
					if(HasFlags("REFL_ROUGH"))
					{
						ShowFilteredProperties("#REFLR#", props);
						EditorGUILayout.HelpBox("Cubemap Texture needs to have MipMaps enabled for Roughness to work!", MessageType.Info);
					}
				}
				else
				{
					var reflection = Utils.HasKeywords(keywordsList, "TCP2_REFLECTION", "TCP2_REFLECTION_MASKED");
					Utils.ShaderVariantUpdate("Reflection", ShaderVariants, ShaderVariantsEnabled, reflection, ref updateVariant);
					
					reflection |= Utils.ShaderKeywordRadio("REFLECTION", new[]{"TCP2_REFLECTION_OFF","TCP2_REFLECTION","TCP2_REFLECTION_MASKED"}, new[]
					{
						new GUIContent("Off", "No Cubemap Reflection"),
						new GUIContent("Global", "Global Cubemap Reflection"),
						new GUIContent("Masked", "Masked Cubemap Reflection (using the main texture's alpha channel)")
					},
					keywordsList, ref updateKeywords);
					
					if( reflection )
					{
#if UNITY_5
						//Reflection Probes toggle
						if( Utils.ShaderKeywordToggle("TCP2_U5_REFLPROBE", "Use Reflection Probes", "Use Unity 5's Reflection Probes", keywordsList, ref updateKeywords) )
						{
							ShowFilteredProperties("#REFL_U5#", props);
						}
#endif
						ShowFilteredProperties("#REFL#", props);
					}
				}
				
				TCP2_GUI.Separator();
			}

			//MATCAP -----------------------------------------------------------------------------
			
			if(CategoryFilter("MATCAP"))
			{
				if(isGeneratedShader)
				{
					TCP2_GUI.Header("MATCAP");
					ShowFilteredProperties("#MC#", props);

					TCP2_GUI.Separator();
				}
				else if(isMobileShader)
				{
					var matcap = Utils.HasKeywords(keywordsList, "TCP2_MC", "TCP2_MCMASK");
					Utils.ShaderVariantUpdate("Matcap", ShaderVariants, ShaderVariantsEnabled, matcap, ref updateVariant);
					
					matcap |= Utils.ShaderKeywordRadio("MATCAP", new[]{"TCP2_MC_OFF","TCP2_MC","TCP2_MCMASK"}, new[]
					{
						new GUIContent("Off", "No MatCap reflection"),
						new GUIContent("Global", "Global additive MatCap"),
						new GUIContent("Masked", "Masked additive MatCap (using the main texture's alpha channel)")
					},
					keywordsList, ref updateKeywords);
					
					if( matcap )
					{
						ShowFilteredProperties("#MC#", props);
					}
					
					TCP2_GUI.Separator();
				}
				
			}

			//SUBSURFACE SCATTERING --------------------------------------------------------------------------------

			if (CategoryFilter("SUBSURFACE_SCATTERING") && isGeneratedShader)
			{
				TCP2_GUI.HeaderAndHelp("SUBSURFACE SCATTERING", "Subsurface Scattering");
				ShowFilteredProperties("#SUBS#", props);
				TCP2_GUI.Separator();
			}

			//RIM --------------------------------------------------------------------------------

			if(CategoryFilter("RIM", "RIM_OUTLINE"))
			{
				if(isGeneratedShader)
				{
					TCP2_GUI.HeaderAndHelp("RIM", "Rim");
					
					ShowFilteredProperties("#RIM#", props);

					if(HasFlags("RIMDIR"))
					{
						ShowFilteredProperties("#RIMDIR#", props);

						if(HasFlags("PARALLAX"))
						{
							EditorGUILayout.HelpBox("Because it affects the view direction vector, Rim Direction may distort Parallax effect.", MessageType.Warning);
						}
					}
				}
				else
				{
					var rim = Utils.HasKeywords(keywordsList, "TCP2_RIM");
					var rimOutline = Utils.HasKeywords(keywordsList, "TCP2_RIMO");

					Utils.ShaderVariantUpdate("Rim", ShaderVariants, ShaderVariantsEnabled, rim, ref updateVariant);
					Utils.ShaderVariantUpdate("RimOutline", ShaderVariants, ShaderVariantsEnabled, rimOutline, ref updateVariant);
					
					rim |= rimOutline |= Utils.ShaderKeywordRadio("RIM", new[]{"TCP2_RIM_OFF","TCP2_RIM","TCP2_RIMO"}, new[]
					{
						new GUIContent("Off", "No Rim effect"),
						new GUIContent("Lighting", "Rim lighting (additive)"),
						new GUIContent("Outline", "Rim outline (blended)")
					},
					keywordsList, ref updateKeywords);
					
					if( rim || rimOutline )
					{
						ShowFilteredProperties("#RIM#", props);
						
						if(CategoryFilter("RIMDIR"))
						{
							if( Utils.ShaderKeywordToggle("TCP2_RIMDIR", "Directional Rim", "Enable directional rim control (rim calculation is approximated if enabled)", keywordsList, ref updateKeywords) )
							{
								ShowFilteredProperties("#RIMDIR#", props);
							}
						}
					}
				}

				TCP2_GUI.Separator();
			}

			//CUBEMAP AMBIENT --------------------------------------------------------------------
			
			if(CategoryFilter("CUBE_AMBIENT") && isGeneratedShader)
			{
				TCP2_GUI.HeaderAndHelp("CUBEMAP AMBIENT", "Cubemap Ambient");
				ShowFilteredProperties("#CUBEAMB#", props);
				TCP2_GUI.Separator();
			}

			//DIRECTIONAL AMBIENT --------------------------------------------------------------------

			if(CategoryFilter("DIRAMBIENT") && isGeneratedShader)
			{
				TCP2_GUI.HeaderAndHelp("DIRECTIONAL AMBIENT", "Directional Ambient");
				DirectionalAmbientGUI("#DAMB#", props);
				TCP2_GUI.Separator();
			}

			//SKETCH --------------------------------------------------------------------------------
			
			if(CategoryFilter("SKETCH", "SKETCH_GRADIENT") && isGeneratedShader)
			{
				TCP2_GUI.HeaderAndHelp("SKETCH", "Sketch");
				
				var sketch = HasFlags("SKETCH");
				var sketchG = HasFlags("SKETCH_GRADIENT");
				
				if(sketch || sketchG)
					ShowFilteredProperties("#SKETCH#", props);
				
				if(sketchG)
					ShowFilteredProperties("#SKETCHG#", props);
				
				TCP2_GUI.Separator();
			}

			//OUTLINE --------------------------------------------------------------------------------

			if(CategoryFilter("OUTLINE", "OUTLINE_BLENDING"))
			{
				var hasOutlineOpaque = false;
				var hasOutlineBlending = false;
				var hasOutline = false;

				if(isGeneratedShader)
				{
					TCP2_GUI.HeaderAndHelp("OUTLINE", "Outline");
					
					hasOutlineOpaque = HasFlags("OUTLINE");
					hasOutlineBlending = HasFlags("OUTLINE_BLENDING");
					hasOutline = hasOutlineOpaque || hasOutlineBlending;
				}
				else
				{
					hasOutlineOpaque = Utils.HasKeywords(keywordsList, "OUTLINES");
					hasOutlineBlending = Utils.HasKeywords(keywordsList, "OUTLINE_BLENDING");
					hasOutline = hasOutlineOpaque || hasOutlineBlending;

					Utils.ShaderVariantUpdate("Outline", ShaderVariants, ShaderVariantsEnabled, hasOutlineOpaque, ref updateVariant);
					Utils.ShaderVariantUpdate("OutlineBlending", ShaderVariants, ShaderVariantsEnabled, hasOutlineBlending, ref updateVariant);
					
					hasOutline |= Utils.ShaderKeywordRadio("OUTLINE", new[]{"OUTLINE_OFF","OUTLINES","OUTLINE_BLENDING"}, new[]
					{
						new GUIContent("Off", "No Outline"),
						new GUIContent("Opaque", "Opaque Outline"),
						new GUIContent("Blended", "Allows transparent Outline and other effects")
					},
					keywordsList, ref updateKeywords);
				}

				if( hasOutline )
				{
					EditorGUI.indentLevel++;

					//Outline Type ---------------------------------------------------------------------------
					ShowFilteredProperties("#OUTLINE#", props, false);
					if(!isMobileShader && !HasFlags("FORCE_SM2"))
					{
						var outlineTextured = Utils.ShaderKeywordToggle("TCP2_OUTLINE_TEXTURED", "Outline Color from Texture", "If enabled, outline will take an averaged color from the main texture multiplied by Outline Color", keywordsList, ref updateKeywords);
						if(outlineTextured)
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
					EditorGUI.indentLevel--;
					TCP2_GUI.Header("OUTLINE NORMALS", "Defines where to take the vertex normals from to draw the outline.\nChange this when using a smoothed mesh to fill the gaps shown in hard-edged meshes.");
					EditorGUI.indentLevel++;
					Utils.ShaderKeywordRadio(null, new[]{"TCP2_NONE", "TCP2_COLORS_AS_NORMALS", "TCP2_TANGENT_AS_NORMALS", "TCP2_UV2_AS_NORMALS"}, new[]
					{
						new GUIContent("Regular", "Use regular vertex normals"),
						new GUIContent("Vertex Colors", "Use vertex colors as normals (with smoothed mesh)"),
						new GUIContent("Tangents", "Use tangents as normals (with smoothed mesh)"),
						new GUIContent("UV2", "Use second texture coordinates as normals (with smoothed mesh)")
					},
					keywordsList, ref updateKeywords);
					EditorGUI.indentLevel--;

					//Outline Blending -----------------------------------------------------------------------

					if(hasOutlineBlending)
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
				}

				TCP2_GUI.Separator();
			}

			//TRANSPARENCY --------------------------------------------------------------------------------
			
			if(CategoryFilter("ALPHA", "CUTOUT") && isGeneratedShader)
			{
				var alpha = false;
				var cutout = false;

				if(isGeneratedShader)
				{
					TCP2_GUI.Header("TRANSPARENCY");

					alpha = HasFlags("ALPHA");
					cutout = HasFlags("CUTOUT");
				}

				if( alpha )
				{
					var blendProps = GetFilteredProperties("#ALPHA#", props);
					if(blendProps.Length != 2)
					{
						EditorGUILayout.HelpBox("Couldn't find Blending properties!", MessageType.Error);
					}
					else
					{
						TCP2_GUI.Header("BLENDING", "BLENDING EXAMPLES:\nAlpha Transparency: SrcAlpha / OneMinusSrcAlpha\nMultiply: DstColor / Zero\nAdd: One / One\nSoft Add: OneMinusDstColor / One");
						
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

				if( cutout )
				{
					ShowFilteredProperties("#CUTOUT#", props);
				}
			}
			
#if DEBUG_INFO
			//--------------------------------------------------------------------------------------
			//DEBUG --------------------------------------------------------------------------------

			TCP2_GUI.SeparatorBig();
			
			TCP2_GUI.Header("DEBUG");

			//Clear Keywords
			if(GUILayout.Button("Clear Keywords", EditorStyles.miniButton))
			{
				keywordsList.Clear();
				updateKeywords = true;
			}

			//Shader Flags
			GUILayout.Label("Features", EditorStyles.boldLabel);
			string features = "";
			if(mShaderFeatures != null)
			{
				foreach(string flag in mShaderFeatures)
				{
					features += flag + ", ";
				}
			}
			if(features.Length > 0)
				features = features.Substring(0, features.Length-2);

			GUILayout.Label(features, EditorStyles.wordWrappedMiniLabel);

			//Shader Keywords
			GUILayout.Label("Keywords", EditorStyles.boldLabel);
			string keywords = "";
			foreach(string keyword in keywordsList)
			{
				keywords += keyword + ", ";
			}
			if(keywords.Length > 0)
				keywords = keywords.Substring(0, keywords.Length-2);

			GUILayout.Label(keywords, EditorStyles.wordWrappedMiniLabel);
#endif
			//--------------------------------------------------------------------------------------

			if(EditorGUI.EndChangeCheck())
			{
				materialEditor.PropertiesChanged();
			}
		}

		//Update Keywords
		if(updateKeywords)
		{
			if(materialEditor.targets != null && materialEditor.targets.Length > 0)
			{
				foreach(var t in materialEditor.targets)
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

		//Update Variant
		if(updateVariant && !isGeneratedShader)
		{
			var baseName = isMobileShader ? BASE_SHADER_NAME_MOB : BASE_SHADER_NAME;

			var newShader = baseName;
			for(var i = 0; i < ShaderVariants.Count; i++)
			{
				if(ShaderVariantsEnabled[i])
				{
					newShader += " " + ShaderVariants[i];
				}
			}
			newShader = newShader.TrimEnd();

			//If variant shader
			var basePath = BASE_SHADER_PATH;
			if(newShader != baseName)
			{
				basePath = VARIANT_SHADER_PATH;
			}

			var shader = Shader.Find(basePath + newShader);
			if(shader != null)
			{
				materialEditor.SetShader(shader, false);

				mJustChangedShader = true;
			}
			else
			{
				if(Event.current.type != EventType.Layout)
				{
					mVariantError = "Can't find shader variant:\n" + basePath + newShader;
				}
				materialEditor.Repaint();
			}
		}
		else if(!string.IsNullOrEmpty(mVariantError) && Event.current.type != EventType.Layout)
		{
			mVariantError = null;
			materialEditor.Repaint();
		}

#endif

#if UNITY_5_5_OR_NEWER
		materialEditor.RenderQueueField();
#endif
#if UNITY_5_6_OR_NEWER
		materialEditor.EnableInstancingField();
#endif
	}

	//--------------------------------------------------------------------------------------------------
	// Properties GUI

	//Hide parts of the GUI if the shader is compiled
	private bool CategoryFilter(params string[] filters)
	{
		if(!isGeneratedShader)
		{
			return true;
		}

		foreach(var filter in filters)
		{
			if(mShaderFeatures.Contains(filter))
			   return true;
		}

		return false;
	}

	private bool HasFlags(params string[] flags)
	{
		foreach(var flag in flags)
		{
			if(mShaderFeatures.Contains(flag))
				return true;
		}

		return false;
	}

	private bool ShowFilteredProperties(string filter, MaterialProperty[] properties, bool indent = true)
	{
		if(indent)
			EditorGUI.indentLevel++;

		var propertiesShown = false;
		foreach (var p in properties)
		{
			if ((p.flags & (MaterialProperty.PropFlags.PerRendererData | MaterialProperty.PropFlags.HideInInspector)) == MaterialProperty.PropFlags.None)
				propertiesShown |= ShaderMaterialPropertyImpl(p, filter);
		}

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
		mMaterialEditor.ShaderProperty(property, displayName);

		return true;
	}
	
	private void DirectionalAmbientGUI(string filter, MaterialProperty[] properties)
	{
		var width = (EditorGUIUtility.currentViewWidth-20)/6;
		EditorGUILayout.BeginHorizontal();
		foreach(var p in properties)
		{
			//Filter
			var displayName = p.displayName;
			if(filter != null)
			{
				if(!displayName.Contains(filter))
					continue;
				displayName = displayName.Remove(displayName.IndexOf(filter), filter.Length+1);
			}
			else if(displayName.Contains("#"))
				continue;

			GUILayout.Label(displayName, GUILayout.Width(width));
		}
		EditorGUILayout.EndHorizontal();
		EditorGUILayout.BeginHorizontal();
		foreach(var p in properties)
		{
			//Filter
			var displayName = p.displayName;
			if(filter != null)
			{
				if(!displayName.Contains(filter))
					continue;
				displayName = displayName.Remove(displayName.IndexOf(filter), filter.Length+1);
			}
			else if(displayName.Contains("#"))
				continue;
			
			DirAmbientColorProperty(p, displayName, width);
		}
		EditorGUILayout.EndHorizontal();
	}

	private Color DirAmbientColorProperty(MaterialProperty prop, string label, float width)
	{
		EditorGUI.BeginChangeCheck();
		EditorGUI.showMixedValue = prop.hasMixedValue;
		var colorValue = EditorGUILayout.ColorField(prop.colorValue, GUILayout.Width(width));
		EditorGUI.showMixedValue = false;
		if(EditorGUI.EndChangeCheck())
		{
			prop.colorValue = colorValue;
		}
		return prop.colorValue;
	}
}
