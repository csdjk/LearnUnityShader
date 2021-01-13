Shader "lcl/shader3D/XRay1"
{
    Properties
    {
		_Color ("Main Color", Color) = (0, 0.15, 0.115, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            ZWrite Off
            ZTest Greater
            Blend SrcAlpha One

            CGPROGRAM

            #include "UnityCG.cginc"
          
            struct v2f
            {
                float4 vertex : SV_POSITION;
				float3 viewDir : TEXCOORD0;
                float3 normal : normal;
            };

            float4 _Color;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.viewDir = ObjSpaceViewDir(v.vertex);
				o.normal = v.normal;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 normal = normalize(i.normal);
				float3 viewDir = normalize(i.viewDir);
				float rim = 1 - dot(normal, viewDir);

				return _Color * rim;
            }
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }
    }
}
