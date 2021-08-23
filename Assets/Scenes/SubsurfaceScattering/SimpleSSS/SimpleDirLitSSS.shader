Shader "WalkingFat/SSS/SimpleDirLitSSS"
{
    Properties
    {
        //Basic
        _MainTex ("Texture", 2D) = "white" {}
        _Tint ("Tint", Color) = (1,1,1,1)
        
        // Directional Subsurface Scattering
        _InteriorColor ("Interior Color", Color) = (1,1,1,1)
        _FrontSubsurfaceDistortion ("Front Subsurface Distortion", Range(0,1)) = 0.5
        _BackSubsurfaceDistortion ("Back Subsurface Distortion", Range(0,1)) = 0.5
        _FrontSssIntensity ("Front SSS Intensity", Range(0,1)) = 0.2
        _InteriorColorPower ("Interior Color Power", Range(0,5)) = 2
        
        // Specular
        _Specular ("Specular", Range(0,1)) = 0.5
        _Gloss ("Gloss", Range(0,1) ) = 0.5
        
        // fresnel
        _RimPower("Rim Power", Range(0.01, 36)) = 0.1
        _RimIntensity("Rim Intensity", Range(0, 1)) = 0.2
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags {"LightMode"="ForwardBase"}
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #pragma enable_d3d11_debug_symbols
            
            #include "UnityCG.cginc"
			#include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed4 diff : COLOR0; // diffuse lighting color
                float2 uv : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float3 lightDir : TEXCOORD3;
                float3 viewDir : TEXCOORD4;
                UNITY_FOG_COORDS(5)
            };
            
            inline float SubsurfaceScattering (float3 viewDir, float3 lightDir, float3 normalDir, 
            float frontSubsurfaceDistortion, float backSubsurfaceDistortion, float frontSssIntensity)
            {
                float3 frontLitDir = normalDir * frontSubsurfaceDistortion - lightDir;
                float3 backLitDir = normalDir * backSubsurfaceDistortion + lightDir;
                
                float frontSSS = saturate(dot(viewDir, -frontLitDir));
                float backSSS = saturate(dot(viewDir, -backLitDir));
                
                float result = saturate(frontSSS * frontSssIntensity + backSSS);
                
                return result;
            }

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Tint, _InteriorColor;
            float _FrontSubsurfaceDistortion, _BackSubsurfaceDistortion, _FrontSssIntensity, _InteriorColorPower;
            float _PointLitRadius;
            float _Specular, _Gloss, _RimPower, _RimIntensity;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos (v.vertex);
                o.normalDir = UnityObjectToWorldNormal (v.normal);
                o.posWorld = mul (unity_ObjectToWorld, v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                
                o.viewDir = normalize(_WorldSpaceCameraPos.xyz - o.posWorld.xyz);
                o.lightDir = normalize(_WorldSpaceLightPos0.xyz);
                
                // Diffuse
                half nl = max(0, dot(o.normalDir, _WorldSpaceLightPos0.xyz));
                o.diff = nl * _LightColor0;
                o.diff.rgb += ShadeSH9(half4(o.normalDir,1));
                
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }
            
            // Custom point light
            float _CustomPointLitArray;
            uniform float4 _CustomPointLitPosList[20];
            uniform float4 _CustomPointLitColorList[20];
            uniform float _CustomPointLitRangeList[20];
            
            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv) * _Tint;
                
                // Point Light SSS
                float pointLitSssValue;
                fixed3 pointLitSssCol;
                for (int n = 0; n < _CustomPointLitArray; n++)
                {
                    float rangeValue = _CustomPointLitRangeList[n];
                    float dis = distance(i.posWorld, _CustomPointLitPosList[n]);
                    float plsValue =  1 - min(dis / rangeValue,1);
                    pointLitSssValue += plsValue;
                    pointLitSssCol += plsValue * _CustomPointLitColorList[n];
                }
                
                // Directional light SSS
                float sssValue = SubsurfaceScattering (i.viewDir, i.lightDir, i.normalDir, 
                _FrontSubsurfaceDistortion, _BackSubsurfaceDistortion, _FrontSssIntensity);
                fixed3 sssCol = lerp(_InteriorColor, _LightColor0, saturate(pow(sssValue, _InteriorColorPower))).rgb * sssValue;
                
                
                // Diffuse
                fixed4 unlitCol = col * _InteriorColor * 0.5;
                fixed4 diffCol = lerp(unlitCol, col, i.diff); 
                
                // Specular
                float specularPow = exp2 ((1 - _Gloss) * 10.0 + 1.0);
                float3 specularColor = float4 (_Specular,_Specular,_Specular,1);
                float3 halfVector = normalize (i.lightDir + i.viewDir);
                float3 directSpecular = pow (max (0,dot (halfVector, normalize(i.normalDir))), specularPow) * specularColor;
                float3 specular = directSpecular * _LightColor0.rgb;
                
                // fresnel
                // float rim = 1.0 - saturate(dot(i.normalDir, i.viewDir));
                // float rimValue = lerp(rim, 0, sssValue);
                // float3 rimCol = lerp(_InteriorColor, _LightColor0.rgb, rimValue) * pow(rimValue, _RimPower) * _RimIntensity;  

                // float fresnel = pow(1 - saturate(dot(i.viewDir, i.normalDir)), 5);
                // float3 rimCol = lerp(_InteriorColor, _LightColor0.rgb, fresnel) * _RimIntensity;

                // final color
                fixed3 final = sssCol + diffCol.rgb + specular;
                final += pointLitSssCol;
                return fixed4(final, 1);
                // return fresnel;
            }
            ENDCG
        }
    }
}