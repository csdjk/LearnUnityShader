Shader "lcl/screenEffect/CoverDissolve"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NoiseTex("Noise", 2D) = "white" {}
        // 溶解临界值
        _Threshold("Threshold", Range(0.0, 1.0)) = 0.5
        // 溶解视野范围临界值
        _KenThreshold("Ken Threshold", Range(0.0, 10.0)) = 0.5
        // 溶解视野距离
        _ViewDistanceThreshold("View Distance Threshold", Range(0.0, 1.0)) = 0.5

        _DissolveDistance("DissolveDistance", Range(0, 50)) = 14
		_DissolveDistanceFactor("DissolveDistanceFactor", Range(0,10)) = 3

        _EdgeLength("Edge Length", Range(0.0, 0.2)) = 0.1
        _EdgeFirstColor("EdgeFirstColor", Color) = (1,1,1,1)
        _EdgeSecondColor("EdgeSecondColor", Color) = (1,1,1,1)
    }
    SubShader
    {
        // No culling or depth
        Tags { "Queue"="Geometry" "RenderType"="Opaque" }

        Cull Off ZWrite Off ZTest Always
        Pass
        {
            CGPROGRAM
			#pragma enable_d3d11_debug_symbols

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
                float4 srcPos : TEXCOORD1;
                float2 uv_noise : TEXCOORD2;
                float3 viewDir : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;
            float _Threshold;
            float _KenThreshold;
            float _ViewDistanceThreshold;

            float _DissolveDistance;
            float _DissolveDistanceFactor;

            float _EdgeLength;
            fixed4 _EdgeFirstColor;
            fixed4 _EdgeSecondColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                // o.srcPos = ComputeScreenPos(o.vertex); 
                o.srcPos = ComputeGrabScreenPos(o.vertex);

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv_noise = TRANSFORM_TEX(v.uv, _NoiseTex);
                // 摄像机方向向量
                o.viewDir = ObjSpaceViewDir(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 屏幕坐标
                float2 screenPos = i.srcPos.xy/i.srcPos.w;
                float dis = distance(float2(0.5, 0.5),screenPos);

                // 当前像素到摄像机距离
                float viewDis = length(i.viewDir) * _ViewDistanceThreshold;
                // viewDis = max(0,viewDis);

                // float disolveFactor = 1;
                // float disolveFactor = (_KenThreshold - dis );
                //镂空
                fixed cutout = tex2D(_NoiseTex, i.uv_noise).r;

                // clip( viewDis * cutout - _Threshold);
                
                //边缘颜色
                float degree = saturate((viewDis * cutout - _Threshold) / _EdgeLength); //需要保证在[0,1]以免后面插值时颜色过亮
                fixed4 edgeColor = lerp(_EdgeFirstColor, _EdgeSecondColor, degree);

                fixed4 col = tex2D(_MainTex, i.uv);

                fixed4 finalColor = lerp(edgeColor, col, degree);

                if(dis > _KenThreshold ){
                    return col;

                }else{
                    clip( viewDis * cutout - _Threshold);
                    return fixed4(finalColor.rgb, 1);
                }
                // return fixed4(finalColor.rgb, 1);


                // return fixed4(viewDis,viewDis,viewDis, 1);
            }
            ENDCG
        }
    }
}
