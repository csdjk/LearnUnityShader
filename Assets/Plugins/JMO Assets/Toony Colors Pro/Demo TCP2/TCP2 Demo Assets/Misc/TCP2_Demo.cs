// Toony Colors Pro+Mobile 2
// (c) 2014-2020 Jean Moreno

using System;
using UnityEngine;
using ToonyColorsPro.Runtime;

namespace ToonyColorsPro
{
	namespace Demo
	{
		public class TCP2_Demo : MonoBehaviour
		{
			//--------------------------------------------------------------------------------------------------
			// PUBLIC INSPECTOR PROPERTIES

			public Material[] AffectedMaterials;
			public Texture2D[] RampTextures;
			public GUISkin GuiSkin;
			public Light DirLight;

			public GameObject Robot, Ethan;

			//--------------------------------------------------------------------------------------------------
			// PRIVATE PROPERTIES

			private bool mUnityShader;

			private bool mShaderSpecular = true;
			private bool mShaderBump = true;
			private bool mShaderReflection;
			private bool mShaderRim = true;
			private bool mShaderRimOutline;
			private bool mShaderOutline = true;

			private float mRimMin = 0.5f;
			private float mRimMax = 1.0f;

			private bool mRampTextureFlag;
			private Texture2D mRampTexture;
			private float mRampSmoothing = 0.15f;

			private float mLightRotationX = 80f;
			private float mLightRotationY = 25f;

			private bool mViewRobot;
			private bool mRobotOutlineNormals = true;

			private TCP2_Demo_View DemoView;

			//--------------------------------------------------------------------------------------------------
			// UNITY EVENTS

			void Awake()
			{
				DemoView = GetComponent<TCP2_Demo_View>();
				mRampTexture = RampTextures[0];
				UpdateShader();
			}

			void OnDestroy()
			{
				RestoreRimColors();
				UpdateShader();
			}

