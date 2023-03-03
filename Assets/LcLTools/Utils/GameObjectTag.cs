using System;
using System.Linq;
using UnityEditor;
using UnityEngine;
namespace LcLTools
{
    public class GameObjectTag : MonoBehaviour
    {
        public string tagName;

        public float height = 20;
        public int fontSize = 20;
        public Color color = Color.white;
        private static GUIStyle style;


#if UNITY_EDITOR

        [DrawGizmo(GizmoType.InSelectionHierarchy | GizmoType.NotInSelectionHierarchy)]
        static void DrawGizmo(GameObjectTag goTag, GizmoType gizmoType)
        {
            var transform = goTag.transform;
            var position = transform.position;
            var height = goTag.height;
            var fontSize = goTag.fontSize;

            var mesh = goTag.transform.GetComponentInChildren<MeshRenderer>();
            if (mesh)
            {
                position = mesh.bounds.center;
            }

            var tagName = goTag.tagName;
            if (tagName == null || tagName.Equals(String.Empty))
            {
                tagName = goTag.name;
            }

            if (GameObjectTag.style == null)
            {
                GameObjectTag.style = new GUIStyle();
                GameObjectTag.style.alignment = TextAnchor.MiddleCenter;
            }

            Gizmos.color = goTag.color;
            Gizmos.DrawLine(position, position + Vector3.up * (height - 2));


            GameObjectTag.style.normal.textColor = goTag.color;
            GameObjectTag.style.fontSize = fontSize;
            Handles.Label(position + Vector3.up * height, tagName, GameObjectTag.style);
        }
#endif

    }
}
