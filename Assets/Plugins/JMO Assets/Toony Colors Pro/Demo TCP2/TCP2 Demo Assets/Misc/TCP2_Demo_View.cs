// Toony Colors Pro+Mobile 2
// (c) 2014-2020 Jean Moreno

using UnityEngine;

namespace ToonyColorsPro
{
	namespace Demo
	{
		public class TCP2_Demo_View : MonoBehaviour
		{
			//--------------------------------------------------------------------------------------------------
			// PUBLIC INSPECTOR PROPERTIES

			[Header("Orbit")]
			public float OrbitStrg = 3f;
			public float OrbitClamp = 50f;
			[Header("Panning")]
			public float PanStrg = 0.1f;
			public float PanClamp = 2f;
			[Header("Zooming")]
			public float ZoomStrg = 40f;
			public float ZoomClamp = 30f;
			[Header("Misc")]
			public float Decceleration = 8f;

			public Transform CharacterTransform;

			//--------------------------------------------------------------------------------------------------
			// PRIVATE PROPERTIES

			private Vector3 mouseDelta;
			private Vector3 orbitAcceleration;
			private Vector3 panAcceleration;
			private Vector3 moveAcceleration;
			private float zoomAcceleration;
			private const float XMax = 60;
			private const float XMin = 300;

			private Vector3 mResetCamPos, mResetCamRot;
			private bool mMouseDown;

			//--------------------------------------------------------------------------------------------------
			// UNITY EVENTS

			void Awake()
			{
				mResetCamPos = Camera.main.transform.position;
				mResetCamRot = Camera.main.transform.eulerAngles;
			}

			void OnEnable()
			{
				mouseDelta = Input.mousePosition;
			}

			void Update()
			{

				mouseDelta = Input.mousePosition - mouseDelta;

				if (!mMouseDown)
					mMouseDown = (Input.GetMouseButtonDown(0) && !(new Rect(0, 65, 230, 260).Contains(Input.mousePosition))) ? true : false;
				else
					mMouseDown = Input.GetMouseButtonUp(0) ? false : true;

				//Left Button held
				if (mMouseDown)
					orbitAcceleration.y -= Mathf.Clamp(-mouseDelta.x * OrbitStrg, -OrbitClamp, OrbitClamp);

				//Middle/Right Button held
				else if (Input.GetMouseButton(2) || Input.GetMouseButton(1))
					panAcceleration.y += Mathf.Clamp(-mouseDelta.y * PanStrg, -PanClamp, PanClamp);

				//Keyboard support
				orbitAcceleration.y += Input.GetKey(KeyCode.LeftArrow) ? 15 : (Input.GetKey(KeyCode.RightArrow) ? -15 : 0);
				zoomAcceleration += Input.GetKey(KeyCode.UpArrow) ? 1 : (Input.GetKey(KeyCode.DownArrow) ? -1 : 0);
				if (Input.GetKeyDown(KeyCode.R))
				{
					ResetView();
				}

				//X Angle Clamping
				var angle = Camera.main.transform.localEulerAngles;
				if (angle.x < 180 && angle.x >= XMax && orbitAcceleration.y > 0) orbitAcceleration.y = 0;
				if (angle.x > 180 && angle.x <= XMin && orbitAcceleration.y < 0) orbitAcceleration.y = 0;

				//Rotate Robot
				CharacterTransform.Rotate(-orbitAcceleration * Time.deltaTime, Space.World);

				//Translate Camera
				Camera.main.transform.Translate(panAcceleration * Time.deltaTime, Space.World);

				//Zoom
				var scrollWheel = Input.GetAxis("Mouse ScrollWheel");
				zoomAcceleration += scrollWheel * ZoomStrg;
				zoomAcceleration = Mathf.Clamp(zoomAcceleration, -ZoomClamp, ZoomClamp);
				Camera.main.transform.Translate(Vector3.forward * zoomAcceleration * Time.deltaTime, Space.World);

				//Camera position clamp
				if (Camera.main.transform.position.y > 1.65f)
				{
					var pos = Camera.main.transform.position;
					pos.y = 1.65f;
					Camera.main.transform.position = pos;
				}
				else if (Camera.main.transform.position.y < 0.3f)
				{
					var pos = Camera.main.transform.position;
					pos.y = 0.3f;
					Camera.main.transform.position = pos;
				}

				if (Camera.main.transform.position.z < -1.8f)
				{
					var pos = Camera.main.transform.position;
					pos.z = -1.8f;
					Camera.main.transform.position = pos;
				}
				else if (Camera.main.transform.position.z > -0.6f)
				{
					var pos = Camera.main.transform.position;
					pos.z = -0.6f;
					Camera.main.transform.position = pos;
				}

				//Deccelerate
				orbitAcceleration = Vector3.Lerp(orbitAcceleration, Vector3.zero, Decceleration * Time.deltaTime);
				panAcceleration = Vector3.Lerp(panAcceleration, Vector3.zero, Decceleration * Time.deltaTime);
				zoomAcceleration = Mathf.Lerp(zoomAcceleration, 0, Decceleration * Time.deltaTime);
				moveAcceleration = Vector3.Lerp(moveAcceleration, Vector3.zero, Decceleration * Time.deltaTime);

				mouseDelta = Input.mousePosition;
			}

			public void ResetView()
			{
				Camera.main.transform.position = mResetCamPos;
				Camera.main.transform.eulerAngles = mResetCamRot;
			}
		}
	}
}