			void OnGUI()
			{
				GUI.skin = GuiSkin;

				// Outline Normals
				GUILayout.BeginArea(new Rect(new Rect(Screen.width - 310, 20, 310 - 20, 30)));

				GUILayout.BeginHorizontal();
				GUILayout.Label("Demo Character:");
				if (GUILayout.Button("Ethan", mViewRobot ? "Button" : "ButtonOn"))
				{
					mViewRobot = false;
					Robot.SetActive(false);
					Ethan.SetActive(true);
					DemoView.CharacterTransform = Ethan.transform;
				}
				if (GUILayout.Button("Robot Kyle", !mViewRobot ? "Button" : "ButtonOn"))
				{
					mViewRobot = true;
					Robot.SetActive(true);
					Ethan.SetActive(false);
					DemoView.CharacterTransform = Robot.transform;
				}
				GUILayout.EndHorizontal();
				GUILayout.EndArea();

				GUILayout.BeginArea(new Rect(new Rect(Screen.width - 310, 55, 310 - 20, Screen.height - 40 - 90)));
				if (mViewRobot)
				{
					GUILayout.Label("Outline Normals");
					mRobotOutlineNormals = !GUILayout.Toggle(!mRobotOutlineNormals, "Regular Normals");
					mRobotOutlineNormals = GUILayout.Toggle(mRobotOutlineNormals, "TCP2's Encoded Smoothed Normals");

					GUILayout.Label("Toony Colors Pro 2 introduces an innovative way to fix broken outline caused by hard-edge shading.\nRead the documentation to learn more!", "SmallLabelShadow");
					var r2 = GUILayoutUtility.GetLastRect();
					GUI.Label(r2, "Toony Colors Pro 2 introduces an innovative way to fix broken outline caused by hard-edge shading.\nRead the documentation to learn more!", "SmallLabel");
				}
				GUILayout.EndArea();

				//Quality Settings
				GUILayout.BeginArea(new Rect(new Rect(Screen.width - 210, Screen.height - 60, 210 - 20, 50)));
				GUILayout.Label("Quality Settings:");
				GUILayout.BeginHorizontal();
				if (GUILayout.Button("<", GUILayout.Width(26)))
					QualitySettings.DecreaseLevel(true);
				GUILayout.Label(QualitySettings.names[QualitySettings.GetQualityLevel()], "LabelCenter");
				if (GUILayout.Button(">", GUILayout.Width(26)))
					QualitySettings.IncreaseLevel(true);
				GUILayout.EndHorizontal();
				GUILayout.EndArea();

				// TCP2 Settings
				GUILayout.BeginArea(new Rect(20, 20 + 90, Screen.width - 40, Screen.height - 40));

				mUnityShader = GUILayout.Toggle(mUnityShader, "View with Unity " + (mViewRobot ? "\"Diffuse Specular\"" : "\"Bumped Specular\""));
				GUILayout.Space(10);

				GUI.enabled = !mUnityShader;

				GUILayout.Label("Toony Colors Pro 2 Settings");
				mShaderSpecular = GUILayout.Toggle(mShaderSpecular, "Specular");

				GUI.enabled = !mViewRobot;
				if (GUI.enabled)
					mShaderBump = GUILayout.Toggle(mShaderBump, "Bump");
				else
					GUILayout.Toggle(false, "Bump");
				GUI.enabled = !mUnityShader;
				mShaderReflection = GUILayout.Toggle(mShaderReflection, "Reflection");

				var changed = mShaderRim;
				mShaderRim = GUILayout.Toggle(mShaderRim, "Rim Lighting");
				changed = changed != mShaderRim;
				if (changed && mShaderRim && mShaderRimOutline)
					mShaderRimOutline = false;
				if (changed && mShaderRim)
					RestoreRimColors();

				changed = mShaderRimOutline;
				mShaderRimOutline = GUILayout.Toggle(mShaderRimOutline, "Rim Outline");
				changed = changed != mShaderRimOutline;
				if (changed && mShaderRimOutline && mShaderRim)
					mShaderRim = false;
				if (changed && mShaderRimOutline)
					RimOutlineColor();

				GUI.enabled &= mShaderRim || mShaderRimOutline;
				GUILayout.BeginHorizontal();
				GUILayout.Label("Rim Min", GUILayout.Width(70));
				mRimMin = GUILayout.HorizontalSlider(mRimMin, 0f, 1f, GUILayout.Width(130f));
				GUILayout.EndHorizontal();

				GUILayout.BeginHorizontal();
				GUILayout.Label("Rim Max", GUILayout.Width(70));
				mRimMax = GUILayout.HorizontalSlider(mRimMax, 0f, 1f, GUILayout.Width(130f));
				GUILayout.EndHorizontal();
				GUI.enabled = !mUnityShader;

				mShaderOutline = GUILayout.Toggle(mShaderOutline, "Outline");

				GUILayout.Space(6);

				GUILayout.Label("Ramp Settings");
				mRampTextureFlag = GUILayout.Toggle(mRampTextureFlag, "Textured Ramp");

				GUI.enabled &= mRampTextureFlag;
				GUILayout.BeginHorizontal();
				var r = GUILayoutUtility.GetRect(200, 20, GUILayout.ExpandWidth(false));
				r.y += 4;
				GUI.DrawTexture(r, mRampTexture);
				if (GUILayout.Button("<", GUILayout.Width(26)))
					PrevRamp();
				if (GUILayout.Button(">", GUILayout.Width(26)))
					NextRamp();
				GUILayout.EndHorizontal();

				GUI.enabled = !mUnityShader;
				GUI.enabled &= !mRampTextureFlag;
				GUILayout.BeginHorizontal();
				GUILayout.Label("Smoothing", GUILayout.Width(85));
				mRampSmoothing = GUILayout.HorizontalSlider(mRampSmoothing, 0.01f, 1f, GUILayout.Width(115f));
				GUILayout.EndHorizontal();

				if (GUI.changed)
				{
					if (mUnityShader)
						UnityDiffuseShader();
					else
						UpdateShader();
				}

				// Light Settings
				GUI.enabled = true;
				GUILayout.Space(10);
				GUILayout.Label("Light Rotation");
				mLightRotationX = GUILayout.HorizontalSlider(mLightRotationX, 0f, 360f, GUILayout.Width(200f));
				mLightRotationY = GUILayout.HorizontalSlider(mLightRotationY, 0f, 360f, GUILayout.Width(200f));

				GUILayout.Space(4);
				GUILayout.Label("Hold Left mouse button to rotate character", "SmallLabelShadow");
				r = GUILayoutUtility.GetLastRect();
				GUI.Label(r, "Hold Left mouse button to rotate character", "SmallLabel");
				GUILayout.Label("Hold Right/Middle mouse button to scroll", "SmallLabelShadow");
				r = GUILayoutUtility.GetLastRect();
				GUI.Label(r, "Hold Right/Middle mouse button to scroll", "SmallLabel");
				GUILayout.Label("Use mouse scroll wheel or up/down keys to zoom", "SmallLabelShadow");
				r = GUILayoutUtility.GetLastRect();
				GUI.Label(r, "Use mouse scroll wheel or up/down keys to zoom", "SmallLabel");

				if (GUI.changed)
				{
					var angle = DirLight.transform.eulerAngles;
					angle.y = mLightRotationX;
					angle.x = mLightRotationY;
					DirLight.transform.eulerAngles = angle;
				}

				GUILayout.EndArea();
			}

