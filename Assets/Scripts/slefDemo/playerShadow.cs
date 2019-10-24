using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class playerShadow : MonoBehaviour
{
    
    public GameObject shadow;
    void Start()
    {
        if (!shadow)
        {
            return;
        }

        var shadowMat = shadow.GetComponent<SpriteRenderer>().material;
        var heroTex = GetComponent<SpriteRenderer>().sprite.texture;
        shadowMat.SetTexture("_HeroTex",heroTex);
    }

    

    // Update is called once per frame
    void Update()
    {
        
    }
}
