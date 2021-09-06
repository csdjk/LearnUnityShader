// Toony Colors Pro+Mobile 2
// (c) 2014-2019 Jean Moreno

Shader "Toony Colors Pro 2/Examples/Cat Demo/UnityChan/Style 5 Skin"
{
	Properties
	{
	[TCP2HeaderHelp(BASE, Base Properties)]
		//TOONY COLORS
		_Color ("Color", Color) = (1,1,1,1)
		_HColor ("Highlight Color", Color) = (0.785,0.785,0.785,1.0)
		_SColor ("Shadow Color", Color) = (0.195,0.195,0.195,1.0)
		[NoScaleOffset] _STexture ("Shadow Color Texture", 2D) = "white" {}

		//DIFFUSE
		_MainTex ("Main Texture", 2D) = "white" {}
	[TCP2Separator]

		//TOONY COLORS RAMP
		[TCP2Header(RAMP SETTINGS)]

		[Header(Main Directional Light)]
		_RampThreshold ("Ramp Threshold", Range(0,1)) = 0.5
		_RampSmooth ("Ramp Smoothing", Range(0.001,1)) = 0.1
		[Header(Other Lights)]
		_RampThresholdOtherLights ("Threshold", Range(0,1)) = 0.5
		_RampSmoothOtherLights ("Smoothing", Range(0.001,1)) = 0.5
		[Space]
	[TCP2Separator]

	[TCP2HeaderHelp(RIM, Rim)]
		//RIM LIGHT
		_RimColor ("Rim Color", Color) = (0.8,0.8,0.8,0.6)
		_RimMin ("Rim Min", Range(0,2)) = 0.5
		_RimMax ("Rim Max", Range(0,2)) = 1.0
	[TCP2Separator]

	[TCP2HeaderHelp(SKETCH, Sketch)]
		//SKETCH
		_SketchTex ("Sketch (Alpha)", 2D) = "white" {}
		_SketchColor ("Sketch Color", Color) = (0,0,0,1)
		_SketchSpeed ("Sketch Anim Speed", Range(1.1, 10)) = 6
	[TCP2Separator]

	[TCP2HeaderHelp(OUTLINE, Outline)]
		//OUTLINE
		_OutlineColor ("Outline Color", Color) = (0.2, 0.2, 0.2, 1.0)
		_Outline ("Outline Width", Float) = 1

		//Outline Textured
		[Toggle(TCP2_OUTLINE_TEXTURED)] _EnableTexturedOutline ("Color from Texture", Float) = 0
		[TCP2KeywordFilter(TCP2_OUTLINE_TEXTURED)] _TexLod ("Texture LOD", Range(0,10)) = 5

		//Constant-size outline
		[Toggle(TCP2_OUTLINE_CONST_SIZE)] _EnableConstSizeOutline ("Constant Size Outline", Float) = 0

		//ZSmooth
		[Toggle(TCP2_ZSMOOTH_ON)] _EnableZSmooth ("Correct Z Artefacts", Float) = 0
		//Z Correction & Offset
		[TCP2KeywordFilter(TCP2_ZSMOOTH_ON)] _ZSmooth ("Z Correction", Range(-3.0,3.0)) = -0.5
		[TCP2KeywordFilter(TCP2_ZSMOOTH_ON)] _Offset1 ("Z Offset 1", Float) = 0
		[TCP2KeywordFilter(TCP2_ZSMOOTH_ON)] _Offset2 ("Z Offset 2", Float) = 0

		//This property will be ignored and will draw the custom normals GUI instead
		[TCP2OutlineNormalsGUI] __outline_gui_dummy__ ("_unused_", Float) = 0
	[TCP2Separator]


		//Avoid compile error if the properties are ending with a drawer
		[HideInInspector] __dummy__ ("unused", Float) = 0
	}

	SubShader
	{
		//================================================================
		// OUTLINE INCLUDE

		CGINCLUDE

		#include "UnityCG.cginc"

		struct a2v
		{
			float4 vertex : POSITION;
			float3 normal : NORMAL;
	#if TCP2_OUTLINE_TEXTURED
			float3 texcoord : TEXCOORD0;
	#endif
		#if TCP2_COLORS_AS_NORMALS
			float4 color : COLOR;
		#endif
	#if TCP2_UV2_AS_NORMALS
			float2 uv2 : TEXCOORD1;
	#endif
	#if TCP2_TANGENT_AS_NORMALS
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

		#define OUTLINE_WIDTH _Outline

		v2f TCP2_Outline_Vert(a2v v)
		{
			v2f o;

	#if UNITY_VERSION >= 550
			//GPU instancing support
			UNITY_SETUP_INSTANCE_ID(v);
	#endif


	#if TCP2_ZSMOOTH_ON
			float4 pos = float4(UnityObjectToViewPos(v.vertex), 1.0);
	#endif

	#ifdef TCP2_COLORS_AS_NORMALS
			//Vertex Color for Normals
			float3 normal = (v.color.xyz*2) - 1;
	#elif TCP2_TANGENT_AS_NORMALS
			//Tangent for Normals
			float3 normal = v.tangent.xyz;
	#elif TCP2_UV2_AS_NORMALS
			//UV2 for Normals
			float3 n;
			//unpack uv2
			v.uv2.x = v.uv2.x * 255.0/16.0;
			n.x = floor(v.uv2.x) / 15.0;
			n.y = frac(v.uv2.x) * 16.0 / 15.0;
			//get z
			n.z = v.uv2.y;
			//transform
			n = n*2 - 1;
			float3 normal = n;
	#else
			float3 normal = v.normal;
	#endif

	#if TCP2_ZSMOOTH_ON
			//Correct Z artefacts
			normal = UnityObjectToViewPos(normal);
			normal.z = -_ZSmooth;
	#endif

	#ifdef TCP2_OUTLINE_CONST_SIZE
			//Camera-independent outline size
			float dist = distance(_WorldSpaceCameraPos, mul(unity_ObjectToWorld, v.vertex));
			#define SIZE	dist
	#else
			#define SIZE	1.0
	#endif

	#if TCP2_ZSMOOTH_ON
			o.pos = mul(UNITY_MATRIX_P, pos + float4(normalize(normal),0) * OUTLINE_WIDTH * 0.01 * SIZE);
	#else
			o.pos = UnityObjectToClipPos(v.vertex + float4(normal,0) * OUTLINE_WIDTH * 0.01 * SIZE);
	#endif

	#if TCP2_OUTLINE_TEXTURED
			half2 uv = TRANSFORM_TEX(v.texcoord, _MainTex);
			o.texlod = tex2Dlod(_MainTex, float4(uv, 0, _TexLod)).rgb;
	#endif

			return o;
		}

		#define OUTLINE_COLOR _OutlineColor

		float4 TCP2_Outline_Frag (v2f IN) : SV_Target
		{
	#if TCP2_OUTLINE_TEXTURED
			return float4(IN.texlod, 1) * OUTLINE_COLOR;
	#else
			return OUTLINE_COLOR;
	#endif
		}

		ENDCG

		// OUTLINE INCLUDE END
		//================================================================

		Tags { "RenderType"="Opaque" }

		CGPROGRAM

		#pragma surface surf ToonyColorsCustom addshadow fullforwardshadows vertex:vert exclude_path:deferred exclude_path:prepass
		#pragma target 3.0

		//================================================================
		// VARIABLES

		fixed4 _Color;
		sampler2D _MainTex;
		sampler2D _STexture;
		fixed _SketchSpeed;
		fixed4 _RimColor;
		fixed _RimMin;
		fixed _RimMax;
		float4 _RimDir;
		fixed4 _Random;

		#define UV_MAINTEX uv_MainTex

		struct Input
		{
			half2 uv_MainTex;
			float3 viewDir;
			half4 sketchUv;
		};

		//================================================================
		// CUSTOM LIGHTING

		//Lighting-related variables
		fixed4 _HColor;
		fixed4 _SColor;
		half _RampThreshold;
		half _RampSmooth;
		half _RampThresholdOtherLights;
		half _RampSmoothOtherLights;
		sampler2D _SketchTex;
		float4 _SketchTex_ST;
		half4 _SketchColor;

		// Instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		//Custom SurfaceOutput
		struct SurfaceOutputCustom
		{
			half atten;
			fixed3 Albedo;
			fixed3 Normal;
			fixed3 Emission;
			half Specular;
			fixed Gloss;
			fixed Alpha;
			fixed3 ShadowColorTex;
			half2 ScreenUVs;
		};

		inline half4 LightingToonyColorsCustom (inout SurfaceOutputCustom s, half3 viewDir, UnityGI gi)
		{
		#define IN_NORMAL s.Normal
	
			half3 lightDir = gi.light.dir;
		#if defined(UNITY_PASS_FORWARDBASE)
			half3 lightColor = _LightColor0.rgb;
			half atten = s.atten;
		#else
			half3 lightColor = gi.light.color.rgb;
			half atten = 1;
		#endif

			IN_NORMAL = normalize(IN_NORMAL);
			fixed ndl = max(0, dot(IN_NORMAL, lightDir) * 0.5 + 0.5);
			#define NDL ndl

		#if defined(UNITY_PASS_FORWARDBASE)
			#define		RAMP_THRESHOLD	_RampThreshold
			#define		RAMP_SMOOTH		_RampSmooth
		#else
			#define		RAMP_THRESHOLD	_RampThresholdOtherLights
			#define		RAMP_SMOOTH		_RampSmoothOtherLights
		#endif

			fixed3 ramp = smoothstep(RAMP_THRESHOLD - RAMP_SMOOTH*0.5, RAMP_THRESHOLD + RAMP_SMOOTH*0.5, NDL);
		#if !(POINT) && !(SPOT)
			ramp *= atten;
		#endif
			//Sketch
			#define SKETCH_RGB	sketchRgb
			fixed sketch = tex2D(_SketchTex, s.ScreenUVs).a;
			sketch = lerp(sketch, 1, ramp);	//Regular sketch overlay
			half3 sketchRgb = lerp(_SketchColor, half3(1,1,1), sketch);
			//Shadow Color Texture
			s.Albedo = lerp(s.ShadowColorTex.rgb, s.Albedo, ramp);
		#if !defined(UNITY_PASS_FORWARDBASE)
			_SColor = fixed4(0,0,0,1);
		#endif
			_SColor = lerp(_HColor, _SColor, _SColor.a);	//Shadows intensity through alpha
			ramp = lerp(_SColor.rgb, _HColor.rgb, ramp);
			fixed4 c;
			c.rgb = s.Albedo * lightColor.rgb * ramp;
			c.a = s.Alpha;
			c.rgb *= SKETCH_RGB;

		#ifdef UNITY_LIGHT_FUNCTION_APPLY_INDIRECT
			c.rgb += s.Albedo * gi.indirect.diffuse;
		#endif

			return c;
		}

		void LightingToonyColorsCustom_GI(inout SurfaceOutputCustom s, UnityGIInput data, inout UnityGI gi)
		{
			gi = UnityGlobalIllumination(data, 1.0, IN_NORMAL);

			s.atten = data.atten;	//transfer attenuation to lighting function
			gi.light.color = _LightColor0.rgb;	//remove attenuation
		}

		//Adjust screen UVs relative to object to prevent screen door effect
		inline void ObjSpaceUVOffset(inout float2 screenUV, in float screenRatio)
		{
			// UNITY_MATRIX_P._m11 = Camera FOV
			float4 objPos = float4(-UNITY_MATRIX_T_MV[3].x * screenRatio * UNITY_MATRIX_P._m11, -UNITY_MATRIX_T_MV[3].y * UNITY_MATRIX_P._m11, UNITY_MATRIX_T_MV[3].z, UNITY_MATRIX_T_MV[3].w);

			float offsetFactorX = 0.5;
			float offsetFactorY = offsetFactorX * screenRatio;
			offsetFactorX *= _SketchTex_ST.x;
			offsetFactorY *= _SketchTex_ST.y;

			if (unity_OrthoParams.w < 1)	//don't scale with orthographic camera
			{
				//adjust uv scale
				screenUV -= float2(offsetFactorX, offsetFactorY);
				screenUV *= objPos.z;	//scale with cam distance
				screenUV += float2(offsetFactorX, offsetFactorY);

				// sign(UNITY_MATRIX_P[1].y) is different in Scene and Game views
				screenUV.x -= objPos.x * offsetFactorX * sign(UNITY_MATRIX_P[1].y);
				screenUV.y -= objPos.y * offsetFactorY * sign(UNITY_MATRIX_P[1].y);
			}
			else
			{
				// sign(UNITY_MATRIX_P[1].y) is different in Scene and Game views
				screenUV.x += objPos.x * offsetFactorX * sign(UNITY_MATRIX_P[1].y);
				screenUV.y += objPos.y * offsetFactorY * sign(UNITY_MATRIX_P[1].y);
			}
		}

		//Vertex input
		struct appdata_tcp2
		{
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			float4 texcoord : TEXCOORD0;
			float4 texcoord1 : TEXCOORD1;
			float4 texcoord2 : TEXCOORD2;
		#if defined(LIGHTMAP_ON) && defined(DIRLIGHTMAP_COMBINED)
			float4 tangent : TANGENT;
		#endif
	#if UNITY_VERSION >= 550
			UNITY_VERTEX_INPUT_INSTANCE_ID
	#endif
		};

		//================================================================
		// VERTEX FUNCTION

		void vert(inout appdata_tcp2 v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);

			//Sketch
			float4 pos = UnityObjectToClipPos(v.vertex);
			o.sketchUv = ComputeScreenPos(pos);
			o.sketchUv.xy = TRANSFORM_TEX(o.sketchUv, _SketchTex);
		}

		//================================================================
		// SURFACE FUNCTION

		void surf(Input IN, inout SurfaceOutputCustom o)
		{
			fixed4 mainTex = tex2D(_MainTex, IN.UV_MAINTEX);

			//Shadow Color Texture
			fixed4 shadowTex = tex2D(_STexture, IN.UV_MAINTEX);
			o.ShadowColorTex = shadowTex.rgb;
			o.Albedo = mainTex.rgb * _Color.rgb;
			o.Alpha = mainTex.a * _Color.a;

			//Sketch
			float2 screenUV = IN.sketchUv.xy / IN.sketchUv.w;
			float screenRatio = _ScreenParams.y / _ScreenParams.x;
			screenUV.y *= screenRatio;
			ObjSpaceUVOffset(screenUV, screenRatio);
			_Random.x = round(_Time.z * _SketchSpeed) / _SketchSpeed;
			_Random.y = -round(_Time.z * _SketchSpeed) / _SketchSpeed;
			screenUV.xy += frac(_Random.xy);
			o.ScreenUVs = screenUV;

			//Rim
			float3 viewDir = normalize(IN.viewDir);
			half rim = 1.0f - saturate( dot(viewDir, o.Normal) );
			rim = smoothstep(_RimMin, _RimMax, rim);
			o.Albedo = lerp(o.Albedo.rgb, _RimColor.rgb, rim * _RimColor.a);
			o.ShadowColorTex = lerp(o.ShadowColorTex.rgb, _RimColor.rgb, rim * _RimColor.a);
		}

		ENDCG

		//Outline
		Pass
		{
			Cull Front
			Offset [_Offset1],[_Offset2]

			Tags { "LightMode"="ForwardBase" "IgnoreProjectors"="True" }

			CGPROGRAM

			#pragma vertex TCP2_Outline_Vert
			#pragma fragment TCP2_Outline_Frag

			#pragma multi_compile TCP2_NONE TCP2_ZSMOOTH_ON
			#pragma multi_compile TCP2_NONE TCP2_OUTLINE_CONST_SIZE
			#pragma multi_compile TCP2_NONE TCP2_COLORS_AS_NORMALS TCP2_TANGENT_AS_NORMALS TCP2_UV2_AS_NORMALS
			#pragma multi_compile TCP2_NONE TCP2_OUTLINE_TEXTURED			
			#pragma multi_compile_instancing


			#pragma target 3.0

			ENDCG
		}
	}

	Fallback "Diffuse"
	CustomEditor "TCP2_MaterialInspector_SG"
}
