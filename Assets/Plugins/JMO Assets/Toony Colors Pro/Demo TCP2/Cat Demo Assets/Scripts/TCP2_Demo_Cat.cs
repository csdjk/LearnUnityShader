// Toony Colors Pro+Mobile 2
// (c) 2014-2020 Jean Moreno

using System;
using UnityEngine;
using UnityEngine.UI;

namespace ToonyColorsPro
{
	namespace Demo
	{
		public class TCP2_Demo_Cat : MonoBehaviour
		{
			[Serializable]
			public class Ambience
			{
				public string name;
				public GameObject[] activate;
				public Material skybox;
			}

			[Serializable]
			public class ShaderStyle
			{
				[Serializable]
				public class CharacterSettings
				{
					public Material material;
					public Renderer[] renderers;
				}

				public string name;
				public CharacterSettings[] settings;
			}

			public Ambience[] ambiences;
			public int amb;
			[Space]
			public ShaderStyle[] styles;
			public int style;
			[Space]
			public GameObject shadedGroup;
			public GameObject flatGroup;
			[Space]
			public Animation[] catAnimation;
			public Animation[] unityChanAnimation;
			[Space]
			public GameObject[] cats;
			public GameObject[] unityChans;
			public GameObject unityChanCopyright;
			[Space]
			public Light catDirLight;
			public Light unityChanDirLight;
			[Space]
			public AnimationClip[] catAnimations;
			int catAnim;
			public AnimationClip[] unityChanAnimations;
			int uchanAnim;
			[Space]
			public Light[] dirLights;
			public Light[] otherLights;
			public Transform rotatingPointLights;
			public bool rotateLights { get; set; }
			public bool rotatePointLights { get; set; }
			[Space]
			public Button[] ambiencesButtons;
			public Button[] stylesButtons;
			public Button[] characterButtons;
			public Button[] textureButtons;
			public Button[] animationButtons;
			[Space]
			public Canvas canvas;

			bool animationPaused;
			float playingSpeed = 1;

			//------------------------------------------------------------------------------------------------------------------------

			void Awake()
			{
				rotatePointLights = true;
				rotateLights = false;
				SetAmbience(0);
				SetStyle(0);
				SetCat(true);
				SetFlat(false);
				SetAnimation(0);
			}

			void Update()
			{
				if (rotateLights)
					foreach (var l in dirLights)
						l.transform.Rotate(Vector3.up * Time.deltaTime * -30f, Space.World);

				if (rotatePointLights)
					rotatingPointLights.transform.Rotate(Vector3.up * 50f * Time.deltaTime, Space.World);

				//Keyboard shortcuts
				//Switch style
				if (Input.GetKeyDown(KeyCode.Tab))
				{
					if (Input.GetKey(KeyCode.LeftShift) || Input.GetKey(KeyCode.RightShift))
						SetStyle(--style);
					else
						SetStyle(++style);
				}

				//Keypad -> style
				if (Input.GetKeyDown(KeyCode.Alpha1) || Input.GetKeyDown(KeyCode.Keypad1))
				{
					SetStyle(0);
				}
				if (Input.GetKeyDown(KeyCode.Alpha2) || Input.GetKeyDown(KeyCode.Keypad2))
				{
					SetStyle(1);
				}
				if (Input.GetKeyDown(KeyCode.Alpha3) || Input.GetKeyDown(KeyCode.Keypad3))
				{
					SetStyle(2);
				}
				if (Input.GetKeyDown(KeyCode.Alpha4) || Input.GetKeyDown(KeyCode.Keypad4))
				{
					SetStyle(3);
				}
				if (Input.GetKeyDown(KeyCode.Alpha5) || Input.GetKeyDown(KeyCode.Keypad5))
				{
					SetStyle(4);
				}
				if (Input.GetKeyDown(KeyCode.Alpha6) || Input.GetKeyDown(KeyCode.Keypad6))
				{
					SetStyle(5);
				}

				//Show/hide UI
				if (Input.GetKeyDown(KeyCode.H))
				{
					canvas.enabled = !canvas.enabled;
				}
			}

			//------------------------------------------------------------------------------------------------------------------------
			// UI Callbacks

			public void SetAmbience(int index)
			{
				foreach (var a in ambiences)
					foreach (var g in a.activate)
						g.SetActive(false);

				amb = index % ambiences.Length;
				var current = ambiences[amb];
				foreach (var g in current.activate)
					g.SetActive(true);

				RenderSettings.skybox = current.skybox;
				DynamicGI.UpdateEnvironment();

				for (var i = 0; i < ambiencesButtons.Length; i++)
				{
					var colors = ambiencesButtons[i].colors;
					colors.colorMultiplier = (i == index) ? 0.96f : 0.6f;
					ambiencesButtons[i].colors = colors;
				}
			}

