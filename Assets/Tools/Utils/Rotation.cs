using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotation : MonoBehaviour
{
    public GameObject target;
    public float speed = 10f;

    // Update is called once per frame
    void Update()
    {
        // 绕目标为中心旋转
        if (target)
        {
            transform.RotateAround(target.transform.position, Vector3.up, speed * Time.deltaTime);
        }
        //  绕自身中心旋转
        else
        {
            transform.RotateAround(transform.position, Vector3.up, speed * Time.deltaTime);
        }
    }
}
