using UnityEngine;
using System.Collections;
using UnityEngine.Rendering;

[RequireComponent(typeof(Camera))]
#if UNITY_5_4_OR_NEWER
[ImageEffectAllowedInSceneView]
#endif
[ImageEffectOpaque]
[ExecuteInEditMode]
public class CP_SSSSS_Main : MonoBehaviour
{
	public Shader shader;
	public Shader maskReplacementShader;
	RenderTexture sourceBuf;
	RenderTexture blurBuf;

	CommandBuffer buffer;
	CameraEvent camEvent = CameraEvent.BeforeImageEffectsOpaque;

	private Material m_Material;
	Material material
	{
		get
		{
			if (m_Material == null && shader != null)
			{
				m_Material = new Material(shader);
				m_Material.hideFlags = HideFlags.HideAndDontSave;
			}
			return m_Material;
		}
	}
		
	[Range(1,3)]
	public int downscale = 1;
	[Range(1, 3)]
	public int blurIterations = 1;
	[Range(0.01f, 1.6f)]
	public float scatterDistance = 0.4f;
	[Range(0f,2f)]
	public float scatterIntensity = 1f;
	[Range(0.001f, 0.3f)]
	public float softDepthBias = 0.05f;
	[Range(0f, 1f)]
	public float affectDirect = 0.5f;

	Camera maskRenderCamera;
	RenderTexture maskTexture;
	[HideInInspector]
	public string camName = "SSSSSMaskRenderCamera";
		
	void OnDisable() {
		if (m_Material)
		{
			DestroyImmediate(m_Material);
		}

		if (maskTexture != null)
			Object.DestroyImmediate(maskTexture);
		if (sourceBuf != null)
			Object.DestroyImmediate(sourceBuf);
		if (blurBuf != null)
			Object.DestroyImmediate(blurBuf);

		m_Material = null;
		maskTexture = null;
		sourceBuf = null;
		blurBuf = null;

		CleanupBuffer();
	}

	void OnEnable()
	{
		if (!SystemInfo.supportsImageEffects)
		{
			enabled = false;
			return;
		}

		// Disable the image effect if the shader can't
		// run on the users graphics card
		if (!shader || !shader.isSupported)
			enabled = false;

		CleanupBuffer();
		RenderMasks();
		ApplyBuffer();
		UpdateBuffer();
	}

	private void OnPreRender()
	{
		RenderMasks();
		if (buffer != null) UpdateBuffer();
	}

	void ApplyBuffer()
	{
		buffer = new CommandBuffer();
		buffer.name = "Screen Space Subsurface Scattering";
		GetComponent<Camera>().AddCommandBuffer(camEvent, buffer);	
	}

	void UpdateBuffer()
	{
		buffer.Clear();
		int blurRT1 = Shader.PropertyToID("_CPSSSSSBlur1");
		int blurRT2 = Shader.PropertyToID("_CPSSSSSBlur2");
		int src = Shader.PropertyToID("_CPSSSSSSource");
		buffer.SetGlobalTexture("_MaskTex", maskTexture);
		buffer.GetTemporaryRT(blurRT1, -1, -1, 16, FilterMode.Bilinear, RenderTextureFormat.ARGBFloat);
		buffer.GetTemporaryRT(blurRT2, -1, -1, 16, FilterMode.Bilinear, RenderTextureFormat.ARGBFloat);
		buffer.GetTemporaryRT(src, -1, -1, 24, FilterMode.Bilinear, RenderTextureFormat.ARGBFloat);
		buffer.SetGlobalFloat("_SoftDepthBias", softDepthBias * 0.05f * 0.2f);

		buffer.Blit(BuiltinRenderTextureType.CameraTarget, blurRT2);
		//buffer.Blit(BuiltinRenderTextureType.CurrentActive, sourceBuf);
		buffer.Blit(BuiltinRenderTextureType.CameraTarget, src);

		//multipass pass blur
		for (int k = 1; k <= blurIterations; k++)
		{
			buffer.SetGlobalFloat("_BlurStr", Mathf.Clamp01(scatterDistance * 0.12f - k * 0.02f));
			buffer.SetGlobalVector("_BlurVec", new Vector4(1, 0, 0, 0));
			buffer.Blit(blurRT2, blurRT1, material, 0);
			buffer.SetGlobalVector("_BlurVec", new Vector4(0, 1, 0, 0));
			buffer.Blit(blurRT1, blurRT2, material, 0);

			buffer.SetGlobalVector("_BlurVec", new Vector4(1, 1, 0, 0).normalized);
			buffer.Blit(blurRT2, blurRT1, material, 0);
			buffer.SetGlobalVector("_BlurVec", new Vector4(-1, 1, 0, 0).normalized);
			buffer.Blit(blurRT1, blurRT2, material, 0);
		}

		//buffer.Blit(blurRT2, blurBuf);

		buffer.SetGlobalTexture("_BlurTex", blurRT2);
		buffer.SetGlobalFloat("_EffectStr", scatterIntensity);
		buffer.SetGlobalFloat("_PreserveOriginal", 1 - affectDirect);
		buffer.Blit(src, BuiltinRenderTextureType.CameraTarget, material, 1);

		buffer.ReleaseTemporaryRT(blurRT1);
		buffer.ReleaseTemporaryRT(blurRT2);
		buffer.ReleaseTemporaryRT(src);
	}

	void CleanupBuffer()
	{
		if (buffer!=null)
		{
			buffer.Clear();
			GetComponent<Camera>().RemoveCommandBuffer(camEvent, buffer);
			buffer = null;
		}
	}

	void RenderMasks()
	{
		CheckCamera();
		//Hack to remove the "Screen position out of view frustum" error on Unity startup
		if (Camera.current!=null)
		maskRenderCamera.Render();
	}

	void CheckCamera()
	{
		if (maskRenderCamera==null)
		{
			GameObject camgo = GameObject.Find(camName);
			if (camgo==null)
			{
				camgo = new GameObject(camName);
				camgo.hideFlags = HideFlags.HideAndDontSave;
				maskRenderCamera = camgo.AddComponent<Camera>();
				maskRenderCamera.enabled = false;
			} else
			{
				maskRenderCamera = camgo.GetComponent<Camera>();
				maskRenderCamera.enabled = false;
			}
		}

		if (maskTexture==null)
		{
			Camera c = Camera.current;
			if (c==null)
			c = GetComponent<Camera>();
			maskTexture = RenderTexture.GetTemporary(c.pixelWidth, c.pixelHeight, 16, RenderTextureFormat.ARGB32);
		}

		Camera cam = Camera.current;

		if (cam == null) cam = Camera.main;

		maskRenderCamera.CopyFrom(cam);
		maskRenderCamera.renderingPath = RenderingPath.Forward;
		maskRenderCamera.allowHDR = false;
		maskRenderCamera.targetTexture = maskTexture;
		maskRenderCamera.SetReplacementShader(maskReplacementShader, "RenderType");
	}
}
