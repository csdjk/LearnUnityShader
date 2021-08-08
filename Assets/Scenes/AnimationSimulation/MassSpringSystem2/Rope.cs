
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 绳子
/// </summary>
public class Rope : MonoBehaviour
{
    [Range(20, 500)]
    public float looper = 64;

    [Range(0,64)]
    public int massCount = 10;

    /// 弹力系数
    [Range(0,50000)]
    public float ks = 35000;
    // 阻力系数
    [Range(0,1000)]
    public float kd = 150f;
    // 弹簧长度
    public float restLen = 1f;
    // 质点大小
    public float massSize = 0.05f;
    // 质点质量
    public float pointMass = 1f;
    public float drag = 1f;

    // 显式欧拉 或者 半隐式欧拉
    public bool isExplicit = false;

    List<Spring2> allSprings;
    Mass2[] allMass;
    private float simulateStep = 0;

    void Start()
    {
        simulateStep = 0.01f / looper;
        allMass = new Mass2[massCount];
        //创建所有质点
        for (int i = 0; i < massCount; i++)
        {
            var item = GameObject.CreatePrimitive(PrimitiveType.Sphere).AddComponent<Mass2>();
            item.transform.SetParent(transform);
            item.transform.localScale = Vector3.one * massSize;
            Destroy(item.GetComponent<Collider>());
            item.transform.localPosition = Vector3.right * restLen * i;
            allMass[i] = item;
        }
        // 创建所有弹簧 
        allSprings = new List<Spring2>();
        for (int i = 0; i < massCount - 1; i++)
        {
            var sp = allMass[i].gameObject.AddComponent<Spring2>();
            sp.mass_a = sp.GetComponent<Mass2>();
            sp.mass_b = allMass[i + 1].GetComponent<Mass2>();
            allSprings.Add(sp);
        }
        allMass[0].isStaticPos = true;
    }

    void Update()
    {
        // var dt = simulateStep;
        // SimulateEuler(dt);
        for (var i = 0; i < looper; i++)
        {
            SimulateEuler(simulateStep);
        }
    }

    /// <summary>
    /// 模拟欧拉方法
    /// </summary>
    /// <param name="dt"></param>
    public void SimulateEuler(float dt)
    {
        foreach (var spring in allSprings)
        {
            var mass_a = spring.mass_a;
            var mass_b = spring.mass_b;

            // var ks = spring.ks;
            // var kd = spring.kd;
            // var restLen = spring.restLen;
            // 弹簧的物理模型用胡克定律来描述，质点受到两个力的作用，分别是弹力和阻力

            //胡克定律  弹力 f = 弹力系数（ks） * 变形长度
            Vector3 pos_ab = mass_b.transform.position - mass_a.transform.position;
            Vector3 f_ab = ks * pos_ab.normalized * (pos_ab.magnitude - restLen);

            // 阻尼力 = -kd * Xab * dot(Xab,Vab) 
            Vector3 v_ab = mass_a.v - mass_b.v;
            Vector3 d_ab = -kd * pos_ab.normalized * Vector3.Dot(v_ab, pos_ab.normalized);

            mass_a.F += f_ab + d_ab;
            mass_b.F += -f_ab + -d_ab;
        }

        foreach (var mass in allMass)
        {
            mass.m = pointMass;
            if (mass.isStaticPos)
            {
                mass.F = Vector3.zero;
                continue;
            }

            // 重力
            mass.F += mass.m * 9.78f * Vector3.down.normalized;
            // 拉拽力（用于平衡）
            // mass.F += -mass.v.normalized * drag * Mathf.Pow(mass.v.magnitude, 2);
            mass.F += -mass.v * drag;

            var a = mass.F / mass.m;
            var v = mass.v;
            var v_nx = v + a * dt;

            // 显示欧拉方法
            if (isExplicit)
            {
                mass.v = mass.v + a * dt;
                mass.transform.position = mass.transform.position + v * dt;
            }
            // 半隐式欧拉方法
            else
            {
                mass.v = mass.v + a * dt;
                mass.transform.position = mass.transform.position + v_nx * dt;
            }
            mass.F = Vector3.zero;
        }

    }

    public void SimulateVerlet(float dt)
    {
        foreach (var spring in allSprings)
        {
            if (spring.ks != -1)
            {
                var mass_a = spring.mass_a;
                var mass_b = spring.mass_b;
                var ks = spring.ks;
                var kd = spring.kd;
                var restLen = spring.restLen;
                // 弹簧的物理模型用胡克定律来描述，质点受到两个力的作用，分别是弹力和阻力

                //胡克定律  弹力 f = 弹力系数（ks） * 变形长度(restLen)
                Vector3 pos_ab = mass_b.transform.position - mass_a.transform.position;
                Vector3 f_ab = ks * pos_ab.normalized * (pos_ab.magnitude - restLen);

                // // 阻力
                Vector3 v_ab = mass_a.v - mass_b.v;
                Vector3 d_ab = -kd * pos_ab.normalized * Vector3.Dot(v_ab, pos_ab.normalized);

                mass_a.F += f_ab;
                mass_b.F += -f_ab;

                mass_a.F += d_ab;
                mass_b.F += -d_ab;
            }
        }

        foreach (var mass in allMass)
        {
            if (mass.isStaticPos)
            {
                mass.F = Vector3.zero;
                continue;
            }
            // 重力
            mass.F += mass.m * 9.78f * Vector3.down.normalized;

            var a = mass.F / mass.m;

            Vector3 x_t0 = mass.last_position;
            Vector3 x_t1 = mass.transform.position;
            float damping = 0.00005f;
            Vector3 x_t2 = x_t1 + (1 - damping) * (x_t1 - x_t0) + a * dt * dt;

            mass.last_position = x_t1;
            mass.transform.position = x_t2;

        }

        foreach (var spring in allSprings)
        {
            var mass_a = spring.mass_a;
            var mass_b = spring.mass_b;
            var ks = spring.ks;
            var restLen = spring.restLen;

            if (ks != -1) continue;
            var d = mass_b.transform.position - mass_a.transform.position; // 1->2
            var dir = d.normalized;

            var offset1 = 0.5f * dir * (d.magnitude - restLen);
            var offset2 = -0.5f * dir * (d.magnitude - restLen);

            if (mass_a.isStaticPos && mass_b.isStaticPos) continue;

            if (mass_a.isStaticPos)
            {
                offset2 *= 2;
                offset1 = Vector3.zero;
            }
            if (mass_b.isStaticPos)
            {
                offset1 *= 2;
                offset2 = Vector3.zero;
            }

            mass_a.transform.position += offset1;
            mass_b.transform.position += offset2;
        }

    }

}