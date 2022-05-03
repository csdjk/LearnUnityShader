Shader "lcl/PointLight/PointLight"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Color("Color",Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags { "LightMode" = "ForwardAdd"}
            Blend One One
            CGPROGRAM  

            fixed4 _Color;

            #define POINT
            
            #include "Autolight.cginc" 
            #include "UnityPBSLighting.cginc"
            #pragma vertex vert      
            #pragma fragment frag  
            struct a2v{  
                float4 vertex : POSITION;  
                float3 normal : NORMAL;  
            };  
            
            struct v2f {  
                float4 pos : SV_POSITION;  
                float3 worldNormal : TEXCOORD0;  
                float3 worldPos : TEXCOORD1;  
            };  
            
            v2f vert(a2v v) {  
                v2f o;  
                o.pos = UnityObjectToClipPos (v.vertex);  
                o.worldNormal = UnityObjectToWorldNormal(v.normal);  
                o.worldPos =  mul(unity_ObjectToWorld,v.vertex).xyz;  
                return o;  
                
            }  
            
            fixed4 frag(v2f i) : SV_Target{  
                UNITY_LIGHT_ATTENUATION(attenuation, 0, i.worldPos);
                return _Color*attenuation;  
            }  

            ENDCG   
        }  
    }
}
