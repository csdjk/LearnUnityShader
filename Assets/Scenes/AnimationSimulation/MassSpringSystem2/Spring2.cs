using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 弹簧
/// </summary>
public class Spring2 : MonoBehaviour
{
    // 质点A
    public Mass2 mass_a;
    // 质点B
    public Mass2 mass_b;
    /// 弹力系数
    public float ks = 35000;
    // 阻力系数
    public float kd = 150f;
    // 变形长度
    public float restLen = 1f;
}
