using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 射线与三角形相交
/// </summary>
public class RayCrossTriangle : MonoBehaviour
{
    private LineRenderer line;

    public Transform[] lineDir;

    private Mesh myMesh;
    private Vector3[] myTriangle;
    private GameObject pointGo;

    void Start()
    {
        line = new GameObject("line").AddComponent<LineRenderer>();
        line.startWidth = 0.1f;
        line.endWidth = 0.1f;
        line.material = new Material(Shader.Find("Particles/Standard Unlit"));
        line.startColor = Color.green;
        line.endColor = Color.green;
        // 交点
        pointGo = GameObject.CreatePrimitive(PrimitiveType.Sphere);
        pointGo.transform.localScale = new Vector3(3, 3, 3);
        pointGo.GetComponent<Renderer>().material.color = Color.green;
        Destroy(pointGo.GetComponent<SphereCollider>());
        // 三角形
        myTriangle = new Vector3[3]{
            new Vector3(-30,0,0),
            new Vector3(-30,100,10),
            new Vector3(100,0,-10)
        };
        CreateTriangle(myTriangle);

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

    private Vector3 hitPoint;
    private void Update()
    {
        if (myTriangle == null)
            return;
        if (Input.GetMouseButton(0))
        {
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            RaycastHit hitInfo;
            if (Physics.Raycast(ray, out hitInfo))
            {
                //划出射线，只有在scene视图中才能看到
                // Debug.DrawLine(ray.origin, hitInfo.point);
                lineDir[1].position = hitInfo.point;
            }
        }

        line.positionCount = 2;
        line.SetPositions(new Vector3[] { lineDir[0].position, lineDir[1].position });

        Vector3 dir = (lineDir[1].position - lineDir[0].position).normalized;

        var isHit = RayTriangleIntersection(myTriangle, lineDir[0].position, dir, out hitPoint);
        // var isHit = RayTriangleIntersection2(myTriangle, lineDir[0].position, dir, out hitPoint);
        if (isHit)
        {
            pointGo.transform.position = hitPoint;
        }
        pointGo.SetActive(isHit);
    }

    // ------------------------------------------------算法一(先求射线和三角形所在平面的交点，然后判断交点是否在三角形内部)-----------------------------------------
    public bool RayTriangleIntersection(Vector3[] triangle, Vector3 origin, Vector3 dir, out Vector3 I)
    {
        I = new Vector3(Mathf.Infinity, Mathf.Infinity, Mathf.Infinity);
        // 与三角形所在的面的交点
        Vector3 hitPoint = IntersectionWithTrianglePlane(triangle, origin, dir);
        pointGo.transform.position = hitPoint;

        // 判断交点是否在三角形内
        if (IsInsideTriangle(triangle, hitPoint))
        {
            I = hitPoint;
            return true;
        }
        return false;
    }

    // 与三角形所在的面的交点
    public Vector3 IntersectionWithTrianglePlane(Vector3[] triangle, Vector3 origin, Vector3 dir)
    {
        dir = dir.normalized;
        // 三角形三个顶点
        var A = triangle[0];
        var B = triangle[1];
        var C = triangle[2];
        // 三角形三边
        var AB = B - A;
        var BC = C - B;
        var CA = A - C;
        Vector3 normal = Vector3.Cross( BC,AB).normalized;
        var t = Vector3.Dot((A - origin), normal) / Vector3.Dot(dir, normal);
        var p = origin + t * dir;
        return p;
    }
    // 判断点是否在三角形内部
    public bool IsInsideTriangle(Vector3[] triangle, Vector3 point)
    {
        // 三角形三个顶点
        var A = triangle[0];
        var B = triangle[1];
        var C = triangle[2];

        // 三角形三边
        var AB = B - A;
        var BC = C - B;
        var CA = A - C;

        var P = point;
        // 构建点P和顶点连线向量
        var AP = P - A;
        var BP = P - B;
        var CP = P - C;

        // 判断P 与 三边的位置关系（如果叉乘结果都为同一个方向，那么就在内部，否则在外部）
        var normal1 = Vector3.Cross(AB, AP).normalized;
        var normal2 = Vector3.Cross(BC, BP).normalized;
        var normal3 = Vector3.Cross(CA, CP).normalized;

        // 在边上的点也算在三角形内部
        if (normal1.z * normal2.z * normal3.z == 0)
            return true;

        return Vector3.Dot(normal1, normal2) > 0 && Vector3.Dot(normal2, normal3) > 0;
    }



    // ------------------------------------------------算法二(基于重心坐标)-----------------------------------------

    public bool RayTriangleIntersection2(Vector3[] triangle, Vector3 origin, Vector3 dir, out Vector3 I)
    {
        I = new Vector3(Mathf.Infinity, Mathf.Infinity, Mathf.Infinity);

        dir = dir.normalized;
        // 三角形三个顶点
        var A = triangle[0];
        var B = triangle[1];
        var C = triangle[2];


        //Find vectors for two edges sharing A
        Vector3 AB = B - A;
        Vector3 AC = C - A;

        //Begin calculating determinant - also used to calculate u parameter
        Vector3 P = Vector3.Cross(dir, AC);

        //if determinant is near zero, ray lies in plane of triangle
        float det = Vector3.Dot(AB, P);
        //NOT CULLING
        if (det > -0.000001 && det < 0.000001)
        {
            return false;
        }
        float inv_det = 1.0f / det;

        //calculate distance from A to ray origin
        Vector3 T = origin - A;

        //Calculate u parameter and test bound
        float u = Vector3.Dot(T, P) * inv_det;

        //The intersection lies outside of the triangle
        if (u < 0.0f || u > 1.0f)
        {
            return false;
        }

        //Prepare to test v parameter
        Vector3 Q = Vector3.Cross(T, AB);
        //Calculate V parameter and test bound
        float v = Vector3.Dot(dir, Q) * inv_det;

        //The intersection lies outside of the triangle
        if (v < 0.0f || u + v > 1.0f)
        {
            return false;
        }

        float t = Vector3.Dot(AC, Q) * inv_det;

        //ray intersection
        if (t > 0.000001)
        {
            I = origin + dir * t;
            return true;
        }

        return false;
    }




    void OnGUI()
    {
        GUI.Box(new Rect(0, 40, 150, 30), hitPoint.ToString());
    }
}
