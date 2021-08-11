

using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class GrassTerrian2 : MonoBehaviour
{
    [Range(1, 100)]
    public int grassCount = 1;
    [Range(1, 1000)]
    public float radius = 100;
    public Mesh grassMesh;
    public Material grassMaterial;

    private int cachedGrassCount = -1;
    private ComputeBuffer grassBuffer;
    private Mesh terrianMesh;
    private int grassTotalCount;
    public Transform target;
    void Start()
    {
        terrianMesh = GetComponent<MeshFilter>().sharedMesh;
        UpdateBuffers();
    }

    void Update()
    {
        if (cachedGrassCount != grassCount)
            UpdateBuffers();

        Graphics.DrawMeshInstancedProcedural(grassMesh, 0, grassMaterial, new Bounds(Vector3.zero, new Vector3(radius, radius, radius)), grassTotalCount);
    }


    void UpdateBuffers()
    {

        if (grassBuffer != null)
            grassBuffer.Release();

        List<GrassInfo> grassInfos = new List<GrassInfo>();

        grassTotalCount = 0;

        foreach (var v in terrianMesh.vertices)
        {
            var vertexPosition = v;
            for (var i = 0; i < grassCount; i++)
            {
                //贴图参数，暂时不用管
                Vector2 texScale = Vector2.one;
                Vector2 texOffset = Vector2.zero;
                Vector4 texParams = new Vector4(texScale.x, texScale.y, texOffset.x, texOffset.y);

                //1x1范围内随机分布
                Vector3 randPos = vertexPosition + new Vector3(Random.Range(0, 1f), 0.5f, Random.Range(0, 1f));
                //0到180度随机旋转
                float rot = Random.Range(0, 180);
                //构造变换矩阵
                target.position = transform.TransformPoint(randPos);
                target.rotation = Quaternion.Euler(0, rot, 0);
                // var localToTerrian = Matrix4x4.TRS(transform.TransformPoint(randPos), Quaternion.Euler(0, rot, 0), Vector3.one);
                var grassInfo = new GrassInfo()
                {
                    localToTerrian = target.localToWorldMatrix,
                    texParams = texParams
                };
                grassInfos.Add(grassInfo);
                grassTotalCount++;
            }
        }
        grassBuffer = new ComputeBuffer(grassTotalCount, 64 + 16);
        grassBuffer.SetData(grassInfos);
        grassMaterial.SetBuffer("_GrassInfoBuffer", grassBuffer);

        cachedGrassCount = grassCount;
    }

    void OnDisable()
    {
        if (grassBuffer != null)
            grassBuffer.Release();
        grassBuffer = null;
    }



    public struct GrassInfo
    {
        public Matrix4x4 localToTerrian;
        public Vector4 texParams;
    }
}