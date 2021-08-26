// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/CPSSSSSShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}

	CGINCLUDE
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

		v2f vert(appdata v)
		{
			v2f o;
			o.vertex = UnityObjectToClipPos(v.vertex);
			o.uv = v.uv;
			return o;
		}
	ENDCG

	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		//Separable depth based blur
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			sampler2D _MainTex;
			sampler2D_float _CameraDepthTexture;
			sampler2D _MaskTex;
			fixed4 _BlurVec;
			float _BlurStr;
			float _SoftDepthBias;

			inline float SAMPLE_INVERSE_DEPTH(float2 uvs) {
				float t = unity_CameraProjection._m11;
				float z = LinearEyeDepth(tex2D(_CameraDepthTexture, uvs).r);
				/*
				Voodoo math on visible size multiplier here that i dont understand, but it works
				*/
				float size = 0.5/(z + 0.5);
				return size*t*0.6;
			}

			inline float SAMPLE_INVERSE_DEPTH_LINEAR(float2 uvs) {
				return saturate(1.0 - Linear01Depth(tex2D(_CameraDepthTexture, uvs).r));
			}

			float4 frag (v2f i) : SV_Target
			{
				//If theres nothing in the mask texture, then we dont need to blur/process it
				float4 testMask = tex2D(_MaskTex, i.uv);
				if (testMask.r + testMask.g + testMask.b < 0.005) discard;

				float4 col = tex2D(_MainTex, i.uv);
				fixed2 blurvec = _BlurVec.xy;
				float d = SAMPLE_INVERSE_DEPTH(i.uv);
				float str = _BlurStr * d;

				float dlin = SAMPLE_INVERSE_DEPTH_LINEAR(i.uv);
				if (dlin < 0.1) discard;

				//Gaussian blur
				/*
				col *= 0.38;
				col += tex2D(_MainTex, i.uv + blurvec * 1 * str)*0.18;
				col += tex2D(_MainTex, i.uv - blurvec * 1 * str)*0.18;
				col += tex2D(_MainTex, i.uv + blurvec * 2 * str)*0.09;
				col += tex2D(_MainTex, i.uv - blurvec * 2 * str)*0.09;
				col += tex2D(_MainTex, i.uv + blurvec * 3 * str)*0.04;
				col += tex2D(_MainTex, i.uv - blurvec * 3 * str)*0.04;
				*/

				//Blur with depth check
				/**/
				float sum = 1;
				float diff = 0;
				float cont = 0;

				//HACK:
				//We multiply the depth sample vector by a 1.06 to get rid of the 1 pixel wide lines, 
				//that show up on the edges where the depth difference between samples is significant, 
				//i have no clue whats causing it and how to fix it properly :(
				for (uint n = 1; n <= 2; n++) {
					float contrib_base = 0.99 / (n + 2);

					float4 colr = tex2D(_MainTex, i.uv + blurvec * n * str);
					float dr = SAMPLE_INVERSE_DEPTH_LINEAR(i.uv + blurvec * n * str * 1.06);
					diff = abs(dlin - dr);
					cont = 1.0-saturate(diff / _SoftDepthBias);
					cont *= contrib_base;
					col.rgb += colr.rgb*cont;
					sum += cont;

					float4 coll = tex2D(_MainTex, i.uv - blurvec * n * str);
					float dl = SAMPLE_INVERSE_DEPTH_LINEAR(i.uv - blurvec * n * str * 1.06);
					diff = abs(dlin - dl);
					cont = 1.0 - saturate(diff / _SoftDepthBias);
					cont *= contrib_base;
					col.rgb += coll.rgb*cont;
					sum += cont;
				}
				col.rgb /= sum;
				//return testMask;
				return col;
				//return pow(sum*0.5, 6);
			}
			ENDCG
		}

		//Combine pass
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			sampler2D _BlurTex;
			sampler2D _CameraDepthTexture;
			sampler2D _MaskTex;
			half _EffectStr;
			fixed _PreserveOriginal;

			float4 frag(v2f i) : SV_Target
			{
				float4 src = tex2D(_MainTex, i.uv);
				fixed4 mask = tex2D(_MaskTex, i.uv);
				float fac = 1-pow(saturate(max(max(src.r, src.g), src.b) * 1), 0.5);
				float4 blr = tex2D(_BlurTex, i.uv);
				//return blr;
				//return mask;
				//return src;
				// blr = clamp(blr - src*_PreserveOriginal, 0, 50);
				// blr *= mask;
				// return src+blr*fac*_EffectStr;


				return blr;

			}
			ENDCG
		}
	}
}
