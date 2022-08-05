
//来自于：MOMO https://www.xuanyusong.com/archives/4620
using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif
public class CombineMesh : MonoBehaviour 
{
    public int lightmapIndex = -1;
 
    private void Awake()
    {
        //初始化设置烘焙贴图的index
        if (lightmapIndex >= 0)
        {
            if(TryGetComponent<MeshRenderer>(out var m))
            {
                m.lightmapIndex = lightmapIndex;
            }
        }
    }
 
#if UNITY_EDITOR
    [MenuItem("LcLTools/CombineMesh")]
    static void StartCombineMesh()
    {
        if (Selection.activeTransform)
        {
            MeshFilter[] meshFilters = Selection.activeTransform.GetComponentsInChildren<MeshFilter>();
            //计算父节点的中心点
            Vector3 centerPos = GetCenter(meshFilters);
            CombineInstance[] combine = new CombineInstance[meshFilters.Length];
            Material material=null; 
            int lightmap = -1;
            int i = 0;
            while (i < meshFilters.Length)
            {
                var meshRender = meshFilters[i].GetComponent<MeshRenderer>();
                if (meshRender)
                {
                    if (material == null)
                        material = meshRender.sharedMaterial;
                    if (material!= meshRender.sharedMaterial)
                    {
                        Debug.LogError("存在不同材质不予合并");
                        return;
                    }
                    if (lightmap == -1)
                        lightmap = meshRender.lightmapIndex;
                    if (lightmap != meshRender.lightmapIndex)
                    {
                        Debug.LogError("存在不同烘焙贴图不予合并");
                        return;
                    }
                    combine[i].mesh = meshFilters[i].sharedMesh;
                    //记录参与合批的lightmapOffset
                    combine[i].lightmapScaleOffset = meshRender.lightmapScaleOffset;
                    //每个参与合批mesh的矩阵与中心点进行偏移计算
                    Matrix4x4 matrix4X4 = meshFilters[i].transform.localToWorldMatrix;
                    matrix4X4.m03 -= centerPos.x;
                    matrix4X4.m13 -= centerPos.y;
                    matrix4X4.m23 -= centerPos.z;
                    combine[i].transform = matrix4X4;
                    i++;
                }
            }
            var go = new GameObject("combine", typeof(MeshFilter), typeof(MeshRenderer));
            go.transform.position = centerPos;
            go.AddComponent<CombineMesh>().lightmapIndex = lightmap;
 
            var mesh = new Mesh();
            mesh.CombineMeshes(combine, true, true, true);
            //合拼会自动生成UV3，但是我们并不需要，可以这样删除
            mesh.uv3 = null;
            AssetDatabase.CreateAsset(mesh, "Assets/combine.asset");
            go.GetComponent<MeshFilter>().sharedMesh = mesh;
            go.GetComponent<MeshRenderer>().sharedMaterial = material;
            if (go)
            {
                PrefabUtility.SaveAsPrefabAssetAndConnect(go, Application.dataPath + "/combine.prefab", InteractionMode.AutomatedAction);
            }
        }
 
        Vector3 GetCenter(Component[] components)
        {
            if (components != null && components.Length > 0)
            {
                Vector3 min = components[0].transform.position;
                Vector3 max = min;
                foreach (var comp in components)
                {
                    min = Vector3.Min(min, comp.transform.position);
                    max = Vector3.Max(max, comp.transform.position);
                }
                return min + ((max - min) / 2);
            }
            return Vector3.zero;
        }
 
    }
#endif
 
}