using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif

namespace ToonyColorsPro
{
	namespace Demo
	{
		public class TCP2_Demo_Interactive_Environment : MonoBehaviour
		{
			public Material skybox;

			public void ApplyEnvironment()
			{
				var root = this.transform.parent;
				var envs = root.GetComponentsInChildren<TCP2_Demo_Interactive_Environment>();
				foreach (var env in envs)
				{
					env.gameObject.SetActive(false);
				}

				this.gameObject.SetActive(true);
				RenderSettings.skybox = this.skybox;
				RenderSettings.customReflection = (Cubemap)this.skybox.GetTexture("_Tex");

				if (Application.isPlaying)
				{
					DynamicGI.UpdateEnvironment();
				}
			}
		}
	}
}

#if UNITY_EDITOR
namespace ToonyColorsPro
{
	namespace Demo
	{
		[CustomEditor(typeof(TCP2_Demo_Interactive_Environment))]
		public class TCP2_Demo_Interactive_Environment_Editor : Editor
		{
			public override void OnInspectorGUI()
			{
				base.OnInspectorGUI();

				GUILayout.Space(8);

				if (GUILayout.Button("Apply Environment"))
				{
					(target as TCP2_Demo_Interactive_Environment).ApplyEnvironment();
				}
			}
		}
	}
}
#endif