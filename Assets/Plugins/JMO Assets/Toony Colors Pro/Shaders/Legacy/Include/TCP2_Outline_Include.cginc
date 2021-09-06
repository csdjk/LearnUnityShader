// Toony Colors Pro+Mobile Shaders
// (c) 2014-2019 Jean Moreno

#ifndef TOONYCOLORS_OUTLINE_INCLUDED
	#define TOONYCOLORS_OUTLINE_INCLUDED

	struct a2v
	{
		float4 vertex : POSITION;
		
		float3 normal : NORMAL;
	#if defined(TCP2_UV1_AS_NORMALS) || defined(TCP2_OUTLINE_TEXTURED)
		float4 texcoord0 : TEXCOORD0;
	#elif defined(TCP2_UV2_AS_NORMALS)
		float4 texcoord1 : TEXCOORD1;
	#elif defined(TCP2_UV3_AS_NORMALS)
		float4 texcoord2 : TEXCOORD2;
	#elif defined(TCP2_UV4_AS_NORMALS)
		float4 texcoord3 : TEXCOORD3;
	#endif
	#if defined(TCP2_COLORS_AS_NORMALS)
		float4 vertexColor : COLOR;
	#endif
	#if defined(TCP2_TANGENT_AS_NORMALS) || (defined(TCP2_OUTLINE_LIGHTING_ALL) && defined(_ADDITIONAL_LIGHTS_VERTEX))
		float4 tangent : TANGENT;
	#endif

	#if UNITY_VERSION >= 550
		UNITY_VERTEX_INPUT_INSTANCE_ID
	#endif
    }; 
	
	struct v2f
	{
		float4 pos : SV_POSITION;
	#if TCP2_OUTLINE_TEXTURED
		float3 texlod : TEXCOORD1;
	#endif
	};
	
	float _Outline;
	float _ZSmooth;
	fixed4 _OutlineColor;
	
#if TCP2_OUTLINE_TEXTURED
	sampler2D _MainTex;
	float4 _MainTex_ST;
	float _TexLod;
#endif

#endif

v2f TCP2_Outline_Vert(a2v v)
{
	v2f o;
	
#if UNITY_VERSION >= 550
	//GPU instancing support
	UNITY_SETUP_INSTANCE_ID(v);
#endif
	
//Correct Z artefacts
#if TCP2_ZSMOOTH_ON
	float4 pos = float4(UnityObjectToViewPos(v.vertex), 1.0);
	
	#ifdef TCP2_COLORS_AS_NORMALS
		//Vertex Color for Normals
		float3 normal = (v.vertexColor.xyz*2) - 1;
	#elif TCP2_TANGENT_AS_NORMALS
		//Tangent for Normals
		float3 normal = v.tangent.xyz;
	#elif TCP2_UV1_AS_NORMALS || TCP2_UV2_AS_NORMALS || TCP2_UV3_AS_NORMALS || TCP2_UV4_AS_NORMALS
		#if TCP2_UV1_AS_NORMALS
			#define uvChannel texcoord0
		#elif TCP2_UV2_AS_NORMALS
			#define uvChannel texcoord1
		#elif TCP2_UV3_AS_NORMALS
			#define uvChannel texcoord2
		#elif TCP2_UV4_AS_NORMALS
			#define uvChannel texcoord3
		#endif

		#if TCP2_UV_NORMALS_FULL
		//UV for Normals, full
		float3 normal = v.uvChannel.xyz;
		#else
		//UV for Normals, compressed
		#if TCP2_UV_NORMALS_ZW
			#define ch1 z
			#define ch2 w
		#else
			#define ch1 x
			#define ch2 y
		#endif
		float3 n;
		//unpack uvs
		v.uvChannel.ch1 = v.uvChannel.ch1 * 255.0/16.0;
		n.x = floor(v.uvChannel.ch1) / 15.0;
		n.y = frac(v.uvChannel.ch1) * 16.0 / 15.0;
		//- get z
		n.z = v.uvChannel.ch2;
		//- transform
		n = n*2 - 1;
		float3 normal = n;
		#endif
	#else
		float3 normal = v.normal;
	#endif
	
	normal = mul((float3x3)UNITY_MATRIX_IT_MV, normal);
	normal.z = -_ZSmooth;
	
	#ifdef TCP2_OUTLINE_CONST_SIZE
		//Camera-independent outline size
		float dist = distance(_WorldSpaceCameraPos, mul(unity_ObjectToWorld, v.vertex));
		pos = pos + float4(normalize(normal),0) * _Outline * 0.01 * dist;
	#else
		pos = pos + float4(normalize(normal),0) * _Outline * 0.01;
	#endif
	
#else

	#ifdef TCP2_COLORS_AS_NORMALS
		//Vertex Color for Normals
		float3 normal = (v.vertexColor.xyz*2) - 1;
	#elif TCP2_TANGENT_AS_NORMALS
		//Tangent for Normals
		float3 normal = v.tangent.xyz;
	#elif TCP2_UV1_AS_NORMALS || TCP2_UV2_AS_NORMALS || TCP2_UV3_AS_NORMALS || TCP2_UV4_AS_NORMALS
		#if TCP2_UV1_AS_NORMALS
			#define uvChannel texcoord0
		#elif TCP2_UV2_AS_NORMALS
			#define uvChannel texcoord1
		#elif TCP2_UV3_AS_NORMALS
			#define uvChannel texcoord2
		#elif TCP2_UV4_AS_NORMALS
			#define uvChannel texcoord3
		#endif

		#if TCP2_UV_NORMALS_FULL
		//UV for Normals, full
		float3 normal = v.uvChannel.xyz;
		#else
		//UV for Normals, compressed
		#if TCP2_UV_NORMALS_ZW
			#define ch1 z
			#define ch2 w
		#else
			#define ch1 x
			#define ch2 y
		#endif
		float3 n;
		//unpack uvs
		v.uvChannel.ch1 = v.uvChannel.ch1 * 255.0/16.0;
		n.x = floor(v.uvChannel.ch1) / 15.0;
		n.y = frac(v.uvChannel.ch1) * 16.0 / 15.0;
		//- get z
		n.z = v.uvChannel.ch2;
		//- transform
		n = n*2 - 1;
		float3 normal = n;
		#endif
	#else
		float3 normal = v.normal;
	#endif
	
	//Camera-independent outline size
	#ifdef TCP2_OUTLINE_CONST_SIZE
		float dist = distance(_WorldSpaceCameraPos, mul(unity_ObjectToWorld, v.vertex));
		float4 pos =  float4(UnityObjectToViewPos(v.vertex + float4(normal, 0) * _Outline * 0.01 * dist), 1.0);
	#else
		float4 pos = float4(UnityObjectToViewPos(v.vertex + float4(normal, 0) * _Outline * 0.01), 1.0);
	#endif
#endif
	
	o.pos = mul(UNITY_MATRIX_P, pos);
	
#if TCP2_OUTLINE_TEXTURED
	half2 uv = TRANSFORM_TEX(v.texcoord0, _MainTex);
	o.texlod = tex2Dlod(_MainTex, float4(uv, 0, _TexLod)).rgb;
#endif
	
	return o;
}

float4 TCP2_Outline_Frag (v2f IN) : COLOR
{
#if TCP2_OUTLINE_TEXTURED
	return float4(IN.texlod, 1) * _OutlineColor;
#else
	return _OutlineColor;
#endif
}
