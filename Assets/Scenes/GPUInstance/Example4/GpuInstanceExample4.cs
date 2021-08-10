

using UnityEngine;
using System.Collections;

public class GpuInstanceExample4 : MonoBehaviour
{
    [Range(1,500000)]
    public int instanceCount = 10000;
    [Range(1,1000)]
    public float radius = 100;
    public Mesh instanceMesh;
    public Material instanceMaterial;
    //随便找个位置做随机
    public Transform target;

    private int cachedInstanceCount = -1;
    private float cachedInstanceRadius = -1;
    private ComputeBuffer localToWorldBuffer;
    void Start()
    {
        UpdateBuffers();
    }

    void Update()
    {
        if (cachedInstanceCount != instanceCount || cachedInstanceRadius != radius)
            UpdateBuffers();

        Graphics.DrawMeshInstancedProcedural(instanceMesh, 0, instanceMaterial, new Bounds(Vector3.zero, new Vector3(radius, radius, radius)), instanceCount);
    }

    void OnGUI()
    {
        GUI.Label(new Rect(265, 25, 200, 30), "Instance Count: " + instanceCount.ToString());
        instanceCount = (int)GUI.HorizontalSlider(new Rect(25, 20, 200, 30), (float)instanceCount, 1.0f, 500000.0f);
    }

    void UpdateBuffers()
    {
        Matrix4x4[] matrix4x4s = new Matrix4x4[instanceCount];
        if (localToWorldBuffer != null)
            localToWorldBuffer.Release();
        localToWorldBuffer = new ComputeBuffer(instanceCount, 4*4*4);

        for (int i = 0; i < instanceCount; i++)
        {
            target.position = Random.onUnitSphere * radius;
            matrix4x4s[i] = target.localToWorldMatrix;
        }
        localToWorldBuffer.SetData(matrix4x4s);
        instanceMaterial.SetBuffer("localToWorldBuffer", localToWorldBuffer);
        cachedInstanceCount = instanceCount;
        cachedInstanceRadius = radius;
    }

    void OnDisable()
    {
        if (localToWorldBuffer != null)
            localToWorldBuffer.Release();
        localToWorldBuffer = null;
    }
}