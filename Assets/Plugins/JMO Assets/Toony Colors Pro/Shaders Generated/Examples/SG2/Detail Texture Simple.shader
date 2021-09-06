// Toony Colors Pro+Mobile 2
// (c) 2014-2019 Jean Moreno

Shader "Toony Colors Pro 2/Examples/SG2/Detail Texture Simple"
{
	Properties
	{
		[TCP2HeaderHelp(Base)]
		_Color ("Color", Color) = (1,1,1,1)
		[TCP2ColorNoAlpha] _HColor ("Highlight Color", Color) = (0.75,0.75,0.75,1)
		[TCP2ColorNoAlpha] _SColor ("Shadow Color", Color) = (0.2,0.2,0.2,1)
		_MainTex ("Albedo", 2D) = "white" {}
		 _DetailTex ("Detail Map", 2D) = "white" {}
		[TCP2Separator]

		[TCP2Header(Ramp Shading)]
		_RampThreshold ("Threshold", Range(0.01,1)) = 0.5
		_RampSmoothing ("Smoothing", Range(0.001,1)) = 0.1
		[TCP2Separator]
		
		//Avoid compile error if the properties are ending with a drawer
		[HideInInspector] __dummy__ ("unused", Float) = 0
	}

	SubShader
	{
		Tags
		{
			"RenderType"="Opaque"
		}

		// Main Surface Shader

		CGPROGRAM

		#pragma surface surf ToonyColorsCustom vertex:vertex_surface exclude_path:deferred exclude_path:prepass keepalpha nolightmap nofog
		#pragma target 3.0

		//================================================================
		// VARIABLES

		// Shader Properties
		sampler2D _MainTex;
		float4 _MainTex_ST;
		sampler2D _DetailTex;
		float4 _DetailTex_ST;
		fixed4 _Color;
		float _RampThreshold;
		float _RampSmoothing;
		fixed3 _HColor;
		fixed3 _SColor;

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
			UNITY_VERTEX_INPUT_INSTANCE_ID
		};

		struct Input
		{
			float2 texcoord0;
		};

		//================================================================
		// VERTEX FUNCTION

		void vertex_surface(inout appdata_tcp2 v, out Input output)
		{
			UNITY_INITIALIZE_OUTPUT(Input, output);

			// Texture Coordinates
			output.texcoord0.xy = (v.texcoord0.xy) * _MainTex_ST.xy + _MainTex_ST.zw;

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
			float4 __albedo = ( tex2D(_MainTex, (input.texcoord0.xy)).rgba * tex2D(_DetailTex, (input.texcoord0.xy) * _DetailTex_ST.xy + _DetailTex_ST.zw).aaaa );
			float __alpha = ( 1.0 );
			float4 __mainColor = ( _Color.rgba );
			output.__rampThreshold = ( _RampThreshold );
			output.__rampSmoothing = ( _RampSmoothing );
			output.__highlightColor = ( _HColor.rgb );
			output.__shadowColor = ( _SColor.rgb );
			output.__ambientIntensity = ( 1.0 );

			output.input = input;

			output.Albedo = __albedo.rgb;
			output.Alpha = __alpha;
			
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

/* TCP_DATA u config(ver:"2.4.0";tmplt:"SG2_Template_Default";features:list["UNITY_5_4","UNITY_5_5"];flags:list[];keywords:dict[RENDER_TYPE="Opaque",RampTextureDrawer="[TCP2Gradient]",RampTextureLabel="Ramp Texture",SHADER_TARGET="3.0"];shaderProperties:list[sp(name:"Albedo";imps:list[imp_mp_texture(guid:"9cccb019-4e39-44fd-bf0b-427aeb59b752";uto:True;tov:"";gto:True;sbt:False;scr:False;scv:"";gsc:False;roff:False;goff:False;notile:False;def:"white";locked_uv:False;uv:0;cc:4;chan:"RGBA";mip:-1;mipprop:False;ssuv:False;ssuv_vert:False;ssuv_obj:False;prop:"_MainTex";md:"";custom:False;refs:"";op:Multiply;lbl:"Albedo";gpu_inst:False;locked:False;impl_index:0),imp_mp_texture(guid:"2bff1333-4c27-47d5-83bb-5dc27dc016ad";uto:True;tov:"";gto:False;sbt:False;scr:False;scv:"";gsc:False;roff:False;goff:False;notile:False;def:"white";locked_uv:False;uv:0;cc:4;chan:"AAAA";mip:-1;mipprop:False;ssuv:False;ssuv_vert:False;ssuv_obj:False;prop:"_DetailTex";md:"";custom:False;refs:"";op:Multiply;lbl:"Detail Map";gpu_inst:False;locked:False;impl_index:-1)]),,sp(name:"Alpha";imps:list[imp_constant(type:float;fprc:float;fv:1;f2v:(1.0, 1.0);f3v:(1.0, 1.0, 1.0);f4v:(1.0, 1.0, 1.0, 1.0);cv:RGBA(1.000, 1.000, 1.000, 1.000);op:Multiply;lbl:"Alpha";gpu_inst:False;locked:False;impl_index:-1)]),,,,,,,,,,,,,,,,,sp(name:"Normal Map";imps:list[imp_customcode(code:"lerp({2}.rgba, {3}.rgba, {4}.a)";op:Multiply;lbl:"Normal Map";gpu_inst:False;locked:False;impl_index:-1),imp_mp_texture(guid:"99c71125-3b44-4e0d-b337-f81343e3dcfd";uto:True;tov:"";gto:True;sbt:False;scr:False;scv:"";gsc:False;roff:False;goff:False;notile:False;def:"bump";locked_uv:False;uv:0;cc:4;chan:"RGBA";mip:-1;mipprop:False;ssuv:False;ssuv_vert:False;ssuv_obj:False;prop:"_NormalMap";md:"";custom:False;refs:"";op:Multiply;lbl:"Normal Map Texture";gpu_inst:False;locked:False;impl_index:-1),imp_mp_texture(guid:"dff3efe8-6675-4101-a9f6-05f8a7d9a439";uto:False;tov:"";gto:False;sbt:False;scr:False;scv:"";gsc:False;roff:False;goff:False;notile:False;def:"white";locked_uv:False;uv:0;cc:4;chan:"RGBA";mip:-1;mipprop:False;ssuv:False;ssuv_vert:False;ssuv_obj:False;prop:"_NormalMap1";md:"";custom:False;refs:"";op:Multiply;lbl:"Normal Map";gpu_inst:False;locked:False;impl_index:-1),imp_ct(lct:"";cc:4;chan:"-";avchan:"-";op:Multiply;lbl:"Normal Map";gpu_inst:False;locked:False;impl_index:-1)]),sp(name:"Parallax Height Map";imps:list[imp_mp_texture(guid:"d73c530a-d490-464a-ba72-551605797427";uto:False;tov:"";gto:False;sbt:False;scr:False;scv:"";gsc:False;roff:False;goff:False;notile:False;def:"black";locked_uv:False;uv:0;cc:1;chan:"A";mip:-1;mipprop:False;ssuv:False;ssuv_vert:False;ssuv_obj:False;prop:"_ParallaxMap";md:"";custom:False;refs:"";op:Multiply;lbl:"Height Map";gpu_inst:False;locked:False;impl_index:0)])];customTextures:list[]) */
/* TCP_HASH ca9f9ac71eb1bfc558634dd95ae2d3e5 */
