// Toony Colors Pro+Mobile 2
// (c) 2014-2020 Jean Moreno

using UnityEngine;

namespace ToonyColorsPro
{
	namespace Demo
	{
		public class TCP2_Demo_Camera : MonoBehaviour
		{
			//--------------------------------------------------------------------------------------------------
			// PUBLIC INSPECTOR PROPERTIES

			public Transform Pivot;
			public Vector3 pivotOffset;
			[Header("Orbit")]
			public float OrbitStrg = 3f;
			public float OrbitClamp = 50f;
			[Header("Panning")]
			public float PanStrgMin = 0.1f;
			public float PanStrgMax = 0.5f;
			[Header("Zooming")]
			public float ZoomStrg = 40f;
			public float ZoomClamp = 30f;
			public float ZoomDistMin = 1f;
			public float ZoomDistMax = 2f;
			[Header("Misc")]
			public float Decceleration = 8f;
			public RectTransform ignoreMouseRect;
			Rect ignoreMouseActualRect;

			//--------------------------------------------------------------------------------------------------
			// PRIVATE PROPERTIES

			private Vector3 mouseDelta;
			private Vector3 orbitAcceleration;
			private Vector3 panAcceleration;
			private Vector3 moveAcceleration;
			private float zoomAcceleration;
			private float zoomDistance;
			private const float XMax = 60;
			private const float XMin = 300;

			private Vector3 mResetCamPos, mResetPivotPos, mResetCamRot, mResetPivotRot;

			bool leftMouseHeld;
			bool rightMouseHeld;
			bool middleMouseHeld;

			//--------------------------------------------------------------------------------------------------
			// UNITY EVENTS

			void Awake()
			{
				mResetCamPos = transform.position;
				mResetCamRot = transform.eulerAngles;
				mResetPivotPos = Pivot.position;
				mResetPivotRot = Pivot.eulerAngles;
			}

			void OnEnable()
			{
				mouseDelta = Input.mousePosition;

				Vector2 size = Vector2.Scale(ignoreMouseRect.rect.size, ignoreMouseRect.lossyScale);
				Rect rect = new Rect(ignoreMouseRect.position.x, ignoreMouseRect.position.y, size.x, size.y);
				rect.x -= (ignoreMouseRect.pivot.x * size.x);
				rect.y -= ((-ignoreMouseRect.pivot.y) * size.y);

				ignoreMouseActualRect = rect;
			}

			void Update()
			{
				mouseDelta = Input.mousePosition - mouseDelta;
				mouseDelta.x = Mathf.Clamp(mouseDelta.x, -150f, 150f);
				mouseDelta.y = Mathf.Clamp(mouseDelta.y, -150f, 150f);

				var ignoreMouse = ignoreMouseRect != null ? ignoreMouseActualRect.Contains(Input.mousePosition) : false;

				if (Input.GetMouseButtonDown(0))
					leftMouseHeld = !ignoreMouse;
				else if (Input.GetMouseButtonUp(0) || !Input.GetMouseButton(0))
					leftMouseHeld = false;

				if (Input.GetMouseButtonDown(1))
					rightMouseHeld = !ignoreMouse;
				else if (Input.GetMouseButtonUp(1) || !Input.GetMouseButton(1))
					rightMouseHeld = false;

				if (Input.GetMouseButtonDown(2))
					middleMouseHeld = !ignoreMouse;
				else if (Input.GetMouseButtonUp(2) || !Input.GetMouseButton(2))
					middleMouseHeld = false;

				//Left Button held
				if (leftMouseHeld)
				{
					orbitAcceleration.x += Mathf.Clamp(mouseDelta.x * OrbitStrg, -OrbitClamp, OrbitClamp);
					orbitAcceleration.y += Mathf.Clamp(-mouseDelta.y * OrbitStrg, -OrbitClamp, OrbitClamp);
				}
				//Middle/Right Button held
				else if (middleMouseHeld || rightMouseHeld)
				{
					var str = Mathf.Lerp(PanStrgMin, PanStrgMax, Mathf.Clamp01((zoomDistance-ZoomDistMin)/(ZoomDistMax-ZoomDistMin)));
					panAcceleration.x = -mouseDelta.x * str;
					panAcceleration.y = -mouseDelta.y * str;
				}

				//Keyboard support
				//orbitAcceleration.x += Input.GetKey(KeyCode.LeftArrow) ? 15 : (Input.GetKey(KeyCode.RightArrow) ? -15 : 0);
				//orbitAcceleration.y += Input.GetKey(KeyCode.UpArrow) ? 15 : (Input.GetKey(KeyCode.DownArrow) ? -15 : 0);

				if (Input.GetKeyDown(KeyCode.R))
				{
					ResetView();
				}

				//X Angle Clamping
				var angle = transform.localEulerAngles;
				if (angle.x < 180 && angle.x >= XMax && orbitAcceleration.y > 0) orbitAcceleration.y = 0;
				if (angle.x > 180 && angle.x <= XMin && orbitAcceleration.y < 0) orbitAcceleration.y = 0;

				Vector3 pivotPlusOffset = Pivot.position + pivotOffset;

				//Rotate
				transform.RotateAround(pivotPlusOffset, transform.right, orbitAcceleration.y * Time.deltaTime);
				transform.RotateAround(pivotPlusOffset, Vector3.up, orbitAcceleration.x * Time.deltaTime);

				//Pan
				pivotOffset += transform.TransformDirection(panAcceleration) * Time.deltaTime;
				//Pivot.Translate(panAcceleration * Time.deltaTime, transform);
				transform.Translate(panAcceleration * Time.deltaTime, transform);

				//Zoom
				var scrollWheel = Input.GetAxis("Mouse ScrollWheel");
				zoomAcceleration += scrollWheel * ZoomStrg;
				zoomAcceleration = Mathf.Clamp(zoomAcceleration, -ZoomClamp, ZoomClamp);
				zoomDistance = Vector3.Distance(transform.position, pivotPlusOffset);
				if ((zoomDistance >= ZoomDistMin && zoomAcceleration > 0) || (zoomDistance <= ZoomDistMax && zoomAcceleration < 0))
				{
					transform.Translate(Vector3.forward * zoomAcceleration * Time.deltaTime, Space.Self);
				}

				//Decelerate
				orbitAcceleration = Vector3.Lerp(orbitAcceleration, Vector3.zero, Decceleration * Time.deltaTime);
				panAcceleration = Vector3.Lerp(panAcceleration, Vector3.zero, Decceleration * Time.deltaTime);
				zoomAcceleration = Mathf.Lerp(zoomAcceleration, 0, Decceleration * Time.deltaTime);
				moveAcceleration = Vector3.Lerp(moveAcceleration, Vector3.zero, Decceleration * Time.deltaTime);

				mouseDelta = Input.mousePosition;
			}

			public void ResetView()
			{
				moveAcceleration = Vector3.zero;
				orbitAcceleration = Vector3.zero;
				panAcceleration = Vector3.zero;
				pivotOffset = Vector3.zero;
				zoomAcceleration = 0f;

				transform.position = mResetCamPos;
				transform.eulerAngles = mResetCamRot;
				Pivot.position = mResetPivotPos;
				Pivot.eulerAngles = mResetPivotRot;

			}
		}
	}
}