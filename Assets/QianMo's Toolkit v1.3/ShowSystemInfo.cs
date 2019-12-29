//-----------------------------------------------【脚本说明】-------------------------------------------------------
//      脚本功能：   在游戏运行时显示系统CPU、显卡信息
//      使用语言：   C#
//      开发所用IDE版本：Unity4.5 06f 、Visual Studio 2010    
//      2014年12月 Created by 浅墨    
//      更多内容或交流，请访问浅墨的博客：http://blog.csdn.net/poem_qianmo
//---------------------------------------------------------------------------------------------------------------------

//-----------------------------------------------【使用方法】-------------------------------------------------------
//      方法一：在Unity中拖拽此脚本到场景主摄像机之上
//      方法二：在Inspector中[Add Component]->[浅墨's Toolkit]->[ShowSystemInfo]
//---------------------------------------------------------------------------------------------------------------------


using UnityEngine;
using System.Collections;


//添加组件菜单
[AddComponentMenu("浅墨's Toolkit/ShowSystemInfo")]

[ExecuteInEditMode]
public class ShowSystemInfo : MonoBehaviour
{

    string systemInfoLabel;
    public Rect rect = new Rect(10, 100, 300, 300);

    void OnGUI()
    {
        //在指定位置输出参数信息
        GUI.Label(rect, systemInfoLabel);
    }

    void Update()
    {
        //获取参数信息
        systemInfoLabel = " \n\n\nCPU型号：" + SystemInfo.processorType + "\n (" + SystemInfo.processorCount +
               " cores核心数, " + SystemInfo.systemMemorySize + "MB RAM内存)\n " + "\n 显卡型号：" + SystemInfo.graphicsDeviceName + "\n " +
               Screen.width + "x" + Screen.height + " @" + Screen.currentResolution.refreshRate +
               " (" + SystemInfo.graphicsMemorySize + "MB VRAM显存)";
    }
}
