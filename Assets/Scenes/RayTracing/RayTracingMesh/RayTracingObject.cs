using System;
using UnityEngine;

[Serializable]
public struct RayTracingMaterial
{
    public Color ambientColor;
    public Color diffuseColor;
    public Color specularColor;
    public Color refractedColor;
    public Color reflectedColor;
    // 反射率
	[Range(0f, 1f)]
    public float reflectiveIndex;
    // 折射率
	[Range(0f, 5f)]
    public float refractiveIndex;
}

[RequireComponent(typeof(MeshRenderer))]
[RequireComponent(typeof(MeshFilter))]
public class RayTracingObject : MonoBehaviour
{
    [SerializeField]
    public RayTracingMaterial material;

    private void OnEnable()
    {
        RayTracingMaster.RegisterObject(this);
    }

    private void OnDisable()
    {
        RayTracingMaster.UnregisterObject(this);
    }
}