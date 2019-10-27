using UnityEngine;  
using System.Collections;  
  
//编辑状态下也运行  
[ExecuteInEditMode]  
//继承自PostEffectsbase
public class MyGaussianBlur : PostEffectsBase  
{  

    public Shader gaussianBlurShader;
	private Material gaussianBlurMaterial = null;

	public Material material {  
		get {
			gaussianBlurMaterial = CheckShaderAndCreateMaterial(gaussianBlurShader, gaussianBlurMaterial);
			return gaussianBlurMaterial;
		}  
	}

    //模糊半径  
	[Range(0.2f, 3.0f)]
    public float BlurRadius = 1.0f;  
    //降分辨率  
	[Range(1, 8)]
    public int downSample = 2;  
    //迭代次数  
	[Range(0, 4)]
    public int iteration = 1;  
  
    void OnRenderImage(RenderTexture source, RenderTexture destination)  
    {  
        if (material)  
        {  
            //申请RenderTexture，RT的分辨率按照downSample降低  
            RenderTexture rt1 = RenderTexture.GetTemporary(source.width >> downSample, source.height >> downSample, 0, source.format);  
            RenderTexture rt2 = RenderTexture.GetTemporary(source.width >> downSample, source.height >> downSample, 0, source.format);  
  
            //直接将原图拷贝到降分辨率的RT上  
            Graphics.Blit(source, rt1);  
  
            //进行迭代高斯模糊  
            for(int i = 0; i < iteration; i++)  
            {  
                //第一次高斯模糊，设置offsets，竖向模糊  
                material.SetVector("_offsets", new Vector4(0, BlurRadius, 0, 0));  
                Graphics.Blit(rt1, rt2, material);  
                //第二次高斯模糊，设置offsets，横向模糊  
                material.SetVector("_offsets", new Vector4(BlurRadius, 0, 0, 0));  
                Graphics.Blit(rt2, rt1, material);  
            }  
  
            //将结果输出  
            Graphics.Blit(rt1, destination);  
  
            //释放申请的两块RenderBuffer内容  
            RenderTexture.ReleaseTemporary(rt1);  
            RenderTexture.ReleaseTemporary(rt2);  
        }  
    }  
}  