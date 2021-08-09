using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class PBDTest : MonoBehaviour
{

    public Transform target;//绑定点
    public Transform endPoint;//质心点


    public float mass = 0.1f;//质量
    public float powerIntensity = 5;//复位力系数
    public float dragIntensity = 0.3f;//空气阻力系数
    Vector3 v;
    Vector3 virtualPos;

    public Vector3 windForce;//测试风力

    // Update is called once per frame
    void Update()
    {

        Vector3 dtPos = target.position - virtualPos;
        Vector3 f = dtPos * powerIntensity;
        //F = (1 / 2)CρSV ^ 2
        Vector3 fz = -v.normalized * v.sqrMagnitude * dragIntensity;
        f += fz;
        f += windForce * Random.Range(-0.4f, 1.0f);//模拟简单风力

        Vector3 a = f / mass;
        v += a * Time.deltaTime;


        virtualPos += v * Time.deltaTime;

        transform.rotation = Quaternion.FromToRotation(-Vector3.up, (virtualPos + endPoint.localPosition - transform.position).normalized);

        transform.position = target.position;
    }
}