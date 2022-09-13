using System.Collections;
using System.Collections.Generic;
using UnityEngine;


/// <summary>
/// GPU粒子
/// </summary>
[ExecuteAlways]
public class ParticleCS : MonoBehaviour
{

    public struct ParticleData
    {
        public Vector3 pos;
        public Color color;
    }
    public ComputeShader computeShader;
    public Material material;
    public int mParticleCount = 1000;

    private int numThreads = 10 * 10 * 10;
    private int kernelIndex;
    private ComputeBuffer particleBuffer;
    private ParticleData[] particleDatas;


    void OnValidate()
    {
        UpdateBuffer();
    }
    void OnEnable()
    {
        UpdateBuffer();
    }


    void UpdateBuffer()
    {
        if (computeShader == null || material == null)
            return;

        if (particleBuffer != null)
        {
            particleBuffer.Release();
            particleBuffer = null;
        }
        // 每个float占内存4个字节，sizeof(float) 可以获取
        // struct中一共7个float, 所以stride：7 * 4 = 28
        particleBuffer = new ComputeBuffer(mParticleCount, 28);
        particleDatas = new ParticleData[mParticleCount];
        particleBuffer.SetData(particleDatas);
        kernelIndex = computeShader.FindKernel("UpdateParticle");
    }

    void Update()
    {

        if (computeShader == null || material == null)
            return;

        // 传递参数
        computeShader.SetBuffer(kernelIndex, "ParticleBuffer", particleBuffer);
        computeShader.SetFloat("Time", Time.time);
        // 执行ComputeShader
        computeShader.Dispatch(kernelIndex, mParticleCount / numThreads + 1, 1, 1);
        // 把执行结果的buffer传递到Shader
        material.SetBuffer("_particleDataBuffer", particleBuffer);
    }

    void OnRenderObject()
    {
        if (computeShader == null || material == null)
            return;

        material.SetPass(0);
        // 绘制particle
        Graphics.DrawProceduralNow(MeshTopology.Points, mParticleCount);
    }

    void OnDisable()
    {

    }

    void OnDestroy()
    {
        particleBuffer.Release();
        particleBuffer = null;
    }
}
