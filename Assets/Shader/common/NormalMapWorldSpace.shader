
Shader "lcl/Common/NormalMapWorldSpace"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BumpTex("BumpTex",2D)="white"{}
		_BumpScale("BumpScale",Range(-2.0,2.0))=-1.0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal:NORMAL;
				float4 tangent:TANGENT;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 T2W0:TEXCOORD1;
				float3 T2W1:TEXCOORD2;
				float3 T2W2:TEXCOORD3;
				float3 worldViewDir:TEXCOORD4;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpTex;
			float _BumpScale;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				float3 worldNormal=UnityObjectToWorldNormal(v.normal);
				float3 worldTangent=UnityObjectToWorldDir(v.tangent.xyz);
				//切线，法线都垂直的方向有两个，而w决定了我们选择哪一个方向
				float3 worldBinormal=cross(worldNormal,worldTangent)*v.tangent.w;
				//构建变换矩阵
				//z轴是法线方向(n)，x轴是切线方向(t)，y轴可由法线和切线叉积得到，也称为副切线（bitangent, b）
				o.T2W0=float3(worldTangent.x,worldBinormal.x,worldNormal.x);
				o.T2W1=float3(worldTangent.y,worldBinormal.y,worldNormal.y);
				o.T2W2=float3(worldTangent.z,worldBinormal.z,worldNormal.z);
				o.worldViewDir=WorldSpaceViewDir(v.vertex);
				return o;
			}
			
			float4 frag (v2f i) : SV_Target
			{
				float4 packedNormal = tex2D(_BumpTex, i.uv);
				//解析法线贴图的采样
                float3 tangentNormal = UnpackNormal(packedNormal);
				//乘以凹凸系数
                tangentNormal.xy *= _BumpScale;
				//向量点乘自身算出x2+y2，再求出z的值
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
				//向量变换只需要3*3
				float3x3 T2WMatrix=float3x3(i.T2W0,i.T2W1,i.T2W2);								
				float3 worldNormal=mul(T2WMatrix,tangentNormal);
				worldNormal=normalize(worldNormal);
				float3 worldLightDir=normalize(-_WorldSpaceLightPos0.xyz);
				float3 col = tex2D(_MainTex, i.uv).xyz;
				float3 diffuse=_LightColor0.rgb*col*saturate(dot(worldNormal,worldLightDir));
				float3 ambient=col*UNITY_LIGHTMODEL_AMBIENT.xyz;
				float3 worldHalfDir=normalize(worldLightDir+normalize(i.worldViewDir));
				float3 specular=_LightColor0.rgb*pow(saturate(dot(worldHalfDir,worldNormal)),20);
				specular*=smoothstep(0.0,0.5,dot(worldNormal,worldLightDir));
				return float4(specular+diffuse+ambient,1.0);
			}
			ENDCG
		}
	}
}
