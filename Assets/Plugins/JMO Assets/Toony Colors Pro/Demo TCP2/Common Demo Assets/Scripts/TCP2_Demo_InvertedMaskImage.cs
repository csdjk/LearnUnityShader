using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.UI;

public class TCP2_Demo_InvertedMaskImage : Image
{
	public override Material materialForRendering
	{
		get
		{
			Material mat = new Material(base.materialForRendering);
			mat.SetInt("_StencilComp", (int)CompareFunction.NotEqual);
			return mat;
		}
	}
}
