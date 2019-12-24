Shader "lcl/screenEffect/MaskEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

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
                // float4 srcPos : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                // o.srcPos = ComputeScreenPos(o.pos); 
                return o;
            }

            sampler2D _MainTex;
            float2 _Pos;
            float _Size;
            float _EdgeBlurLength;
            // 创建圆
            fixed3 createCircle(float2 pos,float radius,float2 uv){
                //当前像素到中心点的距离
                float dis = distance(pos,uv);
                //  smoothstep 平滑过渡
                float col = smoothstep(radius + _EdgeBlurLength,radius,dis );
                return fixed3(col,col,col) ;
            }

            // 齿轮
            float3 createGear(float2 pos,float scale,float2 uv){
                float2 dir = pos - uv;
                float radius = length(dir)*scale;
                float angle = atan2(dir.y,dir.x);
                //造型函数
                float f = smoothstep(-0.484,1., cos(angle*10.0))*0.080+0.372;
                float col = 1.-smoothstep(f,f+0.02,radius);
                return float3(col,col,col );
            }

            // 花瓣
            float3 createPetal(float2 pos,float scale,float2 uv){
                float2 dir = pos - uv;
                float radius = length(dir)*scale;
                float angle = atan2(dir.y,dir.x);
                //造型函数
                float f = abs(cos(angle*2.5))*.5+.3;
                float col = 1.-smoothstep(f,f+0.02,radius);
                return float3(col,col,col );
            }

            // 水滴
            float3 createWaterDrop(float2 pos,float scale,float2 uv){
                float2 dir = pos - uv;
                float radius = length(dir)*scale;
                float angle = atan2(dir.y,dir.x);
                //造型函数
                float f = 1.0 - pow(abs(angle+-1.548),2.416);
                float col = 1.-smoothstep(f,f+0.02,radius);
                return float3(col,col,col );
            }

            // 风车
            float3 createWindmill(float2 pos,float scale,float2 uv){
                float2 dir = pos-uv;
                float radius = length(dir)*scale;
                float angle = atan2(dir.y,dir.x);
                
                float f = frac(angle*1.273)*0.956;
                 float col = 1.-smoothstep(f,f+0.02,radius);
                return float3(col,col,col );
            }

            // ...
            float3 createD(float2 pos,float scale,float2 uv){
                float2 dir = pos - uv;
                float radius = length(dir)*scale;
                float angle = atan2(dir.y,dir.x);
                //造型函数
                float f = abs(cos(angle*13.136)*sin(angle*3.))*.8+.1;
                float col = 1.-smoothstep(f,f+0.02,radius);
                return float3(col,col,col );
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed3 mask = createCircle(_Pos,_Size,i.uv);

                return col * fixed4(mask,1.0);
            }
            ENDCG
        }
    }
}
