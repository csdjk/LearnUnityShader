using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 在三角形内随机生成点
/// </summary>
[ExecuteAlways]
public class RandomTriangle : MonoBehaviour
{
    public Material mat;
    [Range(0, 10000)]
    public int randSeed = 0;
    private int _randSeed = 0;

    [Range(0, 1000)]
    public int randCount = 100;
    private int _randCount = 0;

    public Vector3[] triangle = new Vector3[3]{
            new Vector3(-30,0,0),
            new Vector3(-30,100,10),
            new Vector3(100,0,-10)
        };
    private Mesh myMesh;


    void OnEnable()
    {
        Init();
    }

    void Init()
    {
        Clear();
        // 三角形
        CreateTriangle(triangle);
        for (var i = 0; i < randCount; i++)
        {
            Vector3 randomPos = RandomTri(triangle);
            CreatePoint(randomPos, Random.ColorHSV(), i);
        }
    }
    void Update()
    {
        // 
        if (_randSeed != randSeed)
        {
            _randSeed = randSeed;
            Random.InitState(_randSeed);
            Init();
        }
        if (_randCount != randCount)
        {
            _randCount = randCount;
            Init();
        }
    }

    // clean
    void OnDisable()
    {
        Clear();
    }

    // clear
    void Clear()
    {
        // remove all children
        for (int i = transform.childCount; i > 0; i--)
        {
#if UNITY_EDITOR
            DestroyImmediate(transform.GetChild(0).gameObject);
#else
                Destroy(transform.GetChild(0).gameObject);
#endif

        }

    }
    public void CreateTriangle(Vector3[] triangle)
    {
        if (myMesh == null)
        {
            myMesh = new Mesh();
            if (gameObject.TryGetComponent<MeshFilter>(out var meshFilter))
                meshFilter.mesh = myMesh;
            else
                gameObject.AddComponent<MeshFilter>().mesh = myMesh;
            // MeshRenderer
            if (mat == null)
            {
                mat = new Material(Shader.Find("Standard"));
            }
            if (gameObject.TryGetComponent<MeshRenderer>(out var meshRenderer))
                meshRenderer.material = mat;
            else
                gameObject.AddComponent<MeshRenderer>().material = mat;
        }

        int[] triangles = new int[3] { 0, 1, 2 };
        myMesh.vertices = triangle;
        myMesh.triangles = triangles;
        myMesh.RecalculateNormals();
    }

    // create material list
    public List<Material> materials = new List<Material>();
    public GameObject CreatePoint(Vector3 pos, Color color, int index)
    {
        GameObject point = GameObject.CreatePrimitive(PrimitiveType.Sphere);
        point.name = "point_" + index;
        point.transform.parent = this.transform;
        point.transform.localPosition = pos;
        var render = point.GetComponent<Renderer>();

        var mat = new Material(Shader.Find("Standard"));
        mat.color = color;
        render.material = mat;

        return point;
    }
    /// <summary>
    /// 三角形内随机采样
    /// </summary>
    /// <param name="triangle"></param>
    public Vector3 RandomTri(Vector3[] triangle)
    {
        // 重心坐标
        float randomX = Random.Range(0, 1f);
        float randomY = Random.Range(0, 1 - randomX);
        float randomZ = 1 - randomX - randomY;

        return triangle[0] * randomX + triangle[1] * randomY + triangle[2] * randomZ;
    }

}
