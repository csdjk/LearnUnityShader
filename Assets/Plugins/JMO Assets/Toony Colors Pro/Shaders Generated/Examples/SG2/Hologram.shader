// Toony Colors Pro+Mobile 2
// (c) 2014-2019 Jean Moreno

Shader "Hologram"
{
	Properties
	{

		[TCP2HeaderHelp(Emission)]
		[NoScaleOffset] _MainTex ("Emission Texture", 2D) = "white" {}
		[TCP2Separator]
		
		[TCP2HeaderHelp(Outline)]
		_OutlineWidth ("Width", Range(0.1,4)) = 1
		//This property will be ignored and will draw the custom normals GUI instead
		[TCP2OutlineNormalsGUI] __outline_gui_dummy__ ("_unused_", Float) = 0
		[TCP2Separator]
		_NDVMinFrag ("NDV Min", Range(0,2)) = 0.5
		_NDVMaxFrag ("NDV Max", Range(0,2)) = 1
		[TCP2Separator]
		// Custom Material Properties
		[TCP2ColorNoAlpha] [HDR] _HologramColor ("Hologram Color", Color) = (0,0.502,1,1)
		 _ScanlinesTex ("Scanlines Texture", 2D) = "white" {}
		[TCP2UVScrolling] _ScanlinesTex_SC ("Scanlines Texture UV Scrolling", Vector) = (1,1,0,0)

		//Avoid compile error if the properties are ending with a drawer
		[HideInInspector] __dummy__ ("unused", Float) = 0
	}

	SubShader
	{
		Tags
		{
			"RenderType"="Transparent"
			"Queue"="Transparent"
			"IgnoreProjectors"="True"
		}

		// Outline Include
		CGINCLUDE

		#include "UnityCG.cginc"
		#include "UnityLightingCommon.cginc"	// needed for LightColor

		// Custom Material Properties
		half4 _HologramColor;
		
		// Shader Properties
		float _OutlineWidth;

		struct appdata_outline
		{
			float4 vertex : POSITION;
			float3 normal : NORMAL;
		#if TCP2_COLORS_AS_NORMALS
			float4 vertexColor : COLOR;
		#endif
		// TODO: need a way to know if texcoord1 is used in the Shader Properties
		#if TCP2_UV2_AS_NORMALS
			float2 uv2 : TEXCOORD1;
		#endif
		#if TCP2_TANGENT_AS_NORMALS
			float4 tangent : TANGENT;
		#endif
			UNITY_VERTEX_INPUT_INSTANCE_ID
		};

		struct v2f_outline
		{
			float4 vertex : SV_POSITION;
			float4 vcolor : TEXCOORD0;
			UNITY_VERTEX_OUTPUT_STEREO
		};

		v2f_outline vertex_outline (appdata_outline v)
		{
			v2f_outline output;
			UNITY_INITIALIZE_OUTPUT(v2f_outline, output);
			UNITY_SETUP_INSTANCE_ID(v);
			UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

			// Shader Properties Sampling
			float __outlineWidth = ( _OutlineWidth );
			float4 __outlineColorVertex = ( _HologramColor.rgba );

			float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
			worldPos.xyz = ( worldPos.xyz + float3(-0.05,0,0) * saturate((0.0333 - (sin(_Time.z - worldPos.y*5)+1)*0.5)*30) );
			v.vertex.xyz = mul(unity_WorldToObject, float4(worldPos, 1)).xyz;
		
		#ifdef TCP2_COLORS_AS_NORMALS
			//Vertex Color for Normals
			float3 normal = (v.vertexColor.xyz*2) - 1;
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
			//- get z
			n.z = v.uv2.y;
			//- transform
			n = n*2 - 1;
			float3 normal = n;
		#else
			float3 normal = v.normal;
		#endif
			float size = 1;
		
		#if !defined(SHADOWCASTER_PASS)
			output.vertex = UnityObjectToClipPos(v.vertex);
			normal = mul(unity_ObjectToWorld, float4(normal, 0)).xyz;
			float2 clipNormals = normalize(mul(UNITY_MATRIX_VP, float4(normal,0)).xy);
			clipNormals.xy *= output.vertex.w;
			clipNormals.xy = (clipNormals.xy / _ScreenParams.xy) * 2.0;
			output.vertex.xy += clipNormals.xy * __outlineWidth * size;
		#else
			v.vertex = v.vertex + float4(normal,0) * __outlineWidth * size * 0.01;
		#endif
		
			output.vcolor.xyzw = __outlineColorVertex;
			return output;
		}

		float4 fragment_outline (v2f_outline input) : SV_Target
		{
			// Shader Properties Sampling
			float4 __outlineColor = ( float4(1,1,1,1) );

			half4 outlineColor = __outlineColor * input.vcolor.xyzw;
			return outlineColor;
		}

		ENDCG
		// Outline Include End

		//Depth pre-pass
		Pass
		{
			Name "Depth Prepass"
			Tags { "LightMode"="ForwardBase" }
			ColorMask 0
			ZWrite On

			CGPROGRAM
			#pragma vertex vertex_depthprepass
			#pragma fragment fragment_depthprepass
			#pragma target 3.0

			#include "UnityCG.cginc"
			#include "UnityLightingCommon.cginc"	// needed for LightColor

			struct appdata_sil
			{
				float4 vertex : POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f_depthprepass
			{
				float4 vertex : SV_POSITION;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			v2f_depthprepass vertex_depthprepass (appdata_sil v)
			{
				v2f_depthprepass output;
				UNITY_INITIALIZE_OUTPUT(v2f_depthprepass, output);
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				worldPos.xyz = ( worldPos.xyz + float3(-0.05,0,0) * saturate((0.0333 - (sin(_Time.z - worldPos.y*5)+1)*0.5)*30) );
				v.vertex.xyz = mul(unity_WorldToObject, float4(worldPos, 1)).xyz;
				output.vertex = UnityObjectToClipPos(v.vertex);
				return output;
			}

			half4 fragment_depthprepass (v2f_depthprepass input) : SV_Target
			{
				return 0;
			}
			ENDCG
		}
		// Main Surface Shader
		Blend One One

		CGPROGRAM

		#pragma surface surf ToonyColorsCustom vertex:vertex_surface exclude_path:deferred exclude_path:prepass keepalpha noforwardadd novertexlights nolightmap nofog keepalpha
		#pragma target 3.0

		//================================================================
		// VARIABLES

		// Custom Material Properties
		sampler2D _ScanlinesTex;
		float4 _ScanlinesTex_ST;
		float4 _ScanlinesTex_TexelSize;
		float4 _ScanlinesTex_SC;
		
		// Shader Properties
		float _NDVMinFrag;
		float _NDVMaxFrag;
		sampler2D _MainTex;

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
			half3 viewDir;
			half3 worldNormal; INTERNAL_DATA
			float4 screenPosition;
			float2 texcoord0;
		};

		//================================================================
		// VERTEX FUNCTION

		void vertex_surface(inout appdata_tcp2 v, out Input output)
		{
			UNITY_INITIALIZE_OUTPUT(Input, output);

			// Texture Coordinates
			output.texcoord0 = v.texcoord0;

			float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
			worldPos.xyz = ( worldPos.xyz + float3(-0.05,0,0) * saturate((0.0333 - (sin(_Time.z - worldPos.y*5)+1)*0.5)*30) );
			v.vertex.xyz = mul(unity_WorldToObject, float4(worldPos, 1)).xyz;
			float4 clipPos = UnityObjectToClipPos(v.vertex);

			//Screen Position
			float4 screenPos = ComputeScreenPos(clipPos);
			output.screenPosition = screenPos;

		}

		//================================================================

		//Custom SurfaceOutput
		struct SurfaceOutputCustom
		{
			half atten;
			half3 Albedo;
			half3 Normal;
			half3 worldNormal;
			half3 Emission;
			half Specular;
			half Gloss;
			half Alpha;
			half ndv;
			half ndvRaw;

			Input input;
			
			// Shader Properties
			float3 __highlightColor;
			float3 __shadowColor;
			float __ambientIntensity;
		};

		//================================================================
		// SURFACE FUNCTION

		void surf(Input input, inout SurfaceOutputCustom output)
		{
			//Screen Space UV
			float2 screenUV = input.screenPosition.xy / input.screenPosition.w;
			
			// Custom Material Properties Sampling
			half4 value__ScanlinesTex = tex2D(_ScanlinesTex, (screenUV + frac(_Time.yy * _ScanlinesTex_SC.xy)) * _ScanlinesTex_TexelSize.xy * _ScreenParams.xy * _ScanlinesTex_ST.xy + _ScanlinesTex_ST.zw).rgba;

			// Shader Properties Sampling
			float __ndvMinFrag = ( _NDVMinFrag );
			float __ndvMaxFrag = ( _NDVMaxFrag );
			float4 __albedo = ( float4(0,0,0,0) );
			float4 __mainColor = ( float4(0,0,0,0) );
			float __alpha = ( __albedo.a * __mainColor.a );
			float3 __emission = ( tex2D(_MainTex, (input.texcoord0.xy)).rgb * _HologramColor.rgb * float3(0.5,0.5,0.5) * value__ScanlinesTex.aaa );
			output.__highlightColor = ( float3(0,0,0) );
			output.__shadowColor = ( float3(0,0,0) );
			output.__ambientIntensity = ( 1.0 );

			output.input = input;

			half3 worldNormal = WorldNormalVector(input, output.Normal);
			output.worldNormal = worldNormal;

			half ndv = max(0, dot(input.viewDir, output.Normal.xyz));
			half ndvRaw = ndv;
			ndv = 1 - ndv;
			ndv = smoothstep(__ndvMinFrag, __ndvMaxFrag, ndv);
			output.ndv = ndv;
			output.ndvRaw = ndvRaw;

			output.Albedo = __albedo.rgb;
			output.Alpha = __alpha;
			
			output.Albedo *= __mainColor.rgb;
			output.Emission += ( __emission * ndv.xxx );
		}

		//================================================================
		// LIGHTING FUNCTION

		inline half4 LightingToonyColorsCustom(inout SurfaceOutputCustom surface, half3 viewDir, UnityGI gi)
		{
			half ndv = surface.ndv;
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
			ndl = saturate(ndl);
			ramp = ndl.xxx;
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

		//Outline
		Pass
		{
			Name "Outline"
			Tags { "LightMode"="ForwardBase" }
			Cull Front

			CGPROGRAM
			#pragma vertex vertex_outline
			#pragma fragment fragment_outline
			#pragma target 3.0
			#pragma multi_compile TCP2_NONE TCP2_COLORS_AS_NORMALS TCP2_TANGENT_AS_NORMALS TCP2_UV2_AS_NORMALS
			#pragma multi_compile_instancing
			ENDCG
		}
	}

	Fallback "Diffuse"
	CustomEditor "ToonyColorsPro.ShaderGenerator.MaterialInspector_SG2"
}

/* TCP_DATA u config(ver:"2.4.0";tmplt:"SG2_Template_Default";features:list["UNITY_5_4","UNITY_5_5","EMISSION","SHADER_BLENDING","DEPTH_PREPASS","OUTLINE","ADDITIVE_BLENDING","OUTLINE_CONSTANT_SIZE","OUTLINE_CLIP_SPACE","OUTLINE_PIXEL_PERFECT","NO_RAMP"];flags:list["noforwardadd","novertexlights"];keywords:dict[RENDER_TYPE="Opaque",RampTextureDrawer="[TCP2Gradient]",RampTextureLabel="Ramp Texture",SHADER_TARGET="3.0"];shaderProperties:list[sp(name:"Albedo";imps:list[imp_constant(type:color_rgba;fprc:float;fv:1;f2v:(1.0, 1.0);f3v:(1.0, 1.0, 1.0);f4v:(1.0, 1.0, 1.0, 1.0);cv:RGBA(0.000, 0.000, 0.000, 0.000);op:Multiply;lbl:"Albedo";gpu_inst:False;locked:False;impl_index:-1)]),sp(name:"Main Color";imps:list[imp_constant(type:color_rgba;fprc:float;fv:1;f2v:(1.0, 1.0);f3v:(1.0, 1.0, 1.0);f4v:(1.0, 1.0, 1.0, 1.0);cv:RGBA(0.000, 0.000, 0.000, 0.000);op:Multiply;lbl:"Color";gpu_inst:False;locked:False;impl_index:-1)]),,,sp(name:"Ramp Threshold";imps:list[imp_constant(type:float;fprc:float;fv:0;f2v:(1.0, 1.0);f3v:(1.0, 1.0, 1.0);f4v:(1.0, 1.0, 1.0, 1.0);cv:RGBA(1.000, 1.000, 1.000, 1.000);op:Multiply;lbl:"Threshold";gpu_inst:False;locked:False;impl_index:-1)]),sp(name:"Ramp Smoothing";imps:list[imp_constant(type:float;fprc:float;fv:0;f2v:(1.0, 1.0);f3v:(1.0, 1.0, 1.0);f4v:(1.0, 1.0, 1.0, 1.0);cv:RGBA(1.000, 1.000, 1.000, 1.000);op:Multiply;lbl:"Smoothing";gpu_inst:False;locked:False;impl_index:-1)]),sp(name:"Highlight Color";imps:list[imp_constant(type:color;fprc:float;fv:1;f2v:(1.0, 1.0);f3v:(1.0, 1.0, 1.0);f4v:(1.0, 1.0, 1.0, 1.0);cv:RGBA(0.000, 0.000, 0.000, 1.000);op:Multiply;lbl:"Highlight Color";gpu_inst:False;locked:False;impl_index:-1)]),sp(name:"Shadow Color";imps:list[imp_constant(type:color;fprc:float;fv:1;f2v:(1.0, 1.0);f3v:(1.0, 1.0, 1.0);f4v:(1.0, 1.0, 1.0, 1.0);cv:RGBA(0.000, 0.000, 0.000, 1.000);op:Multiply;lbl:"Shadow Color";gpu_inst:False;locked:False;impl_index:-1)]),sp(name:"Emission";imps:list[imp_mp_texture(guid:"be90ab57-5c55-48a8-a72c-b9f1647d2637";uto:False;tov:"";gto:False;sbt:False;scr:False;scv:"";gsc:False;roff:False;goff:False;notile:False;def:"white";locked_uv:False;uv:0;cc:3;chan:"RGB";mip:-1;mipprop:False;ssuv:False;ssuv_vert:False;ssuv_obj:False;prop:"_MainTex";md:"";custom:False;refs:"";op:Multiply;lbl:"Emission Texture";gpu_inst:False;locked:False;impl_index:-1),imp_ct(lct:"_HologramColor";cc:3;chan:"RGB";avchan:"RGBA";op:Multiply;lbl:"Emission Color";gpu_inst:False;locked:False;impl_index:-1),imp_constant(type:color;fprc:float;fv:1;f2v:(1.0, 1.0);f3v:(1.0, 1.0, 1.0);f4v:(1.0, 1.0, 1.0, 1.0);cv:RGBA(0.500, 0.500, 0.500, 1.000);op:Multiply;lbl:"Emission";gpu_inst:False;locked:False;impl_index:-1),imp_ct(lct:"_ScanlinesTex";cc:3;chan:"AAA";avchan:"RGBA";op:Multiply;lbl:"Emission";gpu_inst:False;locked:False;impl_index:-1),imp_generic(cc:3;chan:"XXX";source_id:"float ndv3fragment";needed_features:"USE_NDV_FRAGMENT";custom_code_compatible:False;options_v:dict[Use Min/Max Properties=True,Invert=True,Ignore Normal Map=False];op:Multiply;lbl:"Emission";gpu_inst:False;locked:False;impl_index:-1)]),,,sp(name:"Outline Color Vertex";imps:list[imp_ct(lct:"_HologramColor";cc:4;chan:"RGBA";avchan:"RGBA";op:Multiply;lbl:"Color";gpu_inst:False;locked:False;impl_index:-1)]),,sp(name:"Vertex Position World";imps:list[imp_hook(op:Multiply;lbl:"worldPos.xyz";gpu_inst:False;locked:False;impl_index:0),imp_customcode(code:"+ float3(-0.05,0,0) * saturate((0.0333 - (sin(_Time.z - worldPos.y*5)+1)*0.5)*30)";op:Multiply;lbl:"Vertex Position World";gpu_inst:False;locked:False;impl_index:-1)]),,,,,,,,,,sp(name:"Blend Destination";imps:list[imp_enum(value_type:0;value:0;enum_type:"ToonyColorsPro.ShaderGenerator.BlendFactor";op:Multiply;lbl:"Blend Destination";gpu_inst:False;locked:False;impl_index:0)]),sp(name:"Outline Blend Source";imps:list[imp_enum(value_type:0;value:0;enum_type:"ToonyColorsPro.ShaderGenerator.BlendFactor";op:Multiply;lbl:"Blend Source";gpu_inst:False;locked:False;impl_index:0)]),sp(name:"Outline Blend Destination";imps:list[imp_enum(value_type:0;value:1;enum_type:"ToonyColorsPro.ShaderGenerator.BlendFactor";op:Multiply;lbl:"Blend Destination";gpu_inst:False;locked:False;impl_index:0)])];customTextures:list[ct(cimp:imp_mp_color(def:RGBA(0.000, 0.502, 1.000, 1.000);hdr:True;cc:4;chan:"RGBA";prop:"_HologramColor";md:"[TCP2ColorNoAlpha]";custom:True;refs:"Emission Color, Color";op:Multiply;lbl:"Hologram Color";gpu_inst:False;locked:False;impl_index:-1);exp:False;uv_exp:False;imp_lbl:"Color"),ct(cimp:imp_mp_texture(guid:"e059c82d-333e-41a0-b42d-83d58469534e";uto:True;tov:"";gto:False;sbt:True;scr:True;scv:"";gsc:False;roff:False;goff:False;notile:False;def:"white";locked_uv:False;uv:4;cc:4;chan:"RGBA";mip:0;mipprop:False;ssuv:True;ssuv_vert:False;ssuv_obj:False;prop:"_ScanlinesTex";md:"";custom:True;refs:"";op:Multiply;lbl:"Scanlines Texture";gpu_inst:False;locked:False;impl_index:-1);exp:False;uv_exp:False;imp_lbl:"Texture")]) */
/* TCP_HASH 99c52f0ddba45c96bfb6f4f0af330880 */
