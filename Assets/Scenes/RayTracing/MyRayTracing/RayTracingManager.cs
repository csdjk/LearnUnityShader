using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RayTracingManager : MonoBehaviour
{

    public List<GameObject> Models;

    public Material material;

    public Light PointLight;

    // public Transform MagicCricle;

    private List<Vector4> BoundingSpere;

    // public float MagicAlpha;

    void OnEnable()
    {
        CaculateBoundingSpere();
    }

    void OnRenderImage(RenderTexture src, RenderTexture dst)
    {
        Graphics.Blit(src, dst, material);
    }

    void Update()
    {
        if (material)
        {
            SetRenderData();
        }
    }

    /// <summary>
    /// 设置材质数据
    /// </summary>
    void SetRenderData()
    {
        List<Vector4> list = new List<Vector4>();

        int count = 0;
        foreach (GameObject model in Models)
        {
            Matrix4x4 localToWorldMatrix = model.transform.localToWorldMatrix;

            Mesh mesh = model.GetComponent<MeshFilter>().sharedMesh;

            Vector3 origin = localToWorldMatrix.MultiplyPoint((Vector3)BoundingSpere[count]);

            list.Add(new Vector4(origin.x, origin.y, origin.z, BoundingSpere[count].w * model.transform.lossyScale.x));     //加入包围球数据

            list.Add(new Vector4(mesh.triangles.Length, 0));                                                                //加入顶点长度数据

            count++;

            for (int i = 0; i < mesh.triangles.Length; i++)                                                                  //材质数据
            {
                Vector4 vec = localToWorldMatrix.MultiplyPoint(mesh.vertices[mesh.triangles[i]]);

                if (model.name == "Quad")
                    vec.w = 1;

                if (model.name == "Trillion")
                    vec.w = 2;

                if (model.name == "Pyramid")
                    vec.w = 3;

                if (model.name == "HdrPyramid")
                    vec.w = 4;

                list.Add(vec);

            }
        }

        material.SetVectorArray("_Vertices", list);

        material.SetVector("_LightPos", PointLight.transform.position);

        // material.SetVector("_MagicOrigin", MagicCricle.position);

        // material.SetFloat("_MagicAlpha", MagicAlpha);
    }

    /// <summary>
    /// 计算所有几何体的包围球
    /// </summary>
    void CaculateBoundingSpere()
    {
        BoundingSpere = new List<Vector4>();
        foreach (GameObject model in Models)
        {
            Mesh mesh = model.GetComponent<MeshFilter>().sharedMesh;
            float maxX = -Mathf.Infinity, maxY = -Mathf.Infinity, maxZ = -Mathf.Infinity, minX = Mathf.Infinity, minY = Mathf.Infinity, minZ = Mathf.Infinity;

            foreach (var vert in mesh.vertices)
            {
                if (vert.x > maxX) maxX = vert.x;
                if (vert.y > maxY) maxY = vert.y;
                if (vert.z > maxZ) maxZ = vert.z;
                if (vert.x < minX) minX = vert.x;
                if (vert.y < minY) minY = vert.y;
                if (vert.z < minZ) minZ = vert.z;
            }

            float x = maxX - minX;
            float y = maxY - minY;
            float z = maxZ - minZ;

            Vector3 origin = new Vector3(0.5f * (maxX + minX), 0.5f * (maxY + minY), 0.5f * (maxZ + minZ));

            float r = x > y ? x * 0.5f : y * 0.5f;
            r = r > z ? r : z * 0.5f;

            foreach (var vert in mesh.vertices)
            {
                if (Vector3.Distance(vert, origin) > r)
                    r = Vector3.Distance(vert, origin);
            }
            BoundingSpere.Add(new Vector4(origin.x, origin.y, origin.z, r));
        }
    }
}
