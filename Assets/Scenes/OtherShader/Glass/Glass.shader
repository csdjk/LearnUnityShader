Shader "lcl/Glass/Glass"{
   Properties {
      _Cube("Skybox", Cube) = "" {}
      _EtaRatio("EtaRatio", Range(0, 1)) = 0
      _FresnelBias("Bias", Range(0, 1)) = .5
      _FresnelScale("Scale", Range(0, 10)) = .5
      _FresnelPower("Power", Range(0, 10)) = .5 
   }
   SubShader {
      Pass {   

         CGPROGRAM
         
         #pragma vertex vert  
         #pragma fragment frag

         #include "UnityCG.cginc"

         samplerCUBE _Cube;
         float _EtaRatio;
         float _FresnelBias;
         float _FresnelScale;
         float _FresnelPower;

         struct appdata {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
         };

         struct v2f {
            float4 pos : SV_POSITION;
            float3 normalDir : TEXCOORD0;
            float3 viewDir : TEXCOORD1;
         };

         //计算反射方向
         float3 caculateReflectDir(float3 I, float3 N)
         {
            float3 R = I - 2.f * N * dot(I, N); 
            return R;
         }

         //计算折射方向
         float3 caculateRefractDir(float3 I, float3 N, float etaRatio)
         {
            float cosTheta = dot(-I, N);
            float cosTheta2 = sqrt(1.f - pow(etaRatio,2) * (1 - pow(cosTheta,2)));
            float3 T = etaRatio * (I + N * cosTheta) - N * cosTheta2;
            return T;
         }

         //菲涅耳效果
         float CaculateFresnelApproximation(float3 I, float3 N)
         {
            float fresnel = max(0, min(1, _FresnelBias + _FresnelScale * pow(min(0.0, 1.0 - dot(I, N)), _FresnelPower)));
            return fresnel;
         }

         
         v2f vert(appdata v) 
         {
            v2f o;
            
            float4x4 modelMatrixInverse = unity_WorldToObject; 
            
            o.viewDir = mul(unity_ObjectToWorld, v.vertex).xyz - _WorldSpaceCameraPos;

            o.normalDir = normalize (mul ((float3x3)unity_ObjectToWorld, v.normal));

            o.pos = UnityObjectToClipPos(v.vertex);

            return o;
         }
         
         fixed4 frag(v2f input) : SV_Target
         {
            float3 reflectedDir = caculateReflectDir(input.viewDir, input.normalDir);
            fixed4 reflectCol = texCUBE(_Cube, reflectedDir);

            float3 refractedDir = caculateRefractDir(normalize(input.viewDir), input.normalDir, _EtaRatio);
            fixed4 refractCol = texCUBE(_Cube, refractedDir);

            //菲涅耳
            float fresnel = CaculateFresnelApproximation(input.viewDir, input.normalDir);

            fixed4 col = lerp(refractCol, reflectCol, fresnel);
            return col;
         }
         
         ENDCG
      }
   }
}