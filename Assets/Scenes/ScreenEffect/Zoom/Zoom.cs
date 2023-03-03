// create by 长生但酒狂
// create time 2020.4.8
// ---------------------------【放大镜特效】---------------------------

using UnityEngine;
public class Zoom : PostEffectsBase {
    static readonly string shaderName = "lcl/screenEffect/Zoom";
    // 放大强度
    [Range (-2.0f, 2.0f), Tooltip ("放大强度")]
    public float zoomFactor = 0.4f;

     // 放大镜大小
    [Range (0.0f, 0.2f), Tooltip ("放大镜大小")]
    public float size = 0.15f;

    // 凸镜边缘强度
    [Range (0.0001f, 0.1f), Tooltip ("凸镜边缘强度")]
    public float edgeFactor = 0.05f;

    // 遮罩中心位置
    private Vector2 pos = new Vector4 (0.5f, 0.5f);

    void OnEnable () {
        shader = Shader.Find(shaderName);
    }

    // 渲染屏幕
    void OnRenderImage (RenderTexture source, RenderTexture destination) {
        if (material) {
            // 把鼠标坐标传递给Shader
            material.SetVector ("_Pos", pos);
            material.SetFloat ("_ZoomFactor", zoomFactor);
            material.SetFloat ("_EdgeFactor", edgeFactor);
            material.SetFloat ("_Size", size);
            // 渲染
            Graphics.Blit (source, destination, material);
        } else {
            Graphics.Blit (source, destination);
        }
    }

    void Update () {
        if (Input.GetMouseButton (0)) {
            Vector2 mousePos = Input.mousePosition;
            //将mousePos转化为（0，1）区间
            pos = new Vector2 (mousePos.x / Screen.width, mousePos.y / Screen.height);
        }
    }
}