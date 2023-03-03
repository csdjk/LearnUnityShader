using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace LcLTools
{
    public class Dissolve : MonoBehaviour
    {

        void Start()
        {
            Material mat = GetComponent<MeshRenderer>().material;
            mat.SetFloat("_MaxDistance", CalculateMaxDistance());

        }

        float CalculateMaxDistance()
        {
            float maxDistance = 0;
            Vector3[] vertices = GetComponent<MeshFilter>().mesh.vertices;
            for (int i = 0; i < vertices.Length; i++)
            {
                Vector3 v1 = vertices[i];
                for (int k = 0; k < vertices.Length; k++)
                {
                    if (i == k) continue;

                    Vector3 v2 = vertices[k];
                    float mag = (v1 - v2).magnitude;
                    if (maxDistance < mag) maxDistance = mag;
                }
            }
            Debug.Log(maxDistance);
            return maxDistance;
        }
    }
}