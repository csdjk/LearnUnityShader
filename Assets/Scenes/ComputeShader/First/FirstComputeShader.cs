using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class FirstComputeShader : MonoBehaviour
{
    public struct TestData
    {
        public Vector4 v1;
        public Vector4 v2;
    }
    private int kernelIndex;
    public Material material;
    public ComputeShader computeShader;
    // RT
    private RenderTexture mRenderTexture;



    public int dataCount = 1000;
    private int numThreads = 8 * 8 * 1;
    // Buffer
    private ComputeBuffer testBuffer;
    private TestData[] testDatas;


    void OnValidate()
    {
        InitBuffer();
    }
    void OnEnable()
    {
        if (computeShader == null || material == null)
            return;

        InitBuffer();
        UpdateTexture();
        UpdateBuffer();
    }

    void UpdateTexture()
    {
        // 创建一张RT
        if (mRenderTexture)
        {
            mRenderTexture.Release();
        }
        mRenderTexture = new RenderTexture(1024, 1024, 16);
        mRenderTexture.enableRandomWrite = true;
        mRenderTexture.Create();
        material.mainTexture = mRenderTexture;

        // 赋值给ComputeShader的Result变量
        kernelIndex = computeShader.FindKernel("CSMain");
        computeShader.SetTexture(kernelIndex, "Result", mRenderTexture);

        // 执行ComputeShader
        computeShader.Dispatch(kernelIndex, mRenderTexture.width / 8, mRenderTexture.height / 8, 1);
    }

    void InitBuffer()
    {
        if (computeShader == null || material == null)
            return;

        if (testBuffer != null)
        {
            testBuffer.Release();
            testBuffer = null;
        }
        // 每个float占内存4个字节，sizeof(float) 可以获取
        // struct中一共8个float, 所以stride：8 * 4 = 32
        testBuffer = new ComputeBuffer(dataCount, 32);
        testDatas = new TestData[dataCount];
        testBuffer.SetData(testDatas);
        kernelIndex = computeShader.FindKernel("CSMain");
    }

    void UpdateBuffer()
    {
        if (computeShader == null || material == null)
            return;
        // 传递参数
        computeShader.SetBuffer(kernelIndex, "TestBuffer", testBuffer);
        // 开辟线程组并执行ComputeShader
        computeShader.Dispatch(kernelIndex, dataCount / numThreads + 1, 1, 1);
        // 把执行结果的buffer传递到Shader
        material.SetBuffer("_particleDataBuffer", testBuffer);
        if (Input.GetKeyDown(KeyCode.P))
        {
            testBuffer.GetData(testDatas);
            int i = 0;
            foreach (var item in testDatas)
            {
                Debug.Log($"i:{i}, v1:{item.v1}, v2:{item.v2}");
                i++;
            }
        }
    }
    private void OnGUI()
    {
        if (GUILayout.Button("Print Data", GUILayout.Width(100), GUILayout.Height(50)))
        {
            material.SetBuffer("_particleDataBuffer", testBuffer);
            testBuffer.GetData(testDatas);
            int i = 0;
            foreach (var item in testDatas)
            {
                Debug.Log($"i:{i}, v1:{item.v1}, v2:{item.v2}");
                i++;
            }
        }
    }

    void Update()
    {
        UpdateBuffer();
    }

    void OnDestroy()
    {
        mRenderTexture.Release();
        mRenderTexture = null;
        testBuffer.Release();
        testBuffer = null;
    }
}
