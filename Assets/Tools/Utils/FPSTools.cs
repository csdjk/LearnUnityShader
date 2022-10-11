using System.Collections.Generic;
using System.Text;
using Unity.Profiling;
using UnityEngine;

[ExecuteAlways]
public class FPSTools : MonoBehaviour
{
    public int targetFrameRate = 300;

    // GUI
    public Vector2 uiBoxSize = new Vector2(200, 200);
    public Vector2 uiBoxOffset = new Vector2(50, 50);
    [Range(10, 100)]
    public int fpsFontSize = 25;
    [Range(10, 100)]
    public int infoFontSize = 20;
    private Rect uiBoxRect;



    string statsText;
    StringBuilder statsSB;
    string systemInfoText;
    StringBuilder systemInfoSB;

#if UNITY_2020_2_OR_NEWER
    ProfilerRecorder systemMemoryRecorder;
    ProfilerRecorder gcMemoryRecorder;
    ProfilerRecorder mainThreadTimeRecorder;
    ProfilerRecorder setPassCallsRecorder;
    ProfilerRecorder drawCallsRecorder;
    ProfilerRecorder verticesRecorder;

    static double GetRecorderFrameAverage(ProfilerRecorder recorder)
    {
        var samplesCount = recorder.Capacity;
        if (samplesCount == 0)
            return 0;

        double r = 0;
        unsafe
        {
            var samples = stackalloc ProfilerRecorderSample[samplesCount];
            recorder.CopyTo(samples, samplesCount);
            for (var i = 0; i < samplesCount; ++i)
                r += samples[i].Value;
            r /= samplesCount;
        }

        return r;
    }
#else
    private int count = 0;
    private float time = 0;
    private float fps = 0;
    private float deltaTime = 0.0f;

#endif

    void OnEnable()
    {
        Application.targetFrameRate = targetFrameRate;
        QualitySettings.vSyncCount = 1;

#if UNITY_2020_2_OR_NEWER

        mainThreadTimeRecorder = ProfilerRecorder.StartNew(ProfilerCategory.Internal, "Main Thread", 15);
        systemMemoryRecorder = ProfilerRecorder.StartNew(ProfilerCategory.Memory, "System Used Memory");
        gcMemoryRecorder = ProfilerRecorder.StartNew(ProfilerCategory.Memory, "GC Reserved Memory");

        setPassCallsRecorder = ProfilerRecorder.StartNew(ProfilerCategory.Render, "SetPass Calls Count");
        drawCallsRecorder = ProfilerRecorder.StartNew(ProfilerCategory.Render, "Draw Calls Count");
        verticesRecorder = ProfilerRecorder.StartNew(ProfilerCategory.Render, "Vertices Count");
#endif

        statsSB = new StringBuilder(500);
        systemInfoSB = new StringBuilder(500);
    }

    void OnValidate()
    {
        Application.targetFrameRate = targetFrameRate;
    }

    void OnDisable()
    {
#if UNITY_2020_2_OR_NEWER
        systemMemoryRecorder.Dispose();
        gcMemoryRecorder.Dispose();
        mainThreadTimeRecorder.Dispose();
         setPassCallsRecorder.Dispose();
        drawCallsRecorder.Dispose();
        verticesRecorder.Dispose();
#endif

    }

    void Update()
    {
        statsSB.Clear();
#if UNITY_2020_2_OR_NEWER
        var time = GetRecorderFrameAverage(mainThreadTimeRecorder) * (1e-6f);
        statsSB.AppendLine($"\n FPS: {1000 / time:F1} ");
        statsSB.AppendLine($"Frame Time: {time:F1} ms");
        statsSB.AppendLine($"GC Memory: {gcMemoryRecorder.LastValue / (1024 * 1024)} MB");
        statsSB.AppendLine($"System Memory: {systemMemoryRecorder.LastValue / (1024 * 1024)} MB");
        statsSB.AppendLine($"SetPass Calls: {setPassCallsRecorder.LastValue}");
        statsSB.AppendLine($"Draw Calls: {drawCallsRecorder.LastValue}");
        statsSB.AppendLine($"Vertices: {verticesRecorder.LastValue}");
     
#else
        deltaTime += (Time.deltaTime - deltaTime) * 0.1f;

        if (++count > 20)
        {
            count = 0;
            time = deltaTime * 1000.0f;
            fps = 1.0f / deltaTime;
        }
        statsSB.AppendLine($"\n FPS: {fps:F1} ");
        statsSB.AppendLine($"Frame Time: {time:F1} ms");
#endif

        statsText = statsSB.ToString();


        // 硬件信息
        systemInfoSB.Clear();
        systemInfoSB.AppendLine("\n CPU型号：");
        systemInfoSB.AppendLine($"{SystemInfo.processorType}");
        systemInfoSB.AppendLine($" ({SystemInfo.processorCount} cores核心数, {SystemInfo.systemMemorySize}MB RAM内存)");
        systemInfoSB.AppendLine("\n 显卡型号：");
        systemInfoSB.AppendLine($"{SystemInfo.graphicsDeviceName}");
        systemInfoSB.AppendLine($"{Screen.width}x{Screen.height} @{Screen.currentResolution.refreshRate} ({SystemInfo.graphicsMemorySize} MB VRAM显存)");
        systemInfoText = systemInfoSB.ToString();
    }

    void OnGUI()
    {
        uiBoxRect = new Rect(uiBoxOffset.x, uiBoxOffset.y, uiBoxSize.x, uiBoxSize.y);
        GUILayout.BeginArea(uiBoxRect, GUI.skin.box);
        // 水平居中
        GUI.skin.box.alignment = TextAnchor.MiddleCenter;

        GUI.skin.box.fontSize = fpsFontSize;
        GUILayout.Box(statsText, GUILayout.Height(uiBoxSize.y * 0.3f));

        GUI.skin.box.fontSize = infoFontSize;
        GUILayout.Box(systemInfoText, GUILayout.Height(uiBoxSize.y * 0.7f - 15));
        GUILayout.EndArea();

    }
}