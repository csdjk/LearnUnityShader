using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class RayTracingMaster : MonoBehaviour
{
    // ------------------------------------------------------------------------------------------------------------------------------------------------

    public Light DirectionalLight;
    public Material RayTracingMaterial;


    struct MeshObject
    {
        public Matrix4x4 localToWorldMatrix;
        public int indicesOffset;
        public int indicesCount;

    }
    private Camera _camera;
    private RenderTexture _target;
    private RenderTexture _converged;
    private Material _addMaterial;
    private uint _currentSample = 0;


    private static List<RayTracingObject> _gemObjects = new List<RayTracingObject>();
    private static List<MeshObject> _meshObjects = new List<MeshObject>();
    private static List<Vector3> _vertices = new List<Vector3>();
    private static List<int> _indices = new List<int>();
    private static List<RayTracingMaterial> _materials = new List<RayTracingMaterial>();
    private ComputeBuffer _meshObjectBuffer;
    private ComputeBuffer _vertexBuffer;
    private ComputeBuffer _indexBuffer;
    private ComputeBuffer _materialBuffer;

    private static List<Transform> _transformsToWatch = new List<Transform>();
    private static bool _meshObjectsNeedRebuilding = true;

    private void Awake()
    {
        _camera = GetComponent<Camera>();
        _transformsToWatch.Add(transform);
        _transformsToWatch.Add(DirectionalLight.transform);
    }

    void Update()
    {

        if (Input.GetKeyDown(KeyCode.F12))
        {
            ScreenCapture.CaptureScreenshot("Screenshot/" + Time.time + ".png");
        }

        foreach (Transform t in _transformsToWatch)
        {
            if (t.hasChanged)
            {
                _meshObjectsNeedRebuilding = true;
                t.hasChanged = false;
            }
        }

        if (_meshObjectsNeedRebuilding)
        {
            RebuildMeshObjectBuffers();
            _meshObjectsNeedRebuilding = false;
        }
    }

    void OnDisable()
    {
        _meshObjectBuffer?.Release();
        _vertexBuffer?.Release();
        _indexBuffer?.Release();
        _materialBuffer?.Release();
    }


    public static void RegisterObject(RayTracingObject obj)
    {
        _gemObjects.Add(obj);
        _transformsToWatch.Add(obj.transform);
        _meshObjectsNeedRebuilding = true;
    }
    public static void UnregisterObject(RayTracingObject obj)
    {
        _gemObjects.Remove(obj);
        _transformsToWatch.Remove(obj.transform);
        _meshObjectsNeedRebuilding = true;
    }


    private void RebuildMeshObjectBuffers()
    {
        if (!_meshObjectsNeedRebuilding)
        {
            return;
        }

        _meshObjectsNeedRebuilding = false;
        // Clear all lists
        _meshObjects.Clear();
        _vertices.Clear();
        _indices.Clear();
        _materials.Clear();

        foreach (RayTracingObject obj in _gemObjects)
        {
            MeshFilter filter = obj.GetComponent<MeshFilter>();
            Mesh mesh = filter.sharedMesh;

            // Add vertex data
            int firstVertex = _vertices.Count;
            _vertices.AddRange(mesh.vertices);

            // Add index data - if the vertex buffer wasn't empty before, the
            // indices need to be offset
            int firstIndex = _indices.Count;
            var indices = mesh.GetIndices(0);
            _indices.AddRange(indices.Select(index => index + firstVertex));

            // Add the object itself
            _meshObjects.Add(new MeshObject()
            {
                localToWorldMatrix = obj.transform.localToWorldMatrix,
                indicesOffset = firstIndex,
                indicesCount = indices.Length
            });

            _materials.Add(obj.material);
        }

        CreateComputeBuffer(ref _meshObjectBuffer, _meshObjects, 72);
        CreateComputeBuffer(ref _vertexBuffer, _vertices, 12);
        CreateComputeBuffer(ref _indexBuffer, _indices, 4);
        CreateComputeBuffer(ref _materialBuffer, _materials, 88);
    }

    private static void CreateComputeBuffer<T>(ref ComputeBuffer buffer, List<T> data, int stride)
        where T : struct
    {
        // Do we already have a compute buffer?
        if (buffer != null)
        {
            // If no data or buffer doesn't match the given criteria, release it
            if (data.Count == 0 || buffer.count != data.Count || buffer.stride != stride)
            {
                buffer.Release();
                buffer = null;
            }
        }

        if (data.Count != 0)
        {
            // If the buffer has been released or wasn't there to
            // begin with, create it
            if (buffer == null)
            {
                buffer = new ComputeBuffer(data.Count, stride);
            }

            // Set data on the buffer
            buffer.SetData(data);
        }
    }

    private void SetComputeBuffer(string name, ComputeBuffer buffer)
    {
        if (buffer != null)
        {
            RayTracingMaterial.SetBuffer(name, buffer);
        }
    }
    private void SetShaderParameters()
    {
        // _addMaterial.SetTexture("_SkyboxTexture", SkyboxTexture);
        RayTracingMaterial.SetMatrix("_MyCameraToWorld", _camera.cameraToWorldMatrix);
        RayTracingMaterial.SetMatrix("_CameraInverseProjection", _camera.projectionMatrix.inverse);
        // _addMaterial.SetVector("_PixelOffset", new Vector2(Random.value, Random.value));
        // RayTracingMaterial.SetFloat("_Seed", 0.5f);

        Vector3 l = DirectionalLight.transform.forward;
        RayTracingMaterial.SetVector("_DirectionalLight", new Vector4(l.x, l.y, l.z, DirectionalLight.intensity));

        SetComputeBuffer("_MeshObjects", _meshObjectBuffer);
        SetComputeBuffer("_Vertices", _vertexBuffer);
        SetComputeBuffer("_Indices", _indexBuffer);
        SetComputeBuffer("_Materials", _materialBuffer);
    }

    // ----------------------------------------

    private void InitRenderTexture()
    {
        if (_target == null || _target.width != Screen.width || _target.height != Screen.height)
        {
            // Release render texture if we already have one
            if (_target != null)
            {
                _target.Release();
                _converged.Release();
            }

            // Get a render target for Ray Tracing
            _target = new RenderTexture(Screen.width, Screen.height, 0,
                RenderTextureFormat.ARGBFloat, RenderTextureReadWrite.Linear);
            _target.enableRandomWrite = true;
            _target.Create();
            _converged = new RenderTexture(Screen.width, Screen.height, 0,
                RenderTextureFormat.ARGBFloat, RenderTextureReadWrite.Linear);
            _converged.enableRandomWrite = true;
            _converged.Create();

            // Reset sampling
            _currentSample = 0;
        }
    }

    private void Render(RenderTexture source, RenderTexture destination)
    {
        // Make sure we have a current render target
        InitRenderTexture();
        // Blit the result texture to the screen
        // if (_addMaterial == null)
        //     _addMaterial = new Material(Shader.Find("Hidden/AddShader"));
        // _addMaterial.SetFloat("_Sample", _currentSample);

        // Graphics.Blit(source, _converged, _addMaterial);
        // Graphics.Blit(_converged, destination);
        Graphics.Blit(source, destination, RayTracingMaterial);
        _currentSample++;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        RebuildMeshObjectBuffers();
        SetShaderParameters();
        Render(source, destination);
    }
}