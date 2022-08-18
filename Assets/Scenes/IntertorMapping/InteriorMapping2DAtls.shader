Shader "lcl/InteriorMapping/InteriorMapping2DAtls"
{
    Properties
    {
        _RoomTex ("Room Atlas RGB (A - back wall depth01)", 2D) = "gray" { }
        _Rooms ("Room Count(X count,Y count)", vector) = (1, 1, 0, 0)
        _RoomMaxDepth01 ("Room Max Depth define(0 to 1)", range(0.001, 0.999)) = 0.5
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
            #include "Assets\Shader\ShaderLibs\Node.cginc"
            #include "Assets\Shader\ShaderLibs\Noise.cginc"

            sampler2D _RoomTex;
            float4 _RoomTex_ST;
            float2 _Rooms;
            float _RoomMaxDepth01;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
            };
            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 viewTS : TEXCOORD1;
            };

           
            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _RoomTex);

                //find view dir OS
                float3 camPosOS = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1.0)).xyz;
                float3 viewDirOS = v.vertex.xyz - camPosOS;

                // get tangent space view vector
                o.viewTS = ObjectToTangentDir(viewDirOS, v.normal, v.tangent);
                return o;
            }

         
            half4 frag(v2f i) : SV_Target
            {
                
                // room uvs
                float2 roomUV = frac(i.uv);
                float2 roomIndexUV = floor(i.uv);

                // randomize the room
                float2 n = floor(random2(roomIndexUV.x + roomIndexUV.y * (roomIndexUV.x + 1)) * _Rooms.xy);
                roomIndexUV += n; //colin: result = index XY + random (0,0)~(3,1)


                float2 interiorUV = ConvertOriginalRawUVToInteriorUV(roomUV, i.viewTS, _RoomMaxDepth01);
                fixed4 room = tex2D(_RoomTex, (roomIndexUV + interiorUV) / _Rooms);

                // return fixed4(interiorUV, 1, 1.0);

                return fixed4(room.rgb, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
