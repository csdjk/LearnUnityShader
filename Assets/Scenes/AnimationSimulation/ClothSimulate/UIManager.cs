using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UIManager : MonoBehaviour
{
    public InputField inputField;
    public Cloth cloth;
    // Start is called before the first frame update
    void Start()
    {
        inputField.onEndEdit.AddListener((value) =>
        {
            print(inputField.name + "的值为" + value);
            cloth.ChangeSpringKs(Convert.ToSingle(value));
        });
    }


}
