// Toony Colors Pro+Mobile 2
// (c) 2014-2020 Jean Moreno

using UnityEditor;
using ToonyColorsPro.Runtime;

// Script to get the water height from a specific world position
// Useful to easily make objects float on water for example

namespace ToonyColorsPro
{
	namespace Inspector
	{
		[CustomEditor(typeof(TCP2_GetPosOnWater)), CanEditMultipleObjects]
		public class TCP2_GetPosOnWater_Editor : Editor
		{
			public override void OnInspectorGUI()
			{
				//base.OnInspectorGUI();

				EditorGUILayout.HelpBox("Use this script with a Water Template-generated shader to get the water height at a specific world point.\n\nMake sure that the shader has the following features enabled:\n- Custom Time\n- Vertex Waves\n- World-based Position\n\nMake sure to also use the TCP2_ShaderUpdateUnityTime script!", MessageType.Info);
				base.OnInspectorGUI();
			}
		}
	}
}