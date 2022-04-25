using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AutoRandomMove : MonoBehaviour
{
    public Vector3 rangeMin;
    public Vector3 rangeMax;
    [Range(0.1f,100)]
    public float speed = 1;

    private Vector3 currentTarget;
    private Vector3 currentPos;
    private float moveTime;
    private float time;
    private float speedCache;
    void Start()
    {
        ResetPosition();
    }

    void ResetPosition()
    {
        currentTarget = new Vector3(Random.Range(rangeMin.x, rangeMax.x), Random.Range(rangeMin.y, rangeMax.y), Random.Range(rangeMin.z, rangeMax.z));
        currentPos = transform.localPosition;
        moveTime = 10 / speed * Vector3.Distance(currentTarget, currentPos);
        time = 0;
        speedCache = speed;
    }


    void Update()
    {
        time += Time.deltaTime;
        if (time > moveTime)
        {
            ResetPosition();
        }
        if(speed != speedCache){
            ResetPosition();
        }
        float lerpValue = time / moveTime;
        Vector3 newPos = Vector3.Lerp(currentPos, currentTarget, lerpValue);
        transform.localPosition = newPos;
    }
}
