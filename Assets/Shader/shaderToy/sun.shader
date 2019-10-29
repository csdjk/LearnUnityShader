// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Shadertoy/sun" { 
    Properties{
        iMouse ("Mouse Pos", Vector) = (100, 100, 0, 0)
        iChannel0("iChannel0", 2D) = "white" {}  
        iChannel1("iChannel1", 2D) = "white" {}  
        iChannelResolution0 ("iChannelResolution0", Vector) = (100, 100, 0, 0)
        _Cutoff("Alpha Cutoff",Range(0,1))=1
    }

 CGINCLUDE    
    #include "UnityCG.cginc"   
    #pragma target 3.0      

    #define vec2 float2
    #define vec3 float3
    #define vec4 float4
    #define mat2 float2x2
    #define mat3 float3x3
    #define mat4 float4x4
    #define iGlobalTime _Time.y
    #define mod fmod
    #define mix lerp
    #define fract frac
    #define texture2D tex2D
    #define iResolution _ScreenParams
    #define gl_FragCoord ((_iParam.scrPos.xy/_iParam.scrPos.w) * _ScreenParams.xy)

    #define PI2 6.28318530718
    #define pi 3.14159265358979
    #define halfpi (pi * 0.5)
    #define oneoverpi (1.0 / pi)

    fixed4 iMouse;
    sampler2D iChannel0;
     sampler2D iChannel1;
    fixed4 iChannelResolution0;
    fixed _Cutoff;
    

    struct v2f {    
        float4 pos : SV_POSITION;    
        float4 scrPos : TEXCOORD0;   
    };              

    v2f vert(appdata_base v) {  
        v2f o;
        o.pos = UnityObjectToClipPos (v.vertex);
        o.scrPos = ComputeScreenPos(o.pos);
        return o;
    }  

    vec4 main(vec2 fragCoord);

    fixed4 frag(v2f _iParam) : COLOR0 { 
        vec2 fragCoord = gl_FragCoord;
        return main(gl_FragCoord);
    }  

    //vec4 main(vec2 fragCoord) {
    //    return vec4(1, 1, 1, 1);
    //}
    float snoise(vec3 uv, float res)    // by trisomie21
{
    const vec3 s = vec3(1e0, 1e2, 1e4);
    
    uv *= res;
    
    vec3 uv0 = floor(mod(uv, res))*s;
    vec3 uv1 = floor(mod(uv+float3(1,1,1), res))*s;
    
    vec3 f = fract(uv); f = f*f*(3.0-2.0*f);
    
    vec4 v = vec4(uv0.x+uv0.y+uv0.z, uv1.x+uv0.y+uv0.z,
                  uv0.x+uv1.y+uv0.z, uv1.x+uv1.y+uv0.z);
    
    vec4 r = fract(sin(v*1e-3)*1e5);
    float r0 = mix(mix(r.x, r.y, f.x), mix(r.z, r.w, f.x), f.y);
    
    r = fract(sin((v + uv1.z - uv0.z)*1e-3)*1e5);
    float r1 = mix(mix(r.x, r.y, f.x), mix(r.z, r.w, f.x), f.y);
    
    return mix(r0, r1, f.z)*2.-1.;
    
}

    vec4 main(vec2 fragCoord) {

        float freqs[4];

        freqs[0] = tex2D( iChannel1, vec2( 0.01, 0.25 ) ).x;
        freqs[1] = tex2D( iChannel1, vec2( 0.07, 0.25 ) ).x;
        freqs[2] = tex2D( iChannel1, vec2( 0.15, 0.25 ) ).x;
        freqs[3] = tex2D( iChannel1, vec2( 0.30, 0.25 ) ).x;

        float brightness    = freqs[1] * 0.25 + freqs[2] * 0.25;
        float radius        = 0.24 + brightness * 0.2;
        float invRadius     = 1.0/radius;
    
        vec3 orange         = vec3( 0.8, 0.65, 0.3 );
        vec3 orangeRed      = vec3( 0.8, 0.35, 0.1 );
        float time      = iGlobalTime * 0.1;
        float aspect    = iResolution.x/iResolution.y;
        vec2 uv         = fragCoord.xy / iResolution.xy;
        vec2 p          = -0.5 + uv;
        p.x *= aspect;

        float fade      = pow( length( 2.0 * p ), 0.5 );
        float fVal1     = 1.0 - fade;
        float fVal2     = 1.0 - fade;
        
        float angle     = atan2( p.x, p.y )/6.2832;
        float dist      = length(p);
        vec3 coord      = vec3( angle, dist, time * 0.1 );
    
        float newTime1  = abs( snoise( coord + vec3( 0.0, -time * ( 0.35 + brightness * 0.001 ), time * 0.015 ), 15.0 ) );
        float newTime2  = abs( snoise( coord + vec3( 0.0, -time * ( 0.15 + brightness * 0.001 ), time * 0.015 ), 45.0 ) );  
        for( int i=1; i<=7; i++ ){
            float power = pow( 2.0, float(i + 1) );
            fVal1 += ( 0.5 / power ) * snoise( coord + vec3( 0.0, -time, time * 0.2 ), ( power * ( 10.0 ) * ( newTime1 + 1.0 ) ) );
            fVal2 += ( 0.5 / power ) * snoise( coord + vec3( 0.0, -time, time * 0.2 ), ( power * ( 25.0 ) * ( newTime2 + 1.0 ) ) );
        }
    
        float corona        = pow( fVal1 * max( 1.1 - fade, 0.0 ), 2.0 ) * 50.0;
        corona              += pow( fVal2 * max( 1.1 - fade, 0.0 ), 2.0 ) * 50.0;
        corona              *= 1.2 - newTime1;
        vec3 sphereNormal   = vec3( 0.0, 0.0, 1.0 );
        vec3 dir            = vec3( 0,0,0 );
        vec3 center         = vec3( 0.5, 0.5, 1.0 );
        vec3 starSphere     = vec3( 0,0,0 );
    
        vec2 sp = -1.0 + 2.0 * uv;
        sp.x *= aspect;
        sp *= ( 2.0 - brightness );
        float r = dot(sp,sp);
        float f = (1.0-sqrt(abs(1.0-r)))/(r) + brightness * 0.5;
        if( dist < radius ){
            corona          *= pow( dist * invRadius, 24.0 );
            vec2 newUv;
            newUv.x = sp.x*f;
            newUv.y = sp.y*f;
            newUv += vec2( time, 0.0 );
        
            vec3 texSample  = tex2D( iChannel0, newUv ).rgb;
            float uOff      = ( texSample.g * brightness * 4.5 + time );
            vec2 starUV     = newUv + vec2( uOff, 0.0 );
            starSphere      = tex2D( iChannel0, starUV ).rgb;
        }
    
        float starGlow  = min( max( 1.0 - dist * ( 1.0 - brightness ), 0.0 ), 1.0 );
        
        fixed4 fragColor;
        fragColor.rgb   = vec3( f * ( 0.75 + brightness * 0.3 ) * orange ) + starSphere + corona * orange + starGlow * orangeRed;
        fragColor.a     = 1;

        return fragColor;
    }

    ENDCG    

    SubShader {    
        Pass {    
        Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM    
            
            #pragma vertex vert    
            #pragma fragment frag    
            #pragma fragmentoption ARB_precision_hint_fastest     

            ENDCG    
        }    
    }     
    FallBack Off    
}