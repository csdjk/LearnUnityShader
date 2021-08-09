using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DrawGraph : MonoBehaviour
{
    public Vector3[] line = new Vector3[2] { Vector3.zero, new Vector3(100, 100, 100) };


    public Vector3 circleCenter = Vector3.zero;
    public float circleRadius = 50;

    public Vector3 ellipseCenter = Vector3.zero;
    public float ellipseRadius1 = 50;
    public float ellipseRadius2 = 40;


    [Range(0, 100)]
    public float spiralRadius = 2;
    public float spiralLength = 50;


    // Update is called once per frame
    void Update()
    {
        DrawLine(line[0], line[1]);
        DrawCircle(circleCenter, circleRadius);
        DrawEllipse(ellipseCenter, ellipseRadius1, ellipseRadius2);


        // ClearPixel("Spiral");
        DrawSpiral(spiralRadius, spiralLength, 0.6f);
    }


    void OnGUI()
    {
        // GUI.Box(new Rect(0, 40, 150, 30), hitPoint.ToString());
        // {

        //     GUI.TextField(new Rect(0, 40, 150, 30),line[0].ToString());
        // }
    }

    /// <summary>
    /// 参数方程绘制直线
    /// </summary>
    /// <param name="start"></param>
    /// <param name="end"></param>
    public void DrawLine(Vector3 start, Vector3 end, float smoothness = 100)
    {
        // p(t) = p0 + t(p1-p0)

        float step = 1.0f / smoothness;
        for (float t = 0; t < 1; t += step)
        {
            Vector3 p = start + t * (end - start);
            CreatePixel(p, "line", t.ToString());
        }
    }

    /// <summary>
    /// 参数方程绘制圆
    /// </summary>
    /// <param name="start"></param>
    /// <param name="end"></param>
    public void DrawCircle(Vector3 center, float r, float smoothness = 360)
    {
        // x = Cx + r * cosθ
        // y = Cy + r * sinθ

        float step = 360 / smoothness;
        for (float theta = 0; theta <= 360; theta += step)
        {
            var x = center.x + r * Mathf.Cos(theta);
            var y = center.y + r * Mathf.Sin(theta);
            CreatePixel(new Vector3(x, y, 0), "circle", theta.ToString());
        }
    }

    public void DrawEllipse(Vector3 center, float r1, float r2, float smoothness = 360)
    {
        // x = Cx + r * cosθ
        // y = Cy + r * sinθ

        float step = 360 / smoothness;
        for (float theta = 0; theta <= 360; theta += step)
        {
            var x = center.x + r1 * Mathf.Cos(theta);
            var y = center.y + r2 * Mathf.Sin(theta);
            CreatePixel(new Vector3(x, y, 0), "Ellipse", theta.ToString());
        }
    }

    /// <summary>
    /// 参数方程绘制螺旋(绕z轴)
    /// </summary>
    /// <param name="start"></param>
    /// <param name="end"></param>
    public void DrawSpiral(float r, float length = 50, float smoothness = 0.1f)
    {
        if (smoothness == 0)
            return;
        // x = cosθ
        // y = sinθ
        // z = θ
        for (float theta = 0; theta <= length; theta += smoothness)
        {
            var x = r * Mathf.Cos(theta);
            var y = r * Mathf.Sin(theta);
            var z = r * theta;
            CreatePixel(new Vector3(x, y, z), "Spiral", theta.ToString());
        }
    }


    // public void DrawSphere(float r, float smoothness = 360)
    // {
    //     // x = cosθ
    //     // y = sinθ
    //     // z = θ
    //     float step = 360 / smoothness;

    //     for (float i = 0; i <= 720; i += step)
    //     {
    //         for (float j = 0; j <= 720; j += step)
    //         {
    //             var x = r * Mathf.Cos(i) * Mathf.Cos(j);
    //             var y = r * Mathf.Sin(i) * Mathf.Sin(j);
    //             var z = r * Mathf.Cos(j);
    //             CreatePixel(x, y, z);
    //         }
    //     }
    // }

    // 创建像素
    private Dictionary<string, Dictionary<string, GameObject>> pixelDic = new Dictionary<string, Dictionary<string, GameObject>>();
    public GameObject CreatePixel(Vector3 pos, string name, string key)
    {
        if (!pixelDic.ContainsKey(name))
            pixelDic.Add(name, new Dictionary<string, GameObject>());

        var dict = pixelDic[name];
        GameObject pixel;
        if (dict.ContainsKey(key))
        {
            pixel = dict[key];
        }
        else
        {
            pixel = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            pixel.transform.parent = this.transform;
            pixel.name = name + "_" + key;
            pixelDic[name].Add(key, pixel);
        }
        pixel.transform.localPosition = pos;
        return pixel;
    }


    public void ClearPixel(string name)
    {
        if (!pixelDic.ContainsKey(name))
            return;

        var dict = pixelDic[name];
        foreach (var item in dict)
        {
            Destroy(item.Value);
        }
        pixelDic.Remove(name);
    }
}
