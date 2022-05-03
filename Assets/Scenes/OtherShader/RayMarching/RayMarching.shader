Shader "lcl/RayMarching/RayMarchSimpleScene"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
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

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            // #define lightPos (normalize(float3(5., 3.0, -1.0)))

            //最大光线检测次数
            #define MAX_RAYCAST_STEPS 100
            // 最大深度
            #define Max_Dist 100.
            // 表面距离
            #define Surf_Dist 0.001

            // 来源:http://iquilezles.org/www/articles/distfunctions/distfunctions.htm
            // 距离场函数 - 球
            float sphereSDF(float3 p, float s)
            {
                return length(p) - s;
            }
            // 距离场函数 - 盒子
            float boxSDF(float3 p, float3 b)
            {
                float3 q = abs(p) - b;
                return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
            }
            // 距离场函数 - 圆环
            float torusSDF(float3 p, float2 t)
            {
                float2 q = float2(length(p.xz) - t.x, p.y);
                return length(q) - t.y;
            }

            //距离场函数 - 场景(包含需要绘制的所有物体)
            float sceneSDF(float3 p)
            {
                float z = 10.;
                //盒子
                float3 boxPos = float3(3, 2., z);
                float3 boxSize = 0.6;
                float boxDist = boxSDF(p - boxPos, boxSize);// P点到box的距离
                //球
                float3 spherePos = float3(0, 3, z);
                float sphereSize = 1.;
                float sphereDist = sphereSDF(p - spherePos, sphereSize);// P点到球面的距离
                //圆环
                float3 torusPos = float3(-3.0, 2., z);
                float2 torusSize = float2(.920, 0.290);
                float torusDist = torusSDF(p - torusPos, torusSize);// P点到圆环面的距离
                
                //地面
                float planeDist = p.y;// P点到地面的距离，平面是xz平面，高度y = 0；
                //融合距离场
                float d = min(sphereDist, planeDist);
                d = min(d, boxDist);
                d = min(d, torusDist);
                return d;
            }

            // 阴影
            float SoftShadow(float3 ro, float3 rd)
            {
                float res = 1.0;
                float t = 0.001;
                for (int i = 0; i < 50; i++)
                {
                    float3 p = ro + t * rd;
                    float h = sceneSDF(p);
                    res = min(res, 16.0 * h / t);
                    t += h;
                    if (res < 0.001 || p.y > (200.0)) break;
                }
                return clamp(res, 0.0, 1.0);
            }

            //计算法线
            float3 CalcNormal(in float3 p)
            {
                const float eps = 0.0001; // or some other value
                const float2 h = float2(eps, 0);
                return normalize(float3(sceneSDF(p + h.xyy) - sceneSDF(p - h.xyy),
                sceneSDF(p + h.yxy) - sceneSDF(p - h.yxy),
                sceneSDF(p + h.yyx) - sceneSDF(p - h.yyx))
                );
            }
            //设置相机
            void SetCamera(float2 uv, out float3 ro, out float3 rd)
            {
                //步骤1 获得相机位置ro
                ro = float3(0.0, 5.0, 1);//获取相机的位置
                float3 ta = float3(0, 0, 15);//获取目标位置
                float3 forward = normalize(ta - ro);//计算 forward 方向
                float3 left = normalize(cross(float3(0.0, 1.0, 0), forward));//计算 left 方向
                float3 up = normalize(cross(forward, left));////计算 up 方向
                const float zoom = 1.;

                //步骤2 获得射线朝向
                rd = normalize(uv.x * left + uv.y * up + zoom * forward);
            }

            //着色
            float Shade(float3 p)
            {
                float3 lightPos = float3(0, 12, 10);

                lightPos.xz += float2(sin(_Time.y), cos(_Time.y)) * 2.0;
                
                float3 l = normalize(lightPos - p);//光方向
                float3 n = CalcNormal(p);
                
                float dif = dot(n, l);//漫反射颜色
                //计算阴影
                float shadow = SoftShadow(p, l);
                return dif * shadow;
            }

            //射线检测
            //ro:位置, rd:方向
            float RayCast(float3 ro, float3 rd)
            {
                float depth = 0.;//深度

                for (int i = 0; i < MAX_RAYCAST_STEPS; i++)
                {
                    //对UV进行偏移，偏移方向为rd
                    float3 p = ro + rd * depth;
                    //最短距离
                    float ds = sceneSDF(p);
                    depth += ds;
                    if (depth > Max_Dist || ds < Surf_Dist)
                        break;
                }
                
                return depth;
            }


            fixed4 frag(v2f i) : SV_Target
            {
                // map uv into [-0.5,0.5]
                float2 uv = (i.uv - 0.5) * float2(_ScreenParams.x / _ScreenParams.y, 1.0);
                //ro:位置, rd:方向
                float3 ro, rd;
                //设置Camera
                SetCamera(uv, ro, rd);
                //求射线和场景中物体的碰撞点p
                float ret = RayCast(ro, rd);
                float3 pos = ro + ret * rd;
                // 着色
                half3 color = Shade(pos);
                return float4(color, 1.0);
            }


            ENDCG

        }
    }
    FallBack Off
}
