using System.Collections;
using System.Collections.Generic;
using UnityEngine;


/// <summary>
/// 动态批处理测试（观察Drawcall）
/// </summary>
public class DynamicBatch : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        ScaleTest();

    }


    /// <summary>
    /// scale 对动态批处理是否有影响
    /// </summary>
    void ScaleTest()
    {
        for (var i = 0; i < 100; i++)
        {
            GameObject go;
            // cube = GameObject.Instantiate(prefab) as GameObject;
            go = GameObject.CreatePrimitive(PrimitiveType.Cube);
            go.transform.localPosition = new Vector3(i,0,0);
            // if (i / 100 == 0)
            // {
            //     go.transform.localScale = new Vector3(2 + i, 2 + i, 2 + i);
            // }
        }
    }
}
