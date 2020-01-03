// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

//create by 长生但酒狂
// ------------------------【残影】---------------------------
Shader "lcl/shader3D/Ghost" {
	/// ------------------------【属性】---------------------------
	Properties{
		// 材质颜色
		_Diffuse("Diffuse Color",Color) = (1,1,1,1)
		// 残影颜色
		_GhostColor("Ghost Color",Color) = (1,1,1,1)
		// 残影方向
		_Direction("Direction",vector) = (0,0,0)
		// 残影强度
		_Power("Power",Range(0,1)) = 0.1
	}
	// ------------------------【子着色器】---------------------------
	SubShader {
		// ------------------------【渲染通道】---------------------------
		Pass{

			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			#include "../ShaderLibs/LightingModel.cginc"
			#include "../ShaderLibs/Noise.cginc"

			#pragma vertex vert
			#pragma fragment frag
			//顶点着色器输入结构体
			struct a2v {
				float4 vertex : POSITION;
				float3 normal: NORMAL;
			};
			//片元着色器输入结构体
			struct v2f{
				float4 position:SV_POSITION;
				float3 worldNormal:COLOR0;
				float3 worldVertex: TEXCOORD0;
				float isOffset:TEXCOORD1;
				float radian:TEXCOORD2;
			};
			//变量声明
			fixed4 _Diffuse;
			fixed4 _GhostColor;
			float3 _Direction;
			half _Power;
			
			//随机数 - 2D Random
			float random (in float2 st) {
				return frac(sin(dot(st.xy,
				float2(12.9898,78.233)))
				* 43758.5453123);
			}
			
			// ------------------------【顶点着色器】---------------------------
			v2f vert(a2v v){
				v2f f;
				// 计算世界空间下的法线和坐标
				f.worldNormal = mul(v.normal,(float3x3) unity_WorldToObject);
				f.worldVertex = mul(v.vertex,unity_WorldToObject).xyz;
				//
				// float isOffsetX = 1 - step(0,v.vertex.x * - _Direction.x);
				// float isOffsetY = 1 - step(0,v.vertex.y * - _Direction.y);
				// float isOffsetZ = 1 - step(0,v.vertex.z * - _Direction.z);
				// float isOffset = saturate(isOffsetX + isOffsetY + isOffsetZ);
				// 通过计算法线与残影方向的夹角,判断该顶点是否在运动方向的背面(需要偏移的顶点)；
				f.radian = dot(normalize(v.normal),_Direction);
				float isOffset = step(0,f.radian);
				// if(length(_Direction) == 0){
				// 	isOffset = 0;
				// }
				// 通过残影方向,强度,随机数计算偏移量；
				v.vertex.xyz += _Direction * random(v.vertex.xy) * _Power * isOffset; 
				// 传递给片元着色器
				f.isOffset = isOffset;
				// 转换坐标到裁剪空间
				f.position = UnityObjectToClipPos(v.vertex);
				return f;

			};

			
			// ------------------------【片元着色器】---------------------------
			fixed4 frag(v2f f):SV_TARGET{
				//计算兰伯特光照模型
				fixed3 resultColor = ComputeLambertLighting(f.worldNormal,_Diffuse);
				//叠加残影颜色
				// resultColor += f.isOffset * _GhostColor;
				resultColor = lerp(resultColor,_GhostColor,f.radian);
				// 输出
				return fixed4(resultColor,1);
			};
			
			ENDCG
		}
	}
	FallBack "VertexLit"
}
