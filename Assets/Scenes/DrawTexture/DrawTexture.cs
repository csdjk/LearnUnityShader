using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DrawTexture : MonoBehaviour
{
    public Camera mainCamera;

    public RenderTexture pathRT;
    public Shader DrawShader;
    public float brushStrength;
    public float brushSize;
    public Color brushColor;
    private Material drawMat;

    void Start()
    {
        mainCamera = Camera.main.GetComponent<Camera>();
        drawMat = new Material(DrawShader);
        pathRT = new RenderTexture(1024, 1024, 0, RenderTextureFormat.ARGBFloat);

        var  floorMat = transform.GetComponent<MeshRenderer>().sharedMaterial;
        floorMat.SetTexture("_MaskTex",pathRT);
    }

    // Update is called once per frame
    void Update()
    {
        // 射线检测
        if (Input.GetMouseButton(0))
        {
            Ray ray = mainCamera.ScreenPointToRay(Input.mousePosition);
            RaycastHit hit;
            if (Physics.Raycast(ray, out hit))
            {
                // 绘制图案
                drawMat.SetColor("_Color", brushColor);

                drawMat.SetVector("_Pos", new Vector4(hit.textureCoord.x, hit.textureCoord.y, 0, 0));
                drawMat.SetFloat("_Strength", brushStrength);
                drawMat.SetFloat("_Size", brushSize);

                RenderTexture temp = RenderTexture.GetTemporary(pathRT.width, pathRT.height,0, RenderTextureFormat.ARGBFloat);
                Graphics.Blit(pathRT,temp);
                Graphics.Blit(temp,pathRT,drawMat);
                RenderTexture.ReleaseTemporary(temp);
            }
        }
    }

    private void OnGUI() {
        GUI.DrawTexture(new Rect(0,0,256,256),pathRT,ScaleMode.ScaleToFit,false,1);
    }
}
