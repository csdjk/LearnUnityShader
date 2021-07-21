using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
///  光栅化测试（判断点是否在三角形内部）
/// </summary>
public class Rasterize : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        // 画布
        var canvas = CreateCanvas(100, 100);
        // 三角形
        var triangle = new Vector3[3]{
            new Vector3(50,0,0),
            new Vector3(0,50,0),
            new Vector3(100,50,0)
        };

        // IsInsideTriangle(triangle, new Vector3(20, 50, 0));
        // 光栅化
        StarRasterize(triangle, canvas);
    }


    // 创建画布
    public GameObject[][] CreateCanvas(int width, int height)
    {
        var canvas = new GameObject[width][];

        for (int i = 0; i < width; i++)
        {
            for (int j = 0; j < height; j++)
            {
                if (canvas[i] == null)
                    canvas[i] = new GameObject[height];
                canvas[i][j] = CreatePixel(i, j);
            }
        }

        return canvas;
    }

    // 创建像素
    public GameObject CreatePixel(int x, int y)
    {
        GameObject pixel = GameObject.CreatePrimitive(PrimitiveType.Quad);
        pixel.transform.parent = this.transform;
        pixel.name = x + "_" + y;
        pixel.transform.localPosition = new Vector3(x, y, 0);
        return pixel;
    }

    /// <summary>
    /// 判断点是否在三角形内部 (核心算法)
    /// </summary>
    /// <param name="triangle">三角形</param>
    /// <param name="point">点</param>
    /// <returns></returns>
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

    // 开始光栅化
    public void StarRasterize(Vector3[] triangle, GameObject[][] canvas)
    {
        for (int i = 0; i < canvas.Length; i++)
        {
            for (int j = 0; j < canvas[i].Length; j++)
            {
                if (IsInsideTriangle(triangle, new Vector3(i, j, 0)))
                {
                    var pixel = canvas[i][j];
                    var render = pixel.GetComponent<Renderer>();
                    render.material.color = Color.red;
                }
            }
        }
    }
}
