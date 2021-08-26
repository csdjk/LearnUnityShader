Shader "Hidden/CPSSSSSReplacement"
{
	Properties
	{
		_MainTex("Texture", 2D) = "black" {}
		_MaskTex("Texture", 2D) = "black" {}
		_SSColor("Color", Color) = (0,0,0,0)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _SSColor;
			uint _MaskSource;
			uniform sampler2D _MaskTex;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = fixed4(1,1,1,1);
				if (_MaskSource == 0) col = tex2D(_MainTex, i.uv);
				if (_MaskSource == 1) col = tex2D(_MaskTex, i.uv);
				return _SSColor*col.a;
			}
			ENDCG
		}
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				// sample the texture
				discard;
				return 0;
			}
			ENDCG
		}
	}
	//Fallback "Legacy Shaders/Diffuse"
}
