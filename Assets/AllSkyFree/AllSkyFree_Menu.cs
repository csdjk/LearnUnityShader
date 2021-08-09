using UnityEditor;
using UnityEngine;

/* Delete this file to remove the AllSky menu item. */ 

namespace Com.AllSkyFree
{
	public class AllSkyFreeMenu : MonoBehaviour
	{
		[MenuItem("Window/AllSky/AllSky 200+ Skybox Set")]
		static void Link()
	    {
		    Application.OpenURL( "https://assetstore.unity.com/packages/2d/textures-materials/sky/allsky-200-sky-skybox-set-10109" );
	    }
	
	}	
}