using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class BezierMesh : MonoBehaviour
{
    // ---------------------------
    public static List<Vector3> CalculateBezier(Vector3[] pointArr, int smoothness = 100)
    {
        var list = new List<Vector3>();
        // 开始分割曲线
        for (float i = 0, len = smoothness; i <= len; i++)
        {
            list.Add(CalculateBezier(i / smoothness, pointArr));
        }
        return list;
    }
    public static Vector3 CalculateBezier(float t, Vector3[] pointArr)
    {
        float x = 0, y = 0, z = 0;
        //控制点数组
        float n = pointArr.Length - 1;
        for (int i = 0; i < pointArr.Length; i++)
        {

            Vector3 item = pointArr[i];
            if (i == 0)
            {
                x += item.x * (float)(Math.Pow((1 - t), n - i) * Math.Pow(t, i));
                y += item.y * (float)(Math.Pow((1 - t), n - i) * Math.Pow(t, i));
                z += item.z * (float)(Math.Pow((1 - t), n - i) * Math.Pow(t, i));
            }
            else
            {
                //factorial为阶乘函数
                x += Factorial(n) / Factorial(i) / Factorial(n - i) * item.x * (float)Math.Pow((1 - t), n - i) * (float)Math.Pow(t, i);
                y += Factorial(n) / Factorial(i) / Factorial(n - i) * item.y * (float)Math.Pow((1 - t), n - i) * (float)Math.Pow(t, i);
                z += Factorial(n) / Factorial(i) / Factorial(n - i) * item.z * (float)Math.Pow((1 - t), n - i) * (float)Math.Pow(t, i);
            }
        }

        return new Vector3(x, y, z);
    }
    //阶乘
    private static float Factorial(float i)
    {
        float n = 1;
        for (float j = 1; j <= i; j++)
            n *= j;
        return n;
    }


    public GameObject point;
    public Transform[] control1 = new Transform[4];
    public Transform[] control2 = new Transform[4];
    public Transform[] control3 = new Transform[4];
    public Transform[] control4 = new Transform[4];

    private List<Vector3> _vertices = new List<Vector3>();
    private List<int> _triangles = new List<int>();
    private Mesh myMesh;

    void Awake()
    {
        // myMesh = new Mesh();
        // gameObject.AddComponent<MeshFilter>().mesh = myMesh;
        // gameObject.AddComponent<MeshRenderer>().material = Resources.Load<Material>("Standard");
    }

    private List<List<Vector3>> pointList = new List<List<Vector3>>();
    void Update()
    {
        pointList.Clear();
        var bezier1 = BezierMesh.CalculateBezier(control1.Select(t => t.position).ToArray(), 30);
        var bezier2 = BezierMesh.CalculateBezier(control2.Select(t => t.position).ToArray(), 30);
        var bezier3 = BezierMesh.CalculateBezier(control3.Select(t => t.position).ToArray(), 30);
        var bezier4 = BezierMesh.CalculateBezier(control4.Select(t => t.position).ToArray(), 30);
        for (int i = 0; i < 30; i++)
        {
            var verticalBezier = BezierMesh.CalculateBezier(
                new Vector3[4]{
                    bezier1[i],
                    bezier2[i],
                    bezier3[i],
                    bezier4[i],
                }, 30);
            pointList.Add(verticalBezier);
            // CreateLine(verticalBezier, i);
        }
        CreateMesh();
    }


    public Dictionary<string, GameObject> pointMap = new Dictionary<string, GameObject>();
    void CreateLine(List<Vector3> bezier, int key)
    {
        for (int i = 0; i < bezier.Count; i++)
        {
            string pointkey = key + "_" + i;
            GameObject go;
            pointMap.TryGetValue(pointkey, out go);
            if (!pointMap.ContainsKey(pointkey))
            {
                go = Instantiate(point);
                go.transform.parent = transform;
                pointMap.Add(pointkey, go);
            }
            go.transform.localPosition = bezier[i];
        }
    }


    void CreateMesh()
    {
        if (myMesh == null)
        {
            myMesh = new Mesh();
            gameObject.AddComponent<MeshFilter>().mesh = myMesh;
            var mat = new Material(Shader.Find("Standard"));
            gameObject.AddComponent<MeshRenderer>().material = mat;

        }
        myMesh.Clear();
        _vertices.Clear();
        _triangles.Clear();
        Vector3 posA;
        Vector3 posB;
        Vector3 posC;
        Vector3 posD;
        for (int i = 0; i < pointList.Count - 1; i++)
        {
            for (int j = 0; j < pointList[i].Count - 1; j++)
            {
                posA = pointList[i][j];
                posB = pointList[i][j + 1];
                posC = pointList[i + 1][j + 1];
                posD = pointList[i + 1][j];
                // 第一个三角形
                _vertices.Add(posA);
                _vertices.Add(posB);
                _vertices.Add(posC);
                // 第二个三角形
                _vertices.Add(posC);
                _vertices.Add(posD);
                _vertices.Add(posA);
            }
        }
        for (int i = 0; i < _vertices.Count; i++)
        {
            _triangles.Add(i);
        }

        myMesh.vertices = _vertices.ToArray();
        myMesh.triangles = _triangles.ToArray();
        myMesh.RecalculateNormals();
    }
}
