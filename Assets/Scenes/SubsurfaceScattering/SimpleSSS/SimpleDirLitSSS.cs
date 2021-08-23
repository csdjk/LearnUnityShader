using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
[ExecuteInEditMode]
public class SimpleDirLitSSS : MonoBehaviour
{
    public Transform[] sssList;
    public Light[] pointLight;
    private Color[] pointColors;
    private Vector4[] pointPos;
    private float[] pointRange;
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        if (pointLight == null)
            return;
        var len = pointLight.Length;
        pointPos = new Vector4[len];
        pointColors = new Color[len];
        pointRange = new float[len];

        for (var i = 0; i < len; i++)
        {
            var light = pointLight[i];
            pointPos[i] = light.transform.position;
            pointColors[i] = light.color;
            pointRange[i] = light.range;
        }

        foreach (var go in sssList)
        {
            var mat = go.GetComponent<MeshRenderer>().sharedMaterial;
            mat.SetFloat("_CustomPointLitArray", len);
            mat.SetVectorArray("_CustomPointLitPosList", pointPos);
            mat.SetColorArray("_CustomPointLitColorList", pointColors);
            mat.SetFloatArray("_CustomPointLitRangeList", pointRange);
        }
    }
}
