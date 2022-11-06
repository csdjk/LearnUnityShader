using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteAlways]
public class CameraDir : MonoBehaviour
{
    // Start is called before the first frame update
    private void OnEnable() {
        Debug.Log(transform.forward);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
