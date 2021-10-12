Shader "Unlit/BRDF_Anistropic"
{
     Properties
    {
        _BaseColor ("_BaseColor",Color) = (0.5,0.3,0.2,1)
        _Metallic ("_Metallic",Range(0,1)) = 1
        _Roughness ("_Roughness",Range(0,1)) =1
        _Anisotropy ("_Anisotropy",Float) =0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode"="ForwardBase" "Queue" = "Geometry"}
//"LightMode"="ForwardBase" ForwardBase 让Shader接受主光源影响
        
        /*
        //Transparent Setup
         Tags { "Queue"="Transparent"  "RenderType"="Transparent" "LightMode"="ForwardBase"}
         Blend SrcAlpha OneMinusSrcAlpha
        */

        Pass
        {
	        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma fullforwardshadows
            #pragma multi_compile_fwdbase
            
            #include "UnityCG.cginc"
	        #include "Lighting.cginc"
            #include "UnityGlobalIllumination.cginc"
            #include "AutoLight.cginc"
            // #include "NPRBrdf.cginc"	
			

            #ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
            //only defining to not throw compilation error over Unity 5.5
            #define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
            #endif
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #include "UnityCG.cginc"

	        struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float4 tangent :TANGENT;
                float3 normal : NORMAL;
                float4 vertexColor : COLOR;
            };

            struct v2f
            {
                float4 pos              : SV_POSITION; // 必须命名为pos ，因为 TRANSFER_VERTEX_TO_FRAGMENT 是这么命名的，为了正确地获取到Shadow
                float2 uv               : TEXCOORD0;
                float3 tangent          : TEXCOORD1;
                float3 bitangent        : TEXCOORD2; 
                float3 normal           : TEXCOORD3; 
                float3 worldPosition    : TEXCOORD4;
                float3 localPosition    : TEXCOORD5;
                float3 localNormal      : TEXCOORD6;
                float4 vertexColor      : TEXCOORD7;
                float2 uv2              : TEXCOORD8;
                LIGHTING_COORDS(9,10)
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.uv2 = v.uv2;
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldPosition = mul(unity_ObjectToWorld,v.vertex);
                o.localPosition = v.vertex.xyz;
                o.tangent = UnityObjectToWorldDir(v.tangent);
                o.bitangent = cross(o.normal,o.tangent) * v.tangent.w;
                o.localNormal = v.normal;
                o.vertexColor = v.vertexColor;
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                
                return o;
            }

            #ifndef PI
            #define PI 3.141592654
            #endif

            float4 _BaseColor;
            float _Roughness,_Metallic;
            float _Anisotropy;

            inline float pow5(float value)
            {
                return value*value*value*value*value;
            }

            float D_Anisotropic(float at, float ab, float ToH, float BoH, float NoH)    
            {
                // Burley 2012, "Physically-Based Shading at Disney"
                float a2 = at * ab;
                float3 d = float3(ab * ToH, at * BoH, a2 * NoH);
                return saturate(a2 * sqrt(a2 / dot(d, d)) * (1.0 / PI));
            }

            float V_Anisotropic(float at, float ab, float ToV, float BoV,float ToL, float BoL, float NoV, float NoL) 
            {
                // Heitz 2014, "Understanding the Masking-Shadowing Function in Microfacet-Based BRDFs"
                // TODO: lambdaV can be pre-computed for all the lights, it should be moved out of this function
                float lambdaV = NoL * length(float3(at * ToV, ab * BoV, NoL));
                float lambdaL = NoV * length(float3(at * ToL, ab * BoL, NoV));
                float v = 0.5 / (lambdaV + lambdaL);
                return saturate(v);
            }

            float3 F_Schlick(  float3 f0, float f90, float VoH) 
            {
                // Schlick 1994, "An Inexpensive BRDF Model for Physically-Based Rendering"
                float f = pow5(1.0 - VoH);
                return f + f0 * (f90 - f);
            }

            float3 F_Anisotropic( float3 f0, float LoH) 
            {
                return F_Schlick(f0, 1.0, LoH);
            }

            struct PixelParams
            {
                float3 anisotropicT;
                float3 anisotropicB;
                float linearRoughness;
                float anisotropy;
                float3 f0;
            };

            float3 BRDF_Anisotropic( in PixelParams pixel,float3 L, float3 V, float3 H,float NoV, float NoL, float NoH, float LoH) 
            {
                float3 t = pixel.anisotropicT;
                float3 b = pixel.anisotropicB;
                float3 v = V;

                float ToV = dot(t, v);
                float BoV = dot(b, v);
                float ToL = dot(t, L);
                float BoL = dot(b, L);
                float ToH = dot(t, H);
                float BoH = dot(b, H);

                // Anisotropic parameters: at and ab are the roughness along the tangent and bitangent
                // to simplify materials, we derive them from a single roughness parameter
                // Kulla 2017, "Revisiting Physically Based Shading at Imageworks"
                float at = max(pixel.linearRoughness * (1.0 + pixel.anisotropy), 0.001);
                float ab = max(pixel.linearRoughness * (1.0 - pixel.anisotropy), 0.001);

                // specular anisotropic BRDF
                float D = D_Anisotropic(at, ab, ToH, BoH, NoH);
                float V_ = V_Anisotropic(at, ab, ToV, BoV, ToL, BoL, NoV, NoL);
                float3  F = F_Anisotropic(pixel.f0, LoH);

                return D * V_ * F;
            }
			
            float4 frag (v2f i ) : SV_Target
            {
            
                float3 T = normalize(i.tangent);
                float3 N = normalize(i.normal);
                //float3 B = normalize( cross(N,T));
                float3 B = normalize( i.bitangent);
                float3 L = normalize( UnityWorldSpaceLightDir(i.worldPosition.xyz));
                float3 V = normalize( UnityWorldSpaceViewDir(i.worldPosition.xyz));
                float3 H = normalize(V+L);
                float2 uv = i.uv;
                float2 uv2 = i.uv2;

                // return float4(uv2,0,0);
                float4 vertexColor = i.vertexColor;
                // return vertexColor.xyzz;
                float HV = dot(H,V);
                float NV = dot(N,V);
                float NL = dot(N,L);
                float NH = dot(N,H);
                float LH = dot(L,H);


                float3 anisotropicT;
                float3 anisotropicB;
                float linearRoughness;
                float anisotropy;
                float f0;

                float3 F0 = lerp(0.04,_BaseColor,_Metallic);

                PixelParams pixel;
                pixel.anisotropicT = T;
                pixel.anisotropicB = B;
                pixel.linearRoughness = _Roughness;
                pixel.f0 = F0;
                pixel.anisotropy = _Anisotropy;
                
            // float3 BRDF_Anisotropic( in PixelParams pixel,float3 L, float3 V, float3 H,float NoV, float NoL, float NoH, float LoH) 

                float3 brdf = BRDF_Anisotropic(pixel,L,V,H,NV,NL,NH,LH);

                return (brdf*5).xyzz;//只显示高光 *5 为了突出高光表现

            }
	    ENDCG
	}
    }
    Fallback "Diffuse"
}
