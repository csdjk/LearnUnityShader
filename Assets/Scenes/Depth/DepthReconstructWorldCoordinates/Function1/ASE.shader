// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "New Amplify Shader"
{
    Properties { }
    
    SubShader
    {
        
        
        Tags { "RenderType" = "Opaque" }
        LOD 100

        CGINCLUDE
        #pragma target 3.0
        ENDCG
        Blend Off
        Cull Back
        ColorMask RGBA
        ZWrite On
        ZTest LEqual
        Offset 0, 0
        
        
        
        Pass
        {
            Name "Unlit"
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM

            

            #ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
                //only defining to not throw compilation error over Unity 5.5
                #define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
            #endif
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #include "UnityCG.cginc"
            #include "UnityShaderVariables.cginc"


            struct appdata
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct v2f
            {
                float4 vertex : SV_POSITION;
                #ifdef ASE_NEEDS_FRAG_WORLD_POSITION
                    float3 worldPos : TEXCOORD0;
                #endif
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
                float4 ase_texcoord1 : TEXCOORD1;
            };

            UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
            float2 UnStereo(float2 UV)
            {
                #if UNITY_SINGLE_PASS_STEREO
                    float4 scaleOffset = unity_StereoScaleOffset[ unity_StereoEyeIndex ];
                    UV.xy = (UV.xy - scaleOffset.zw) / scaleOffset.xy;
                #endif
                return UV;
            }
            

            
            v2f vert(appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

                float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
                float4 screenPos = ComputeScreenPos(ase_clipPos);
                o.ase_texcoord1 = screenPos;
                
                float3 vertexValue = float3(0, 0, 0);
                #if ASE_ABSOLUTE_VERTEX_POS
                    vertexValue = v.vertex.xyz;
                #endif
                vertexValue = vertexValue;
                #if ASE_ABSOLUTE_VERTEX_POS
                    v.vertex.xyz = vertexValue;
                #else
                    v.vertex.xyz += vertexValue;
                #endif
                o.vertex = UnityObjectToClipPos(v.vertex);

                #ifdef ASE_NEEDS_FRAG_WORLD_POSITION
                    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                #endif
                return o;
            }
            
            fixed4 frag(v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                fixed4 finalColor;
                #ifdef ASE_NEEDS_FRAG_WORLD_POSITION
                    float3 WorldPosition = i.worldPos;
                #endif
                float4 screenPos = i.ase_texcoord1;
                float4 ase_screenPosNorm = screenPos / screenPos.w;
                ase_screenPosNorm.z = (UNITY_NEAR_CLIP_VALUE >= 0) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
                float2 UV22_g3 = ase_screenPosNorm.xy;
                float2 localUnStereo22_g3 = UnStereo(UV22_g3);
                float2 break64_g1 = localUnStereo22_g3;
                float4 tex2DNode36_g1 = tex2D(_CameraDepthTexture, ase_screenPosNorm.xy);
                #ifdef UNITY_REVERSED_Z
                    float4 staticSwitch38_g1 = (1.0 - tex2DNode36_g1);
                #else
                    float4 staticSwitch38_g1 = tex2DNode36_g1;
                #endif
                float3 appendResult39_g1 = (float3(break64_g1.x, break64_g1.y, staticSwitch38_g1.r));
                float4 appendResult42_g1 = (float4((appendResult39_g1 * 2.0 + - 1.0), 1.0));
                float4 temp_output_43_0_g1 = mul(unity_CameraInvProjection, appendResult42_g1);
                float4 appendResult49_g1 = (float4((((temp_output_43_0_g1).xyz / (temp_output_43_0_g1).w) * float3(1, 1, -1)), 1.0));
                
                
                finalColor = mul(unity_CameraToWorld, appendResult49_g1);
                return finalColor;
            }
            ENDCG
        }
    }
    CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18000
52;125;1724;694;1307.354;351.3382;1;True;False
Node;AmplifyShaderEditor.FunctionNode;2;-816.3535,-29.33823;Inherit;False;Reconstruct World Position From Depth;0;;1;e7094bcbcc80eb140b2a3dbe6a861de8;0;0;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;0,0;Float;False;True;-1;2;ASEMaterialInspector;100;1;New Amplify Shader;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;True;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;0
WireConnection;0;0;2;0
ASEEND*/
//CHKSM=7CF538F645F8B837A703ABD6E2BD95169994F8B2