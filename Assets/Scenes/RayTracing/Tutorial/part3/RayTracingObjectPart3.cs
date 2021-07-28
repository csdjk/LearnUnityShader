using UnityEngine;

[RequireComponent(typeof(MeshRenderer))]
[RequireComponent(typeof(MeshFilter))]
public class RayTracingObjectPart3 : MonoBehaviour
{
    private void OnEnable()
    {
        RayTracingMasterPart3.RegisterObject(this);
    }

    private void OnDisable()
    {
        RayTracingMasterPart3.UnregisterObject(this);
    }
}