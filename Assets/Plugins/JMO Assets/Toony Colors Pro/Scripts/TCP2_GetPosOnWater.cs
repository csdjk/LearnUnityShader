// Toony Colors Pro+Mobile 2
// (c) 2014-2020 Jean Moreno

using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif

// Script to get the water height from a specific world position
// Useful to easily make objects float on water for example

namespace ToonyColorsPro
{
	namespace Runtime
	{
		public class TCP2_GetPosOnWater : MonoBehaviour
		{
			public Material WaterMaterial;
			[Tooltip("Height scale, for example if the water mesh is scaled along its Y axis")]
			public float heightScale = 1f;

			[Space]
			[Tooltip("Will make the object stick to the water plane")]
			public bool followWaterHeight = true;
			[Tooltip("Y Position offset")]
			public float heightOffset;

			[Space]
			[Tooltip("Will align the object to the wave normal based on its position")]
			public bool followWaterNormal;
			[Tooltip("Determine the object's up axis (when following wave normal)")]
			public Vector3 upAxis = new Vector3(0, 1, 0);
			[Tooltip("Rotation of the object once it's been affected by the water normal")]
			public Vector3 postRotation = new Vector3(0, 0, 0);

			[SerializeField, HideInInspector]
			bool isValid;
			[SerializeField, HideInInspector]
			int sineCount;

			float[] sinePosOffsetsX = { 1.0f, 2.2f, 2.7f, 3.4f, 1.4f, 1.8f, 4.2f, 3.6f };
			float[] sinePosOffsetsZ = { 0.6f, 1.3f, 3.1f, 2.4f, 1.1f, 2.8f, 1.7f, 4.3f };
			float[] sinePhsOffsetsX = { 1.0f, 1.3f, 0.7f, 1.75f, 0.2f, 2.6f, 0.7f, 3.1f };
			float[] sinePhsOffsetsZ = { 2.2f, 0.4f, 3.3f, 2.9f, 0.5f, 4.8f, 3.1f, 2.3f };

#if UNITY_EDITOR
			//Verify that the material has a valid shader
			void OnValidate()
			{
				isValid = false;

				if (WaterMaterial == null)
					return;

				var shader = WaterMaterial.shader;
				if (shader == null)
				{
					WaterMaterial = null;
				}

				var validMaterial = false;
				var assetImporter = AssetImporter.GetAtPath(AssetDatabase.GetAssetPath(shader)) as ShaderImporter;
				if (assetImporter != null)
				{
					sineCount = 1;
					var userData = assetImporter.userData.Split(',');
					foreach (var ud in userData)
					{
						if (ud == "FVERTEX_SIN_WAVES")
							validMaterial = true;

						if (ud == "FVSW_8")
							sineCount = 8;

						if (ud == "FVSW_4")
							sineCount = 4;

						if (ud == "FVSW_2")
							sineCount = 2;
					}
				}

				if (!validMaterial)
				{
					WaterMaterial = null;
					Debug.LogWarning("Please use a material that has a generated TCP2 Water Shader!");
				}

				isValid = validMaterial;
			}
#endif

			void LateUpdate()
			{
				if (followWaterHeight)
				{
					var worldPosition = GetPositionOnWater(transform.position);
					worldPosition.y += heightOffset;
					transform.position = worldPosition;
				}

				if (followWaterNormal)
				{
					transform.rotation = Quaternion.FromToRotation(upAxis, GetNormalOnWater(transform.position));
					transform.Rotate(postRotation, Space.Self);
				}
			}

