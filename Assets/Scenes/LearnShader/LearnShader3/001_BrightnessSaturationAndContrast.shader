// ------------------------【亮度,饱和度,对比度调整】---------------------------
Shader "lcl/learnShader3/001_BrightnessSaturationAndContrast" {
	// ------------------------【属性】---------------------------
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		//亮度
		_Brightness ("Brightness", Float) = 1
		//饱和度
		_Saturation("Saturation", Float) = 1
		//对比度
		_Contrast("Contrast", Float) = 1
	}
	// ------------------------【子着色器】---------------------------
	SubShader {
		Pass {  
			ZTest Always Cull Off ZWrite Off
			
			CGPROGRAM  
			#pragma vertex vert  
			#pragma fragment frag  
			  
			#include "UnityCG.cginc"  
			  
			sampler2D _MainTex;  
			half _Brightness;
			half _Saturation;
			half _Contrast;
			  
			struct v2f {
				float4 pos : SV_POSITION;
				half2 uv: TEXCOORD0;
			};
			  
			v2f vert(appdata_img v) {
				v2f o;
				
				o.pos = UnityObjectToClipPos(v.vertex);
				
				o.uv = v.texcoord;
						 
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target {
				fixed4 renderTex = tex2D(_MainTex, i.uv);  
				  
				// 调整亮度
				fixed3 finalColor = renderTex.rgb * _Brightness;
				// 调整饱和度
				//根据灰度公式计算而来, gray = 0.2125 * r + 0.7154 * g + 0.0721 * b,
				//离灰度偏离越大，饱和度越大
				fixed luminance = 0.2125 * renderTex.r + 0.7154 * renderTex.g + 0.0721 * renderTex.b;
				fixed3 luminanceColor = fixed3(luminance, luminance, luminance);
				finalColor = lerp(luminanceColor, finalColor, _Saturation);
				//调整对比度
				//对比度表示颜色差异越大对比度越强，当颜色为纯灰色，也就是（0.5,0.5,0.5）时，对比度最小.
				fixed3 avgColor = fixed3(0.5, 0.5, 0.5);
				finalColor = lerp(avgColor, finalColor, _Contrast);
				//输出最终颜色
				return fixed4(finalColor, renderTex.a);  
			}  
			  
			ENDCG
		}  
	}
	
	Fallback Off
}
