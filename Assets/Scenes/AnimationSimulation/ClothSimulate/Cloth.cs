
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Random = UnityEngine.Random;

[Serializable]
public struct RandomForce
{
    public Vector2 RangeX;
    public Vector2 RangeY;
    public Vector2 RangeZ;
}
/// <summary>
/// 布料
/// </summary>
[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class Cloth : MonoBehaviour
{
    [Range(1, 500)]
    public float looper = 64;

    [Range(0, 64)]
    public int massCount = 10;

    [Header("弹簧参数")]
    [Tooltip("弹簧长度")]
    // 弹簧长度
    public float restLen = 1f;
    /// 弹力系数
    [Range(0, 50000)]
    public float ks = 35000;
    // 阻力系数
    [Range(0, 1000)]
    public float kd = 150f;

    [Header("质点参数")]
    // 质点大小
    public float massSize = 0.05f;
    // 是否显示质点
    public bool showMass = true;
    // 布料质量
    public float clothMass = 1f;

    public float drag = 1f;

    [Header("外力")]
    [Tooltip("恒定的外力")]
    // 恒定的外力
    public Vector3 externalForce;
    [Tooltip("随机力")]
    [SerializeField]
    // 随机力
    public RandomForce randomForce;
    // 随机间隔
    public float randomInterval = 0;

    [Header("布料材质")]
    public Material clothMat;

    // public float xieKs = 0.7f;
    // public float hengKs = 0.5f;

    // 模拟步长
    private float simulateStep = 0;

    List<ClothSpring> allSprings;
    ClothMass[,] allMass;

    // Mesh
    private Mesh clothMesh;
    private Vector3[] _vertices;
    private Vector2[] _uv;
    private int[] _triangles;
    void Start()
    {
        clothMesh = new Mesh();
        gameObject.GetComponent<MeshFilter>().sharedMesh = clothMesh;
        // gameObject.GetComponent<MeshRenderer>().material = clothMat;
        simulateStep = 0.01f / looper;

        InitMassList();
        InitSprings();
        // 创建Mesh
        CreateMesh();
    }

    void Update()
    {
        float pointMass = clothMass / (massCount * massCount);
        for (var a = 0; a < looper; a++)
        {
            for (int i = 0, len = allSprings.Count; i < len; i++)
            {

                allSprings[i].SetParams(ks, restLen);
                allSprings[i].kd = kd;
                allSprings[i].Simulate();//产生所有弹簧力
            }
            for (int i = 0; i < massCount; i++)
            {
                for (int j = 0; j < massCount; j++)
                {
                    allMass[i, j].m = pointMass;
                    allMass[i, j].drag = drag;
                    allMass[i, j].Simulate(simulateStep);//计算这一帧所有合力 质点运动变化
                }
            }
        }

        // 更新顶点
        int index = 0;
        for (int i = 0; i < massCount; i++)
        {
            for (int j = 0; j < massCount; j++)
            {
                UpdateVertices(index, i, j);
                UpdateMassView(i, j);
                index++;
            }
        }
        clothMesh.vertices = _vertices;
        clothMesh.RecalculateTangents();
        clothMesh.RecalculateNormals();
        clothMesh.RecalculateBounds();
    }

    void InitMassList()
    {
        allMass = new ClothMass[massCount, massCount];
        //创建所有质点
        for (int i = 0; i < massCount; i++)
        {
            for (int j = 0; j < massCount; j++)
            {
                var item = GameObject.CreatePrimitive(PrimitiveType.Sphere).AddComponent<ClothMass>();
                item.transform.SetParent(transform);
                item.transform.localScale = Vector3.one * massSize;
                item.name = i + "_" + j;
                Destroy(item.GetComponent<Collider>());
                item.transform.localPosition = new Vector3(i * restLen, -j * restLen, 0);
                allMass[i, j] = item;
                item.SetExternalForce(externalForce);
            }
        }
        // 静态质点
        allMass[0, 0].isStaticPos = true;
        allMass[massCount - 1, 0].isStaticPos = true;
        allMass[massCount - 1, 0].transform.localPosition += new Vector3(-0.3f, 0, 0.1f);
    }

    // 初始化所有弹簧系统
    void InitSprings()
    {
        // 创建所有弹簧 
        allSprings = new List<ClothSpring>();
        for (int i = 0; i < massCount; i++)
        {
            for (int j = 0; j < massCount; j++)
            {
                // 创建横向弹簧
                if (i < massCount - 1)
                {
                    CreateJoin(i, j, i + 1, j);
                }
                // 创建纵向弹簧
                if (j < massCount - 1)
                {
                    CreateJoin(i, j, i, j + 1);
                }
                // 创建斜线弹簧
                if (i < massCount - 1 && j < massCount - 1)
                {
                    CreateJoin(i, j, i + 1, j + 1).SetPercent(0.7f, Mathf.Sqrt(2));
                }
                if (i < massCount - 1 && j > 0)
                {
                    CreateJoin(i, j, i + 1, j - 1).SetPercent(0.7f, Mathf.Sqrt(2));
                }
                // 创建隔行 隔列 抗弯曲弹簧
                if (i < massCount - 2)
                {
                    CreateJoin(i, j, i + 2, j).SetPercent(0.5f, 2);
                }
                if (j < massCount - 2)
                {
                    CreateJoin(i, j, i, j + 2).SetPercent(0.5f, 2);
                }
            }
        }
    }

    // 创建弹簧
    ClothSpring CreateJoin(int ci, int cj, int ni, int nj)
    {
        var item = allMass[ci, cj].gameObject.AddComponent<ClothSpring>();
        item.mass_a = allMass[ci, cj];
        item.mass_b = allMass[ni, nj];
        allSprings.Add(item);
        return item;
    }

    // 创建mesh
    void CreateMesh()
    {
        // 顶点
        _vertices = new Vector3[massCount * massCount];
        _uv = new Vector2[_vertices.Length];
        int index = 0;
        for (int i = 0; i < massCount; i++)
        {
            for (int j = 0; j < massCount; j++)
            {
                _vertices[index] = allMass[i, j].transform.localPosition;
                _uv[index] = new Vector2((float)i / (massCount - 1), (float)j / (massCount - 1));
                index++;
            }
        }
        // 三角形
        _triangles = new int[6 * massCount * massCount];
        int ti = 0;
        int vi = 0;
        for (int i = 0; i < massCount - 1; i++)
        {
            for (int j = 0; j < massCount - 1; j++)
            {
                _triangles[ti] = _triangles[ti + 3] = vi + 0;
                _triangles[ti + 1] = _triangles[ti + 5] = vi + massCount + 1;
                _triangles[ti + 2] = vi + 1;
                _triangles[ti + 4] = vi + massCount;
                ti += 6;
                vi++;
            }
            vi++;
        }
        clothMesh.vertices = _vertices;
        clothMesh.triangles = _triangles;
        clothMesh.uv = _uv;
        clothMesh.RecalculateTangents();
        clothMesh.RecalculateNormals();
        clothMesh.RecalculateBounds();
    }

    // 更新顶点
    void UpdateVertices(int vi, int i, int j)
    {
        _vertices[vi] = allMass[i, j].transform.localPosition;
    }

    // 更新质点数据
    private float randomIntervalCount = 0;
    void UpdateMassView(int i, int j)
    {
        var mass = allMass[i, j];
        // 外力
        mass.SetExternalForce(externalForce);


        randomIntervalCount += Time.deltaTime;
        if (randomIntervalCount >= randomInterval)
        {
            // 随机力
            // mass.SetRandomFactor(new Vector3(Random.value, Random.value, Random.value));
            // mass.SetRandomForce(randomForce);

            mass.SetRandomForce(new Vector3(
                Random.Range(randomForce.RangeX.x, randomForce.RangeX.y),
                Random.Range(randomForce.RangeY.x, randomForce.RangeY.y),
                Random.Range(randomForce.RangeZ.x, randomForce.RangeZ.y))
            );
            randomIntervalCount = 0;
        }


        if (mass.isStaticPos)
        {
            mass.transform.localScale = Vector3.one * 0.05f;
            mass.transform.gameObject.SetActive(true);
            mass.SetColor(Color.green);
        }
        else
        {
            mass.transform.localScale = Vector3.one * massSize;
            mass.transform.gameObject.SetActive(showMass);
            mass.SetColor(Color.black);
        }

    }


    // void 
    public void ChangeSpringKs(float ks)
    {
        for (int i = 0, len = allSprings.Count; i < len; i++)
        {
            allSprings[i].ks = ks;

        }
    }
    public void ChangeSpringKd(float kd)
    {
        for (int i = 0, len = allSprings.Count; i < len; i++)
        {
            allSprings[i].kd = kd;

        }
    }
    public void ChangeSpringRestLen(float restLen)
    {
        for (int i = 0, len = allSprings.Count; i < len; i++)
        {
            allSprings[i].restLen = restLen;

        }
    }




    private void OnGUI()
    {
        if (GUILayout.Button("风力开关", GUILayout.Width(100)))
        {
           randomForce.RangeX = Vector3.zero;
           randomForce.RangeY = Vector3.zero;
           randomForce.RangeZ = Vector3.zero;
           randomInterval = 1;
        }
        if (GUILayout.Button("移除固定节点", GUILayout.Width(100)))
        {
          for (int i = 0; i < massCount; i++)
            {
                for (int j = 0; j < massCount; j++)
                {
                    allMass[i, j].isStaticPos = false;
                }
            }
        }
    }
}