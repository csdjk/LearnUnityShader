
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 绳子
/// </summary>
public class DemoLine1 : MonoBehaviour
{
    public float simulateStep = 0.01f;
    public int massCount = 5;
    List<Spring1> allSprings;
    Mass1[] allMass;
    void Start()
    {
        allMass = new Mass1[massCount];
        float disStep = 0.1f;
        float massSize = 0.05f;
        //创建所有质点
        for (int i = 0; i < massCount; i++)
        {
            var item = GameObject.CreatePrimitive(PrimitiveType.Sphere).AddComponent<Mass1>();
            item.transform.SetParent(transform);
            item.transform.localScale = Vector3.one * massSize;
            Destroy(item.GetComponent<Collider>());
            item.transform.localPosition = Vector3.right * disStep * i;
            allMass[i] = item;
        }
        // 创建所有弹簧 
        //分开循环写是因为 2，3维度连接的时候 需要依赖 后创建的质点
        allSprings = new List<Spring1>();
        for (int i = 0; i < massCount - 1; i++)
        {
            var sp = allMass[i].gameObject.AddComponent<Spring1>();
            sp.mass_a = sp.GetComponent<Mass1>();
            sp.mass_b = allMass[i + 1].GetComponent<Mass1>();
            allSprings.Add(sp);
        }
        allMass[0].isStaticPos = true;
    }

    void Update()
    {
        var dt = simulateStep;

        for (int i = 0, len = allSprings.Count; i < len; i++)
        {
            allSprings[i].Simulate();//产生所有弹簧力

        }
        for (int i = 0; i < massCount; i++)
        {
            allMass[i].Simulate(dt);//计算这一帧所有合力 质点运动变化
        }
    }
}