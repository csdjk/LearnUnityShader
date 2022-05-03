using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 在三角形内随机生成点
/// </summary>
public class RandomTriangle : MonoBehaviour
{
    private Mesh myMesh;
    private Vector3[] myTriangle;


    // Start is called before the first frame update
    void Start()
    {
        // 三角形
        myTriangle = new Vector3[3]{
            new Vector3(-30,0,0),
            new Vector3(-30,100,10),
            new Vector3(100,0,-10)
        };
        CreateTriangle(myTriangle);


        for (var i = 0; i < 100; i++)
        {
            Vector3 randomPos = RandomTri(myTriangle);
            var point = CreatePoint(randomPos,Random.ColorHSV());
        }
    }

    public void CreateTriangle(Vector3[] triangle)
    {
        myMesh = new Mesh();
        gameObject.AddComponent<MeshFilter>().mesh = myMesh;
        var mat = new Material(Shader.Find("Standard"));
        gameObject.AddComponent<MeshRenderer>().material = mat;

        int[] triangles = new int[3] { 0, 1, 2 };
        myMesh.vertices = triangle;
        myMesh.triangles = triangles;
        myMesh.RecalculateNormals();
    }

    public GameObject CreatePoint(Vector3 pos, Color color)
    {
        GameObject point = GameObject.CreatePrimitive(PrimitiveType.Sphere);
        point.transform.parent = this.transform;
        point.transform.localPosition = pos;
        var render = point.GetComponent<Renderer>();
        render.material.color = color;
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
