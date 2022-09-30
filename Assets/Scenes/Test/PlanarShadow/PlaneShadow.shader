Shader "lcl/PlaneShadow"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _ShadowColor ("ShadowColor", Color) = (0,0,0,1)
        _Falloff("Falloff", Range(0,1)) = 0.5
        _Height("Height",float) = 0
     }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue" = "Geometry+20"}
        Pass
        {
            //设置这个Pass的名字  
            Name "PlaneShadow"
            
            //用使用模板测试以保证alpha显示正确
            Stencil
            {
                Comp equal
                Pass incrWrap
            }

            //设置透明度混合模式为普通透明度混合模式
            Blend SrcAlpha OneMinusSrcAlpha
            //关闭深度写入
            ZWrite off

            CGPROGRAM

            #pragma vertex vert
	        #pragma fragment frag
	        #include "UnityCG.cginc"

	        float4 _ShadowColor;
	        float _Falloff;
            float _Height;

	        struct a2v
	        {
		        float4 vertex : POSITION;
	        };

	        struct v2f
	        {
		        float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD0;
	        };

	        v2f vert (a2v v)
	        {
                //顶点的世界空间坐标
		        float3 worldPos = mul(unity_ObjectToWorld , v.vertex).xyz;
                //灯光方向
		        float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

		        //计算阴影的世界空间坐标
		        float3 shadowPos;
		        shadowPos.y = min(worldPos .y ,_Height);
		        shadowPos.xz = worldPos .xz - lightDir.xz * max(0 , worldPos .y - _Height) / lightDir.y; 

		        v2f o;
		        //转换到裁切空间
		        o.vertex = UnityWorldToClipPos(shadowPos);
                o.worldPos = shadowPos;

		        return o;
	        }

	        fixed4 frag (v2f i) : SV_Target
	        {
                float4 Color = _ShadowColor;
                //获取中心点世界坐标
		        float3 center =float3( unity_ObjectToWorld[0].w , unity_ObjectToWorld[1].w , unity_ObjectToWorld[2].w);
                //计算阴影衰减
		        float falloff = 1-saturate(distance(i.worldPos , center) * _Falloff);
                Color.a *= falloff;
		        return Color;
	        }
	        ENDCG
        }
        
        Pass
        {
            
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			fixed4 _Color;

			struct a2v 
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
			struct v2f 
            {
                float4 pos : SV_POSITION;
                fixed3 worldNormal : TEXCOORD0;
            };
			v2f vert (a2v v) 
            {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
				return o;
            }
			fixed4 frag(v2f i) : SV_Target 
            {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * saturate(dot(worldNormal,worldLightDir ));
                fixed3 color = ambient + diffuse;
                return fixed4(color, 1.0);
            }
            ENDCG	
        }
    }
}