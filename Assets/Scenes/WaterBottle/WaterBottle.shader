Shader "lcl/WaterBottle"
{
    Properties
    {
        
        _LiquidColor ("LiquidColor", Color) = (1,1,1,1)
        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _FillAmount ("Fill Amount", Range(-10,10)) = 0.0
         _WobbleX ("WobbleX", Range(-1,1)) = 0.0
         _WobbleZ ("WobbleZ", Range(-1,1)) = 0.0
        _LiquidTopColor ("Liquid Top Color", Color) = (1,1,1,1)
        _LiquidFoamColor ("Liquid Foam Color", Color) = (1,1,1,1)
        _FoamLineWidth ("Liquid Foam Line Width", Range(0,0.1)) = 0.0    
        _LiquidRimColor ("Liquid Rim Color", Color) = (1,1,1,1)
        _LiquidRimPower ("Liquid Rim Power", Range(0,10)) = 0.0
        _LiquidRimIntensity ("Liquid Rim Intensity", Range(0.0,3.0)) = 1.0
        
        _BottleColor ("Bottle Color", Color) = (0.5,0.5,0.5,1)
        _BottleThickness ("Bottle Thickness", Range(0,1)) = 0.1
          
        _BottleRimColor ("Bottle Rim Color", Color) = (1,1,1,1)
        _BottleRimPower ("Bottle Rim Power", Range(0,10)) = 0.0
        _BottleRimIntensity ("Bottle Rim Intensity", Range(0.0,3.0)) = 1.0
        
        _BottleSpecular ("BottleSpecular", Range(0,1)) = 0.5
        _BottleGloss ("BottleGloss", Range(0,1) ) = 0.5
    }
 
    SubShader
    {
        Tags
        { 
            "DisableBatching" = "True" 
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        
        //1st pass draw liquid
        Pass
        {
            Tags {"RenderType" = "Opaque" "Queue" = "Geometry"}
            
            Zwrite On
            Cull Off // we want the front and back faces
            AlphaToMask On // transparency

            CGPROGRAM


            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL; 
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 viewDir : COLOR;
                float3 normal : COLOR2;    
                float fillEdge : TEXCOORD2;
            };

            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;
            float _FillAmount, _WobbleX, _WobbleZ;
            float4 _LiquidTopColor, _LiquidRimColor, _LiquidFoamColor, _LiquidColor;
            float _FoamLineWidth, _LiquidRimPower, _LiquidRimIntensity;

            float4 RotateAroundYInDegrees (float4 vertex, float degrees)
            {
                float alpha = degrees * UNITY_PI / 180;
                float sina, cosa;
                sincos(alpha, sina, cosa);
                float2x2 m = float2x2(cosa, sina, -sina, cosa);
                return float4(vertex.yz , mul(m, vertex.xz)).xzyw ;            
            }


            v2f vert (appdata v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _NoiseTex);
                // get world position of the vertex
                float3 worldPos = mul (unity_ObjectToWorld, v.vertex.xyz);  
                // rotate it around XY
                float3 worldPosX= RotateAroundYInDegrees(float4(worldPos,0),360);
                // rotate around XZ
                float3 worldPosZ = float3 (worldPosX.y, worldPosX.z, worldPosX.x);     
                // combine rotations with worldPos, based on sine wave from script
                float3 worldPosAdjusted = worldPos + (worldPosX * _WobbleX)+ (worldPosZ * _WobbleZ);
                // how high up the liquid is
                o.fillEdge =  worldPosAdjusted.y + _FillAmount;

                o.viewDir = normalize(ObjSpaceViewDir(v.vertex));
                o.normal = v.normal;
                return o;
            }

            fixed4 frag (v2f i, fixed facing : VFACE) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_NoiseTex, i.uv) * _LiquidColor;

                // rim light
                float dotProduct = 1 - pow(dot(i.normal, i.viewDir), _LiquidRimPower);
                float4 RimResult = _LiquidRimColor * smoothstep(0.5, 1.0, dotProduct) * _LiquidRimIntensity;

                // foam edge
                float4 foam = step(i.fillEdge, 0.5) - step(i.fillEdge, (0.5 - _FoamLineWidth));
                float4 foamColored = foam * _LiquidFoamColor;
                // rest of the liquid
                float4 result = step(i.fillEdge, 0.5) - foam;
                float4 resultColored = result * col;
                // both together, with the texture
                float4 finalResult = resultColored + foamColored;               
                finalResult.rgb += RimResult;

                // color of backfaces/ top
                float4 topColor = _LiquidTopColor * (foam + result);
                //VFACE returns positive for front facing, negative for backfacing
                return facing > 0 ? finalResult : topColor;
                   
            }
            ENDCG
        }
        
        // 2nd pass draw glass bottle
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
 
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL; 
            };
     
            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 viewDir : COLOR;
                float3 normal : COLOR2;
                float2 uv : TEXCOORD0;
                float3 lightDir : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float3 viewDirWorld : TEXCOORD3;
                UNITY_FOG_COORDS(3)
            };
     
            float4 _BottleColor, _BottleRimColor;
            float _BottleThickness, _BottleRim, _BottleRimPower, _BottleRimIntensity;
            float _BottleSpecular, _BottleGloss;
     
            v2f vert (appdata v)
            {
                v2f o;
                v.vertex.xyz += _BottleThickness * v.normal;
                o.vertex = UnityObjectToClipPos(v.vertex);

                o.viewDir = normalize(ObjSpaceViewDir(v.vertex));
                o.normal = v.normal;
                
                float4 posWorld = mul (unity_ObjectToWorld, v.vertex);
                o.viewDirWorld = normalize(_WorldSpaceCameraPos.xyz - posWorld.xyz);
                o.normalDir = UnityObjectToWorldNormal (v.normal);
                o.lightDir = normalize(_WorldSpaceLightPos0.xyz);

                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }
               
            fixed4 frag (v2f i, fixed facing : VFACE) : SV_Target
            {
                // specular
                i.normalDir = normalize(i.normalDir);
                float specularPow = exp2 ((1 - _BottleGloss) * 10.0 + 1.0);
                fixed4 specularColor = fixed4 (_BottleSpecular, _BottleSpecular, _BottleSpecular, _BottleSpecular);
               
                float3 halfVector = normalize (i.lightDir + i.viewDirWorld);
                fixed4 specularCol = pow (max (0,dot (halfVector, i.normalDir)), specularPow) * specularColor;
                
                // rim light
                float dotProduct = 1 - pow(dot(i.normal, i.viewDir), _BottleRimPower);
                fixed4 RimCol = _BottleRimColor * smoothstep(0.5, 1.0, dotProduct) * _BottleRimIntensity;
                
                fixed4 finalCol = RimCol + _BottleColor + specularCol;
                
                UNITY_APPLY_FOG(i.fogCoord, col);

                return finalCol;
            }
            ENDCG
        }
    }
    Fallback "VertexLit"
}