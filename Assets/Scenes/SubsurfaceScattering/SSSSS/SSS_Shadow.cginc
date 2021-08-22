#ifndef SSS_SHADOW_INCLUDED
#define SSS_SHADOW_INCLUDED

#include "HLSLSupport.cginc"
#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
	#define CAN_SKIP_VPOS
#endif
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "UnityPBSLighting.cginc"
struct v2f
{
	V2F_SHADOW_CASTER;
	float4 customPack1 : TEXCOORD1;
	float4 tSpace0 : TEXCOORD2;
	float4 tSpace1 : TEXCOORD3;
	float4 tSpace2 : TEXCOORD4;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};
v2f vert( appdata_full v )
{
	v2f o;
	UNITY_SETUP_INSTANCE_ID( v );
	UNITY_INITIALIZE_OUTPUT( v2f, o );
	UNITY_TRANSFER_INSTANCE_ID( v, o );
	Input customInputData;
	float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
	half3 worldNormal = UnityObjectToWorldNormal( v.normal );
	half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
	half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
	half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
	o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
	o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
	o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
	o.customPack1.xy = customInputData.uv_texcoord;
	o.customPack1.xy = v.texcoord;
	o.customPack1.zw = v.texcoord1;

	TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
	return o;
}
half4 frag( v2f IN
#if !defined( CAN_SKIP_VPOS )
, UNITY_VPOS_TYPE vpos : VPOS
#endif
) : SV_Target
{
	UNITY_SETUP_INSTANCE_ID( IN );
	Input surfIN;
	UNITY_INITIALIZE_OUTPUT( Input, surfIN );
	surfIN.uv_texcoord = IN.customPack1.xy;
	surfIN.uv2_texcoord2 = IN.customPack1.zw;
	float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
	half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
	surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
	surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
	surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
	surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
	SurfaceOutputCustomLightingCustom o;
	UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o );

	#if !defined(SSS_CUSTOM_SHADOW)
	float2 scaledUV = TRANSFORM_TEX(surfIN.uv_texcoord, _MainTex);

	float4 _MainTex_var = tex2D( _MainTex, scaledUV );
	#if !(defined(_ALPHATEST_ON) || defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON))
		o.Alpha = 1.0;
	#else
		o.Alpha = (_SmoothnessFromAlbedo? 1.0 : _MainTex_var.a) * _Color.a ;
		o.Alpha = ((o.Alpha - _Cutout) /  0.0001 + 0.5);
		clip(o.Alpha - 1.0/255.0 );
	#endif
	#else
	customShadow( surfIN, o );
	#endif

	#if defined( CAN_SKIP_VPOS )
	float2 vpos = IN.pos;
	#endif
	SHADOW_CASTER_FRAGMENT( IN )
}

#endif // SSS_SHADOW_INCLUDED