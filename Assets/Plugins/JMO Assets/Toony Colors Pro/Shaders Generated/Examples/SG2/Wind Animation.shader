// Toony Colors Pro+Mobile 2
// (c) 2014-2020 Jean Moreno

Shader "Toony Colors Pro 2/Examples/SG2/Wind Animation"
{
	Properties
	{
		[TCP2HeaderHelp(Base)]
		_Color ("Color", Color) = (1,1,1,1)
		 _ColorBack ("Color Backfaces", Color) = (1,1,1,1)
		[TCP2ColorNoAlpha] _HColor ("Highlight Color", Color) = (0.75,0.75,0.75,1)
		[TCP2ColorNoAlpha] _SColor ("Shadow Color", Color) = (0.2,0.2,0.2,1)
		_MainTex ("Albedo", 2D) = "white" {}
		_Cutoff ("Alpha Cutoff", Range(0,1)) = 0.5
		[TCP2Separator]

		[TCP2Header(Ramp Shading)]
		_RampThreshold ("Threshold", Range(0.01,1)) = 0.5
		_RampSmoothing ("Smoothing", Range(0.001,1)) = 0.1
		[TCP2Separator]
		
		[Header(Wind)]
		_WindDirection ("Direction", Vector) = (1,0,0,0)
		_WindStrength ("Strength", Range(0,0.2)) = 0.025
		_WindTimeOffset ("Wind Time Offset Range", Range(0,1)) = 1
		_WindSpeed ("Speed", Range(0,10)) = 2.5
		_WindFrequency ("Frequency", Range(0,5)) = 0.5
		
		//Avoid compile error if the properties are ending with a drawer
		[HideInInspector] __dummy__ ("unused", Float) = 0
	}

	SubShader
	{
		Tags
		{
			"RenderType"="TransparentCutout"
			"Queue"="AlphaTest"
		}

		// Main Surface Shader
		AlphaToMask On
		Cull Off

		CGPROGRAM

		#pragma surface surf ToonyColorsCustom vertex:vertex_surface exclude_path:deferred exclude_path:prepass keepalpha addshadow fullforwardshadows nolightmap nofog nolppv
		#pragma target 3.0

		//================================================================
		// VARIABLES

		// Shader Properties
		float _WindTimeOffset;
		float _WindSpeed;
		float _WindFrequency;
		float4 _WindDirection;
		float _WindStrength;
		sampler2D _MainTex;
		float4 _MainTex_ST;
		float _Cutoff;
		fixed4 _Color;
		fixed4 _ColorBack;
		float _RampThreshold;
		float _RampSmoothing;
		fixed4 _HColor;
		fixed4 _SColor;

		//Vertex input
		struct appdata_tcp2
		{
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			float4 texcoord0 : TEXCOORD0;
			float4 texcoord1 : TEXCOORD1;
			float4 texcoord2 : TEXCOORD2;
		#if defined(LIGHTMAP_ON) && defined(DIRLIGHTMAP_COMBINED)
			half4 tangent : TANGENT;
		#endif
			fixed4 vertexColor : COLOR;
			UNITY_VERTEX_INPUT_INSTANCE_ID
		};

		struct Input
		{
			float vFace : VFACE;
			float2 texcoord0;
		};

		//================================================================
		// VERTEX FUNCTION

		void vertex_surface(inout appdata_tcp2 v, out Input output)
		{
			UNITY_INITIALIZE_OUTPUT(Input, output);

			// Texture Coordinates
			output.texcoord0.xy = v.texcoord0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
			// Shader Properties Sampling
			float __windTimeOffset = ( v.vertexColor.g * _WindTimeOffset );
			float __windSpeed = ( _WindSpeed );
			float __windFrequency = ( _WindFrequency );
			float3 __windDirection = ( _WindDirection.xyz );
			float3 __windMask = ( v.vertexColor.rrr );
			float __windStrength = ( _WindStrength );

			float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
			// Wind Animation
			float windTimeOffset = __windTimeOffset;
			float windSpeed = __windSpeed;
			float3 windFrequency = worldPos.xyz * __windFrequency;
			float windPhase = (_Time.y + windTimeOffset) * windSpeed;
			float3 windFactor = sin(windPhase + windFrequency);
			float4 windSin2scale = float4(2.3, 1.7, 1.4, 1.2);
			float windSin2strength = 0.6;
			windFactor += sin(windPhase.xxx * windSin2scale.www + windFrequency * windSin2scale.xyz) * windSin2strength;
			float4 windSin3scale = float4(1.3, 2.9, 2.1, 0.8);
			float windSin3strength = 0.5;
			windFactor += sin(windPhase.xxx * windSin3scale.www + windFrequency * windSin3scale.xyz) * windSin3strength;
			float4 windSin4scale = float4(3.4, 2.6, 3.1, 1.5);
			float windSin4strength = 0.2;
			windFactor += sin(windPhase.xxx * windSin4scale.www + windFrequency * windSin4scale.xyz) * windSin4strength;
					
			float3 windDir = normalize(__windDirection);
			float3 windMask = __windMask;
			float windStrength = __windStrength;
			worldPos.xyz += windDir * windFactor * windMask * windStrength;
			v.vertex.xyz = mul(unity_WorldToObject, float4(worldPos, 1)).xyz;

		}

		//================================================================

		//Custom SurfaceOutput
		struct SurfaceOutputCustom
		{
			half atten;
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Specular;
			half Gloss;
			half Alpha;

			Input input;
			
			// Shader Properties
			float __rampThreshold;
			float __rampSmoothing;
			float3 __highlightColor;
			float3 __shadowColor;
			float __ambientIntensity;
		};

		//================================================================
		// SURFACE FUNCTION

		void surf(Input input, inout SurfaceOutputCustom output)
		{
			// Shader Properties Sampling
			float4 __albedo = ( tex2D(_MainTex, input.texcoord0.xy).rgba );
			float4 __mainColor = (  lerp(_Color, _ColorBack, step(input.vFace,0.5)) );
			float __alpha = ( __albedo.a * __mainColor.a );
			float __cutoff = ( _Cutoff );
			output.__rampThreshold = ( _RampThreshold );
			output.__rampSmoothing = ( _RampSmoothing );
			output.__highlightColor = ( _HColor.rgb );
			output.__shadowColor = ( _SColor.rgb );
			output.__ambientIntensity = ( 1.0 );

			output.input = input;

			output.Albedo = __albedo.rgb;
			output.Alpha = __alpha;

			//Sharpen Alpha-to-Coverage
			output.Alpha = (output.Alpha - __cutoff) / max(fwidth(output.Alpha), 0.0001) + 0.5;
			
			output.Albedo *= __mainColor.rgb;
		}

		//================================================================
		// LIGHTING FUNCTION

		inline half4 LightingToonyColorsCustom(inout SurfaceOutputCustom surface, UnityGI gi)
		{
			half3 lightDir = gi.light.dir;
			#if defined(UNITY_PASS_FORWARDBASE)
				half3 lightColor = _LightColor0.rgb;
				half atten = surface.atten;
			#else
				//extract attenuation from point/spot lights
				half3 lightColor = _LightColor0.rgb;
				half atten = max(gi.light.color.r, max(gi.light.color.g, gi.light.color.b)) / max(_LightColor0.r, max(_LightColor0.g, _LightColor0.b));
			#endif

			half3 normal = normalize(surface.Normal);
			normal.xyz *= (surface.input.vFace < 0) ? -1.0 : 1.0;
			half ndl = dot(normal, lightDir);
			half3 ramp;
			#define		RAMP_THRESHOLD	surface.__rampThreshold
			#define		RAMP_SMOOTH		surface.__rampSmoothing
			ndl = saturate(ndl);
			ramp = smoothstep(RAMP_THRESHOLD - RAMP_SMOOTH*0.5, RAMP_THRESHOLD + RAMP_SMOOTH*0.5, ndl);
			half3 rampGrayscale = ramp;

			//Apply attenuation (shadowmaps & point/spot lights attenuation)
			ramp *= atten;

			//Highlight/Shadow Colors
			#if !defined(UNITY_PASS_FORWARDBASE)
				ramp = lerp(half3(0,0,0), surface.__highlightColor, ramp);
			#else
				ramp = lerp(surface.__shadowColor, surface.__highlightColor, ramp);
			#endif

			//Output color
			half4 color;
			color.rgb = surface.Albedo * lightColor.rgb * ramp;
			color.a = surface.Alpha;

			// Apply indirect lighting (ambient)
			half occlusion = 1;
			#ifdef UNITY_LIGHT_FUNCTION_APPLY_INDIRECT
				half3 ambient = gi.indirect.diffuse;
				ambient *= surface.Albedo * occlusion * surface.__ambientIntensity;

				color.rgb += ambient;
			#endif

			return color;
		}

		void LightingToonyColorsCustom_GI(inout SurfaceOutputCustom surface, UnityGIInput data, inout UnityGI gi)
		{
			half3 normal = surface.Normal;

			//GI without reflection probes
			gi = UnityGlobalIllumination(data, 1.0, normal); // occlusion is applied in the lighting function, if necessary

			surface.atten = data.atten; // transfer attenuation to lighting function
			gi.light.color = _LightColor0.rgb; // remove attenuation
		}

		ENDCG

	}

	Fallback "Diffuse"
	CustomEditor "ToonyColorsPro.ShaderGenerator.MaterialInspector_SG2"
}

