Shader "lcl/FilmInterference/LaserMatcap"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _MainColor ("MainColor", Color) = (1, 1, 1, 1)
        _Specular ("_Specular Color", Color) = (1, 1, 1, 1)

        _MatCap ("Matcap", 2D) = "white" { }

        [Space(20)][Header(Change ColorRamp)][Space(20)]
        _ColorRamp ("ColorRamp", 2D) = "white" { }
        _NoiseTex ("NoiseTex", 2D) = "white" { }
        _Blend ("Blend", Range(0, 1.0)) = 0.5
        _Distortion ("Distortion", Range(0, 30)) = 6

        [Space(20)][Header(Hue)][Space(20)]
        _Hue ("Hue", Range(0, 1.0)) = 0
        _Saturation ("Saturation", Range(0, 1.0)) = 0.5
        _Brightness ("Brightness", Range(0, 1.0)) = 0.5
        _Contrast ("Contrast", Range(0, 1.0)) = 0.5
        
        [Space(20)][Header(Fresnel)][Space(20)]
        _FresnelPower ("FresnelPower", Range(0, 80)) = 5
        // _FresnelScale ("FresnelScale", Range(0, 1)) = 1

        _Amount ("Amount", Range(0, 1)) = 1

        _FilmDepth ("Film Depth", Range(1, 2000)) = 500.0
        _IOR ("IOR", Vector) = (0.9, 1.0, 1.1, 1.0)
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }
        
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            
            #include "Lighting.cginc"
            
            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _NoiseTex, _MatCap;

            sampler2D _ColorRamp;
            float4 _ColorRamp_ST;

            half4 _MainColor;
            half4 _Specular;

            float _FresnelPower;
            // float _FresnelScale;
            
            float _Blend, _Distortion, _Amount;
            
            half _Hue, _Saturation, _Brightness, _Contrast;

            float _FilmDepth;
            Vector _IOR;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };
            
            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 mainUV_matcapUV : TEXCOORD0;
                float3 normalWS : NORMAL;
                float3 positionWS : TEXCOORD1;
                float3 viewWS : TEXCOORD2;
                float3 reflectlWS : TEXCOORD3;
            };
            
            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                o.normalWS = UnityObjectToWorldNormal(v.normal);
                o.positionWS = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.viewWS = UnityWorldSpaceViewDir(o.positionWS);
                o.reflectlWS = reflect(-o.viewWS, o.normalWS);

                o.mainUV_matcapUV.xy = TRANSFORM_TEX(v.uv, _MainTex);

                // matcap uv
                // https://blog.csdn.net/puppet_master/article/details/83582477
                float3 viewnormal = normalize(mul(UNITY_MATRIX_IT_MV, v.normal));
                o.mainUV_matcapUV.zw = viewnormal.xy * 0.5 + 0.5;

                float3 viewPos = UnityObjectToViewPos(v.vertex);
                float3 r = reflect(viewPos, viewnormal);
                // r = normalize(r);
                // o.mainUV_matcapUV.zw = r.xy * 0.5 + 0.5;

                // float m = 2.0 * sqrt(r.x * r.x + r.y * r.y + (r.z + 1) * (r.z + 1));
                // o.mainUV_matcapUV.zw = r.xy / m + 0.5;
                return o;
            }
            
            
            inline float3 applyHue(float3 aColor, float aHue)
            {
                float angle = radians(aHue);
                float3 k = float3(0.57735, 0.57735, 0.57735);
                float cosAngle = cos(angle);
                
                return aColor * cosAngle + cross(k, aColor) * sin(angle) + k * dot(k, aColor) * (1 - cosAngle);
            }
            // hsbc = half4(_Hue, _Saturation, _Brightness, _Contrast);
            inline float4 applyHSBCEffect(float4 startColor, half4 hsbc)
            {
                float hue = 360 * hsbc.r;
                float saturation = hsbc.g * 2;
                float brightness = hsbc.b * 2 - 1;
                float contrast = hsbc.a * 2;
                
                float4 outputColor = startColor;
                outputColor.rgb = applyHue(outputColor.rgb, hue);
                outputColor.rgb = (outputColor.rgb - 0.5f) * contrast + 0.5f;
                outputColor.rgb = outputColor.rgb + brightness;
                float3 intensity = dot(outputColor.rgb, float3(0.39, 0.59, 0.11));
                outputColor.rgb = lerp(intensity, outputColor.rgb, saturation);
                
                return outputColor;
            }




            inline half3 thinFilmReflectance(fixed cosI, float lambda, float thickness, float IOR)
            {
                float PI = 3.1415926;
                fixed sin2R = saturate((1 - pow(cosI, 2)) / pow(IOR, 2));
                fixed cosR = sqrt(1 - sin2R);
                float phi = 2.0 * IOR * thickness * cosR / lambda + 0.5; //�����̲�
                fixed reflectionRatio = 1 - pow(cos(phi * PI * 2.0) * 0.5 + 0.5, 1.0);  //����ϵ��

                fixed refRatio_min = pow((1 - IOR) / (1 + IOR), 2.0);

                reflectionRatio = refRatio_min + (1.0 - refRatio_min) * reflectionRatio;

                return reflectionRatio;
            }

            
            half4 frag(v2f i) : SV_Target
            {
                float2 uv = i.mainUV_matcapUV.xy;
                float2 matcap_uv = i.mainUV_matcapUV.zw;

                half3 col = tex2D(_MainTex, uv);
                float noise = tex2D(_NoiseTex, uv);
                float3 matcapColor = tex2D(_MatCap, matcap_uv);

                float3 normalWS = normalize(i.normalWS);
                float3 lightWS = normalize(UnityWorldSpaceLightDir(i.positionWS));
                float3 viewWS = normalize(i.viewWS);
                
                half3 H = normalize(lightWS + viewWS);

                float NdotL = saturate(dot(normalWS, lightWS));
                float NdotV = saturate(dot(normalWS, viewWS));
                float NdotH = saturate(dot(normalWS, H));
                
                fixed3 R = normalize(reflect(-lightWS, normalWS));
                fixed RdotV = max(0, dot(R, viewWS));

                // ----------------Color Ramp----------------

                float2 distortion = noise * _Distortion;
                float4 colorRamp = tex2D(_ColorRamp, TRANSFORM_TEX(float2(NdotV, NdotV), _ColorRamp) * distortion);
                // colorRamp = max(colorRamp, (1 - mask) * c);
                

                half4 hsbc = half4(_Hue, _Saturation, _Brightness, _Contrast);
                float4 colorRampHSBC = applyHSBCEffect(colorRamp, hsbc);

                //
                float fresnel = saturate(1 - pow(NdotV, _FresnelPower));

                half3 filmColor = lerp(0, colorRampHSBC, _Blend) * fresnel;
                filmColor = filmColor * NdotL * 0.35 + filmColor * pow(RdotV, 25);

                // ----------------thinFilmReflectance----------------

                // fixed ref_red = thinFilmReflectance(NdotH, 650.0, _FilmDepth, _IOR.r);
                // fixed ref_green = thinFilmReflectance(NdotH, 510.0, _FilmDepth, _IOR.g);
                // fixed ref_blue = thinFilmReflectance(NdotH, 470.0, _FilmDepth, _IOR.b);

                // fixed4 tfi_rgb = fixed4(ref_red, ref_green, ref_blue, 1.0);

                // fixed3 ref_filmFilm = tfi_rgb * NdotL * 0.35 + tfi_rgb * pow(RdotV, 25);

                // ----------------Direct Lighting----------------

                // Diffuse
                half3 halfLambert = NdotL * 0.5 + 0.5;
                // half3 halfLambert = NdotL;
                half3 diff = halfLambert * _MainColor;
                // Specular
                half3 specular = _LightColor0.rgb * pow(NdotH, 80) * _Specular;

                half3 directLight = diff + specular;

                //
                half3 resCol = directLight + filmColor;

                resCol = resCol * matcapColor;

                // resCol = colorRamp;
                return half4(resCol, 1.0);
            }
            ENDCG

        }
    }
    FallBack "Reflective/VertexLit"
}

