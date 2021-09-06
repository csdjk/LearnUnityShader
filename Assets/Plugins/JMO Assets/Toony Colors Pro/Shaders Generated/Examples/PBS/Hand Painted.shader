// Toony Colors Pro+Mobile 2
// (c) 2014-2019 Jean Moreno


Shader "Toony Colors Pro 2/Examples/PBS/Hand Painted"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo", 2D) = "white" {}

		_Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

		_Glossiness("Smoothness", Range(0.0, 1.0)) = 0.5
		_GlossMapScale("Smoothness Scale", Range(0.0, 1.0)) = 1.0

		[Gamma] _Metallic("Metallic", Range(0.0, 1.0)) = 0.0

		// [ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
		// [ToggleOff] _GlossyReflections("Glossy Reflections", Float) = 1.0


		// Blending state
		[HideInInspector] _Mode("__mode", Float) = 0.0
		[HideInInspector] _SrcBlend("__src", Float) = 1.0
		[HideInInspector] _DstBlend("__dst", Float) = 0.0
		[HideInInspector] _ZWrite("__zw", Float) = 1.0

		//TOONY COLORS PRO 2 ----------------------------------------------------------------
		_HColor("Highlight Color", Color) = (0.785,0.785,0.785,1.0)
		_SColor("Shadow Color", Color) = (0.195,0.195,0.195,1.0)

	[Header(Ramp Shading)]
		_RampThreshold("Threshold", Range(0,1)) = 0.5
		_RampSmooth("Main Light Smoothing", Range(0,1)) = 0.2
		_RampSmoothAdd("Other Lights Smoothing", Range(0,1)) = 0.75

	[Header(Threshold Texture)]
		[NoScaleOffset]
		_ThresholdTex ("Texture (Alpha)", 2D) = "gray" {}
		_ThresholdStrength ("Strength", Range(0,1)) = 1
		_ThresholdScale ("Scale", Float) = 4

	[Header(Stylized Specular)]
		_SpecSmooth("Specular Smoothing", Range(0,1)) = 1.0
		_SpecBlend("Specular Blend", Range(0,1)) = 1.0


	[Header(Stylized Fresnel)]
		[PowerSlider(3)] _RimStrength("Strength", Range(0, 2)) = 0.5
		_RimMin("Min", Range(0, 1)) = 0.6
		_RimMax("Max", Range(0, 1)) = 0.85


		//Avoid compile error if the properties are ending with a drawer
		[HideInInspector] __dummy__ ("__unused__", Float) = 0
	}

	SubShader
	{
		Blend [_SrcBlend] [_DstBlend]
		ZWrite [_ZWrite]
		Tags { "RenderType"="Opaque" "PerformanceChecks"="False" }

		CGPROGRAM

		#pragma surface surf StandardTCP2  keepalpha exclude_path:deferred exclude_path:prepass
		#pragma target 3.0

		#pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON

		//================================================================================================================================
		// STRUCTS

		struct Input
		{
			float2 uv_MainTex;
			#define uv_TexturedThreshold uv_MainTex
		};

		//================================================================================================================================
		// LIGHTING FUNCTION

		inline half4 LightingStandardTCP2(SurfaceOutputStandardTCP2 s, half3 viewDir, UnityGI gi)
		{
			s.Normal = normalize(s.Normal);

			half oneMinusReflectivity;
			half3 specColor;
			s.Albedo = DiffuseAndSpecularFromMetallic(s.Albedo, s.Metallic, /*out*/ specColor, /*out*/ oneMinusReflectivity);

			// shader relies on pre-multiply alpha-blend (_SrcBlend = One, _DstBlend = OneMinusSrcAlpha)
			// this is necessary to handle transparency in physically correct way - only diffuse component gets affected by alpha
			half outputAlpha;
			s.Albedo = PreMultiplyAlpha(s.Albedo, s.Alpha, oneMinusReflectivity, /*out*/ outputAlpha);

		#if defined(UNITY_PASS_FORWARDBASE)
			fixed atten = s.atten;
		#else
			fixed atten = 1;
		#endif

			half4 c = TCP2_BRDF_PBS(s.Albedo, specColor, oneMinusReflectivity, s.Smoothness, s.Normal, viewDir, gi.light, gi.indirect, /* TCP2 */ atten, s

				,s.texThresholdTexcoords
				);
			c.a = outputAlpha;
			return c;
		}

		inline void LightingStandardTCP2_GI(inout SurfaceOutputStandardTCP2 s, UnityGIInput data, inout UnityGI gi)
		{
			Unity_GlossyEnvironmentData g = UnityGlossyEnvironmentSetup(s.Smoothness, data.worldViewDir, s.Normal, lerp(unity_ColorSpaceDielectricSpec.rgb, s.Albedo, s.Metallic));
			gi = UnityGlobalIllumination(data, s.Occlusion, s.Normal, g);

			s.atten = data.atten;				//transfer attenuation to lighting function
			gi.light.color = _LightColor0.rgb;	//remove attenuation
		}

		//================================================================================================================================
		// SURFACE FUNCTION

		void surf (Input IN, inout SurfaceOutputStandardTCP2 o)
		{

			fixed4 mainTex = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = mainTex.rgb;
			o.Alpha = mainTex.a;

		#if _ALPHATEST_ON
			clip(o.Alpha - _Cutoff);
		#endif


			//Metallic Workflow
			fixed4 metalGlossMap = fixed4(0,0,0,0);
			half2 metallicGloss = MetallicGloss(mainTex.a, metalGlossMap);
			half metallic = metallicGloss.x;
			half smoothness = metallicGloss.y;
			o.Metallic = metallic;
			o.Smoothness = smoothness;


			o.texThresholdTexcoords = IN.uv_TexturedThreshold;
		#ifdef _ALPHABLEND_ON
			o.Albedo *= o.Alpha;
		#endif
		}
		ENDCG

	}

	CGINCLUDE

	#if !defined(EXCLUDE_TCP2_MAIN_PASS)
		#include "Lighting.cginc"

		//================================================================================================================================
		// STRUCT

		struct SurfaceOutputStandardTCP2
		{
			fixed3 Albedo;      // base (diffuse or specular) color
			fixed3 Normal;      // tangent space normal, if written
			half3 Emission;

			half Metallic;      // 0=non-metal, 1=metal

			//Smoothness is the user facing name, it should be perceptual smoothness but user should not have to deal with it.
			// Everywhere in the code you meet smoothness it is perceptual smoothness
			half Smoothness;    // 0=rough, 1=smooth
			half Occlusion;     // occlusion (default 1)
			fixed Alpha;        // alpha for transparencies

			fixed atten;
			float2 texThresholdTexcoords;
		};

		//================================================================================================================================
		// VARIABLES

		sampler2D _MainTex;
		fixed4 _Color;
		half _Cutoff;
		half _Glossiness;
		half _GlossMapScale;
		half _Metallic;

		//-------------------------------------------------------------------------------------
		//TCP2 Params

		fixed4 _HColor;
		fixed4 _SColor;
		sampler2D _Ramp;
		fixed _RampThreshold;
		fixed _RampSmooth;
		fixed _RampSmoothAdd;
		fixed _SpecSmooth;
		fixed _SpecBlend;
		fixed _RimStrength;
		fixed _RimMin;
		fixed _RimMax;
		sampler2D _ThresholdTex;
		fixed _ThresholdScale;
		fixed _ThresholdStrength;

		//================================================================================================================================
		// LIGHTING / BRDF

		//-------------------------------------------------------------------------------------
		// TCP2 Tools

		inline half WrapRampNL(half nl, fixed threshold, fixed smoothness)
		{
			nl = saturate(nl);
			nl = smoothstep(threshold - smoothness*0.5, threshold + smoothness*0.5, nl);
			return nl;
		}

		inline half StylizedSpecular(half specularTerm, fixed specSmoothness)
		{
			return smoothstep(specSmoothness*0.5, 0.5 + specSmoothness*0.5, specularTerm);
		}

		inline half3 StylizedFresnel(half nv, half roughness, UnityLight light, half3 normal, fixed rimMin, fixed rimMax, fixed rimStrength)
		{
			half rim = 1-nv;
			rim = smoothstep(rimMin, rimMax, rim) * rimStrength * saturate(1.33-roughness);
			return rim * saturate(dot(normal, light.dir)) * light.color;
		}

		//-------------------------------------------------------------------------------------
		// Standard Shader inputs


		half2 MetallicGloss(float mainTexAlpha, fixed4 metalGlossMap)
		{
			half2 mg;
			mg.r = _Metallic;
			mg.g = _Glossiness;
			return mg;
		}

		//-------------------------------------------------------------------------------------

		// Note: BRDF entry points use oneMinusRoughness (aka "smoothness") and oneMinusReflectivity for optimization
		// purposes, mostly for DX9 SM2.0 level. Most of the math is being done on these (1-x) values, and that saves
		// a few precious ALU slots.

		// Main Physically Based BRDF
		// Derived from Disney work and based on Torrance-Sparrow micro-facet model
		//
		//   BRDF = kD / pi + kS * (D * V * F) / 4
		//   I = BRDF * NdotL
		//
		// * NDF (depending on UNITY_BRDF_GGX):
		//  a) Normalized BlinnPhong
		//  b) GGX
		// * Smith for Visiblity term
		// * Schlick approximation for Fresnel
		half4 TCP2_BRDF_PBS(half3 diffColor, half3 specColor, half oneMinusReflectivity, half smoothness, half3 normal, half3 viewDir, UnityLight light, UnityIndirect gi,
			/* TCP2 */ half atten, SurfaceOutputStandardTCP2 s
			,half2 texThresholdTexcoords
			)
		{
			half perceptualRoughness = SmoothnessToPerceptualRoughness (smoothness);
			half3 halfDir = Unity_SafeNormalize (light.dir + viewDir);

			// NdotV should not be negative for visible pixels, but it can happen due to perspective projection and normal mapping
			// In this case normal should be modified to become valid (i.e facing camera) and not cause weird artifacts.
			// but this operation adds few ALU and users may not want it. Alternative is to simply take the abs of NdotV (less correct but works too).
			// Following define allow to control this. Set it to 0 if ALU is critical on your platform.
			// This correction is interesting for GGX with SmithJoint visibility function because artifacts are more visible in this case due to highlight edge of rough surface
			// Edit: Disable this code by default for now as it is not compatible with two sided lighting used in SpeedTree.
			#define TCP2_HANDLE_CORRECTLY_NEGATIVE_NDOTV 0 

	#if TCP2_HANDLE_CORRECTLY_NEGATIVE_NDOTV
			// The amount we shift the normal toward the view vector is defined by the dot product.
			half shiftAmount = dot(normal, viewDir);
			normal = shiftAmount < 0.0f ? normal + viewDir * (-shiftAmount + 1e-5f) : normal;
			// A re-normalization should be applied here but as the shift is small we don't do it to save ALU.
			//normal = normalize(normal);

			half nv = saturate(dot(normal, viewDir)); // TODO: this saturate should no be necessary here
	#else
			half nv = abs(dot(normal, viewDir));	// This abs allow to limit artifact
	#endif

			half nl = dot(normal, light.dir);

	
			half2 thresholdUv = texThresholdTexcoords.xy * _ThresholdScale;
			half texThreshold = tex2D(_ThresholdTex, thresholdUv).a - 0.5;
			nl += texThreshold * _ThresholdStrength;

		#if defined(UNITY_PASS_FORWARDADD)
			#define RAMP_SMOOTH _RampSmoothAdd
		#else
			#define RAMP_SMOOTH _RampSmooth
		#endif

			//TCP2 Ramp N.L
			nl = WrapRampNL(nl, _RampThreshold, RAMP_SMOOTH);

			half nh = saturate(dot(normal, halfDir));

			half lv = saturate(dot(light.dir, viewDir));
			half lh = saturate(dot(light.dir, halfDir));

			// Diffuse term
			half diffuseTerm = DisneyDiffuse(nv, nl, lh, perceptualRoughness) * nl;

			// Specular term
			// HACK: theoretically we should divide diffuseTerm by Pi and not multiply specularTerm!
			// BUT 1) that will make shader look significantly darker than Legacy ones
			// and 2) on engine side "Non-important" lights have to be divided by Pi too in cases when they are injected into ambient SH
			half roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
	#if UNITY_BRDF_GGX
			half V = SmithJointGGXVisibilityTerm (nl, nv, roughness);
			half D = GGXTerm (nh, roughness);
	#else
			// Legacy
			half V = SmithBeckmannVisibilityTerm (nl, nv, roughness);
			half D = NDFBlinnPhongNormalizedTerm (nh, PerceptualRoughnessToSpecPower(perceptualRoughness));
	#endif
			half specularTerm = V*D * UNITY_PI; // Torrance-Sparrow model, Fresnel is applied later
	//TCP2 Stylized Specular
			half r = sqrt(roughness)*0.85;
			r += 1e-4h;
			specularTerm = lerp(specularTerm, StylizedSpecular(specularTerm, _SpecSmooth) * (1/r), _SpecBlend);
	#ifdef UNITY_COLORSPACE_GAMMA
			specularTerm = sqrt(max(1e-4h, specularTerm));
	#endif
			// specularTerm * nl can be NaN on Metal in some cases, use max() to make sure it's a sane value
			specularTerm = max(0, specularTerm * nl);

			// surfaceReduction = Int D(NdotH) * NdotH * Id(NdotL>0) dH = 1/(roughness^2+1)
			half surfaceReduction;
	#ifdef UNITY_COLORSPACE_GAMMA
			surfaceReduction = 1.0-0.28*roughness*perceptualRoughness;		// 1-0.28*x^3 as approximation for (1/(x^4+1))^(1/2.2) on the domain [0;1]
	#else
			surfaceReduction = 1.0 / (roughness*roughness + 1.0);			// fade \in [0.5;1]
	#endif

			// To provide true Lambert lighting, we need to be able to kill specular completely.
			specularTerm *= any(specColor) ? 1.0 : 0.0;

	//TCP2 Colored Highlight/Shadows
			_SColor = lerp(_HColor, _SColor, _SColor.a);	//Shadows intensity through alpha

	//light attenuation already included in light.color for point lights
	#if !defined(UNITY_PASS_FORWARDADD)
			diffuseTerm *= atten;
	#endif
			half3 diffuseTermRGB = lerp(_SColor.rgb, _HColor.rgb, diffuseTerm);
			half3 diffuseTCP2 = diffColor * (gi.diffuse + light.color * diffuseTermRGB);
			//original: diffColor * (gi.diffuse + light.color * diffuseTerm)

	//light attenuation already included in light.color for point lights
	#if !defined(UNITY_PASS_FORWARDADD)
			//TCP2: atten contribution to specular since it was removed from light calculation
			specularTerm *= atten;
	#endif

			half grazingTerm = saturate(smoothness + (1-oneMinusReflectivity));
			half3 color =	diffuseTCP2
							+ specularTerm * light.color
							* FresnelTerm (specColor, lh)
							+ surfaceReduction * gi.specular
							* FresnelLerp (specColor, grazingTerm, nv);

			//TCP2 Enhanced Rim/Fresnel
			color += StylizedFresnel(nv, roughness, light, normal, _RimMin, _RimMax, _RimStrength);
			return half4(color, 1);
		}

		//================================================================================================================================

	#endif
	ENDCG

	FallBack "VertexLit"
	CustomEditor "TCP2_MaterialInspector_SurfacePBS_SG"
}

