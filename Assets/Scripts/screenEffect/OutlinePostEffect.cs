/********************************************************************
 FileName: OutlinePostEffect.cs
 Description: 后处理描边效果
 Created: 2017/01/12
 history: 12:1:2017 0:42 by puppet_master
*********************************************************************/
using UnityEngine;
using System.Collections;
 
public class OutlinePostEffect : SimplePostEffectsBase
{
 
    private Camera mainCam = null;
    private Camera additionalCam = null;
    private RenderTexture renderTexture = null;
 
    public Shader outlineShader = null;
    //采样率
    public float samplerScale = 1;
    public int downSample = 1;
    public int iteration = 2;
 
    void Awake()
    {
        //创建一个和当前相机一致的相机
        InitAdditionalCam();
 
    }
 
    private void InitAdditionalCam()
    {
        mainCam = GetComponent<Camera>();
        if (mainCam == null)
            return;
 
        Transform addCamTransform = transform.Find("additionalCam");
        if (addCamTransform != null)
            DestroyImmediate(addCamTransform.gameObject);
 
        GameObject additionalCamObj = new GameObject("additionalCam");
        additionalCam = additionalCamObj.AddComponent<Camera>();
 
        SetAdditionalCam();
    }
 
    private void SetAdditionalCam()
    {
        if (additionalCam)
        {
            additionalCam.transform.parent = mainCam.transform;
            additionalCam.transform.localPosition = Vector3.zero;
            additionalCam.transform.localRotation = Quaternion.identity;
            additionalCam.transform.localScale = Vector3.one;
            additionalCam.farClipPlane = mainCam.farClipPlane;
            additionalCam.nearClipPlane = mainCam.nearClipPlane;
            additionalCam.fieldOfView = mainCam.fieldOfView;
            additionalCam.backgroundColor = Color.clear;
            additionalCam.clearFlags = CameraClearFlags.Color;
            additionalCam.cullingMask = 1 << LayerMask.NameToLayer("Additional");
            additionalCam.depth = -999; 
            if (renderTexture == null)
                renderTexture = RenderTexture.GetTemporary(additionalCam.pixelWidth >> downSample, additionalCam.pixelHeight >> downSample, 0);
        }
    }
 
    void OnEnable()
    {
        SetAdditionalCam();
        additionalCam.enabled = true;
    }
 
    void OnDisable()
    {
        additionalCam.enabled = false;
    }
 
    void OnDestroy()
    {
        if (renderTexture)
        {
            RenderTexture.ReleaseTemporary(renderTexture);
        }
        DestroyImmediate(additionalCam.gameObject);
    }
 
    //unity提供的在渲染之前的接口，在这一步渲染描边到RT
    void OnPreRender()
    {
        //使用OutlinePrepass进行渲染，得到RT
        if(additionalCam.enabled)
        {
            //渲染到RT上
            //首先检查是否需要重设RT，比如屏幕分辨率变化了
            if (renderTexture != null && (renderTexture.width != Screen.width >> downSample || renderTexture.height != Screen.height >> downSample))
            {
                RenderTexture.ReleaseTemporary(renderTexture);
                renderTexture = RenderTexture.GetTemporary(Screen.width >> downSample, Screen.height >> downSample, 0);
            }
            additionalCam.targetTexture = renderTexture;
            additionalCam.RenderWithShader(outlineShader, "");
        }
    }
 
    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (_Material && renderTexture)
        {
            //renderTexture.width = 111;
            //对RT进行Blur处理
            RenderTexture temp1 = RenderTexture.GetTemporary(source.width >> downSample, source.height >> downSample, 0);
            RenderTexture temp2 = RenderTexture.GetTemporary(source.width >> downSample, source.height >> downSample, 0);
 
            //高斯模糊，两次模糊，横向纵向，使用pass0进行高斯模糊
            _Material.SetVector("_offsets", new Vector4(0, samplerScale, 0, 0));
            Graphics.Blit(renderTexture, temp1, _Material, 0);
            _Material.SetVector("_offsets", new Vector4(samplerScale, 0, 0, 0));
            Graphics.Blit(temp1, temp2, _Material, 0);
 
            //如果有叠加再进行迭代模糊处理
            for(int i = 0; i < iteration; i++)
            {
                _Material.SetVector("_offsets", new Vector4(0, samplerScale, 0, 0));
                Graphics.Blit(temp2, temp1, _Material, 0);
                _Material.SetVector("_offsets", new Vector4(samplerScale, 0, 0, 0));
                Graphics.Blit(temp1, temp2, _Material, 0);
            }
 
            //用模糊图和原始图计算出轮廓图
            _Material.SetTexture("_BlurTex", temp2);
            Graphics.Blit(renderTexture, temp1, _Material, 1);
 
            //轮廓图和场景图叠加
            _Material.SetTexture("_BlurTex", temp1);
            Graphics.Blit(source, destination, _Material, 2);
 
            RenderTexture.ReleaseTemporary(temp1);
            RenderTexture.ReleaseTemporary(temp2);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
 
 
}