using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class RenderCubeMap : ScriptableWizard
{
    public Transform renderTrans;
    public Cubemap cubemap;

    [MenuItem("LCLTools/CreateCubemap")]
    static void CreateCubemap()
    {
        //"Create Cubemap"是打开的窗口名，"Create"是按钮名，点击时调用OnWizardCreate()方法
        ScriptableWizard.DisplayWizard<RenderCubeMap>("Create Cubemap", "Create");//打开向导
    }

    private void OnWizardUpdate()//打开向导或者在向导中更改了其他内容的时候调用
    {
        helpString = "选择渲染位置并且确定需要设置的cubemap";
        isValid = renderTrans != null && cubemap != null;//isValid为true的时候，“Create”按钮才能点击
    }

    private void OnWizardCreate()//点击创建按钮时调用
    {
        GameObject go = new GameObject();
        go.transform.position = renderTrans.position;
        Camera camera = go.AddComponent<Camera>();
        camera.RenderToCubemap(cubemap);//用户提供的Cubemap传递给RenderToCubemap函数，生成六张图片
        DestroyImmediate(go);//立即摧毁go
    }
}

