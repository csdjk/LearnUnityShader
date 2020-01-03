using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class Ghost : MonoBehaviour {

    public Material mat;
    [Range(1,100)]
    public float power = 1.0f;

    private Vector3 prevPos;
    private Vector3 dir;
    void Start () {
        transform.position = Vector3.zero;
        prevPos = transform.position;
    }

    // Update is called once per frame
    void Update () {
        dir = prevPos - transform.position;
        mat.SetVector("_Direction",dir.normalized);
        mat.SetFloat("_Power",dir.magnitude*power);
        prevPos = transform.position;
    }
}