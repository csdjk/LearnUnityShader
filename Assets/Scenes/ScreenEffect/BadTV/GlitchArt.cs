/*** 
 * @Descripttion: 放大镜特效
 * @Author: lichanglong
 * @Date: 2020-12-18 18:04:00
 * @FilePath: \LearnUnityShader\Assets\Scenes\ScreenEffect\BadTV\GlitchArt.cs
 */
// ---------------------------------------------------------------【故障艺术（坏电视）特效】---------------------------------------------------------------

using UnityEngine;

public class GlitchArt : PostEffectsBase
{
    public Shader myShader;
    //材质 
    private Material mat = null;
    public Material material
    {
        get
        {
            // 检查着色器并创建材质
            mat = CheckShaderAndCreateMaterial(myShader, mat);
            mat.hideFlags = HideFlags.DontSave;
            return mat;
        }
    }


    // 扫描线抖动
    [Range(0, 1)]
    public float scanLineJitter = 0;

    // 纵向抖动
    [Range(0, 1)]
    public float verticalJump = 0;

    // 横向抖动
    [Range(0, 1)]
    public float horizontalShake = 0;

    // 颜色漂移
    [Range(0, 1)]
    public float colorDrift = 0;


    float _verticalJumpTime;

    void Start()
    {
        //找到对应的Shader文件  
        myShader = Shader.Find("lcl/screenEffect/GlitchArt");
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {

        _verticalJumpTime += Time.deltaTime * verticalJump * 11.3f;

        var sl_thresh = Mathf.Clamp01(1.0f - scanLineJitter * 1.2f);
        var sl_disp = 0.002f + Mathf.Pow(scanLineJitter, 3) * 0.05f;
        material.SetVector("_ScanLineJitter", new Vector2(sl_disp, sl_thresh));

        var vj = new Vector2(verticalJump, _verticalJumpTime);
        material.SetVector("_VerticalJump", vj);

        material.SetFloat("_HorizontalShake", horizontalShake * 0.2f);

        var cd = new Vector2(colorDrift * 0.04f, Time.time * 606.11f);
        material.SetVector("_ColorDrift", cd);

        Graphics.Blit(source, destination, material);
    }
}