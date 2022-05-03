

using UnityEngine;
using System.Collections;

public class GpuInstanceExample3 : MonoBehaviour
{
    public int instanceCount = 10000;
    public Mesh instanceMesh;
    public Material instanceMaterial;
    //随便找个位置做随机
    public Transform target;

    private int cachedInstanceCount = -1;
    private ComputeBuffer positionBuffer;
    private Matrix4x4[] matrix4x4s;
    void Start()
    {
        UpdateBuffers();
    }

    void Update()
    {
        if (cachedInstanceCount != instanceCount)
            UpdateBuffers();

        if (Input.GetAxisRaw("Horizontal") != 0.0f)
            instanceCount = (int)Mathf.Clamp(instanceCount + Input.GetAxis("Horizontal") * 40000, 1.0f, 5000000.0f);

        Graphics.DrawMeshInstanced(instanceMesh, 0, instanceMaterial, matrix4x4s, matrix4x4s.Length);
    }

    void OnGUI()
    {
        GUI.Label(new Rect(265, 25, 200, 30), "Instance Count: " + instanceCount.ToString());
        instanceCount = (int)GUI.HorizontalSlider(new Rect(25, 20, 200, 30), (float)instanceCount, 1.0f, 1023.0f);
    }

    void UpdateBuffers()
    {
        matrix4x4s = new Matrix4x4[instanceCount];
        for (int i = 0; i < instanceCount; i++)
        {
            target.position = Random.onUnitSphere * 30f;
            matrix4x4s[i] = target.localToWorldMatrix;
        }
        cachedInstanceCount = instanceCount;
    }

    void OnDisable()
    {
        if (positionBuffer != null)
            positionBuffer.Release();
        positionBuffer = null;
    }
}