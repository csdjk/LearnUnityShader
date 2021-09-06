// Toony Colors Pro+Mobile Shaders
// (c) 2014-2019 Jean Moreno

#ifndef TOONYCOLORS_INCLUDED
	#define TOONYCOLORS_INCLUDED
	
	#if TCP2_RAMPTEXT
		//Lighting Ramp
		sampler2D _Ramp;
	#else
		float _RampThreshold;
		float _RampSmooth;
	#endif
	
	#if TCP2_SPEC_TOON
		fixed _SpecSmooth;
	#endif
	
	//Highlight/Shadow Colors
	fixed4 _HColor;
	fixed4 _SColor;
	
#endif

//================================================================================================================================
// FORWARD PATH
//--------------------------------------------------------------------------------------------------------------------------------
// TOONY COLORS -- REGULAR
inline half4 LightingToonyColors (SurfaceOutput s, half3 lightDir, half atten)
{
#if TCP2_DISABLE_WRAPPED_LIGHT
	fixed ndl = max(0, dot(s.Normal, lightDir));
#else
	fixed ndl = max(0, dot(s.Normal, lightDir)*0.5 + 0.5);
#endif
#if TCP2_RAMPTEXT
	fixed3 ramp = tex2D(_Ramp, fixed2(ndl,ndl));
#else
	fixed3 ramp = smoothstep(_RampThreshold-_RampSmooth*0.5, _RampThreshold+_RampSmooth*0.5, ndl);
#endif
#if !(POINT) && !(SPOT)
	ramp *= atten;
#endif
	_SColor = lerp(_HColor, _SColor, _SColor.a);	//Shadows intensity through alpha
	ramp = lerp(_SColor.rgb,_HColor.rgb,ramp);
	fixed4 c;
	c.rgb = s.Albedo * _LightColor0.rgb * ramp;
#if (POINT || SPOT)
	c.rgb *= atten;
#endif
	c.a = s.Alpha;
	return c;
}
//--------------------------------------------------------------------------------------------------------------------------------
// TOONY COLORS -- REGULAR + SPECULAR
inline half4 LightingToonyColorsSpec (SurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
{
	s.Normal = normalize(s.Normal);
#if TCP2_DISABLE_WRAPPED_LIGHT
	fixed ndl = max(0, dot(s.Normal, lightDir));
#else
	fixed ndl = max(0, dot(s.Normal, lightDir)*0.5 + 0.5);
#endif
#if TCP2_RAMPTEXT
	fixed3 ramp = tex2D(_Ramp, fixed2(ndl,ndl));
#else
	fixed3 ramp = smoothstep(_RampThreshold-_RampSmooth*0.5, _RampThreshold+_RampSmooth*0.5, ndl);
#endif
#if !(POINT) && !(SPOT)
	ramp *= atten;
#endif
	_SColor = lerp(_HColor, _SColor, _SColor.a);	//Shadows intensity through alpha
	ramp = lerp(_SColor.rgb,_HColor.rgb,ramp);
	//Specular
	half3 h = normalize(lightDir + viewDir);
	float ndh = max(0, dot(s.Normal, h));
	float spec = pow(ndh, s.Specular*128.0) * s.Gloss * 2.0;
#if TCP2_SPEC_TOON
	spec = smoothstep(0.5-_SpecSmooth*0.5, 0.5+_SpecSmooth*0.5, spec);
#endif
	spec *= atten;
	fixed4 c;
	c.rgb = s.Albedo * _LightColor0.rgb * ramp;
#if (POINT || SPOT)
	c.rgb *= atten;
#endif
	c.rgb += _LightColor0.rgb * _SpecColor.rgb * spec;
	c.a = s.Alpha + _LightColor0.a * _SpecColor.a * spec;
	
	return c;
}
//--------------------------------------------------------------------------------------------------------------------------------
// TOONY COLORS -- REGULAR LIGHTMAPS
#if TCP2_LIGHTMAP
	inline fixed4 LightingToonyColors_SingleLightmap (SurfaceOutput s, fixed4 color)
	{
		half3 lm = DecodeLightmap(color);
		
		float lum = Luminance(lm);
	#if TCP2_RAMPTEXT
		fixed3 ramp = tex2D(_Ramp, fixed2(lum,lum));
	#else
		fixed3 ramp = smoothstep(_RampThreshold-_RampSmooth*0.5, _RampThreshold+_RampSmooth*0.5, lum);
	#endif
		_SColor = lerp(_HColor, _SColor, _SColor.a);	//Shadows intensity through alpha
		ramp = lerp(_SColor.rgb,_HColor.rgb,ramp);
		lm *= ramp * 2;
		
		return fixed4(lm, 0);
	}

	inline fixed4 LightingToonyColors_DualLightmap (SurfaceOutput s, fixed4 totalColor, fixed4 indirectOnlyColor, half indirectFade)
	{
		half3 lm = lerp(DecodeLightmap(indirectOnlyColor), DecodeLightmap(totalColor), indirectFade);
		
		float lum = Luminance(lm);
	#if TCP2_RAMPTEXT
		fixed3 ramp = tex2D(_Ramp, fixed2(lum,lum));
	#else
		fixed3 ramp = smoothstep(_RampThreshold-_RampSmooth*0.5, _RampThreshold+_RampSmooth*0.5, lum);
	#endif
		_SColor = lerp(_HColor, _SColor, _SColor.a);	//Shadows intensity through alpha
		ramp = lerp(_SColor.rgb,_HColor.rgb,ramp);
		lm *= ramp * 2;
		
		return fixed4(lm, 0);
	}

	inline fixed4 LightingToonyColors_DirLightmap (SurfaceOutput s, fixed4 color, fixed4 scale, bool surfFuncWritesNormal)
	{
		UNITY_DIRBASIS
		half3 scalePerBasisVector;
		
		half3 lm = DirLightmapDiffuse(unity_DirBasis, color, scale, s.Normal, surfFuncWritesNormal, scalePerBasisVector);
		
		float lum = Luminance(lm);
	#if TCP2_RAMPTEXT
		fixed3 ramp = tex2D(_Ramp, fixed2(lum,lum));
	#else
		fixed3 ramp = smoothstep(_RampThreshold-_RampSmooth*0.5, _RampThreshold+_RampSmooth*0.5, lum);
	#endif
		_SColor = lerp(_HColor, _SColor, _SColor.a);	//Shadows intensity through alpha
		ramp = lerp(_SColor.rgb,_HColor.rgb,ramp);
		lm *= ramp * 2;
		
		return half4(lm, 0);
	}
#endif
//--------------------------------------------------------------------------------------------------------------------------------
// TOONY COLORS -- SPECULAR LIGHTMAPS
#if TCP2_LIGHTMAP
	inline fixed4 LightingToonyColorsSpec_SingleLightmap (SurfaceOutput s, fixed4 color)
	{
		half3 lm = DecodeLightmap(color);
		
		float lum = Luminance(lm);
	#if TCP2_RAMPTEXT
		fixed3 ramp = tex2D(_Ramp, fixed2(lum,lum));
	#else
		fixed3 ramp = smoothstep(_RampThreshold-_RampSmooth*0.5, _RampThreshold+_RampSmooth*0.5, lum);
	#endif
		_SColor = lerp(_HColor, _SColor, _SColor.a);	//Shadows intensity through alpha
		ramp = lerp(_SColor.rgb,_HColor.rgb,ramp);
		lm *= ramp * 2;
		
		return fixed4(lm, 0);
	}

	inline fixed4 LightingToonyColorsSpec_DualLightmap (SurfaceOutput s, fixed4 totalColor, fixed4 indirectOnlyColor, half indirectFade)
	{
		half3 lm = lerp(DecodeLightmap(indirectOnlyColor), DecodeLightmap(totalColor), indirectFade);
		
		float lum = Luminance(lm);
	#if TCP2_RAMPTEXT
		fixed3 ramp = tex2D(_Ramp, fixed2(lum,lum));
	#else
		fixed3 ramp = smoothstep(_RampThreshold-_RampSmooth*0.5, _RampThreshold+_RampSmooth*0.5, lum);
	#endif
		_SColor = lerp(_HColor, _SColor, _SColor.a);	//Shadows intensity through alpha
		ramp = lerp(_SColor.rgb,_HColor.rgb,ramp);
		lm *= ramp * 2;
		
		return fixed4(lm, 0);
	}

	inline fixed4 LightingToonyColorsSpec_DirLightmap (SurfaceOutput s, fixed4 color, fixed4 scale, half3 viewDir, bool surfFuncWritesNormal, out half3 specColor)
	{
		UNITY_DIRBASIS
		half3 scalePerBasisVector;
		
		half3 lm = DirLightmapDiffuse(unity_DirBasis, color, scale, s.Normal, surfFuncWritesNormal, scalePerBasisVector);
		
		half3 lightDir = normalize(scalePerBasisVector.x * unity_DirBasis[0] + scalePerBasisVector.y * unity_DirBasis[1] + scalePerBasisVector.z * unity_DirBasis[2]);
		half3 h = normalize(lightDir + viewDir);
		
		float nh = max(0, dot(s.Normal, h));
		float spec = pow(nh, s.Specular * 128.0);
		
		// specColor used outside in the forward path, compiled out in prepass
		specColor = lm * _SpecColor.rgb * s.Gloss * spec;
		
		float lum = Luminance(lm);
	#if TCP2_RAMPTEXT
		fixed3 ramp = tex2D(_Ramp, fixed2(lum,lum));
	#else
		fixed3 ramp = smoothstep(_RampThreshold-_RampSmooth*0.5, _RampThreshold+_RampSmooth*0.5, lum);
	#endif
		_SColor = lerp(_HColor, _SColor, _SColor.a);	//Shadows intensity through alpha
		ramp = lerp(_SColor.rgb,_HColor.rgb,ramp);
		lm *= ramp * 2;
		
		// spec from the alpha component is used to calculate specular
		// in the Lighting*_Prepass function, it's not used in forward
		return half4(lm, spec);
	}
#endif