			//Returns a world space position on a water plane, based on its material
			public Vector3 GetPositionOnWater(Vector3 worldPosition)
			{
				if (!isValid)
				{
					Debug.LogWarning("Invalid Water Material, returning the same worldPosition");
					return worldPosition;
				}

				var freq = WaterMaterial.GetFloat("_WaveFrequency");
				var height = WaterMaterial.GetFloat("_WaveHeight") * heightScale;
				var speed = WaterMaterial.GetFloat("_WaveSpeed");

				var phase = Time.time * speed;
				var x = worldPosition.x * freq;
				var z = worldPosition.z * freq;

				var waveFactorX = 0f;
				var waveFactorZ = 0f;

				switch (sineCount)
				{
					case 1:
						waveFactorX = Mathf.Sin(x + phase) * height;
						waveFactorZ = Mathf.Sin(z + phase) * height;
						break;

					case 2:
						waveFactorX = (Mathf.Sin(sinePosOffsetsX[0] * x + sinePhsOffsetsX[0] * phase) + Mathf.Sin(sinePosOffsetsX[1] * x + sinePhsOffsetsX[1] * phase)) * height / 2f;
						waveFactorZ = (Mathf.Sin(sinePosOffsetsZ[0] * z + sinePhsOffsetsZ[0] * phase) + Mathf.Sin(sinePosOffsetsZ[1] * z + sinePhsOffsetsZ[1] * phase)) * height / 2f;
						break;

					case 4:
						waveFactorX = (Mathf.Sin(sinePosOffsetsX[0] * x + sinePhsOffsetsX[0] * phase) + Mathf.Sin(sinePosOffsetsX[1] * x + sinePhsOffsetsX[1] * phase) + Mathf.Sin(sinePosOffsetsX[2] * x + sinePhsOffsetsX[2] * phase) + Mathf.Sin(sinePosOffsetsX[3] * x + sinePhsOffsetsX[3] * phase)) * height / 4f;
						waveFactorZ = (Mathf.Sin(sinePosOffsetsZ[0] * z + sinePhsOffsetsZ[0] * phase) + Mathf.Sin(sinePosOffsetsZ[1] * z + sinePhsOffsetsZ[1] * phase) + Mathf.Sin(sinePosOffsetsZ[2] * z + sinePhsOffsetsZ[2] * phase) + Mathf.Sin(sinePosOffsetsZ[3] * z + sinePhsOffsetsZ[3] * phase)) * height / 4f;
						break;

					case 8:
						waveFactorX = (Mathf.Sin(sinePosOffsetsX[0] * x + sinePhsOffsetsX[0] * phase) + Mathf.Sin(sinePosOffsetsX[1] * x + sinePhsOffsetsX[1] * phase) + Mathf.Sin(sinePosOffsetsX[2] * x + sinePhsOffsetsX[2] * phase) + Mathf.Sin(sinePosOffsetsX[3] * x + sinePhsOffsetsX[3] * phase) + Mathf.Sin(sinePosOffsetsX[4] * x + sinePhsOffsetsX[4] * phase) + Mathf.Sin(sinePosOffsetsX[5] * x + sinePhsOffsetsX[5] * phase) + Mathf.Sin(sinePosOffsetsX[6] * x + sinePhsOffsetsX[6] * phase) + Mathf.Sin(sinePosOffsetsX[7] * x + sinePhsOffsetsX[7] * phase)) * height / 8f;
						waveFactorZ = (Mathf.Sin(sinePosOffsetsZ[0] * z + sinePhsOffsetsZ[0] * phase) + Mathf.Sin(sinePosOffsetsZ[1] * z + sinePhsOffsetsZ[1] * phase) + Mathf.Sin(sinePosOffsetsZ[2] * z + sinePhsOffsetsZ[2] * phase) + Mathf.Sin(sinePosOffsetsZ[3] * z + sinePhsOffsetsZ[3] * phase) + Mathf.Sin(sinePosOffsetsZ[4] * z + sinePhsOffsetsZ[4] * phase) + Mathf.Sin(sinePosOffsetsZ[5] * z + sinePhsOffsetsZ[5] * phase) + Mathf.Sin(sinePosOffsetsZ[6] * z + sinePhsOffsetsZ[6] * phase) + Mathf.Sin(sinePosOffsetsZ[7] * z + sinePhsOffsetsZ[7] * phase)) * height / 8f;
						break;

				}

				worldPosition.y = (waveFactorX + waveFactorZ);
				return worldPosition;
			}

