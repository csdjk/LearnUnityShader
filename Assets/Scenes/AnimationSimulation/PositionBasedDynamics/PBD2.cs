using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class PBD2 : MonoBehaviour
{
    public Transform target;//复位点
    public float mass = 0.1f;//质量
    public float powerIntensity = 5;//复位力系数
    public float dragIntensity = 0.3f;//空气阻力系数
    Vector3 v;//速度
    Vector3 virtualPos;//计算出的新位置 

    public Transform endPoint;//质心点

    void Update()
    {
        Vector3 dtPos = target.position - virtualPos;
        Vector3 f = dtPos * powerIntensity;
        //F = (1 / 2)CρSV ^ 2 空气阻力公式 简化成 dragIntensity系数 与 速度平方乘积
        Vector3 fz = -v.normalized * v.sqrMagnitude * dragIntensity;
        f += fz;

        Vector3 a = f / mass;
        v += a * Time.deltaTime;

        virtualPos += v * Time.deltaTime;
        transform.rotation = Quaternion.FromToRotation(-Vector3.up, (virtualPos + endPoint.localPosition - transform.position).normalized);//根据之前的重心位置计算 为了保持重心惯性而做的旋转
        transform.position = target.position;// 绑定挂点位置 必须每帧一致

    }
}