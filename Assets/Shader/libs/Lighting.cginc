#ifndef LCL_LIGHTING_DIFFUSE_LAMBERT
#define LCL_LIGHTING_DIFFUSE_LAMBERT

// Custom Build-in Variables
fixed4 _MyColor;

// Lighting models
inline fixed4 LightingLambert (SurfaceOutput s, fixed3 lightDir, fixed atten) {
    // 环境光
    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
    //法线
    fixed3 normalDir = normalize(f.worldNormalDir);
    //灯光
    fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
    //漫反射计算
    fixed3 diffuse = _LightColor0.rgb * max(dot(normalDir,lightDir),0);
    fixed3 resultColor = (diffuse+ambient) * _Diffuse;

    return fixed4(resultColor,1);

    
	fixed diff = max (0, dot (s.Normal, lightDir));
	
	diff = (diff + 0.5) * 0.5;
	
	fixed4 c;
	c.rgb = s.Albedo * _LightColor0.rgb * ((diff * _MyColor.rgb) * atten * 2);
	c.a = s.Alpha;
	return c;
}

#endif
