// ================================= Shader 代码优化 =================================
Shader "lcl/ShaderOptimization"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _Vector0 ("Vector0", Vector) = (1, 1, 1, 1)
        _Vector1 ("Vector1", Vector) = (1, 1, 1, 1)
        _Int ("Int", Int) = 1
        _Float ("Float0", Float) = 1
        _Float1 ("Float1", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            #include "Assets\Shader\ShaderLibs\Node.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;


            half4 _Color;
            int _Int;
            float _Float, _Float1;
            float4 _Vector0;
            float4 _Vector1;
            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
            };
            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
            };
            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.positionWS = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }
            // ================================= 分析方法 =================================
            // 1. 下载安装Arm Mobile Studio  (百度网盘:工具->GraphicTools)(https://developer.arm.com/Tools%20and%20Software/Mali%20Offline%20Compiler)
            // 复制Compile Shader顶点或者片元代码到一个单独的文件(.vert 或者 .frag)
            // cmd进入文件目录
            // cmd 执行命令: malioc FragShader.frag
            half4 frag(v2f i) : SV_Target
            {
                // float3 L = normalize(UnityWorldSpaceLightDir(i.positionWS));
                // float3 V = normalize(UnityWorldSpaceViewDir(i.positionWS));
                // float NdotL = saturate(dot(V, L));
                float3 value = _Color;
                float4 v = _Vector0;
                float4 t = _Vector1;
                float2 uv = i.uv;
                float3 positionWS = i.positionWS;

                // ================================= 倒数优化 =================================
                // Bad!!
                // value = 0.5 / value; //4 cycles
                // Good!!
                // value = 0.5 * rcp(value); //3 cycles


                // ================================= Nnormalize =================================
                // Bad!!
                // value.xyz = -normalize(value.xyz);//5 cycles
                // Good!!
                // value.xyz = normalize(-value.xyz);//4 cycles


                // ================================= Abs =================================
                // Bad!!
                // value = abs(value.x * value.y);
                // Good!!
                // value = abs(value.x) * abs(value.y);


                // ================================= dot =================================
                // Bad!!
                // value.x = -dot(value.xyz, value.yzx); // 5 cycles
                // Good!!
                // value.x = dot(-value.xyz, value.yzx); // 4 cycles


                // ================================= clamp =================================
                // Bad!!
                // value.x = 1.0 - clamp(value.x, 0.0, 1.0);// 5 cycle
                // Good!!
                // value.x = clamp(1.0 - value.x, 0.0, 1.0); // 4 cycle


                // ================================= exp =================================
                // Bad!!
                // value = exp(value);
                // Good!!
                // value = exp2(value * 1.442695);
                

                // ================================= distance =================================
                // Bad!!
                // value.x = length(t - v);
                // value.y = distance(v, t);// 9 cycle

                // Good!!
                // value.x = length(t - v); // 6 cycles
                // value.y = distance(t, v);



                // ================================= 分组运算 =================================
                // 将标量和向量一次分组，可以提升效率

                // Bad!!
                // value.xyz = t.xyz * t.x * t.y * t.wzx * t.z * t.w; // 8 cycles
                // Good!!
                value.xyz = (t.x * t.y * t.z * t.w) * (t.xyz * t.wzx); // 6 cycles


                // ================================= if or step or 三元运算 =================================
                // value.xyz = uv.x >= 0.5 ? value.yyy : value.zzz;
                // value.xyz = lerp(value.zzz, value.yyy, step(0.5, uv.x));
                // if (uv.x >= 0.5)
                // {
                //     value.xyz = value.yyy;
                // }
                // else
                // {
                //     value.xyz = value.zzz;
                // }



                // value = value.xyz * (uv.x >= 0.5).xxx;
                // value = value.xyz * step(0.5, uv.x);


                half3 resCol = value;
                return half4(resCol, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}