			//--------------------------------------------------------------------------------------------------
			// PRIVATE

			private void UnityDiffuseShader()
			{
				var bumpedSpecular = Shader.Find("Bumped Specular");
				var specular = Shader.Find("Specular");
				foreach (var m in AffectedMaterials)
				{
					if (m.name.Contains("Robot"))
						m.shader = specular;
					else
						m.shader = bumpedSpecular;
				}
			}

			private void UpdateShader()
			{
				foreach (var m in AffectedMaterials)
				{
					ToggleKeyword(m, mShaderSpecular, "TCP2_SPEC");
					if (!m.name.Contains("Robot"))
						ToggleKeyword(m, mShaderBump, "TCP2_BUMP");
					ToggleKeyword(m, mShaderReflection, "TCP2_REFLECTION_MASKED");
					ToggleKeyword(m, mShaderRim, "TCP2_RIM");
					ToggleKeyword(m, mShaderRimOutline, "TCP2_RIMO");
					ToggleKeyword(m, mShaderOutline, "OUTLINES");
					ToggleKeyword(m, mRampTextureFlag, "TCP2_RAMPTEXT");

					m.SetFloat("_RampSmooth", mRampSmoothing);
					m.SetTexture("_Ramp", mRampTexture);
					m.SetFloat("_RimMin", mRimMin);
					m.SetFloat("_RimMax", mRimMax);

					if (m.name.Contains("Robot"))
					{
						ToggleKeyword(m, mRobotOutlineNormals, "TCP2_TANGENT_AS_NORMALS");
					}
				}

				foreach (var m in AffectedMaterials)
				{
					var s = TCP2_RuntimeUtils.GetShaderWithKeywords(m);
					if (s == null)
					{
						var keywords = "";
						foreach (var kw in m.shaderKeywords)
							keywords += kw + ",";
						keywords = keywords.TrimEnd(',');
						Debug.LogError("[TCP2 Demo] Can't find shader for keywords: \"" + keywords + "\" in material \"" + m.name + "\"\nThe missing shaders probably need to be unpacked. See TCP2 Documentation!");
					}
					else
					{
						m.shader = s;
					}
				}
			}

			private void RimOutlineColor()
			{
				foreach (var m in AffectedMaterials)
				{
					m.SetColor("_RimColor", Color.black);
				}
			}

			private void RestoreRimColors()
			{
				foreach (var m in AffectedMaterials)
				{
					if (m.name.Contains("Robot"))
						m.SetColor("_RimColor", new Color(0.2f, 0.6f, 1f, 0.5f));
					else
						m.SetColor("_RimColor", new Color(1f, 1f, 1f, 0.25f));
				}
			}

			private void ToggleKeyword(Material m, bool enabled, string keyword)
			{
				if (enabled)
					m.EnableKeyword(keyword);
				else
					m.DisableKeyword(keyword);
			}

			private void PrevRamp()
			{
				var i = Array.IndexOf(RampTextures, mRampTexture);
				i = Mathf.Clamp(i, 0, RampTextures.Length-1);
				i--;
				if (i < 0)
					i = RampTextures.Length-1;

				mRampTexture = RampTextures[i];
			}

			private void NextRamp()
			{
				var i = Array.IndexOf(RampTextures, mRampTexture);
				i = Mathf.Clamp(i, 0, RampTextures.Length-1);
				i++;
				if (i >= RampTextures.Length)
					i = 0;

				mRampTexture = RampTextures[i];
			}

		}
	}
}