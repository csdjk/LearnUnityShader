//create by 长生但酒狂
// ------------------------【残影】---------------------------
Shader "lcl/shader3D/Ghost" {
	/// ------------------------【属性】---------------------------
	Properties{
		_Diffuse("Diffuse Color",Color) = (1,1,1,1)
		_Power("Power",Range(1,20)) = 10
	}
	// ------------------------【子着色器】---------------------------
	SubShader {
		Pass{
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM
			#include "../ShaderLibs/LightingModel.cginc"
			#pragma vertex vert
			#pragma fragment frag


			struct a2v {
				float4 vertex : POSITION;
				float3 normal: NORMAL;
			};

			struct v2f{
				float4 position:SV_POSITION;
				float3 worldNormal:COLOR0;
				float3 worldVertex: TEXCOORD1;
			};

			float mod289(float x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
			float4 mod289(float4 x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
			float4 perm(float4 x){return mod289(((x * 34.0) + 1.0) * x);}

			float noise(float3 p){
				float3 a = floor(p);
				float3 d = p - a;
				d = d * d * (3.0 - 2.0 * d);

				float4 b = a.xxyy + float4(0.0, 1.0, 0.0, 1.0);
				float4 k1 = perm(b.xyxy);
				float4 k2 = perm(k1.xyxy + b.zzww);

				float4 c = k2 + a.zzzz;
				float4 k3 = perm(c);
				float4 k4 = perm(c + 1.0);

				float4 o1 = frac(k3 * (1.0 / 41.0));
				float4 o2 = frac(k4 * (1.0 / 41.0));

				float4 o3 = o2 * d.z + o1 * (1.0 - d.z);
				float2 o4 = o3.yw * d.x + o3.xz * (1.0 - d.x);

				return o4.y * d.y + o4.x * (1.0 - d.y);
			}
		

			float4 _Diffuse;
			half _Power;
			// ------------------------【顶点着色器】---------------------------
			v2f vert(a2v v){
				v2f f;
				//计算世界空间下的法线和坐标
				f.worldNormal = mul(v.normal,(float3x3) unity_WorldToObject);
				f.worldVertex = mul(v.vertex,unity_WorldToObject).xyz;

				//
				v.vertex.xyz += float3(-1,0,0) * noise(v.vertex.xyz) * _Power; 

				f.position = UnityObjectToClipPos(v.vertex);
				return f;
			};

			

			fixed4 frag(v2f f):SV_TARGET{
				//兰伯特
				fixed3 resultColor = ComputeLambertLighting(f.worldNormal,_Diffuse);

				return fixed4(resultColor,1);
			};
			
			ENDCG
		}
	}
	FallBack "VertexLit"
}
