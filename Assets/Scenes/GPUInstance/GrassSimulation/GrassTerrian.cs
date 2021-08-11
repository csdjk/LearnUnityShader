using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class GrassTerrian : MonoBehaviour
{

    [SerializeField]
    private Vector2 _grassQuadSize = new Vector2(0.1f, 0.6f);


    private int _grassCount;

    public int grassCount
    {
        get
        {
            return _grassCount;
        }
    }


    private ComputeBuffer _grassBuffer;
    public ComputeBuffer grassBuffer
    {
        get
        {
            if (_grassBuffer != null)
            {
                return _grassBuffer;
            }
            var filter = GetComponent<MeshFilter>();
            var terrianMesh = filter.sharedMesh;
            List<GrassInfo> grassInfos = new List<GrassInfo>();
            var maxGrassCount = 10000;
            var grassIndex = 0;

            foreach (var v in terrianMesh.vertices)
            {
                var vertexPosition = v;
                for (var i = 0; i < 10; i++)
                {

                    //贴图参数，暂时不用管
                    Vector2 texScale = Vector2.one;
                    Vector2 texOffset = Vector2.zero;
                    Vector4 texParams = new Vector4(texScale.x, texScale.y, texOffset.x, texOffset.y);

                    //1x1范围内随机分布
                    Vector3 offset = vertexPosition + new Vector3(Random.Range(0, 1f), 0, Random.Range(0, 1f));
                    //0到180度随机旋转
                    float rot = Random.Range(0, 180);
                    //构造变换矩阵
                    var localToTerrian = Matrix4x4.TRS(offset, Quaternion.Euler(0, rot, 0), Vector3.one);
                    var grassInfo = new GrassInfo()
                    {
                        localToTerrian = localToTerrian,
                        texParams = texParams
                    };
                    grassInfos.Add(grassInfo);
                    grassIndex++;
                    if (grassIndex >= maxGrassCount)
                    {
                        break;
                    }
                }
                if (grassIndex >= maxGrassCount)
                {
                    break;
                }
            }
            _grassCount = grassIndex;
            _grassBuffer = new ComputeBuffer(_grassCount, 64 + 16);
            _grassBuffer.SetData(grassInfos);
            return _grassBuffer;
        }
    }


    private MaterialPropertyBlock _materialBlock;

    public void UpdateMaterialProperties()
    {
        materialPropertyBlock.SetMatrix(ShaderProperties.TerrianLocalToWorld, transform.localToWorldMatrix);
        materialPropertyBlock.SetBuffer(ShaderProperties.GrassInfos, grassBuffer);
        materialPropertyBlock.SetVector(ShaderProperties.GrassQuadSize, _grassQuadSize);
    }

    public MaterialPropertyBlock materialPropertyBlock
    {
        get
        {
            if (_materialBlock == null)
            {
                _materialBlock = new MaterialPropertyBlock();
            }
            return _materialBlock;
        }
    }

    public Material grassMaterial;
    public Mesh terrianMesh;
    private void Start()
    {
        // terrianMesh = GetComponent<MeshFilter>().mesh;
    }
    void Update()
    {
        // Render
        UpdateMaterialProperties();
        Graphics.DrawMeshInstancedProcedural(terrianMesh, 0, grassMaterial, new Bounds(Vector3.zero, new Vector3(100.0f, 100.0f, 100.0f)), 10, materialPropertyBlock);
    }


    [ContextMenu("ForceRebuildGrassInfoBuffer")]
    private void ForceUpdateGrassBuffer()
    {
        if (_grassBuffer != null)
        {
            _grassBuffer.Dispose();
            _grassBuffer = null;
        }
        UpdateMaterialProperties();
    }

    public struct GrassInfo
    {
        public Matrix4x4 localToTerrian;
        public Vector4 texParams;
    }
    private class ShaderProperties
    {

        public static readonly int TerrianLocalToWorld = Shader.PropertyToID("_TerrianLocalToWorld");
        public static readonly int GrassInfos = Shader.PropertyToID("_GrassInfos");
        public static readonly int GrassQuadSize = Shader.PropertyToID("_GrassQuadSize");

    }
}