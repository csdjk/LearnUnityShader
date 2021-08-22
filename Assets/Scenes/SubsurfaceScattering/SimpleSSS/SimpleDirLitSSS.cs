using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
[ExecuteInEditMode]
public class SimpleDirLitSSS : MonoBehaviour
{
    public Transform[] sssList;

    public Transform[] pointTrans;
    public Color[] pointColors;
    public float[] pointRange;
    void Start()
    {
    }

    // Update is called once per frame
    void Update()
    {
        var posList = pointTrans.Select(v => new Vector4(v.position.x,v.position.y,v.position.z,0)).ToArray();
        foreach (var go in sssList)
        {
            var mat = go.GetComponent<MeshRenderer>().sharedMaterial;
            mat.SetFloat("_CustomPointLitArray", pointTrans.Length);
            mat.SetVectorArray("_CustomPointLitPosList", posList);
            mat.SetColorArray("_CustomPointLitColorList", pointColors);
            mat.SetFloatArray("_CustomPointLitRangeList", pointRange);
        }
    }
}
