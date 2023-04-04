using System.Collections.Generic;
using System.Text;
using Unity.Profiling;
using UnityEngine;
using UnityEngine.Experimental.Rendering;

namespace LcLTools
{
    [AddComponentMenu("LcLTools/LcLProfiler")]
    [ExecuteAlways]
    public class LcLProfiler : MonoBehaviour
    {
        static int windowID = 100;

        public int targetFrameRate = 300;

        // GUI
        public float boxWidth = 300;
        public float fpsBoxHeight = 200;
        [Range(10, 100)]
        public int fpsFontSize = 25;

        public float infoBoxHeight = 200;

        [Range(10, 100)]
        public int infoFontSize = 20;

        public float powerBoxHeight = 200;
        [Range(10, 100)]
        public int powerSize = 20;

        public bool cpuGpuInfoActive = true;
        public bool powerActive = false;

        public bool GCMemoryActive = false;
        public bool systemMemoryActive = false;
        public bool setPassCallsActive = false;
        public bool drawCallsActive = false;
        public bool trianglesActive = false;
        public bool verticesActive = false;


        private Rect uiBoxRect;



        string statsText;
        StringBuilder statsSB;
        string systemInfoText;
        StringBuilder systemInfoSB;
        string powerText;
        StringBuilder powerSB;

        // -----------------------------------SRP Batcher Profiler-----------------------------------
        SRPBatcherProfiler srpBatcherProfiler;
        public bool enableSRPBatcherProfiler = false;
        public Vector2 srpBoxSize = new Vector2(600, 250);
        public float srpBoxHeight = 200;

        [Range(10, 100)]
        public int srpFontSize = 20;

        // -----------------------------------SRP Batcher Profiler-----------------------------------
#if UNITY_2020_2_OR_NEWER
        ProfilerRecorder systemMemoryRecorder;
        ProfilerRecorder gcMemoryRecorder;
        ProfilerRecorder mainThreadTimeRecorder;
        ProfilerRecorder setPassCallsRecorder;
        ProfilerRecorder drawCallsRecorder;
        ProfilerRecorder verticesRecorder;
        ProfilerRecorder trianglesRecorder;

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
        private void Awake()
        {
            if (Application.isPlaying)
            {
                DontDestroyOnLoad(gameObject);
            }
        }

        void OnEnable()
        {
            Init();
        }

        void OnValidate()
        {
            Init();
        }

        void Init()
        {
            if (uiBoxRect == null)
            {
                uiBoxRect = new Rect(0, 0, boxWidth, fpsBoxHeight);
            }


            Application.targetFrameRate = targetFrameRate;
            // QualitySettings.vSyncCount = 1;

#if UNITY_2020_2_OR_NEWER
            mainThreadTimeRecorder = ProfilerRecorder.StartNew(ProfilerCategory.Internal, "Main Thread", 15);
            if (systemMemoryActive)
                systemMemoryRecorder = ProfilerRecorder.StartNew(ProfilerCategory.Memory, "System Used Memory");
            if (GCMemoryActive)
                gcMemoryRecorder = ProfilerRecorder.StartNew(ProfilerCategory.Memory, "GC Reserved Memory");
            if (setPassCallsActive)
                setPassCallsRecorder = ProfilerRecorder.StartNew(ProfilerCategory.Render, "SetPass Calls Count");
            if (drawCallsActive)
                drawCallsRecorder = ProfilerRecorder.StartNew(ProfilerCategory.Render, "Draw Calls Count");
            if (verticesActive)
                verticesRecorder = ProfilerRecorder.StartNew(ProfilerCategory.Render, "Vertices Count");
            if (trianglesActive)
                trianglesRecorder = ProfilerRecorder.StartNew(ProfilerCategory.Render, "Triangles Count");
#endif

            statsSB = new StringBuilder(500);
            systemInfoSB = new StringBuilder(500);
            powerSB = new StringBuilder(500);
            srpBatcherProfiler = new SRPBatcherProfiler();
        }

        void Clean()
        {
            statsSB.Clear();
            statsSB = null;
            systemInfoSB.Clear();
            systemInfoSB = null;
            powerSB.Clear();
            powerSB = null;
#if UNITY_2020_2_OR_NEWER
            mainThreadTimeRecorder.Dispose();
            if (systemMemoryActive)
                systemMemoryRecorder.Dispose();
            if (GCMemoryActive)
                gcMemoryRecorder.Dispose();
            if (setPassCallsActive)
                setPassCallsRecorder.Dispose();
            if (drawCallsActive)
                drawCallsRecorder.Dispose();
            if (verticesActive)
                verticesRecorder.Dispose();
            if (trianglesActive)
                trianglesRecorder.Dispose();
#endif
        }

        void OnDisable()
        {
            Clean();
            srpBatcherProfiler = null;
        }

        float e = 0;
        float t = 0f;