			public Vector3 GetNormalOnWater(Vector3 worldPosition)
			{
				if (!isValid)
				{
					Debug.LogWarning("Invalid Water Material, returning the Vector3.up as the normal");
					return Vector3.up;
				}

				var freq = WaterMaterial.GetFloat("_WaveFrequency");
				var height = WaterMaterial.GetFloat("_WaveHeight") * heightScale;
				var speed = WaterMaterial.GetFloat("_WaveSpeed");

				var phase = Time.time * speed;
				var x = worldPosition.x * freq;
				var z = worldPosition.z * freq;

				var waveNormalX = 0f;
				var waveNormalZ = 0f;

				switch (sineCount)
				{
					case 1:
						waveNormalX = -height * Mathf.Cos(x + phase);
						waveNormalZ = -height * Mathf.Cos(z + phase);
						break;

					case 2:
						waveNormalX = -height/2f * ((Mathf.Cos(sinePosOffsetsX[0]*x + sinePhsOffsetsX[0]*phase)*sinePosOffsetsX[0]) + (Mathf.Cos(sinePosOffsetsX[1]*x + sinePhsOffsetsX[1]*phase)*sinePosOffsetsX[1]));
						waveNormalZ = -height/2f * ((Mathf.Cos(sinePosOffsetsZ[0]*z + sinePhsOffsetsZ[0]*phase)*sinePosOffsetsZ[0]) + (Mathf.Cos(sinePosOffsetsZ[1]*z + sinePhsOffsetsZ[1]*phase)*sinePosOffsetsZ[1]));
						break;

					case 4:
						waveNormalX = -height/4f * ((Mathf.Cos(sinePosOffsetsX[0]*x + sinePhsOffsetsX[0]*phase)*sinePosOffsetsX[0]) + (Mathf.Cos(sinePosOffsetsX[1]*x + sinePhsOffsetsX[1]*phase)*sinePosOffsetsX[1]) + (Mathf.Cos(sinePosOffsetsX[2]*x + sinePhsOffsetsX[2]*phase)*sinePosOffsetsX[2]) + (Mathf.Cos(sinePosOffsetsX[3]*x + sinePhsOffsetsX[3]*phase)*sinePosOffsetsX[3]));
						waveNormalZ = -height/4f * ((Mathf.Cos(sinePosOffsetsZ[0]*z + sinePhsOffsetsZ[0]*phase)*sinePosOffsetsZ[0]) + (Mathf.Cos(sinePosOffsetsZ[1]*z + sinePhsOffsetsZ[1]*phase)*sinePosOffsetsZ[1]) + (Mathf.Cos(sinePosOffsetsZ[2]*z + sinePhsOffsetsZ[2]*phase)*sinePosOffsetsZ[2]) + (Mathf.Cos(sinePosOffsetsZ[3]*z + sinePhsOffsetsZ[3]*phase)*sinePosOffsetsZ[3]));
						break;

					case 8:
						waveNormalX = -height/8f * ((Mathf.Cos(sinePosOffsetsX[0]*x + sinePhsOffsetsX[0]*phase)*sinePosOffsetsX[0]) + (Mathf.Cos(sinePosOffsetsX[1]*x + sinePhsOffsetsX[1]*phase)*sinePosOffsetsX[1]) + (Mathf.Cos(sinePosOffsetsX[2]*x + sinePhsOffsetsX[2]*phase)*sinePosOffsetsX[2]) + (Mathf.Cos(sinePosOffsetsX[3]*x + sinePhsOffsetsX[3]*phase)*sinePosOffsetsX[3]) + (Mathf.Cos(sinePosOffsetsX[4]*x + sinePhsOffsetsX[4]*phase)*sinePosOffsetsX[4]) + (Mathf.Cos(sinePosOffsetsX[5]*x + sinePhsOffsetsX[5]*phase)*sinePosOffsetsX[5]) + (Mathf.Cos(sinePosOffsetsX[6]*x + sinePhsOffsetsX[6]*phase)*sinePosOffsetsX[6]) + (Mathf.Cos(sinePosOffsetsX[7]*x + sinePhsOffsetsX[7]*phase)*sinePosOffsetsX[7]));
						waveNormalZ = -height/8f * ((Mathf.Cos(sinePosOffsetsZ[0]*z + sinePhsOffsetsZ[0]*phase)*sinePosOffsetsZ[0]) + (Mathf.Cos(sinePosOffsetsZ[1]*z + sinePhsOffsetsZ[1]*phase)*sinePosOffsetsZ[1]) + (Mathf.Cos(sinePosOffsetsZ[2]*z + sinePhsOffsetsZ[2]*phase)*sinePosOffsetsZ[2]) + (Mathf.Cos(sinePosOffsetsZ[3]*z + sinePhsOffsetsZ[3]*phase)*sinePosOffsetsZ[3]) + (Mathf.Cos(sinePosOffsetsZ[4]*z + sinePhsOffsetsZ[4]*phase)*sinePosOffsetsZ[4]) + (Mathf.Cos(sinePosOffsetsZ[5]*z + sinePhsOffsetsZ[5]*phase)*sinePosOffsetsZ[5]) + (Mathf.Cos(sinePosOffsetsZ[6]*z + sinePhsOffsetsZ[6]*phase)*sinePosOffsetsZ[6]) + (Mathf.Cos(sinePosOffsetsZ[7]*z + sinePhsOffsetsZ[7]*phase)*sinePosOffsetsZ[7]));
						break;
				}

				return new Vector3(waveNormalX, 1, waveNormalZ).normalized; ;
			}
		}
	}
}