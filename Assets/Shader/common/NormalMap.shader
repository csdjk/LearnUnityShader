// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//Bump Map
//by：puppet_master
//2016.12.14
Shader "lcl/Common/NormalMap"
{
	//属性
	Properties{
		_Diffuse("Diffuse", Color) = (1,1,1,1)
		_MainTex("Base 2D", 2D) = "white"{}
		_BumpMap("Bump Map", 2D) = "bump"{}
		_BumpScale ("Bump Scale", Range(0.1, 30.0)) = 10.0
	}
 
	//子着色器	
	SubShader
	{
		Pass
		{
			//定义Tags
			Tags{ "RenderType" = "Opaque" }
 
			CGPROGRAM
			//引入头文件
			#include "Lighting.cginc"
			//定义Properties中的变量
			fixed4 _Diffuse;
			sampler2D _MainTex;
			//使用了TRANSFROM_TEX宏就需要定义XXX_ST
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float _BumpScale;
 
			//定义结构体：vertex shader阶段输出的内容
			struct v2f
			{
				float4 pos : SV_POSITION;
				//转化纹理坐标
				float2 uv : TEXCOORD0;
				//tangent空间的光线方向
				float3 lightDir : TEXCOORD1;
			};
 
			//定义顶点shader
			v2f vert(appdata_tan v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				//这个宏为我们定义好了模型空间到切线空间的转换矩阵rotation，注意后面有个；
				TANGENT_SPACE_ROTATION;
				//ObjectSpaceLightDir可以把光线方向转化到模型空间，然后通过rotation再转化到切线空间
				o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex));
				//通过TRANSFORM_TEX宏转化纹理坐标，主要处理了Offset和Tiling的改变,默认时等同于o.uv = v.texcoord.xy;
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}
 
			//定义片元shader
			fixed4 frag(v2f i) : SV_Target
			{
				//unity自身的diffuse也是带了环境光，这里我们也增加一下环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * _Diffuse.xyz;
				//直接解出切线空间法线
				float3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uv));
				tangentNormal.xy *= _BumpScale;
				//normalize一下切线空间的光照方向
				float3 tangentLight = normalize(i.lightDir);
				//根据半兰伯特模型计算像素的光照信息
				fixed3 lambert = max(0,dot(tangentNormal, tangentLight));
				//最终输出颜色为lambert光强*材质diffuse颜色*光颜色
				fixed3 diffuse = lambert * _Diffuse.xyz * _LightColor0.xyz + ambient;
				//进行纹理采样
				fixed4 color = tex2D(_MainTex, i.uv);
				
				return fixed4(diffuse * color.rgb, 1.0);
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