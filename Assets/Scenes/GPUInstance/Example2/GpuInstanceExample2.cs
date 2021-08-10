using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 同样材质，不同属性会打断批处理，
/// 可以在shader中使用 UNITY_DEFINE_INSTANCED_PROP 定义一个具有特定类型和名字的每个Instance独有的Shader属性
/// </summary>
public class GpuInstanceExample2 : MonoBehaviour
{
    public GameObject obj;
    public int count;


    void Start()
    {
        MaterialPropertyBlock props = new MaterialPropertyBlock();
        MeshRenderer renderer;

        for (var i = 0; i < count; i++)
        {
            var go = Instantiate(obj);
            go.transform.parent = transform;

            float angle = Random.Range(0.0f, Mathf.PI * 2.0f);
            float distance = Random.Range(1.0f, 10.0f);
            float height = Random.Range(-2.0f, 2.0f);
            float size = Random.Range(0.05f, 0.25f);
            go.transform.localPosition = new Vector4(Mathf.Sin(angle) * distance, height, Mathf.Cos(angle) * distance, size);

            
            float r = Random.Range(0.0f, 1.0f);
            float g = Random.Range(0.0f, 1.0f);
            float b = Random.Range(0.0f, 1.0f);
            props.SetColor("_Color", new Color(r, g, b));

            renderer = go.GetComponent<MeshRenderer>();
            renderer.SetPropertyBlock(props);
        }

    }

    // Update is called once per frame
    void Update()
    {

    }
}
