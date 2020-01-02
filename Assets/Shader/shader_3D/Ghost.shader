//create by 长生但酒狂
// ------------------------【残影】---------------------------
Shader "lcl/shader3D/Ghost" {
	/// ------------------------【属性】---------------------------
	Properties{
		_Diffuse("Diffuse Color",Color) = (1,1,1,1)
		_Direction("Direction",vector) = (0,0,0)
		_Power("Power",Range(0,1)) = 0.1
	}
	// ------------------------【子着色器】---------------------------
	SubShader {
		Pass{
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM
			#include "../ShaderLibs/LightingModel.cginc"
			#include "../ShaderLibs/Noise.cginc"

			#pragma vertex vert
			#pragma fragment frag
			// defined (USING_SIMPLEX_NOISE)	

			struct a2v {
				float4 vertex : POSITION;
				float3 normal: NORMAL;
			};

			struct v2f{
				float4 position:SV_POSITION;
				float3 worldNormal:COLOR0;
				float3 worldVertex: TEXCOORD0;
				float isOffset:TEXCOORD1;
			};
			
			float4 _Diffuse;
			float3 _Direction;
			half _Power;
			
			// 2D Random
			float random (in float2 st) {
				return frac(sin(dot(st.xy,
				float2(12.9898,78.233)))
				* 43758.5453123);
			}
			
			// ------------------------【顶点着色器】---------------------------
			v2f vert(a2v v){
				v2f f;
				//计算世界空间下的法线和坐标
				f.worldNormal = mul(v.normal,(float3x3) unity_WorldToObject);
				f.worldVertex = mul(v.vertex,unity_WorldToObject).xyz;

				//
				float isOffsetX = 1 - step(0,v.vertex.x * - _Direction.x);
				float isOffsetY = 1 - step(0,v.vertex.y * - _Direction.y);
				float isOffsetZ = 1 - step(0,v.vertex.z * - _Direction.z);

				// float3 isOffset = float3(1,1,1)-step(float3(0,0,0),v.vertex * - _Direction);

				float isOffset = saturate(isOffsetX + isOffsetY + isOffsetZ);
				// float isOffset = isOffsetX * isOffsetY * isOffsetZ;
				v.vertex.xyz += _Direction * random(v.vertex.xy) * _Power * isOffset; 
				
				f.isOffset = isOffset;
				f.position = UnityObjectToClipPos(v.vertex);
				return f;
			};

			

			fixed4 frag(v2f f):SV_TARGET{
				//兰伯特
				fixed3 resultColor = ComputeLambertLighting(f.worldNormal,_Diffuse);

				resultColor = resultColor + f.isOffset * float3(0,1,1);

				return fixed4(resultColor,1);
			};
			
			ENDCG
		}
	}
	FallBack "VertexLit"
}
