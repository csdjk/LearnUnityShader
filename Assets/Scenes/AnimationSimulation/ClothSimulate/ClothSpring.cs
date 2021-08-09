using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 弹簧
/// </summary>
public class ClothSpring : MonoBehaviour
{
    // 质点A
    public ClothMass mass_a;
    // 质点B
    public ClothMass mass_b;
    /// 弹力系数
    public float ks = 300;
    // 阻力系数
    public float kd = 0.4f;
    // 变形长度
    public float restLen = 0.05f;


    public float ksPercent = 1f;
    public float lenPercent = 1f;

    public void Simulate()
    {
        // 弹簧的物理模型用胡克定律来描述，质点受到两个力的作用，分别是弹力和阻力

        //胡克定律  弹力 f = 弹力系数（ks） * 变形长度(restLen)
        Vector3 pos_ab = mass_b.transform.position - mass_a.transform.position;
        Vector3 f_ab = ks * pos_ab.normalized * (pos_ab.magnitude - restLen);

        // 阻尼力 = -kd * Xab * dot(Xab,Vab) 
        Vector3 v_ab = mass_a.v - mass_b.v;
        Vector3 d_ab = -kd * pos_ab.normalized * Vector3.Dot(v_ab, pos_ab.normalized);

        // 质点受到的 合力 = 弹力 + 阻力
        mass_a.F += f_ab + d_ab;
        mass_b.F += (-f_ab) + (-d_ab);
    }

    // 系数比率
    public void SetPercent(float ksPercentValue, float lenPercentValue)
    {
        ksPercent = ksPercentValue;
        lenPercent = lenPercentValue;
        SetParams(ks,restLen);
    }
    /// <summary>
    /// 设置弹簧系数、自然长度
    /// </summary>
    /// <param name="ksValue"></param>
    /// <param name="lenValue"></param>
    public void SetParams(float ksValue, float lenValue)
    {
        ks = ksPercent * ksValue;
        restLen = lenPercent * lenValue;
    }

}
