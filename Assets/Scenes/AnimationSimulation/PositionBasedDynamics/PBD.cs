using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class PBD : MonoBehaviour
{
    public Transform target;//复位点
    public float mass = 0.1f;//质量
    public float powerIntensity = 5;//复位力系数
    public float dragIntensity = 0.3f;//空气阻力系数
    Vector3 v;//速度
    Vector3 virtualPos;//计算出的新位置 


    void Update()
    {
        Vector3 dtPos = target.position - virtualPos;
        Vector3 f = dtPos * powerIntensity;//复位力
        //F = (1 / 2)CρSV ^ 2 空气阻力公式 简化成 dragIntensity系数 与 速度平方乘积
        Vector3 fz = -v.normalized * v.sqrMagnitude * dragIntensity;//空气阻力
        f += fz;//最终合力
        Vector3 a = f / mass;//瞬时加速度=作用力/质量
        v += a * Time.deltaTime;//瞬时速度+=瞬时加速度
        virtualPos += v * Time.deltaTime;//位移+=瞬时速度*瞬时作用时间；
        transform.position = virtualPos;

    }
}