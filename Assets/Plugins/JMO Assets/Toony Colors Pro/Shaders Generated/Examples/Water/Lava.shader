// Toony Colors Pro+Mobile 2
// (c) 2014-2019 Jean Moreno

Shader "Toony Colors Pro 2/Examples/Water/Lava"
{
	Properties
	{
		[TCP2HelpBox(Warning,Make sure that the Camera renders the depth texture for this material to work properly.    You can use the script __TCP2_CameraDepth__ for this.)]
	[TCP2HeaderHelp(BASE, Base Properties)]
		//TOONY COLORS
		_HColor ("Highlight Color", Color) = (0.6,0.6,0.6,1.0)
		_SColor ("Shadow Color", Color) = (0.3,0.3,0.3,1.0)

		//DIFFUSE
		_MainTex ("Main Texture (RGB)", 2D) = "white" {}
	[TCP2Separator]

		//TOONY COLORS RAMP
		_RampThreshold ("Ramp Threshold", Range(0,1)) = 0.5
		_RampSmooth ("Ramp Smoothing", Range(0.001,1)) = 0.1
	[TCP2Separator]

	[Header(Masks)]
		[NoScaleOffset]
		_Mask1 ("Mask 1 (Emission)", 2D) = "black" {}
		_Mask2 ("Mask 2 (Pulse Time)", 2D) = "black" {}
	[TCP2Separator]
	[TCP2HeaderHelp(WATER)]
		_Color ("Water Color", Color) = (0.5,0.5,0.5,1.0)

		[Header(Depth Color)]
		_DepthColor ("Depth Color", Color) = (0.5,0.5,0.5,1.0)
		[PowerSlider(5.0)] _DepthDistance ("Depth Distance", Range(0.01,3)) = 0.5

		[Header(Foam)]
		_FoamSpread ("Foam Spread", Range(0.01,5)) = 2
		_FoamStrength ("Foam Strength", Range(0.01,1)) = 0.8
		_FoamColor ("Foam Color (RGB) Opacity (A)", Color) = (0.9,0.9,0.9,1.0)
		[NoScaleOffset]
		_FoamTex ("Foam (RGB)", 2D) = "white" {}
		_FoamSmooth ("Foam Smoothness", Range(0,0.5)) = 0.02
		_FoamSpeed ("Foam Speed", Vector) = (2,2,2,2)

		[Header(Vertex Waves Animation)]
		_WaveSpeed ("Speed", Float) = 2
		_WaveHeight ("Height", Float) = 0.1
		_WaveFrequency ("Frequency", Range(0,10)) = 1

		[Header(UV Waves Animation)]
		_UVWaveSpeed ("Speed", Float) = 1
		_UVWaveAmplitude ("Amplitude", Range(0.001,0.5)) = 0.05
		_UVWaveFrequency ("Frequency", Range(0,10)) = 1
	[TCP2Separator]
	[TCP2HeaderHelp(RIM, Rim)]
		//RIM LIGHT
		_RimColor ("Rim Color", Color) = (0.8,0.8,0.8,0.6)
		_RimMin ("Rim Min", Range(0,1)) = 0.5
		_RimMax ("Rim Max", Range(0,1)) = 1.0
	[TCP2Separator]
	[TCP2HeaderHelp(EMISSION, Emission)]
		_EmissionColor ("Emission Color", Color) = (1,1,1,1.0)
		_EmisPulseMin ("Emission Min", Float) = 0
		_EmisPulseSpeed ("Pulse Speed", Float) = 2
	[TCP2Separator]
		//Avoid compile error if the properties are ending with a drawer
		[HideInInspector] __dummy__ ("unused", Float) = 0
	}

	SubShader
	{
		Tags {"Queue"="Geometry" "RenderType"="Opaque"}


		CGPROGRAM

		#pragma surface surf ToonyColorsWater keepalpha vertex:vert nolightmap
		#pragma target 3.0

		//================================================================
		// VARIABLES

		fixed4 _Color;
		sampler2D _MainTex;
		float4 _MainTex_ST;
		sampler2D _Mask1;
		sampler2D _Mask2;
		half4 _EmissionColor;
		half _EmisPulseMin;
		half _EmisPulseSpeed;
		sampler2D_float _CameraDepthTexture;
		fixed4 _DepthColor;
		half _DepthDistance;
		half4 _FoamSpeed;
		half _FoamSpread;
		half _FoamStrength;
		sampler2D _FoamTex;
		fixed4 _FoamColor;
		half _FoamSmooth;
		half _WaveHeight;
		half _WaveFrequency;
		half _WaveSpeed;
		half _UVWaveAmplitude;
		half _UVWaveFrequency;
		half _UVWaveSpeed;

		fixed4 _RimColor;
		fixed _RimMin;
		fixed _RimMax;


		struct Input
		{
			float2 texcoord;
			half2 uv_Mask2;
			half3 viewDir;
			float2 sinAnim;
			float4 sPos;
		};

		//================================================================
		// CUSTOM LIGHTING

		//Lighting-related variables
		half4 _HColor;
		half4 _SColor;
		half _RampThreshold;
		half _RampSmooth;

		// Instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		//Custom SurfaceOutput
		struct SurfaceOutputWater
		{
			half atten;
			fixed3 Albedo;
			fixed3 Normal;
			fixed3 Emission;
			fixed Alpha;
		};

		inline half4 LightingToonyColorsWater (inout SurfaceOutputWater s, half3 viewDir, UnityGI gi)
		{
			half3 lightDir = gi.light.dir;
		#if defined(UNITY_PASS_FORWARDBASE)
			half3 lightColor = _LightColor0.rgb;
			half atten = s.atten;
		#else
			half3 lightColor = gi.light.color.rgb;
			half atten = 1;
		#endif

			s.Normal = normalize(s.Normal);			
			fixed ndl = max(0, dot(s.Normal, lightDir));
			#define NDL ndl
			#define		RAMP_THRESHOLD	_RampThreshold
			#define		RAMP_SMOOTH		_RampSmooth

			fixed3 ramp = smoothstep(RAMP_THRESHOLD - RAMP_SMOOTH*0.5, RAMP_THRESHOLD + RAMP_SMOOTH*0.5, NDL);
		#if !(POINT) && !(SPOT)
			ramp *= atten;
		#endif
		#if !defined(UNITY_PASS_FORWARDBASE)
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

		void LightingToonyColorsWater_GI(inout SurfaceOutputWater s, UnityGIInput data, inout UnityGI gi)
		{
			gi = UnityGlobalIllumination(data, 1.0, s.Normal);

			gi.light.color = _LightColor0.rgb;	//remove attenuation
			s.atten = data.atten;	//transfer attenuation to lighting function
		}

		//================================================================
		// VERTEX FUNCTION


		struct appdata_tcp2
		{
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			float4 texcoord : TEXCOORD0;
			float4 texcoord1 : TEXCOORD1;
			float4 texcoord2 : TEXCOORD2;
	#if !defined(LIGHTMAP_OFF) && defined(DIRLIGHTMAP_COMBINED)
			float4 tangent : TANGENT;
	#endif
	#if UNITY_VERSION >= 550
			UNITY_VERTEX_INPUT_INSTANCE_ID
	#endif
		};

			#define TIME (_Time.y)

		void vert(inout appdata_tcp2 v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);

			//Main texture UVs
			float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
			float2 mainTexcoords = worldPos.xz * 0.1;
			o.texcoord.xy = TRANSFORM_TEX(mainTexcoords.xy, _MainTex);
			half2 x = ((v.vertex.xy+v.vertex.yz) * _UVWaveFrequency) + (TIME.xx * _UVWaveSpeed);
			o.sinAnim = x;
			//vertex waves
			float3 _pos = worldPos.xyz * _WaveFrequency;
			float _phase = TIME * _WaveSpeed;
			half4 vsw_offsets = half4(1.0, 2.2, 0.6, 1.3);
			half4 vsw_ph_offsets = half4(1.0, 1.3, 2.2, 0.4);
			half4 waveXZ = sin((_pos.xxzz * vsw_offsets) + (_phase.xxxx * vsw_ph_offsets));
			// float waveFactorX = (waveXZ.x + waveXZ.y) * _WaveHeight / 2;
			// float waveFactorZ = (waveXZ.z + waveXZ.w) * _WaveHeight / 2;
			float waveFactorX = dot(waveXZ.xy, 1) * _WaveHeight / 2;
			float waveFactorZ = dot(waveXZ.zw, 1) * _WaveHeight / 2;
		#define VSW_STRENGTH 1
			v.vertex.y += (waveFactorX + waveFactorZ) * VSW_STRENGTH;
			half4 waveXZn = cos((_pos.xxzz * vsw_offsets) + (_phase.xxxx * vsw_ph_offsets)) * (vsw_offsets / 2);
			float xn = -_WaveHeight * (waveXZn.x + waveXZn.y);
			float zn = -_WaveHeight * (waveXZn.z + waveXZn.w);
			v.normal = normalize(float3(xn, 1, zn));
			float4 pos = UnityObjectToClipPos(v.vertex);
			o.sPos = ComputeScreenPos(pos);
			COMPUTE_EYEDEPTH(o.sPos.z);
		}

		//================================================================
		// SURFACE FUNCTION

		void surf(Input IN, inout SurfaceOutputWater o)
		{

			half2 uvDistort = ((sin(0.9*IN.sinAnim.xy) + sin(1.33*IN.sinAnim.xy+3.14) + sin(2.4*IN.sinAnim.xy+5.3))/3) * _UVWaveAmplitude;
			IN.texcoord.xy += uvDistort.xy;
			fixed4 mask1 = tex2D(_Mask1, IN.texcoord.xy);
			fixed4 mask2 = tex2D(_Mask2, IN.uv_Mask2);
			half ndv = saturate( dot(IN.viewDir, o.Normal) );
			fixed4 mainTex = tex2D(_MainTex, IN.texcoord.xy);
			float sceneZ = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(IN.sPos));
			if(unity_OrthoParams.w > 0)
			{
				//orthographic camera
			#if defined(UNITY_REVERSED_Z)
				sceneZ = 1.0f - sceneZ;
			#endif
				sceneZ = (sceneZ * _ProjectionParams.z) + _ProjectionParams.y;
			}
			else
				//perspective camera
				sceneZ = LinearEyeDepth(sceneZ);
			float partZ = IN.sPos.z;
			float depthDiff = abs(sceneZ - partZ);
			//Depth-based foam
			half2 foamUV = IN.texcoord.xy;
			foamUV.xy += TIME.xx*_FoamSpeed.xy*0.05;
			fixed4 foam = tex2D(_FoamTex, foamUV);
			foamUV.xy += TIME.xx*_FoamSpeed.zw*0.05;
			fixed4 foam2 = tex2D(_FoamTex, foamUV);
			foam = (foam + foam2) / 2;
			float foamDepth = saturate(_FoamSpread * depthDiff);
			half foamTerm = (smoothstep(foam.r - _FoamSmooth, foam.r + _FoamSmooth, saturate(_FoamStrength - foamDepth)) * saturate(1 - foamDepth)) * _FoamColor.a;
			//Alter color based on depth buffer (soft particles technique)
			mainTex.rgb = lerp(_DepthColor.rgb, mainTex.rgb, saturate(_DepthDistance * depthDiff));	//N.V corrects the result based on view direction (depthDiff tends to not look consistent depending on view angle)));
			o.Albedo = lerp(mainTex.rgb * _Color.rgb, _FoamColor.rgb, foamTerm);
			o.Alpha = mainTex.a * _Color.a;
			o.Alpha = lerp(o.Alpha, _FoamColor.a, foamTerm);
			//Rim
			half3 rim = smoothstep(_RimMax, _RimMin, 1-Pow4(1-ndv)) * _RimColor.rgb * _RimColor.a;
			rim *= mainTex.r;
			o.Emission += rim.rgb;
			half3 emissionCol = mainTex.rgb * (mask1.r * _EmissionColor.a) * _EmissionColor.rgb;
			emissionCol *= lerp(_EmisPulseMin, 1, sin((TIME + mask2.g * 1.5) * _EmisPulseSpeed)*0.5+0.5);
			o.Emission += emissionCol;
		}

		ENDCG

	}

	//Fallback "Diffuse"
	CustomEditor "TCP2_MaterialInspector_SG"
}
