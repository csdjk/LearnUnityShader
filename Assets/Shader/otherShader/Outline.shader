// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//描边Shader
//by：puppet_master
//2017.1.5
 
Shader "ApcShader/Outline"
{
	//属性
	Properties{
		_Diffuse("Diffuse", Color) = (1,1,1,1)
		_OutlineCol("OutlineCol", Color) = (1,0,0,1)
		_OutlineFactor("OutlineFactor", Range(0,1)) = 0.1
		_MainTex("Base 2D", 2D) = "white"{}
		  _OffsetFactor ("Offset Factor", Range(0,200)) = 0
        _OffsetUnits ("Offset Units", Range(0,200)) = 0
	}
 
	//子着色器	
	SubShader
	{
		
		//描边使用两个Pass，第一个pass沿法线挤出一点，只输出描边的颜色
		Pass
		{
			//剔除正面，只渲染背面，对于大多数模型适用，不过如果需要背面的，就有问题了
			Cull Front
			//控制深度偏移，描边pass远离相机一些，防止与正常pass穿插
			Offset [_OffsetFactor], [_OffsetUnits]
			
			CGPROGRAM
			#include "UnityCG.cginc"
			fixed4 _OutlineCol;
			float _OutlineFactor;
			
			struct v2f
			{
				float4 pos : SV_POSITION;
			};
			
			v2f vert(appdata_full v)
			{
				v2f o;
				//在vertex阶段，每个顶点按照法线的方向偏移一部分，不过这种会造成近大远小的透视问题
				//v.vertex.xyz += v.normal * _OutlineFactor;
				o.pos = UnityObjectToClipPos(v.vertex);
				//将法线方向转换到视空间
				float3 vnormal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
				//将视空间法线xy坐标转化到投影空间，只有xy需要，z深度不需要了
				float2 offset = TransformViewToProjection(vnormal.xy);
				//在最终投影阶段输出进行偏移操作
				o.pos.xy += offset * _OutlineFactor;
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target
			{
				//这个Pass直接输出描边颜色
				return _OutlineCol;
			}
			
			//使用vert函数和frag函数
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
		
		//正常着色的Pass
		Pass
		{
			CGPROGRAM	
		
			//引入头文件
			#include "Lighting.cginc"
			//定义Properties中的变量
			fixed4 _Diffuse;
			sampler2D _MainTex;
			//使用了TRANSFROM_TEX宏就需要定义XXX_ST
			float4 _MainTex_ST;
 
			//定义结构体：vertex shader阶段输出的内容
			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float2 uv : TEXCOORD1;
			};
 
			//定义顶点shader,参数直接使用appdata_base（包含position, noramal, texcoord）
			v2f vert(appdata_base v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				//通过TRANSFORM_TEX宏转化纹理坐标，主要处理了Offset和Tiling的改变,默认时等同于o.uv = v.texcoord.xy;
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
				return o;
			}
 
			//定义片元shader
			fixed4 frag(v2f i) : SV_Target
			{
				//unity自身的diffuse也是带了环境光，这里我们也增加一下环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * _Diffuse.xyz;
				//归一化法线，即使在vert归一化也不行，从vert到frag阶段有差值处理，传入的法线方向并不是vertex shader直接传出的
				fixed3 worldNormal = normalize(i.worldNormal);
				//把光照方向归一化
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				//根据半兰伯特模型计算像素的光照信息
				fixed3 lambert = 0.5 * dot(worldNormal, worldLightDir) + 0.5;
				//最终输出颜色为lambert光强*材质diffuse颜色*光颜色
				fixed3 diffuse = lambert * _Diffuse.xyz * _LightColor0.xyz + ambient;
				//进行纹理采样
				fixed4 color = tex2D(_MainTex, i.uv);
				color.rgb = color.rgb* diffuse;
				return fixed4(color);
			}
 
			//使用vert函数和frag函数
			#pragma vertex vert
			#pragma fragment frag	
 
			ENDCG
		}
	}
	//前面的Shader失效的话，使用默认的Diffuse
	FallBack "Diffuse"
}