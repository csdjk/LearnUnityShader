using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WheelTrack : MonoBehaviour
{
    public GameObject terrain;
    public Shader DrawShader;
    [Range(0, 1)]
    public float brushStrength;
    [Range(1, 2)]
    public float brushSize = 1;
    public Color brushColor;
    public Transform[] wheel;


    private RenderTexture pathRT;
    private Material drawMat;
    RaycastHit groundHit;
    int layerMask;

    void Start()
    {
        layerMask = LayerMask.GetMask("Ground");
        drawMat = new Material(DrawShader);
        pathRT = new RenderTexture(1024, 1024, 0, RenderTextureFormat.ARGBFloat);

        var floorMat = terrain.GetComponent<MeshRenderer>().sharedMaterial;
        floorMat.SetTexture("_MaskTex", pathRT);
    }

    // Update is called once per frame
    void Update()
    {
        for (var i = 0; i < wheel.Length; i++)
        {
            RaycastHit hit;
            if (Physics.Raycast(wheel[i].position, -Vector3.up, out hit, 1f, layerMask))
            {
                // 绘制图案
                drawMat.SetColor("_Color", brushColor);

                drawMat.SetVector("_Pos", new Vector4(hit.textureCoord.x, hit.textureCoord.y, 0, 0));
                drawMat.SetFloat("_Strength", brushStrength);
                drawMat.SetFloat("_Size", brushSize);

                RenderTexture temp = RenderTexture.GetTemporary(pathRT.width, pathRT.height, 0, RenderTextureFormat.ARGBFloat);
                Graphics.Blit(pathRT, temp);
                Graphics.Blit(temp, pathRT, drawMat);
                RenderTexture.ReleaseTemporary(temp);
            }
        }
    }

    private void OnGUI()
    {
        GUI.DrawTexture(new Rect(0, 0, 256, 256), pathRT, ScaleMode.ScaleToFit, false, 1);
    }
}
