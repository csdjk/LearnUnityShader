

using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using LcLTools;

[ExecuteInEditMode]
public class GrassTerrian : MonoBehaviour
{
    [Range(1, 100)]
    public int grassCount = 1;
    [Range(1, 1000)]
    public float radius = 100;
    public Mesh grassMesh;
    public Material grassMaterial;
    // 草面片大小
    public Vector2 grassQuadSize = new Vector2(0.1f, 0.6f);
    // 交互对象
    public Transform playerTrs;
    // 碰撞范围
    [Range(0, 10)]
    public float crashRadius;
    // 下压强度
    [Range(0, 100)]
    public float pushStrength;

    private int cachedGrassCount = -1;
    private Vector2 cachedGrassQuadSize;

    private ComputeBuffer grassBuffer;
    private Mesh terrianMesh;
    private int grassTotalCount;

    private RenderTexture pathRenderTexture;

    void Start()
    {
        terrianMesh = GetComponent<MeshFilter>().sharedMesh;
        // CreatePathRenderTexture();
        UpdateBuffers();
    }

    void Update()
    {
        if (cachedGrassCount != grassCount || !cachedGrassQuadSize.Equals(grassQuadSize))
            UpdateBuffers();

        Vector4 playerPos = playerTrs.TransformPoint(Vector3.zero);
        playerPos.w = crashRadius;
        grassMaterial.SetVector("_PlayerPos", playerPos);
        grassMaterial.SetFloat("_PushStrength", pushStrength);

        Graphics.DrawMeshInstancedProcedural(grassMesh, 0, grassMaterial, new Bounds(Vector3.zero, new Vector3(radius, radius, radius)), grassTotalCount);
    }

    [ContextMenu("UpdateGrassBuffers")]
    private void ForceUpdateGrassBuffer()
    {
        UpdateBuffers();
    }

    void UpdateBuffers()
    {
        if (terrianMesh == null)
            terrianMesh = GetComponent<MeshFilter>().sharedMesh;

        if (grassBuffer != null)
            grassBuffer.Release();

        List<GrassInfo> grassInfos = new List<GrassInfo>();

        grassTotalCount = 0;

        // 在三角形内随机生成
        var triIndex = terrianMesh.triangles;
        var vertices = terrianMesh.vertices;
        var len = triIndex.Length;
        for (var i = 0; i < len; i += 3)
        {
            var vertex1 = vertices[triIndex[i]];
            var vertex2 = vertices[triIndex[i + 1]];
            var vertex3 = vertices[triIndex[i + 2]];
            // 计算三角形面积
            var arena = LcLUtility.CalculateTriangleArea(vertex1, vertex2, vertex3);
            // 法向量
            Vector3 normal = LcLUtility.CalculateTriangleNormal(vertex1, vertex2, vertex3).normalized;

            // 一个三角形面生成 grassCount 个
            for (var j = 0; j < grassCount; j++)
            {
                //贴图参数，暂时不用管
                Vector2 texScale = Vector2.one;
                Vector2 texOffset = Vector2.zero;
                Vector4 texParams = new Vector4(texScale.x, texScale.y, texOffset.x, texOffset.y);
                // 三角形内随机采样
                Vector3 randPos = LcLUtility.RandomTriangle(vertex1, vertex2, vertex3);
                // 向法线方向偏移
                randPos += normal.normalized * 0.5f * grassQuadSize.y;

                // 旋转
                float rot = Random.Range(0, 180);
                Quaternion upToNormal = Quaternion.FromToRotation(Vector3.up, normal);
                // rot += 0.5f * grassQuadSize.y;

                //构造变换矩阵
                var localToWorld = Matrix4x4.TRS(transform.TransformPoint(randPos), upToNormal * Quaternion.Euler(0, rot, 0), Vector3.one);
                // var localToWorld = Matrix4x4.TRS(transform.TransformPoint(randPos), upToNormal, Vector3.one);
                // localToWorld = transform.localToWorldMatrix * localToWorld;

                var grassInfo = new GrassInfo()
                {
                    localToWorld = localToWorld,
                    texParams = texParams
                };
                grassInfos.Add(grassInfo);
                grassTotalCount++;
            }
        }

        grassBuffer = new ComputeBuffer(grassTotalCount, 64 + 16);
        grassBuffer.SetData(grassInfos);
        grassMaterial.SetBuffer("_GrassInfoBuffer", grassBuffer);
        grassMaterial.SetVector("_GrassQuadSize", grassQuadSize);
        cachedGrassCount = grassCount;
        cachedGrassQuadSize = grassQuadSize;
    }

    void OnDisable()
    {
        if (grassBuffer != null)
            grassBuffer.Release();
        grassBuffer = null;
    }



    public struct GrassInfo
    {
        public Matrix4x4 localToWorld;
        public Vector4 texParams;
    }
}