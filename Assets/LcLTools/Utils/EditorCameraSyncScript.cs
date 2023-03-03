using UnityEngine;
using UnityEditor;
using System.Linq;

namespace LcLTools
{
#if UNITY_EDITOR

    [ExecuteInEditMode]
    public class EditorCameraSyncScript : MonoBehaviour
    {

        [HideInInspector]
        [SerializeField]
        Camera syncedGameCamera;            //camera synced with scene view

        [HideInInspector]
        [SerializeField]  //transform backups (private, hidden)
        Vector3 startPosition;
        [HideInInspector]
        [SerializeField]
        Quaternion startRotation;

        [HideInInspector]
        [SerializeField]  //camera backups (private, hidden)
        float defaultDepth;
        [HideInInspector]
        [SerializeField]
        bool orthographic;
        [HideInInspector]
        [SerializeField]
        float defaultOrthographicSize;
        [HideInInspector]
        [SerializeField]
        float defaultFieldOfView;

        [SerializeField]                    //settings
        bool disableOnPlay;
        [SerializeField]
        public bool lockOnPlay;
        [SerializeField]
        public bool revertOnDestroy = true;


        void Awake()
        {
            if (syncedGameCamera == null)    //setting up
            {
                foreach (EditorCameraSyncScript script in FindObjectsOfType<EditorCameraSyncScript>()) //destroy previous instances
                {
                    if (script != this)
                    {
                        this.disableOnPlay = script.disableOnPlay;      //but keep previous settings
                        this.lockOnPlay = script.lockOnPlay;
                        //this.revertOnDestroy = script.revertOnDestroy;

                        DestroyImmediate(script);
                    }
                }

                this.startPosition = this.transform.position;           //backup start position & orientation
                this.startRotation = this.transform.rotation;

                SetUpCamera();
            }

            if (Application.isPlaying)
                this.gameObject.SetActive(!disableOnPlay);              //disable objecet in play mode if checked
            else
                this.gameObject.SetActive(true);                        //reenable after moving back from play mode
        }


        void SetUpCamera()
        {
            //float highestDepth = FindObjectsOfType<Camera>().Max(cam => (float?)cam.depth) ?? 0f; //find all cams and get max cam depth or 0
            //float minimalDepth = FindObjectsOfType<Camera>().Min(cam => (float?)cam.depth) ?? 0f;

            var camsDepth = (from cam in FindObjectsOfType<Camera>()
                             orderby cam.depth
                             select cam.depth).DefaultIfEmpty(0f);  //Get all cams depth or get default depth = 0

            Camera attachedCamera = this.GetComponent<Camera>();        //Set up attached camera or create a new one	

            if (attachedCamera != null)
            {

                this.defaultDepth = attachedCamera.depth;               //backup original setup
                this.orthographic = attachedCamera.orthographic;
                // this.defaultFieldOfView = attachedCamera.fieldOfView;
                this.defaultOrthographicSize = attachedCamera.orthographicSize;

                syncedGameCamera = attachedCamera;
            }
            else
            {
                syncedGameCamera = this.gameObject.AddComponent<Camera>();

                this.defaultDepth = camsDepth.First() - 1f;               //backup min depth -1
                this.orthographic = syncedGameCamera.orthographic;        //backup default presets
                                                                          // this.defaultFieldOfView = syncedGameCamera.fieldOfView;
                this.defaultOrthographicSize = syncedGameCamera.orthographicSize;

            }

            syncedGameCamera.depth = camsDepth.Last() + 1f;             //get highest depth and add +1 to make sure our camera will draw over antoher ones
        }


        void OnRenderObject()
        {
            if (!Application.isPlaying || Application.isPlaying && !lockOnPlay) //lock in play mode if checked
            {
                if (SceneView.lastActiveSceneView != null && SceneView.lastActiveSceneView.camera == Camera.current) // Set alignment once, only after scene view has been rerendered
                {
                    Camera sceneViewCamera = SceneView.lastActiveSceneView.camera;

                    if (syncedGameCamera != null)
                    {
                        syncedGameCamera.transform.position = sceneViewCamera.transform.position; //modify transform
                        syncedGameCamera.transform.rotation = sceneViewCamera.transform.rotation;

                        syncedGameCamera.orthographic = sceneViewCamera.orthographic;           //modify camera settings
                        syncedGameCamera.orthographicSize = sceneViewCamera.orthographicSize;
                        // syncedGameCamera.fieldOfView = sceneViewCamera.fieldOfView;
                    }
                    else
                    {
                        //this.gameObject.AddComponent<EditorCameraSyncScript>(); //reset script

                        Debug.LogError("Scene View Cam: (" + this.gameObject.name + ") Camera was removed. Removing script");
                        DestroyImmediate(this);
                    }
                }
            }
        }

#if UNITY_EDITOR

        [MenuItem("GameObject/Scene View Synced Cam/Add Scene View Synced Camera")]
        public static void AddNewCam()
        {
            GameObject gameCameraGO = new GameObject("Scene View Synced Camera");
            EditorCameraSyncScript script = gameCameraGO.AddComponent<EditorCameraSyncScript>();
        }


        [MenuItem("GameObject/Scene View Synced Cam/Clone Selected Camera")]
        public static void CloneSelectedCam()
        {
            GameObject gameCameraGO = Selection.activeGameObject;
            if (gameCameraGO == null)
            {
                Debug.LogError("Scene View Cam: Nothing selected");
                return;
            }

            Camera attachedCam = gameCameraGO.GetComponent<Camera>();
            if (attachedCam == null)
            {
                Debug.LogError("Scene View Cam: No camera selected");
                return;
            }

            GameObject gameCameraGOClone = Instantiate(gameCameraGO);
            gameCameraGOClone.name = gameCameraGOClone.name + " - Synced With Scene View";
            gameCameraGOClone.AddComponent<EditorCameraSyncScript>();
        }
#endif

        //restore backups
        void RevertChanges()
        {
            this.transform.position = this.startPosition;
            this.transform.rotation = this.startRotation;

            if (syncedGameCamera != null)
            {
                syncedGameCamera.depth = this.defaultDepth;
                syncedGameCamera.orthographic = this.orthographic;
                // syncedGameCamera.fieldOfView = this.defaultFieldOfView;
                syncedGameCamera.orthographicSize = this.defaultOrthographicSize;
            }

        }

        void OnDestroy()
        {
            if (revertOnDestroy)
                RevertChanges();
        }
    }

#endif
}