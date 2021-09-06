// Toony Colors Pro+Mobile 2
// (c) 2014-2020 Jean Moreno

using UnityEditor;
using ToonyColorsPro.Runtime;

// Script that will update the custom time value for relevant water materials (using "Custom Time" from the Shader Generator)

// This allows:
// - getting the world height position of the wave with the TCP2_GetPosOnWater script
// - syncing to Unity's Time.timeScale value

namespace ToonyColorsPro
{
	namespace Inspector
	{
		[CustomEditor(typeof(TCP2_ShaderUpdateUnityTime))]
		public class TCP2_ShaderUpdateUnityTime_Editor : Editor
		{
			public override void OnInspectorGUI()
			{
				//base.OnInspectorGUI();

				EditorGUILayout.HelpBox("This script will update the time value for water shaders that use the 'Custom Time' option.\n\n This allows:\n- getting the world height position of the wave with the TCP2_GetPosOnWater script\n- syncing to Unity's Time.timeScale value", MessageType.Info);
				base.OnInspectorGUI();
			}
		}
	}
}