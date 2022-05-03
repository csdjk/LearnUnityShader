Shader "lcl/shader3D/Geometry_particl"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Size("Size",Range(0.0,10)) = 0.0
		_Color("Color",Color) = (1,1,1,1)
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
			//几何着色器
			#pragma geometry geom
			#include "UnityCG.cginc"

			float _Size;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Color;

			struct a2v {
				float4 vertex:POSITION;
				float2 uv:TEXCOORD0;
				float3 normal:NORMAL;
			};

			struct v2g {
				float4 vertex:POSITION;
				float2 uv:TEXCOORD0;
			};

			struct g2f {
				float4 vertex:SV_POSITION;
				float2 uv:TEXCOORD0;
			};

			v2g vert(a2v v) {
				v2g o;
				o.vertex = v.vertex;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			//一个三角面生成的最多顶点数
			[maxvertexcount(1)]
			void geom(triangle v2g IN[3], inout PointStream<g2f> pointStream) {
				g2f o;
				//用两条边算出法线方向
				float3 edgeA = IN[1].vertex - IN[0].vertex;
				float3 edgeB = IN[2].vertex - IN[0].vertex;
				float3 normalFace = normalize(cross(edgeA, edgeB));
				//三个顶点合并成一个
				float3 tempPos = (IN[0].vertex + IN[1].vertex + IN[2].vertex) / 3;
				//沿法线方向位移
				tempPos += normalFace * _Size;
				o.vertex = UnityObjectToClipPos(tempPos);
				o.uv= (IN[0].uv + IN[1].uv + IN[2].uv) / 3;
				//添加顶点
				pointStream.Append(o);
			}

			float4 frag(g2f i) :SV_Target{
				float4 col = tex2D(_MainTex,i.uv)*_Color;
				return col;
			}
			ENDCG
		}
	}
}
