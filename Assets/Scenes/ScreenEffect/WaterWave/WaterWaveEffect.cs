
using UnityEngine;
 
public class WaterWaveEffect : PostEffectsBase {
 
    
    //距离系数
	[Range(0f, 30.0f)]
    public float distanceFactor = 30.0f;
    //时间系数
	[Range(-30f, 30.0f)]
    public float timeFactor = -30.0f;
    //sin函数结果系数
	[Range(0f, 30.0f)]
    public float totalFactor = 1.0f;
 
    //波纹宽度
	[Range(0f, 1f)]
    public float waveWidth = 0.2f;

    //波纹扩散的速度
	[Range(0f, 2f)]
    public float waveSpeed = 0.3f;
 
    private float waveStartTime;
    private Vector4 startPos = new Vector4(0.5f, 0.5f, 0, 0);
 
 
    void OnRenderImage (RenderTexture source, RenderTexture destination)
    {
        //计算波纹移动的距离，根据enable到目前的时间*速度求解
        float curWaveDistance = (Time.time - waveStartTime) * waveSpeed;
        //设置一系列参数
        material.SetFloat("_distanceFactor", distanceFactor);
        material.SetFloat("_timeFactor", timeFactor);
        material.SetFloat("_totalFactor", totalFactor);
        material.SetFloat("_waveWidth", waveWidth);
        material.SetFloat("_curWaveDis", curWaveDistance);
        material.SetVector("_startPos", startPos);
		Graphics.Blit (source, destination, material);
	}
 
    void Update()
    {
        if (Input.GetMouseButton(0))
        {
            Vector2 mousePos = Input.mousePosition;
            //将mousePos转化为（0，1）区间
            startPos = new Vector4(mousePos.x / Screen.width, mousePos.y / Screen.height, 0, 0);
            waveStartTime = Time.time;
        }
 
    }
}