Shader "lcl/shader3D/Geometry_hair"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Length("Length",float) = 1.0
		_Color("Color",Color)=(1,1,1,1)
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			//几何着色器
			#pragma geometry geom
			#include "UnityCG.cginc"

			float _Length;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Color;

			struct a2v {
				float4 vertex:POSITION;
				float2 uv:TEXCOORD0;
			};

			struct v2g {
				float4 vertex:POSITION;
				float2 uv:TEXCOORD0;
			};

			struct g2f {
				float4 vertex:SV_POSITION;
				float2 uv:TEXCOORD0;
				float4 col:COLOR;
			};

			v2g vert(a2v v) {
				v2g o;
				o.vertex = v.vertex;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			//一个三角面生成的最多顶点数
			[maxvertexcount(9)]
			void geom(triangle v2g IN[3], inout TriangleStream<g2f> tristream) {
				g2f o;
				//用两条边算出法线方向
				float3 edgeA = IN[1].vertex - IN[0].vertex;
				float3 edgeB = IN[2].vertex - IN[0].vertex;
				float3 normalFace = normalize(cross(edgeA, edgeB));
				//三角面中心点
				float3 centerPos = (IN[0].vertex + IN[1].vertex + IN[2].vertex) / 3;
				//中心点uv位置
				float2 centerTex = (IN[0].uv + IN[1].uv + IN[2].uv) / 3;
				//外拓的顶点距离
				centerPos += float4(normalFace, 0)*_Length;
				for (uint i = 0; i < 3; i++)
				{
					o.vertex = UnityObjectToClipPos(IN[i].vertex);
					o.uv = IN[i].uv;
					o.col = fixed4(0., 0., 0., 1.);
					//添加顶点
					tristream.Append(o);

					uint index = (i + 1) % 3;
					o.vertex = UnityObjectToClipPos(IN[index].vertex);
					o.uv = IN[index].uv;
					o.col = fixed4(0., 0., 0., 1.);

					tristream.Append(o);

					//外部颜色白
					o.vertex = UnityObjectToClipPos(float4(centerPos, 1));
					o.uv = centerTex;
					o.col = fixed4(1.0, 1.0, 1.0, 1.);

					tristream.Append(o);
					//添加三角面
					tristream.RestartStrip();
				}
			}

			float4 frag(g2f i) :SV_Target{
				float4 col = tex2D(_MainTex,i.uv)*i.col*_Color;
				return col;
			}
			ENDCG

		}
	}
}
