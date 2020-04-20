//-----------------------------【边缘检测】-----------------------------
Shader "lcl/learnShader3/002 Chapter 12/Edge Detection Test" {
	//-----------------------------【属性】-----------------------------
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		// 描边程度
		_EdgeOnly ("Edge Only", Float) = 1.0
		// 边缘颜色
		_EdgeColor ("Edge Color", Color) = (0, 0, 0, 1)
	}
	//-----------------------------【子着色器】-----------------------------
	SubShader {
		Pass {  
			ZTest Always Cull Off ZWrite Off
			
			CGPROGRAM
			
			#include "UnityCG.cginc"
			
			#pragma vertex vert  
			#pragma fragment frag
			
			sampler2D _MainTex;  
			uniform half4 _MainTex_TexelSize;
			fixed _EdgeOnly;
			fixed4 _EdgeColor;

			struct v2f {
				float4 pos : SV_POSITION;
				half2 uv[9] : TEXCOORD0;
			};
			  
			//-----------------------------【顶点着色器】-----------------------------
			v2f vert(appdata_img v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				
				half2 uv = v.texcoord;
				//计算周围像素的纹理坐标位置，其中4为原始点，
				o.uv[0] = uv + _MainTex_TexelSize.xy * half2(-1, -1);
				o.uv[1] = uv + _MainTex_TexelSize.xy * half2(0, -1);
				o.uv[2] = uv + _MainTex_TexelSize.xy * half2(1, -1);
				o.uv[3] = uv + _MainTex_TexelSize.xy * half2(-1, 0);
				o.uv[4] = uv + _MainTex_TexelSize.xy * half2(0, 0);		//原点
				o.uv[5] = uv + _MainTex_TexelSize.xy * half2(1, 0);
				o.uv[6] = uv + _MainTex_TexelSize.xy * half2(-1, 1);
				o.uv[7] = uv + _MainTex_TexelSize.xy * half2(0, 1);
				o.uv[8] = uv + _MainTex_TexelSize.xy * half2(1, 1);
						 
				return o;
			}
			
			// 转换为灰度
			fixed luminance(fixed4 color) {
				return  0.299 * color.r + 0.587 * color.g + 0.114 * color.b; 
			}
			
			// sobel算子
			half Sobel(v2f i) {
				const half Gx[9] = {-1,  0,  1,
									-2,  0,  2,
									-1,  0,  1};
				const half Gy[9] = {-1, -2, -1,
									0,  0,  0,
									1,  2,  1};		
				
				half texColor;
				half edgeX = 0;
				half edgeY = 0;
				for (int it = 0; it < 9; it++) {
					// 转换为灰度值
					texColor = luminance(tex2D(_MainTex, i.uv[it]));

					edgeX += texColor * Gx[it];
					edgeY += texColor * Gy[it];
				}
				// 合并横向和纵向
				half edge = 1 - (abs(edgeX) + abs(edgeY));
				return edge;
			}
			//-----------------------------【片元着色器】-----------------------------
			fixed4 frag(v2f i) : SV_Target {
				half edge = Sobel(i);
				fixed4 edgeColor = lerp(_EdgeColor, tex2D(_MainTex, i.uv[4]), edge);
				edgeColor = lerp(tex2D(_MainTex, i.uv[4]),edgeColor, _EdgeOnly);
				return edgeColor;
 			}
			
			ENDCG
		} 
	}
	FallBack Off
}
