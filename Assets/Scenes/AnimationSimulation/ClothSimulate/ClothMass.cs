
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 质点
/// </summary>
public class ClothMass : MonoBehaviour
{
    public float m = 0.1f;
    public Vector3 F;
    public Vector3 v;
    public bool isStaticPos = false;
    public float drag = 0.4f;

    private Material mat;
    private Vector3 externalForce = Vector3.zero;
    private Vector3 randomForce = Vector3.zero;
    private Vector3 randomFactor = Vector3.zero;

    void Start()
    {
        v = F = Vector3.zero;
        mat = GetComponent<Renderer>().material;
    }



    public void Simulate(float dt)
    {

        if (isStaticPos)
        {
            F = Vector3.zero;
            return;
        }
        // 重力 f = mg 
        F += m * 9.78f * Vector3.down.normalized;
        //  拉拽力（用于平衡）
        // F += -v.normalized * drag * Mathf.Pow(v.magnitude, 2);
        F += -v * drag;
        // 外力
        F += externalForce;
        // 随机力
        // Vector3 ranForce = new Vector3(randomForce.x * randomFactor.x, randomForce.y * randomFactor.y, randomForce.z * randomFactor.z);
        // Vector3 ranForce = new Vector3(Random.Range(-10,10),0,0);
        F += randomForce;

        // 与碰撞球体检测
        var clds = Physics.OverlapSphere(transform.position, 0.001f);
        if (clds.Length > 0)
        {
            float disCld = Vector3.Distance(transform.position, clds[0].transform.position);
            float inDis = 0;

            Vector3 dirPush = (transform.position - clds[0].transform.position).normalized;
            if (clds[0] is SphereCollider)
            {
                inDis = (clds[0] as SphereCollider).radius - disCld;
            }
            if (inDis > 0) F += dirPush * inDis * inDis * 100000;
        }

        // 半隐式欧拉方法（explicit Euler method）
        // v(i+1) = v(i) + a(i) * dt
        // x(i+1) = x(i) + v(i+1) * dt
        // 即下一时刻的速度和位移完全由上一个时刻得出
        Vector3 a = F / m;
        v += dt * a;

        // 碰撞检测
        RaycastHit hit;
        if (Physics.SphereCast(transform.position, 0.01f, v.normalized, out hit, dt * v.magnitude * 1.5f))
        {
            v = Vector3.Reflect(v.normalized, hit.normal) * v.magnitude * 0.5f * Mathf.Clamp01(hit.distance * 300);
            if (v.magnitude < 0.01f)
            {
                v = Vector3.zero;
            }
        }

        Vector3 s = dt * v;
        transform.position += s;
        F = Vector3.zero;
    }


    public void SetColor(Color color)
    {
        mat.color = color;
    }

    // 设置外力（风力、拉力等）
    public void SetExternalForce(Vector3 force)
    {
        externalForce = force;
    }

    // 随机力
    public void SetRandomForce(Vector3 force)
    {
        randomForce = force;
    }
    public void SetRandomFactor(Vector3 factor)
    {
        randomFactor = factor;
    }
}
