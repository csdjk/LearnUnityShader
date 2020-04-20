Shader "lcl/shader3D/flipBook" {
	Properties 
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex("MainTex",2D)="White"{}
		_SecTex("SecTex",2D)="White"{}
		_Angle("Angle",Range(0,180))=0
		_WaveLength("WaveLength",Range(0,1))=0
	}
	SubShader
	{
		pass
		{
			Cull Back

			CGPROGRAM
			#pragma vertex vert 
			#pragma fragment frag 
			#include "UnityCG.cginc"

			struct v2f 
			{
				float4 pos : POSITION;
				float2 uv : TEXCOORD0;
			};
			fixed4 _Color;
			float _Angle;
			float _WaveLength;
			sampler2D _MainTex;
			float4 _MainTex_ST;

			v2f vert(appdata_base v)
			{
				v2f o;
				v.vertex += float4(5,0,0,0);
				float s;
				float c;
				sincos(radians(-_Angle),s,c);
				float4x4 rotate={			
				c,s,0,0,
				-s,c,0,0,
				0,0,1,0,
				0,0,0,1};
				float rangeF=-s;
                v.vertex.y = sin(v.vertex.x*_WaveLength)*rangeF;
				
				v.vertex = mul(rotate,v.vertex);
				
				v.vertex += float4(-5,0,0,0);
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
				return o;
			}

			fixed4 frag(v2f i):COLOR
			{
				fixed4 color = tex2D(_MainTex,-i.uv);
				return _Color * color;
			}


			ENDCG
		}

		pass
		{
			Cull Front

			CGPROGRAM
			#pragma vertex vert 
			#pragma fragment frag 
			#include "UnityCG.cginc"

			struct v2f 
			{
				float4 pos : POSITION;
				float2 uv : TEXCOORD0;
			};
			fixed4 _Color;
			float _Angle;
			float _WaveLength;
			sampler2D _SecTex;
			float4 _MainTex_ST;

			v2f vert(appdata_base v)
			{
				v2f o;
				v.vertex += float4(5,0,0,0);
				float s;
				float c;
				sincos(radians(-_Angle),s,c);
				float4x4 rotate={			
				c,s,0,0,
				-s,c,0,0,
				0,0,1,0,
				0,0,0,1};
				float rangeF=-s;

                v.vertex.y = sin(v.vertex.x*_WaveLength)*rangeF;
				
				v.vertex = mul(rotate,v.vertex);
				
				v.vertex += float4(-5,0,0,0);
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
				return o;
			}

			fixed4 frag(v2f i):COLOR
			{
				float2 uv = i.uv;
				uv.x = -uv.x;
				fixed4 color = tex2D(_SecTex,-uv);
				return _Color * color;
			}
			ENDCG
		}
	}
}
