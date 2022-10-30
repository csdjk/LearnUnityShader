

using UnityEngine;
using System.Collections;
using System.Collections.Generic;

[ExecuteAlways(), RequireComponent(typeof(Camera))]
public class ViewFrustumCulling : MonoBehaviour
{
    [Range(1, 500000)]
    public int instanceCount = 10000;
    [Range(1, 1000)]
    public float radius = 100;
    public Mesh instanceMesh;
    public Material instanceMaterial;
    public bool enableCulling = true;
    public float offsetDistance = 1;
    private bool cachedEnableKillOut = false;
    private int cachedInstanceCount = -1;
    private float cachedInstanceRadius = -1;
    private ComputeBuffer localToWorldBuffer;
    private int instanceRealCount = 1;

    private Camera m_Camera;
    void OnEnable()
    {
        m_Camera = GetComponent<Camera>();
        UpdateBuffers();
    }
    void Update()
    {
        if (cachedInstanceCount != instanceCount || cachedInstanceRadius != radius || cachedEnableKillOut != enableCulling)
            UpdateBuffers();

        Graphics.DrawMeshInstancedProcedural(instanceMesh, 0, instanceMaterial, new Bounds(Vector3.zero, new Vector3(radius, radius, radius)), instanceRealCount);
    }

    void OnGUI()
    {
        GUI.Label(new Rect(265, 25, 200, 30), "Instance Count: " + instanceCount.ToString());
        instanceCount = (int)GUI.HorizontalSlider(new Rect(25, 20, 200, 30), (float)instanceCount, 1.0f, 500000.0f);


        GUILayout.BeginArea(new Rect(Screen.width - 100 - 50, Screen.height - 30 - 50, 100 + 10, 30 + 10), GUI.skin.box);
        {
            string state = enableCulling ? "Culling..." : "Culling";
            if (GUILayout.Button(state, GUILayout.Width(100), GUILayout.Height(30)))
            {
                enableCulling = !enableCulling;
            }
        }
        GUILayout.EndArea();
    }

    void UpdateBuffers()
    {
        Random.InitState(1);
        List<Matrix4x4> matrix4x4s = new List<Matrix4x4>();

        if (localToWorldBuffer != null)
            localToWorldBuffer.Release();

        for (int i = 0; i < instanceCount; i++)
        {
            var randPos = Random.insideUnitSphere * radius;
            if (enableCulling)
            {
                if (IsPointInFrustum(randPos))
                {
                    matrix4x4s.Add(Matrix4x4.TRS(randPos, Quaternion.identity, Vector3.one));
                }
            }
            else
            {
                matrix4x4s.Add(Matrix4x4.TRS(randPos, Quaternion.identity, Vector3.one));
            }
        }
        if (matrix4x4s.Count == 0)
        {
            return;
        }
        localToWorldBuffer = new ComputeBuffer(matrix4x4s.Count, 4 * 4 * 4);
        localToWorldBuffer.SetData(matrix4x4s);
        instanceMaterial.SetBuffer("localToWorldBuffer", localToWorldBuffer);
        instanceRealCount = matrix4x4s.Count;
        cachedInstanceCount = instanceCount;
        cachedInstanceRadius = radius;
        cachedEnableKillOut = enableCulling;
    }


    private Plane[] planes;
    public bool IsPointInFrustum(Vector3 point)
    {
        planes = GeometryUtility.CalculateFrustumPlanes(m_Camera);

        for (int i = 0, len = planes.Length; i < len; ++i)
        {
            var plane = Plane.Translate(planes[i], planes[i].normal * offsetDistance);
            if (!plane.GetSide(point))
            {
                return false;
            }
        }
        return true;
    }

    void OnDisable()
    {
        if (localToWorldBuffer != null)
            localToWorldBuffer.Release();
        localToWorldBuffer = null;
    }
}