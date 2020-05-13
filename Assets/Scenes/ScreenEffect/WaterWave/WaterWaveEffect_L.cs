using UnityEngine;

public class WaterWaveEffect_L : PostEffectsBase {

    public Shader shader;
    private Material _material = null;
    public Material material {
        get {
            _material = CheckShaderAndCreateMaterial (shader, _material);
            return _material;
        }
    }

    //波长
    [Range (0f, 100.0f)]
    public float _waveLength = 5.0f;
    //波纹振幅(高度)
    [Range (0, 2.0f)]
    public float _waveHeight = 1.0f;
    //波纹宽度
    [Range (0f, 1.0f)]
    public float _waveWidth = 0.5f;
    //波纹速度
    [Range (0f, 1.0f)]
    public float waveSpeed = 0.5f;
    private Vector4 startPos = new Vector4 (0.5f, 0.5f, 0, 0);
    //波纹开始运动的时间
    private float waveStartTime;

    [Range (0f, 1.0f)]
    public float _currentWaveDis = 0.5f;
    void OnRenderImage (RenderTexture source, RenderTexture destination) {
        //波纹运动的距离
        float _currentWaveDis = (Time.time - waveStartTime) * waveSpeed;
        // float _currentWaveDis = 2;

        //设置一系列参数
        material.SetVector ("_startPos", startPos);
        material.SetFloat ("_waveLength", _waveLength);
        material.SetFloat ("_waveHeight", _waveHeight);
        material.SetFloat ("_waveWidth", _waveWidth);
        material.SetFloat ("_currentWaveDis", _currentWaveDis);
        Graphics.Blit (source, destination, material);
    }

    void Update () {
        if (Input.GetMouseButton (0)) {
            Vector2 mousePos = Input.mousePosition;
            //将mousePos转化为（0，1）区间
            startPos = new Vector4 (mousePos.x / Screen.width, mousePos.y / Screen.height, 0, 0);
            waveStartTime = Time.time;
        }

    }
}