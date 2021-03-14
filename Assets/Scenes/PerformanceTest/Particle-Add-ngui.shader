// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Dts/Effect/Particles Additive Ngui"
{
	Properties
	{
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("Particle Texture", 2D) = "white" {}
		_ClipRect("Clip Rect", Vector) = (-10,-10,10,10)
	}

	Category
	{
		Tags 
		{ 
			"Queue"="Transparent" 
			"IgnoreProjector"="True" 
			"RenderType"="Transparent" 
		}

		Blend SrcAlpha One
		AlphaTest Greater .01
		Cull Off 
		Lighting Off
		ZWrite Off 
		Fog { Color (0,0,0,0) }
		ColorMask RGB

		SubShader
		{
			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"

				sampler2D _MainTex;
				fixed4 _TintColor;
				float4 _ClipRect;
			
				struct appdata_t
				{
					float4 vertex : POSITION;
					fixed4 color : COLOR;
					float2 texcoord : TEXCOORD0;
				};

				struct v2f
				{
					float4 vertex : SV_POSITION;
					fixed4 color : COLOR;
					float2 texcoord : TEXCOORD0;
					float3 wpos : TEXCOORD1;
				};
			
				float4 _MainTex_ST;

				v2f vert (appdata_t v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.color = v.color;
					o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
					o.wpos = o.vertex;

					return o;
				}

				fixed4 frag (v2f i) : SV_Target
				{
					fixed4 color = 2.0f * i.color * _TintColor * tex2D(_MainTex, i.texcoord);
					color.a *= (i.wpos.x >= _ClipRect.x);
					color.a *= (i.wpos.y >= _ClipRect.y);
					color.a *= (i.wpos.x <= _ClipRect.z);
					color.a *= (i.wpos.y <= _ClipRect.w);

					return color;
				}
				ENDCG
			}
		}	
	}
}