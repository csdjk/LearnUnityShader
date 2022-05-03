using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class Ghost : MonoBehaviour
{

    // public Material mat;
    [Header("残影强度")]
    [Range(1, 10)]
    public float power = 1.0f;
    [Header("残影颜色")]
    public Color ghostColor = Color.red;
    // 子渲染器集合
    private Renderer[] renderers;
    // 上一次位置
    private Vector3 prevPos;
    // 残影方向
    private Vector3 dir;
    void Start()
    {
        // transform.position = Vector3.zero;
        prevPos = transform.position;
        // 获取所有子渲染器
        renderers = transform.GetComponentsInChildren<Renderer>();
    }

    // Update is called once per frame
    void Update()
    {
        // 残影方向，即移动的反方向。
        dir = prevPos - transform.position;
        // if (dir.magnitude <= 0)
        //     return;
        Debug.Log("prevPos"+prevPos);
        Debug.Log("transform.position"+transform.position);
        Debug.Log("dir"+dir.normalized);
        for (int i = 0; i < renderers.Length; i++)
        {
            Material mat = renderers[i].sharedMaterial;
            //设置方向,并且归一化
            mat.SetVector("_Direction", dir.normalized);
            //设置强度, 即 速度越快,残影越长
            mat.SetFloat("_Power", dir.magnitude * power);
            // 设置颜色
            mat.SetColor("_GhostColor", ghostColor);
        }

        //存储当前位置
        prevPos = transform.position;
    }
}