        void Update()
        {
            srpBatcherProfiler.Update();

            var interval = Time.time - t;
            if (interval > 1f)
            {
                t = Time.time;
                e = Power.electricity;
            }


#if UNITY_2020_2_OR_NEWER
            if (interval > 0.1f)
            {
                t = Time.time;

                statsSB.Clear();
                var time = GetRecorderFrameAverage(mainThreadTimeRecorder) * (1e-6f);
                statsSB.AppendLine($"\n FPS: {1000 / time:F1} ");
                statsSB.AppendLine($"Frame Time: {time:F1} ms");

                if (GCMemoryActive)
                    statsSB.AppendLine($"GC Memory: {gcMemoryRecorder.LastValue / (1024 * 1024)} MB");
                if (systemMemoryActive)
                    statsSB.AppendLine($"System Memory: {systemMemoryRecorder.LastValue / (1024 * 1024)} MB");
                if (setPassCallsActive)
                    statsSB.AppendLine($"SetPass Calls: {setPassCallsRecorder.LastValue}");
                if (drawCallsActive)
                    statsSB.AppendLine($"Draw Calls: {drawCallsRecorder.LastValue}");
                if (verticesActive)
                    statsSB.AppendLine($"Vertices: {verticesRecorder.LastValue}");
                if (trianglesActive)
                    statsSB.AppendLine($"Triangles: {trianglesRecorder.LastValue}");
            }

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
            if (cpuGpuInfoActive)
            {
                systemInfoSB.Clear();
                systemInfoSB.AppendLine("\n CPU型号：");
                systemInfoSB.AppendLine($"{SystemInfo.processorType}");
                systemInfoSB.AppendLine($" ({SystemInfo.processorCount} cores核心数, {SystemInfo.systemMemorySize}MB RAM内存)");
                systemInfoSB.AppendLine("\n 显卡型号：");
                systemInfoSB.AppendLine($"{SystemInfo.graphicsDeviceName}");
                systemInfoSB.AppendLine($"{Screen.width}x{Screen.height} @{Screen.currentResolution.refreshRate} ({SystemInfo.graphicsMemorySize} MB VRAM显存)");
                systemInfoText = systemInfoSB.ToString();
            }

            if (powerActive)
            {
                powerSB.Clear();
                powerSB.AppendLine($"电池总容量{Power.capacity}毫安,电压{Power.voltage}伏");
                powerSB.AppendLine($"实时电流{e}毫安,实时功率{(int)(e * Power.voltage)}");
                powerSB.AppendLine($"满电量能玩{((Power.capacity / e).ToString("f2"))}小时");
                powerText = powerSB.ToString();
            }
        }
        private Rect uiBoxRect2;

        void OnGUI()
        {
            if (uiBoxRect == null)
            {
                return;
            }
            uiBoxRect = GUI.Window(windowID, uiBoxRect, WindowCallBack, "");

            var infoBoxH = cpuGpuInfoActive ? infoBoxHeight : 0;
            var powerBoxH = powerActive ? powerBoxHeight : 0;
            var srpBoxH = enableSRPBatcherProfiler ? srpBoxHeight : 0;

            uiBoxRect.width = boxWidth;
            uiBoxRect.height = fpsBoxHeight + infoBoxH + powerBoxH + srpBoxH + 40;


        }

        private void WindowCallBack(int windowID)
        {
            GUILayout.BeginVertical();
            {
                // 水平居中
                GUI.skin.box.alignment = TextAnchor.MiddleCenter;
                GUI.skin.box.fontSize = fpsFontSize;
                GUILayout.Box(statsText, GUILayout.Height(fpsBoxHeight));

                if (cpuGpuInfoActive)
                {
                    GUI.skin.box.fontSize = infoFontSize;
                    GUILayout.Box(systemInfoText, GUILayout.Height(infoBoxHeight));
                }

                if (powerActive)
                {
                    GUI.skin.box.fontSize = powerSize;
                    GUILayout.Box(powerText, GUILayout.Height(powerBoxHeight));
                }


                if (enableSRPBatcherProfiler)
                {
                    GUI.skin.box.fontSize = srpFontSize;
                    GUI.skin.box.alignment = TextAnchor.MiddleLeft;
                    GUILayout.Box(srpBatcherProfiler.ToString(), GUILayout.Height(srpBoxHeight));
                }
            }
            GUILayout.EndVertical();


            GUI.DragWindow(new Rect(0, 0, Screen.width, Screen.height));
        }
    }


    public class Power
    {

        static public float electricity
        {
            get
            {
#if UNITY_ANDROID && !UNITY_EDITOR
            //获取电流（微安），避免频繁获取，取一次大概2毫秒
            float electricity = (float)manager.Call<int>("getIntProperty", PARAM_BATTERY);
            //小于1W就认为它的单位是毫安，否则认为是微安
            return ToMA(electricity);
#else
                return -1f;
#endif
            }
        }
        //获取电压 伏
        static public float voltage { get; private set; }

        //获取电池总容量 毫安
        static public int capacity { get; private set; }

        //获取实时电流参数
        static object[] PARAM_BATTERY = new object[] { 2 }; //BatteryManager.BATTERY_PROPERTY_CURRENT_NOW)
        static AndroidJavaObject manager;
        static Power()
        {
#if UNITY_ANDROID && !UNITY_EDITOR
        AndroidJavaClass unityPlayer = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
        AndroidJavaObject currActivity = unityPlayer.GetStatic<AndroidJavaObject>("currentActivity");
        manager = currActivity.Call<AndroidJavaObject>("getSystemService", new object[] { "batterymanager" });
        capacity = (int)(ToMA((float)manager.Call<int>("getIntProperty", new object[] { 1 })) / ((float)manager.Call<int>("getIntProperty", new object[] { 4 }) / 100f));   //BATTERY_PROPERTY_CHARGE_COUNTER 1 BATTERY_PROPERTY_CAPACITY 4

        AndroidJavaObject receive = currActivity.Call<AndroidJavaObject>("registerReceiver", new object[] { null, new AndroidJavaObject("android.content.IntentFilter", new object[] { "android.intent.action.BATTERY_CHANGED" }) });
        if (receive != null)
        {
            voltage = (float)receive.Call<int>("getIntExtra", new object[] { "voltage", 0 }) / 1000f; //BatteryManager.EXTRA_VOLTAGE
        }
#endif
        }

        static float ToMA(float maOrua)
        {
            return maOrua < 10000 ? maOrua : maOrua / 1000f;
        }
    }
}