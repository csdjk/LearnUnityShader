//-----------------------------------------------【脚本说明】-------------------------------------------------------
//      脚本功能：   在游戏运行时显示帧率相关信息
//      使用语言：   C#
//      开发所用IDE版本：Unity4.5 06f 、Visual Studio 2010    
//      2014年10月 Created by 浅墨    
//      更多内容或交流请访问浅墨的博客：http://blog.csdn.net/poem_qianmo
//---------------------------------------------------------------------------------------------------------------------

//-----------------------------------------------【使用方法】-------------------------------------------------------
//      方法一：在Unity中拖拽此脚本到场景主摄像机之上
//      方法二：在Inspector中[Add Component]->[浅墨's Toolkit]->[ShowFPS]
//---------------------------------------------------------------------------------------------------------------------


using UnityEngine;
using System.Collections;


//添加组件菜单
[AddComponentMenu("浅墨's Toolkit/ShowFPS")]

[ExecuteInEditMode]
//开始ShowFPS类
public class ShowFPS : MonoBehaviour
{
    private static int count = 0;//用于控制帧率的显示速度的count
    private static float milliSecond = 0;//毫秒数
    private static float fps = 0;//帧率值
    private static float deltaTime = 0.0f;//用于显示帧率的deltaTime


    //OnGUI函数
    void OnGUI()
    {
        //左上方帧数显示
        if (++count > 10)
        {
            count = 0;
            milliSecond = deltaTime * 1000.0f;
            fps = 1.0f / deltaTime;
        }
        string text = string.Format(" 当前每帧渲染间隔：{0:0.0} ms ({1:0.} 帧每秒)", milliSecond, fps);
        GUILayout.Label(text);
    }

    //Update函数
    void Update()
    {
        //帧数显示的计时delataTime
        deltaTime += (Time.deltaTime - deltaTime) * 0.1f;
    }
}
