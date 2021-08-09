
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 质点 (显式欧拉方法求解)
/// </summary>
public class Mass2 : MonoBehaviour
{
    public float m = 1f;
    public Vector3 F;
    public Vector3 v;
    public bool isStaticPos = false;

    public Vector3 last_position;

    void Start()
    {
        v = F = Vector3.zero;
        last_position = Vector3.zero;
    }
}