			public void SetStyle(int index)
			{
				if (index < 0)
					index = styles.Length-1;
				if (index >= styles.Length)
					index = 0;
				style = index;

				var s = styles[style];

				foreach (var setting in s.settings)
					foreach (var r in setting.renderers)
						r.sharedMaterial = setting.material;

				for (var i = 0; i < stylesButtons.Length; i++)
				{
					var colors = stylesButtons[i].colors;
					colors.colorMultiplier = (i == index) ? 0.96f : 0.6f;
					stylesButtons[i].colors = colors;
				}
			}

			public void SetFlat(bool flat)
			{
				bool isCat = !unityChanCopyright.activeInHierarchy;
				float currentTime;
				if (isCat)
				{
					var anim = catAnimation[flat ? 0 : 1];
					currentTime = anim[anim.clip.name].normalizedTime;
				}
				else
				{
					var anim = unityChanAnimation[flat ? 0 : 1];
					currentTime = anim[anim.clip.name].normalizedTime;
				}

				shadedGroup.SetActive(!flat);
				flatGroup.SetActive(flat);

				PlayCurrentAnimation(currentTime);

				for (var i = 0; i < textureButtons.Length; i++)
				{
					var colors = textureButtons[i].colors;
					colors.colorMultiplier = (i == 1 && flat) || (i == 0 && !flat) ? 0.96f : 0.6f;
					textureButtons[i].colors = colors;
				}
			}

			public void SetCat(bool cat)
			{
				foreach (var c in cats)
					c.SetActive(cat);
				foreach (var u in unityChans)
					u.SetActive(!cat);

				if (unityChanDirLight != null)
				{
					unityChanDirLight.gameObject.SetActive(!cat);
				}

				if (catDirLight != null)
				{
					catDirLight.gameObject.SetActive(cat);
				}

				unityChanCopyright.SetActive(!cat);

				PlayCurrentAnimation();

				for (var i = 0; i < characterButtons.Length; i++)
				{
					var colors = characterButtons[i].colors;
					colors.colorMultiplier = (i == 0 && cat) || (i == 1 && !cat) ? 0.96f : 0.6f;
					characterButtons[i].colors = colors;
				}
			}

			public void SetLightShadows(bool on)
			{
				foreach (var l in dirLights)
					l.shadows = on ? LightShadows.Soft : LightShadows.None;

				foreach (var l in otherLights)
					l.shadows = on ? LightShadows.Soft : LightShadows.None;
			}

			public void SetAnimation(int index)
			{
				catAnim = index;
				if (catAnim >= catAnimations.Length)
					catAnim = 0;
				if (catAnim < 0)
					catAnim = catAnimations.Length-1;

				foreach (var anim in catAnimation)
				{
					anim.clip = catAnimations[index];
				}

				uchanAnim = index;
				if (uchanAnim >= unityChanAnimations.Length)
					uchanAnim = 0;
				if (uchanAnim < 0)
					uchanAnim = unityChanAnimations.Length-1;

				foreach (var anim in unityChanAnimation)
				{
					anim.clip = unityChanAnimations[index];
				}

				PlayCurrentAnimation();

				for (var i = 0; i < animationButtons.Length; i++)
				{
					var colors = animationButtons[i].colors;
					colors.colorMultiplier = (i == index) ? 0.96f : 0.6f;
					animationButtons[i].colors = colors;
				}
			}

			public void SetAnimationSpeed(float speed)
			{
				playingSpeed = speed;
				UpdateAnimSpeed();
			}

			public void PauseUnpauseAnimation(bool play)
			{
				animationPaused = !play;
				UpdateAnimSpeed();
			}

			void UpdateAnimSpeed()
			{
				foreach (var anim in catAnimation)
				{
					foreach (AnimationState state in anim)
					{
						state.speed = animationPaused ? 0 : playingSpeed;
					}
				}

				foreach (var anim in unityChanAnimation)
				{
					foreach (AnimationState state in anim)
					{
						state.speed = animationPaused ? 0 : playingSpeed;
					}
				}
			}

			void PlayCurrentAnimation(float time = -1)
			{
				bool isCat = !unityChanCopyright.activeInHierarchy;
				bool isFlat = flatGroup.activeSelf;
				if (isCat)
				{
					var anim = catAnimation[isFlat ? 1 : 0];
					anim.Play();
					if (time >= 0)
					{
						anim[anim.clip.name].normalizedTime = time;
					}
				}
				else
				{
					var anim = unityChanAnimation[isFlat ? 1 : 0];
					anim.Play();
					if (time >= 0)
					{
						anim[anim.clip.name].normalizedTime = time;
					}

					// shadows
					anim = unityChanAnimation[2];
					anim.Play();
					if (time >= 0)
					{
						anim[anim.clip.name].normalizedTime = time;
					}
				}
			}
		}
	}
}