#version 300 es

precision highp float;
precision highp int;
#define HLSLCC_ENABLE_UNIFORM_BUFFERS 1
#if HLSLCC_ENABLE_UNIFORM_BUFFERS
#define UNITY_UNIFORM
#else
#define UNITY_UNIFORM uniform
#endif
#define UNITY_SUPPORTS_UNIFORM_LOCATION 1
#if UNITY_SUPPORTS_UNIFORM_LOCATION
#define UNITY_LOCATION(x) layout(location = x)
#define UNITY_BINDING(x) layout(binding = x, std140)
#else
#define UNITY_LOCATION(x)
#define UNITY_BINDING(x) layout(std140)
#endif
uniform 	vec4 _Vector1;
layout(location = 0) out mediump vec4 SV_Target0;
vec4 u_xlat0;
vec3 u_xlat1;
void main()
{
    u_xlat0.xyz = _Vector1.xyx * _Vector1.xyz;
    u_xlat0.xyz = u_xlat0.xyz * _Vector1.yxy;
    u_xlat0.w = _Vector1.z;
    u_xlat1.xyz = u_xlat0.xwz * _Vector1.wzx;
    u_xlat0.xyz = u_xlat0.wyw * u_xlat1.xyz;
    u_xlat0.xyz = u_xlat0.xyz * _Vector1.www;
    SV_Target0.xyz = u_xlat0.xyz;
    SV_Target0.w = 1.0;
    return;
}