// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "lcl/shaderToy/water" {
    Properties{
        iMouse("Mouse Pos", Vector) = (100, 100, 0, 0)
        iChannel0("iChannel0", 2D) = "white" {}
        iChannelResolution0("iChannelResolution0", Vector) = (100, 100, 0, 0)
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
    fixed4 iChannelResolution0;
    //////////////


    #define NUM_STEPS   8 
    #define PI  3.141592 
    #define EPSILON   1e-3 
    #define EPSILON_NRM (0.1 / iResolution.x)
    // sea
    #define SEA_HEIGHT   0.6 
    #define SEA_CHOPPY   4.0 
    #define SEA_SPEED   0.8 
    #define SEA_FREQ   0.16 
    #define ITER_GEOMETRY   3 
    #define ITER_FRAGMENT   5 
    #define   SEA_BASE   vec3(0.1, 0.19, 0.22) 
    #define   SEA_WATER_COLOR   vec3(0.8, 0.9, 0.6) 
    #define iTime _Time.y
    #define SEA_TIME (1.0 + iTime * SEA_SPEED)
    #define   octave_m   mat2(1.6, 1.2, -1.2, 1.6) 



    // math
    mat3 fromEuler(vec3 ang) {
        vec2 a1 = vec2(sin(ang.x), cos(ang.x));
        vec2 a2 = vec2(sin(ang.y), cos(ang.y));
        vec2 a3 = vec2(sin(ang.z), cos(ang.z));
        mat3 m;
        m[0] = vec3(a1.y*a3.y + a1.x*a2.x*a3.x, a1.y*a2.x*a3.x + a3.y*a1.x, -a2.y*a3.x);
        m[1] = vec3(-a2.y*a1.x, a1.y*a2.y, a2.x);
        m[2] = vec3(a3.y*a1.x*a2.x + a1.y*a3.x, a1.x*a3.x - a1.y*a3.y*a2.x, a2.y*a3.y);
        return m;
    }

    float hash(vec2 p) {
        float h = dot(p, vec2(127.1, 311.7));
        return fract(sin(h)*43758.5453123);
    }
    float noise(in vec2 p) {
        vec2 i = floor(p);
        vec2 f = fract(p);
        vec2 u = f*f*(3.0 - 2.0*f);
        return -1.0 + 2.0*mix(mix(hash(i + vec2(0.0, 0.0)),
        hash(i + vec2(1.0, 0.0)), u.x),
        mix(hash(i + vec2(0.0, 1.0)),
        hash(i + vec2(1.0, 1.0)), u.x), u.y);
    }

    // lighting
    float diffuse(vec3 n, vec3 l, float p) {
        return pow(dot(n, l) * 0.4 + 0.6, p);
    }
    float specular(vec3 n, vec3 l, vec3 e, float s) {
        float nrm = (s + 8.0) / (PI * 8.0);
        return pow(max(dot(reflect(e, n), l), 0.0), s) * nrm;
    }

    // sky
    vec3 getSkyColor(vec3 e) {
        e.y = max(e.y, 0.0);
        return vec3(pow(1.0 - e.y, 2.0), 1.0 - e.y, 0.6 + (1.0 - e.y)*0.4);
    }

    // sea
    float sea_octave(vec2 uv, float choppy) {
        uv += noise(uv);
        vec2 wv = 1.0 - abs(sin(uv));
        vec2 swv = abs(cos(uv));
        wv = mix(wv, swv, wv);
        return pow(1.0 - pow(wv.x * wv.y, 0.65), choppy);
    }
    
    float map(vec3 p) {
        float freq = SEA_FREQ;
        float amp = SEA_HEIGHT;
        float choppy = SEA_CHOPPY;
        vec2 uv = p.xz; uv.x *= 0.75;

        float d, h = 0.0;
        for (int i = 0; i < ITER_GEOMETRY; i++) {
            d = sea_octave((uv + SEA_TIME)*freq, choppy);
            d += sea_octave((uv - SEA_TIME)*freq, choppy);
            h += d * amp;
            uv = mul(uv, octave_m);//矩阵运算
            freq *= 1.9;
            amp *= 0.22;
            choppy = mix(choppy, 1.0, 0.2);
        }
        return p.y - h;
    }

    float map_detailed(vec3 p) {
        float freq = SEA_FREQ;
        float amp = SEA_HEIGHT;
        float choppy = SEA_CHOPPY;
        vec2 uv = p.xz; uv.x *= 0.75;

        float d, h = 0.0;
        for (int i = 0; i < ITER_FRAGMENT; i++) {
            d = sea_octave((uv + SEA_TIME)*freq, choppy);
            d += sea_octave((uv - SEA_TIME)*freq, choppy);
            h += d * amp;
            uv = mul(uv, octave_m);//矩阵运算uv *= octave_m; 
            freq *= 1.9; amp *= 0.22;
            choppy = mix(choppy, 1.0, 0.2);
        }
        return p.y - h;
    }

    vec3 getSeaColor(vec3 p, vec3 n, vec3 l, vec3 eye, vec3 dist) {
        float fresnel = clamp(1.0 - dot(n, -eye), 0.0, 1.0);
        fresnel = pow(fresnel, 3.0) * 0.65;

        vec3 reflected = getSkyColor(reflect(eye, n));
        vec3 refracted = SEA_BASE + diffuse(n, l, 80.0) * SEA_WATER_COLOR * 0.12;

        vec3 color = mix(refracted, reflected, fresnel);

        float atten = max(1.0 - dot(dist, dist) * 0.001, 0.0);
        color += SEA_WATER_COLOR * (p.y - SEA_HEIGHT) * 0.18 * atten;

        float s1 = specular(n, l, eye, 60.0);
        color += vec3(s1,s1,s1);

        return color;
    }
    // tracing
    vec3 getNormal(vec3 p, float eps) {
        vec3 n;
        n.y = map_detailed(p);
        n.x = map_detailed(vec3(p.x + eps, p.y, p.z)) - n.y;
        n.z = map_detailed(vec3(p.x, p.y, p.z + eps)) - n.y;
        n.y = eps;
        return normalize(n);
    }

    float heightMapTracing(vec3 ori, vec3 dir, out vec3 p) {
        float tm = 0.0;
        float tx = 1000.0;
        float hx = map(ori + dir * tx);
        if (hx > 0.0) return tx;
        float hm = map(ori + dir * tm);
        float tmid = 0.0;
        for (int i = 0; i < NUM_STEPS; i++) {
            tmid = mix(tm, tx, hm / (hm - hx));
            p = ori + dir * tmid;
            float hmid = map(p);
            if (hmid < 0.0) {
                tx = tmid;
                hx = hmid;
            }
            else {
                tm = tmid;
                hm = hmid;
            }
        }
        return tmid;
    }

    // main
    vec4 mainImage(in vec2 fragCoord) {
        vec2 uv = fragCoord.xy / iResolution.xy;
        uv = uv * 2.0 - 1.0;
        uv.x *= iResolution.x / iResolution.y;
        float time = iTime * 0.3 + iMouse.x*0.01;
        // ray
        vec3 ang = vec3(sin(time*3.0)*0.1,sin(time)*0.2+0.3,time);    
        //vec3 ang = vec3(0, 0, time);
        vec3 ori = vec3(0.0, 3.5, time*5.0);
        vec3 dir = normalize(vec3(uv.xy, -2.0));
        dir.z += length(uv) * 0.15;
        dir = mul(normalize(dir), fromEuler(ang));//dir = normalize(dir) * fromEuler(ang);

        // tracing
        vec3 p;
        heightMapTracing(ori, dir, p);
        vec3 dist = p - ori;
        vec3 n = getNormal(p, dot(dist, dist) * EPSILON_NRM);
        vec3 light = normalize(vec3(0.0, 1.0, 0.8));

        // color
        vec3 color = mix(
        getSkyColor(dir),
        getSeaColor(p, n, light, dir, dist),
        pow(smoothstep(0.0, -0.05, dir.y), 0.3));

        // post
        vec3 po = vec3(pow(color.x, 0.75), pow(color.y, 0.75), pow(color.z, 0.75));
        return  vec4(po, 1.0);//fragColor = vec4(pow(color, vec3(0.75)), 1.0);
    }
    

    ////////////
    struct v2f {
        float4 pos : SV_POSITION;
        float4 scrPos : TEXCOORD0;
    };


    vec4 main(vec2 fragCoord);
    vec4 main(vec2 fragCoord) {
        float2 viewPortCoor = float2(fragCoord.x / iResolution.x, fragCoord.y / iResolution.y);// (0,0) - (1,1) 中心位置为(0.5,0.5)

        return vec4(viewPortCoor, 1, 1);
    }

    v2f vert(appdata_base v) {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.scrPos = ComputeScreenPos(o.pos);
        return o;
    }
    fixed4 frag(v2f _iParam) : COLOR0{
        vec2 fragCoord = gl_FragCoord;
        //vec4 fragColor = Vec4(1,1,1,1);
        //mainImage(  fragColor, fragCoord);
        return mainImage(fragCoord);;
        //return mainImageTest(fragCoord);;
        //return main(fragCoord);
    }


    ENDCG

    SubShader{
        Pass{
            CGPROGRAM

            #pragma vertex vert    
            #pragma fragment frag    
            #pragma fragmentoption ARB_precision_hint_fastest     

            ENDCG
        }
    }
    FallBack Off
}