/* TCP_DATA u config(unity:"2017.4.22f1";ver:"2.4.3";tmplt:"SG2_Template_Default";features:list["UNITY_5_4","UNITY_5_5","UNITY_5_6","UNITY_2017_1","ALPHA_TESTING","ALPHA_TO_COVERAGE","CULLING","BACKFACE_LIGHTING_XYZ","WIND_ANIM_SIN","WIND_ANIM","WIND_SIN_4"];flags:list["addshadow","fullforwardshadows"];keywords:dict[RENDER_TYPE="TransparentCutout",RampTextureDrawer="[TCP2Gradient]",RampTextureLabel="Ramp Texture",SHADER_TARGET="3.0"];shaderProperties:list[,sp(name:"Main Color";imps:list[imp_customcode(prepend_type:Disabled;prepend_code:"";prepend_file:"";prepend_file_block:"";preprend_params:dict[];code:"lerp({2}, {3}, step({4},0.5))";guid:"1c5db44b-8d01-49ad-a5ee-416d3d4962c4";op:Multiply;lbl:"Main Color";gpu_inst:False;locked:False;impl_index:-1),imp_mp_color(def:RGBA(1.000, 1.000, 1.000, 1.000);hdr:False;cc:4;chan:"RGBA";prop:"_Color";md:"";custom:False;refs:"";guid:"789f2dec-39bb-4470-9840-9f7f921bf298";op:Multiply;lbl:"Color";gpu_inst:False;locked:False;impl_index:0),imp_mp_color(def:RGBA(1.000, 1.000, 1.000, 1.000);hdr:False;cc:4;chan:"RGBA";prop:"_ColorBack";md:"";custom:False;refs:"";guid:"d3cfedbe-7cb8-4bfe-9976-761cf43aa208";op:Multiply;lbl:"Color Backfaces";gpu_inst:False;locked:False;impl_index:-1),imp_generic(cc:4;chan:"XXXX";source_id:"float input.vFace3fragment";needed_features:"USE_VFACE";custom_code_compatible:True;options_v:dict[];guid:"12cd787c-e7d9-4b08-9a80-42936cbe31fb";op:Multiply;lbl:"Main Color";gpu_inst:False;locked:False;impl_index:-1)]),,,,,,,,,,sp(name:"Wind Frequency";imps:list[imp_mp_range(def:0.5;min:0;max:5;prop:"_WindFrequency";md:"";custom:False;refs:"";guid:"67b5ef57-6852-4c5c-90e3-574ff9fb1792";op:Multiply;lbl:"Frequency";gpu_inst:False;locked:False;impl_index:-1)]),,,sp(name:"Wind Time Offset";imps:list[imp_vcolors(cc:1;chan:"G";guid:"2ebc261a-2229-4562-af73-fbd31c837a69";op:Multiply;lbl:"Mask";gpu_inst:False;locked:False;impl_index:0),imp_mp_range(def:1;min:0;max:1;prop:"_WindTimeOffset";md:"";custom:False;refs:"";guid:"e0b01e50-df71-4294-aca6-2130bf9f7a29";op:Multiply;lbl:"Wind Time Offset Range";gpu_inst:False;locked:False;impl_index:-1)]),sp(name:"Face Culling";imps:list[imp_enum(value_type:0;value:2;enum_type:"ToonyColorsPro.ShaderGenerator.Culling";guid:"02177cce-d630-4014-9924-a87706edb4c2";op:Multiply;lbl:"Face Culling";gpu_inst:False;locked:False;impl_index:0)]),,,,,,,,,,,,,sp(name:"Depth Write";imps:list[imp_enum(value_type:0;value:1;enum_type:"ToonyColorsPro.ShaderGenerator.DepthWrite";guid:"29f3cfcf-9a2e-4e62-92da-941217ec7141";op:Multiply;lbl:"Depth Write";gpu_inst:False;locked:False;impl_index:0)])];customTextures:list[]) */
/* TCP_HASH c00093c07beffe5151e2eb14a1c3d941 */
