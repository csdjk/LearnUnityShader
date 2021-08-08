using UnityEngine;
using System.Collections;
public class CustomMesh : MonoBehaviour
{
    //材质和高度图
    public Material diffuseMap;
    public Texture2D heightMap;
    //顶点、uv、索引信息
    private Vector3[] vertives;
    private Vector2[] uvs;
    private int[] triangles;
    //生成信息
    private Vector2 size;//长宽
    private float minHeight = -10;
    private float maxHeight = 10;
    private Vector2 segment;
    private float unitH;
    //面片mesh
    private GameObject terrain;
    // Use this for initialization
    void Start()
    {
        //默认生成一个地形，如果不喜欢，注销掉然后用参数生成
        SetTerrain();
    }
    ///
    /// 生成默认地形
    ///
    public void SetTerrain()
    {
        SetTerrain(100, 100, 50, 50, -10, 10);
    }
    ///
    /// 通过参数生成地形
    ///
    /// 地形宽度
    /// 地形长度
    /// 宽度的段数
    /// 长度的段数
    /// 最低高度
    /// 最高高度
    public void SetTerrain(float width, float height, uint segmentX, uint segmentY, int min, int max)
    {
        Init(width, height, segmentX, segmentY, min, max);
        GetVertives();
        DrawMesh();
    }
    ///
    /// 初始化计算某些值
    ///
    ///
    ///
    ///
    ///
    ///
    ///
    private void Init(float width, float height, uint segmentX, uint segmentY, int min, int max)
    {
        size = new Vector2(width, height);
        maxHeight = max;
        minHeight = min;
        unitH = maxHeight - minHeight;
        segment = new Vector2(segmentX, segmentY);
        if (terrain != null)
        {
            Destroy(terrain);
        }
        terrain = new GameObject();
        terrain.name = "plane";
    }
    ///
    /// 绘制网格
    ///
    private void DrawMesh()
    {
        Mesh mesh = terrain.AddComponent<MeshFilter>().mesh;
        // terrain.AddComponent();
        if (diffuseMap == null)
        {
            Debug.LogWarning("No material, Create diffuse!!");
            diffuseMap = new Material(Shader.Find("Diffuse"));
        }
        if (heightMap == null)
        {
            Debug.LogWarning("No heightMap!!!");
        }
        terrain.GetComponent<Renderer>().material = diffuseMap;
        //给mesh 赋值
        mesh.Clear();
        mesh.vertices = vertives;//,pos);
        mesh.uv = uvs;
        mesh.triangles = triangles;
        //重置法线
        mesh.RecalculateNormals();
        //重置范围
        mesh.RecalculateBounds();
    }
    ///
    /// 生成顶点信息
    ///
    ///
    private Vector3[] GetVertives()
    {
        int sum = Mathf.FloorToInt((segment.x + 1) * (segment.y + 1));
        float w = size.x / segment.x;
        float h = size.y / segment.y;
        int index = 0;
        GetUV();
        GetTriangles();
        vertives = new Vector3[sum];
        for (int i = 0; i < segment.y + 1; i++)
        {
            for (int j = 0; j < segment.x + 1; j++)
            {
                float tempHeight = 0;
                if (heightMap != null)
                {
                    tempHeight = GetHeight(heightMap, uvs[index]);
                }
                vertives[index] = new Vector3(j * w, tempHeight, i * h);
                index++;
            }
        }
        return vertives;
    }
    ///
    /// 生成UV信息
    ///
    ///
    private Vector2[] GetUV()
    {
        int sum = Mathf.FloorToInt((segment.x + 1) * (segment.y + 1));
        uvs = new Vector2[sum];
        float u = 1.0F / segment.x;
        float v = 1.0F / segment.y;
        uint index = 0;
        for (int i = 0; i < segment.y + 1; i++)
        {
            for (int j = 0; j < segment.x + 1; j++)
            {
                uvs[index] = new Vector2(j * u, i * v);
                index++;
            }
        }
        return uvs;
    }
    ///
    /// 生成索引信息
    ///
    ///
    private int[] GetTriangles()
    {
        int sum = Mathf.FloorToInt(segment.x * segment.y * 6);
        triangles = new int[sum];
        uint index = 0;
        for (int i = 0; i < segment.y; i++)
        {
            for (int j = 0; j < segment.x; j++)
            {
                int role = Mathf.FloorToInt(segment.x) + 1;
                int self = j + (i * role);
                int next = j + ((i + 1) * role);
                triangles[index] = self;
                triangles[index + 1] = next + 1;
                triangles[index + 2] = self + 1;
                triangles[index + 3] = self;
                triangles[index + 4] = next;
                triangles[index + 5] = next + 1;
                index += 6;
            }
        }
        return triangles;
    }
    private float GetHeight(Texture2D texture, Vector2 uv)
    {
        if (texture != null)
        {
            //提取灰度。如果强制读取某个通道，可以忽略
            Color c = GetColor(texture, uv);
            float gray = c.grayscale;//或者可以自己指定灰度提取算法，比如：gray = 0.3F * c.r + 0.59F * c.g + 0.11F * c.b;
            float h = unitH * gray;
            return h;
        }
        else
        {
            return 0;
        }
    }
    /// <summary>
    /// 获取图片上某个点的颜色
    /// </summary>
    /// <param name="texture"></param>
    /// <param name="uv"></param>
    /// <returns></returns>
    private Color GetColor(Texture2D texture, Vector2 uv)
    {
        Color color = texture.GetPixel(Mathf.FloorToInt(texture.width * uv.x), Mathf.FloorToInt(texture.height * uv.y));
        return color;
    }
    /// <summary>
    /// 从外部设置地形的位置坐标
    /// </summary>
    /// <param name="pos"></param>
    public void SetPos(Vector3 pos)
    {
        if (terrain)
        {
            terrain.transform.position = pos;
        }
        else
        {
            SetTerrain();
            terrain.transform.position = pos;
        }
    }
}
