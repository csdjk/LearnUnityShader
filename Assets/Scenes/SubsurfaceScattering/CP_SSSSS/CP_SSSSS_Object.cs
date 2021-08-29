using UnityEngine;
using System.Collections;
#if UNITY_EDITOR
using UnityEditor;
#endif

public enum CP_SSSSS_MaskSource
{
	mainTexture = 0,
	separateTexture = 1,
	wholeObject = 2
}

[ExecuteInEditMode]
[RequireComponent(typeof(Renderer))]
public class CP_SSSSS_Object : MonoBehaviour {

	//public Texture skinMask;
	public Color subsurfaceColor = new Color(1,0.2f,0.1f,0);
	public CP_SSSSS_MaskSource maskSource = CP_SSSSS_MaskSource.mainTexture;
	public Texture2D maskTex;
	
	private CP_SSSSS_Main mainScript;
	private Material propertiesHostMat;
	private Material previousMat;
	
	Renderer r;

	// Use this for initialization
	void Start () {
		r = GetComponent<Renderer>();
		//r.material.SetTexture("_SSMask", skinMask);
	}

	void OnWillRenderObject()
	{
		//Before the object is rendered

		//We store per-object SSS settings in material copies on each affected renderer's SSSSS_Object script (propertiesHostMat)
		//We use camera events so that SSS objects could swap between the properties host and original materials when rendering the mask
		//This way we can avoid original materials getting instantiated

		if (mainScript == null)
		{
			mainScript = Object.FindObjectOfType<CP_SSSSS_Main>();
		}

		if (mainScript != null)
		{
			if (Camera.current.name == mainScript.camName)
			{
				SubstituteMaterial();
				UpdateSSS();
				Camera.onPostRender -= RevertMaterial;
				Camera.onPostRender += RevertMaterial;
			}
		}
	}

	void OnDisable()
	{
		if (propertiesHostMat!=null)
		propertiesHostMat.SetColor("_SSColor", Color.black);
	}

	void OnEnable()
	{
		UpdateSSS();
	}

	void UpdateSSS()
	{
		if (mainScript == null)
		{
			mainScript = Object.FindObjectOfType<CP_SSSSS_Main>();
		}

		if (r == null) r = GetComponent<Renderer>();

		if (propertiesHostMat == null)
		{
			propertiesHostMat = new Material(Shader.Find("Standard"));
		}
		if (previousMat != null)
			propertiesHostMat.SetTexture("_MainTex", previousMat.mainTexture);
		propertiesHostMat.SetColor("_SSColor", subsurfaceColor);
		propertiesHostMat.SetInt("_MaskSource", (int)maskSource);
		if (maskSource==CP_SSSSS_MaskSource.separateTexture)
		{
			propertiesHostMat.SetTexture("_MaskTex", maskTex);
		}
	}

	void SubstituteMaterial()
	{
		if (r == null) r = GetComponent<Renderer>();
		if (r != null) {
			previousMat = r.sharedMaterial;
			r.sharedMaterial = propertiesHostMat;
		}
	}

    private void OnGUI()
    {
        GUI.DrawTexture(new Rect(0, 0, 256, 256), previousMat.mainTexture, ScaleMode.ScaleToFit, false, 1);
    }
	void RevertMaterial(Camera cam)
	{
		if (cam.name == mainScript.camName)
		{
			if (r == null) r = GetComponent<Renderer>();
			if (r != null && previousMat != null)
			{
				r.sharedMaterial = previousMat;
			}
		}
		Camera.onPostRender -= RevertMaterial;
	}
}

#if UNITY_EDITOR

[CustomEditor(typeof(CP_SSSSS_Object))]
public class CP_SSSSS_Object_Editor : Editor
{
	string[] maskSourceNames = { "Main texture from current material (A)", "Separate texture (A)", "No mask, whole object is translucent" };
	SerializedObject e_object;
	SerializedProperty e_subsurfaceColor;
	SerializedProperty e_maskSource;

	void OnEnable()
	{
		e_object = new SerializedObject(target);
		e_subsurfaceColor = e_object.FindProperty("subsurfaceColor");
		e_maskSource = e_object.FindProperty("maskSource");
	}

	public override void OnInspectorGUI()
	{
		CP_SSSSS_Object myScript = target as CP_SSSSS_Object;
		if (e_object == null)
		{
			e_object = new SerializedObject(target);
			e_subsurfaceColor = e_object.FindProperty("subsurfaceColor");
			e_maskSource = e_object.FindProperty("maskSource");
		}

		EditorGUILayout.PropertyField(e_subsurfaceColor, new GUIContent("Subsurface color:"), true);

		CP_SSSSS_MaskSource msksrc = (CP_SSSSS_MaskSource)EditorGUILayout.Popup("Subsurface mask source:", (int)myScript.maskSource, maskSourceNames);
		if (msksrc != myScript.maskSource)
		{
			//Undo.RecordObject(target, "inspector");
			myScript.maskSource = msksrc;
			e_maskSource.enumValueIndex = (int)msksrc;
		}

		if (myScript.maskSource==CP_SSSSS_MaskSource.separateTexture)
		{
			myScript.maskTex = (Texture2D)EditorGUILayout.ObjectField("Mask texture (A):", myScript.maskTex, typeof(Texture2D), false);
		}

		e_object.ApplyModifiedProperties();

	}
}

#endif
