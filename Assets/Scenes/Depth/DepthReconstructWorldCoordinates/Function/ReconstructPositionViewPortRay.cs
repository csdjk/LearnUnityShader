//  Description:通过深度图重建世界坐标，视口射线插值方式
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ReconstructPositionViewPortRay : MonoBehaviour
{

    private Material postEffectMat = null;
    private Camera currentCamera = null;

    void Awake()
    {
        currentCamera = GetComponent<Camera>();
    }

    void OnEnable()
    {
        if (postEffectMat == null)
            postEffectMat = new Material(Shader.Find("lcl/Depth/ReconstructPositionViewPortRay"));
        currentCamera.depthTextureMode |= DepthTextureMode.Depth;
    }

    void OnDisable()
    {
        currentCamera.depthTextureMode &= ~DepthTextureMode.Depth;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (postEffectMat == null)
        {
            Graphics.Blit(source, destination);
        }
        else
        {
            var aspect = currentCamera.aspect;
            var far = currentCamera.farClipPlane;
            var right = transform.right;
            var up = transform.up;
            var forward = transform.forward;
            var halfFovTan = Mathf.Tan(currentCamera.fieldOfView * 0.5f * Mathf.Deg2Rad);

            //计算相机在远裁剪面处的xyz三方向向量
            var rightVec = right * far * halfFovTan * aspect;
            var upVec = up * far * halfFovTan;
            var forwardVec = forward * far;

            //构建四个角的方向向量
            var topLeft = forwardVec - rightVec + upVec;
            var topRight = forwardVec + rightVec + upVec;
            var bottomLeft = forwardVec - rightVec - upVec;
            var bottomRight = forwardVec + rightVec - upVec;

            var viewPortRay = Matrix4x4.identity;

            viewPortRay.SetRow(0, bottomLeft);
            viewPortRay.SetRow(1, bottomRight);
            viewPortRay.SetRow(2, topLeft);
            viewPortRay.SetRow(3, topRight);
            postEffectMat.SetMatrix("_ViewPortRay", viewPortRay);
            Graphics.Blit(source, destination, postEffectMat);
        }
    }
}