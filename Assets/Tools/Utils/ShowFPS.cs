using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class ShowFPS : MonoBehaviour
{
    private static int count = 0;//用于控制帧率的显示速度的count
    private static float milliSecond = 0;//毫秒数
    private static float fps = 0;//帧率值
    private static float deltaTime = 0.0f;//用于显示帧率的deltaTime


    string fpsInfo;
    string systemInfoLabel;
    public Rect rect = new Rect(10, 100, 300, 300);

    GUIContent systemInfoContent = new GUIContent("info");
    //OnGUI函数
    void OnGUI()
    {
        if (++count > 20)
        {
            count = 0;
            milliSecond = deltaTime * 1000.0f;
            fps = Mathf.Round(1.0f / deltaTime);
        }
        fpsInfo = $"FPS:{fps}   Time:{milliSecond}";
        GUILayout.Label(fpsInfo, GUI.skin.box);

        systemInfoContent.text = systemInfoLabel;
        GUILayout.Label(systemInfoContent, GUI.skin.box);
    }

    void Update()
    {
        deltaTime += (Time.deltaTime - deltaTime) * 0.1f;

        //获取参数信息
        systemInfoLabel = " CPU型号：" + SystemInfo.processorType + "\n (" + SystemInfo.processorCount +
               " cores核心数, " + SystemInfo.systemMemorySize + "MB RAM内存)\n " + "\n 显卡型号：" + SystemInfo.graphicsDeviceName + "\n " +
               Screen.width + "x" + Screen.height + " @" + Screen.currentResolution.refreshRate +
               " (" + SystemInfo.graphicsMemorySize + "MB VRAM显存)";
    }
}
