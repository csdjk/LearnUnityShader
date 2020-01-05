
Shader "lcl/shader3D/outLine3D_swell_normalMap"
{
	//属性
	Properties{
		_Diffuse("Diffuse", Color) = (1,1,1,1)
		_MainTex("Base 2D", 2D) = "white"{}
		_BumpMap("Bump Map", 2D) = "bump"{}
		_BumpScale ("Bump Scale", Range(0.1, 30.0)) = 10.0
		// 描边强度
		_power("power",Range(0,0.2)) = 0.05
		// 描边颜色
		_lineColor("lineColor",Color)=(1,1,1,1)
	}
	
	
	CGINCLUDE
	//引入头文件
	#include "../ShaderLibs/LightingModel.cginc"

	sampler2D _MainTex;
	sampler2D _BumpMap;
	float4 _MainTex_ST;
	float _BumpScale;
	//主颜色
	float4 _Diffuse;
	//描边强度
	float _power;
	//描边颜色
	float4 _lineColor;
	//顶点着色器输入结构体
	struct appdata
	{
		float4 vertex : POSITION;//顶点坐标
		float2 texcoord : TEXCOORD0;//纹理坐标
		float3 normal:NORMAL;//法线
		float4 tangent : TANGENT;
	};
	//定义结构体：vertex shader阶段输出的内容
	struct v2f
	{
		float4 vertex : SV_POSITION;
		//转化纹理坐标
		float2 uv : TEXCOORD0;
		//tangent空间的光线方向
		float3 lightDir : TEXCOORD1;
	};

	// ------------------------【背面-顶点着色器】---------------------------
	v2f vert_back (appdata v)
	{
		v2f o;
		//法线方向
		v.normal = normalize(v.normal);
		//顶点沿着法线方向扩张
		v.vertex.xyz +=  v.normal * _power;
		//由模型空间坐标系转换到裁剪空间
		o.vertex = UnityObjectToClipPos(v.vertex);
		//输出结果
		o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
		return o;
	}

	// ------------------------【背面-片元着色器】---------------------------
	fixed4 frag_back (v2f i) : SV_Target
	{
		//直接输出颜色
		return _lineColor;
	}
	// ------------------------【正面-顶点着色器】---------------------------
	v2f vert_front(appdata v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		//这个宏为我们定义好了模型空间到切线空间的转换矩阵rotation
		TANGENT_SPACE_ROTATION;
		//ObjectSpaceLightDir可以把光线方向转化到模型空间，然后通过rotation再转化到切线空间
		o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex));
		//通过TRANSFORM_TEX宏转化纹理坐标，主要处理了Offset和Tiling的改变,默认时等同于o.uv = v.texcoord.xy;
		o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
		return o;
	}
	// ------------------------【正面-片元着色器】---------------------------
	fixed4 frag_front(v2f i) : SV_Target
	{
		fixed3 result = ComputeNormalMap(_MainTex, _BumpMap, i.uv, i.lightDir,_BumpScale, _Diffuse);
		return fixed4(result , 1.0);
	}
	ENDCG

	//子着色器	
	SubShader
	{

		//透明度混合模式
		Blend SrcAlpha OneMinusSrcAlpha
		//渲染队列
		Tags{ "Queue" = "Transparent"}
		
		// ------------------------【背面通道】---------------------------
		Pass
		{
			//剔除正面
			Cull Front
			//防止背面模型穿透正面模型
			//关闭深度写入，为了让正面的pass完全覆盖背面，同时要把渲染队列改成Transparent，此时物体渲染顺序是从后到前的
			ZWrite Off

			CGPROGRAM
			#pragma vertex vert_back
			#pragma fragment frag_back
			ENDCG
		}

		// ------------------------【正面通道】---------------------------
		Pass
		{
			//定义Tags
			CGPROGRAM
			//使用vert函数和frag函数
			#pragma vertex vert_front
			#pragma fragment frag_front	
			ENDCG
		}
		
	}
	//前面的Shader失效的话，使用默认的Diffuse
	FallBack "Diffuse"
}