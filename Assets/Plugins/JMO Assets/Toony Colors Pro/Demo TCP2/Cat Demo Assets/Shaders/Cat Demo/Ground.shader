// Toony Colors Pro+Mobile 2
// (c) 2014-2019 Jean Moreno

Shader "Toony Colors Pro 2/Examples/Cat Demo/Ground"
{
	Properties
	{
	[TCP2HeaderHelp(BASE, Base Properties)]
		//TOONY COLORS
		_Color ("Color", Color) = (1,1,1,1)
		_HColor ("Highlight Color", Color) = (0.785,0.785,0.785,1.0)
		_SColor ("Shadow Color", Color) = (0.195,0.195,0.195,1.0)

	[Header(Shadow HSV)]
		_Shadow_HSV_H ("Hue", Range(-360,360)) = 0
		_Shadow_HSV_S ("Saturation", Range(-1,1)) = 0
		_Shadow_HSV_V ("Value", Range(-1,1)) = 0
	[TCP2Separator]

		//DIFFUSE
		_MainTex ("Main Texture", 2D) = "white" {}

		[Header(Texture Blending (Vertex Colors))]
		_BlendTex1 ("Texture 1 (r)", 2D) = "white" {}
		_BlendTex2 ("Texture 2 (g)", 2D) = "white" {}
		[Header(Height Blending Parameters)]
		[TCP2Vector4Floats(R,G,B,A,0.001,2,0.001,2,0.001,2,0.001,2)] _VColorBlendSmooth ("Height Smoothing", Vector) = (0.25,0.25,0.25,0.25)
		[TCP2Vector4Floats(R,G,B,A)] _VColorBlendOffset ("Height Offset", Vector) = (0,0,0,0)
		[TCP2HelpBox(Info,Height will be taken from each texture alpha channel.  No alpha in the texture will result in linear blending.)]
	[TCP2Separator]

		//TOONY COLORS RAMP
		[TCP2Header(RAMP SETTINGS)]

		[Header(Main Directional Light)]
		_RampThreshold ("Ramp Threshold", Range(0,1)) = 0.5
		_RampSmooth ("Ramp Smoothing", Range(0.001,1)) = 0.1
	[HideInInspector] __BeginGroup_OtherLights ("Other Lights", Float) = 0
		_RampThresholdPoint ("Threshold (Point)", Range(0,1)) = 0.5
		_RampSmoothPoint ("Smoothing (Point)", Range(0.001,1)) = 0.5
		[Space]
		_RampThresholdSpot ("Threshold (Spot)", Range(0,1)) = 0.5
		_RampSmoothSpot ("Smoothing (Spot)", Range(0.001,1)) = 0.5
		[Space]
		_RampThresholdDir ("Threshold (Directional)", Range(0,1)) = 0.5
		_RampSmoothDir ("Smoothing (Directional)", Range(0.001,1)) = 0.5
	[HideInInspector] __EndGroup ("Other Lights", Float) = 0
		[Space]
	[TCP2Separator]


		//Avoid compile error if the properties are ending with a drawer
		[HideInInspector] __dummy__ ("unused", Float) = 0
	}

	SubShader
	{

		Tags { "RenderType"="Opaque" }

		CGPROGRAM

		#pragma surface surf ToonyColorsCustom fullforwardshadows addshadow exclude_path:deferred exclude_path:prepass
		#pragma target 3.0

		//================================================================
		// VARIABLES

		fixed4 _Color;
		sampler2D _MainTex;
		float _Shadow_HSV_H;
		float _Shadow_HSV_S;
		float _Shadow_HSV_V;
		float4 _VColorBlendSmooth;
		float4 _VColorBlendOffset;
		sampler2D _BlendTex1;
		float4 _BlendTex1_ST;
		sampler2D _BlendTex2;
		float4 _BlendTex2_ST;

		#define UV_MAINTEX uv_MainTex

		struct Input
		{
			half2 uv_MainTex;
			float4 color : COLOR;
		};

		//================================================================
		// HSV HELPERS
		// source: http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl

		float3 rgb2hsv(float3 c)
		{
			float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
			float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
			float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));

			float d = q.x - min(q.w, q.y);
			float e = 1.0e-10;
			return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
		}

		float3 hsv2rgb(float3 c)
		{
			c.g = max(c.g, 0.0); //make sure that saturation value is positive
			float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
			float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
			return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
		}

		//================================================================
		// CUSTOM LIGHTING

		//Lighting-related variables
		fixed4 _HColor;
		fixed4 _SColor;
		half _RampThreshold;
		half _RampSmooth;
		half _RampThresholdPoint;
		half _RampSmoothPoint;
		half _RampThresholdSpot;
		half _RampSmoothSpot;
		half _RampThresholdDir;
		half _RampSmoothDir;

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
			float4 WorldPos_LightCoords;	//WorldPos for POINT, LightCoords for SPOT
			fixed3 Albedo;
			fixed3 Normal;
			fixed3 Emission;
			half Specular;
			fixed Gloss;
			fixed Alpha;
		};

		//----------------------------------------------------------------------
		//Override UNITY_LIGHT_ATTENUATION macro
		// - Only include shadowmap in 'atten' for Point/Spot lights
		// - Falloff/cookie will be based on the ramp

	#ifdef SPOT
		#if defined(UNITY_LIGHT_ATTENUATION)
			#undef UNITY_LIGHT_ATTENUATION
			#if UNITY_VERSION >= 560
				#define UNITY_LIGHT_ATTENUATION(destName, input, worldPos) \
					unityShadowCoord4 lightCoord = mul(unity_WorldToLight, unityShadowCoord4(worldPos, 1)); \
					fixed shadow = UNITY_SHADOW_ATTENUATION(input, worldPos); \
					fixed destName = (lightCoord.z > 0) * shadow; \
					o.WorldPos_LightCoords = lightCoord;	// o = SurfaceOutputCustom, avoid recalculating worldPos
			#else
				#define UNITY_LIGHT_ATTENUATION(destName, input, worldPos) \
					unityShadowCoord4 lightCoord = mul(unity_WorldToLight, unityShadowCoord4(worldPos, 1)); \
					fixed destName = (lightCoord.z > 0) * SHADOW_ATTENUATION(input); \
					o.WorldPos_LightCoords = lightCoord;	// o = SurfaceOutputCustom, avoid recalculating worldPos
			#endif
		#endif
	#endif

		//----------------------------------------------------------------------

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

		#if SPOT
			float4 lightCoord = s.WorldPos_LightCoords;
			float lightFalloff = 1 - dot(lightCoord.xyz, lightCoord.xyz);
			//custom cookie so that it follows a 1D ramp instead of the built-in 2D circle texture
			float2 cookieCoords = lightCoord.xy / lightCoord.w;
			float rampCoords = saturate(1 - dot(cookieCoords, cookieCoords) * 4) * lightFalloff;
		#endif

			IN_NORMAL = normalize(IN_NORMAL);
			fixed ndl = max(0, dot(IN_NORMAL, lightDir));
		#if SPOT
			#define NDL	rampCoords
		#else
			#define NDL ndl
		#endif

		#if defined(UNITY_PASS_FORWARDBASE)
			#define		RAMP_THRESHOLD	_RampThreshold
			#define		RAMP_SMOOTH		_RampSmooth
		#else
		  #if POINT
			#define		RAMP_THRESHOLD	_RampThresholdPoint
			#define		RAMP_SMOOTH		_RampSmoothPoint
		  #elif SPOT
			#define		RAMP_THRESHOLD	_RampThresholdSpot
			#define		RAMP_SMOOTH		_RampSmoothSpot
		  #else
			#define		RAMP_THRESHOLD	_RampThresholdDir
			#define		RAMP_SMOOTH		_RampSmoothDir
		  #endif
		#endif

			fixed3 ramp = smoothstep(RAMP_THRESHOLD - RAMP_SMOOTH*0.5, RAMP_THRESHOLD + RAMP_SMOOTH*0.5, NDL);
		#if SPOT
			ramp *= ndl;
		#endif
		#if !(POINT) && !(SPOT)
			ramp *= atten;
		#endif

			//Shadow Hsv
			float3 albedoHsv = rgb2hsv(s.Albedo.rgb);
			albedoHsv += float3(_Shadow_HSV_H/360,_Shadow_HSV_S,_Shadow_HSV_V);
			s.Albedo = lerp(hsv2rgb(albedoHsv), s.Albedo, ramp);
		// Note: we consider that a directional light with a cookie is supposed to be the main one (even though Unity renders it as an additional light).
		// Thus when using a main directional light AND another directional light with a cookie, then the shadow color might be applied twice.
		// You can remove the DIRECTIONAL_COOKIE check below the prevent that.
		#if !defined(UNITY_PASS_FORWARDBASE) && !defined(DIRECTIONAL_COOKIE)
			_SColor = fixed4(0,0,0,1);
		#endif
			_SColor = lerp(_HColor, _SColor, _SColor.a);	//Shadows intensity through alpha
			ramp = lerp(_SColor.rgb, _HColor.rgb, ramp);
			fixed4 c;
			c.rgb = s.Albedo * lightColor.rgb * ramp;
			c.a = s.Alpha;

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

		// Height-based texture blending
		float4 blend_height_smooth(float4 texture1, float height1, float4 texture2, float height2, float smoothing)
		{
			float ma = max(texture1.a + height1, texture2.a + height2) - smoothing;
			float b1 = max(texture1.a + height1 - ma, 0);
			float b2 = max(texture2.a + height2 - ma, 0);
			return (texture1 * b1 + texture2 * b2) / (b1 + b2);
		}

		//================================================================
		// SURFACE FUNCTION

		void surf(Input IN, inout SurfaceOutputCustom o)
		{
			fixed4 mainTex = tex2D(_MainTex, IN.UV_MAINTEX);

			//Texture Blending
			#define MAIN_UV IN.UV_MAINTEX
			#define BLEND_SOURCE IN.color

			fixed4 tex1 = tex2D(_BlendTex1, MAIN_UV * _BlendTex1_ST.xy + _BlendTex1_ST.zw);
			fixed4 tex2 = tex2D(_BlendTex2, MAIN_UV * _BlendTex2_ST.xy + _BlendTex2_ST.zw);


			#define CONTRAST 5.0
			#define CONTRAST_half CONTRAST/2

			mainTex = lerp(mainTex, blend_height_smooth(mainTex, mainTex.a, tex1, BLEND_SOURCE.r * CONTRAST - CONTRAST_half + tex1.a + _VColorBlendOffset.x, _VColorBlendSmooth.x), saturate(BLEND_SOURCE.r * CONTRAST_half));
			mainTex = lerp(mainTex, blend_height_smooth(mainTex, mainTex.a, tex2, BLEND_SOURCE.g * CONTRAST - CONTRAST_half + tex2.a + _VColorBlendOffset.y, _VColorBlendSmooth.y), saturate(BLEND_SOURCE.g * CONTRAST_half));
			o.Albedo = mainTex.rgb * _Color.rgb;
			o.Alpha = mainTex.a * _Color.a;
		}

		ENDCG
	}

	Fallback "Diffuse"
	CustomEditor "TCP2_MaterialInspector_SG"
}
