Shader "lcl/SnowGround/SnowGround" {
    Properties {
        _GroundTex ("Ground Texture", 2D) = "white" {}
        _GroundColor ("Ground Color", Color) = (1, 1, 1, 1)
        _SnowTex ("Snow Texture", 2D) = "white" {}
        _SnowColor ("Snow Color", Color) = (1, 1, 1, 1)

        // 曲面细分强度
        [PowerSlider(3.0)]_TessellationFactors("TessellationFactors",Range(1,100)) = 1
        // 高度图
        _HeightNoiseTex ("Height Nois Texture", 2D) = "white" {}
        // 高度偏移强度
        [PowerSlider(3.0)]_HeightPower("Height Power",Range(-10,10)) = 0
        // 高度法线强度
        [PowerSlider(3.0)]_HeightNormalPower("Height Normal Power",Range(1,100)) = 5

        // 交互强度
        [PowerSlider(3.0)]_SnikPower("Snik Power",Range(-10,10)) = 1
        // 整体偏移
        [PowerSlider(3.0)]_Displacement("Displacement",Range(-10,10)) = 1
    }
    SubShader {
        Pass { 
            Tags { "LightMode"="ForwardBase" }
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma enable_d3d11_debug_symbols

            #pragma hull hs
            #pragma domain ds

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            //引入曲面细分的头文件
            // #include "Tessellation.cginc"
            
            sampler2D _MaskTex;
            half4 _MaskTex_TexelSize;
            float4 _MainTex_ST;
            float4x4 _GroundCameraMatrixVP;

            sampler2D _GroundTex;
            float4 _GroundTex_ST;

            fixed4 _GroundColor;
            sampler2D _SnowTex;
            fixed4 _SnowColor;
            float _Displacement;
            float _SnikPower;


            sampler2D _HeightNoiseTex;
            float4 _HeightNoiseTex_ST;
            half4 _HeightNoiseTex_TexelSize;
            float _HeightPower;
            float _HeightNormalPower;

            struct a2v {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };
            
            struct v2t {
                float4 vertex : INTERNALTESSPOS;
                float4 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };
            
            struct t2g {
                float4 pos : SV_POSITION;
                float4 normal : NORMAL;
                float2 uv : TEXCOORD0;
                float4 height_uv:TEXCOORD1;
                float4 mask_uv:TEXCOORD2;
                float3 worldPos:TEXCOORD3;
            };

            // struct g2f {
                //     float4 pos : SV_POSITION;
                //     float4 normal : NORMAL;
                //     float2 uv : TEXCOORD0;
                //     float4 mask_uv:TEXCOORD2;
            // };
            
            // 顶点着色器（简单的对数据进行传输到曲面细分着色器）
            v2t vert(a2v v) {
                v2t o;
                o.vertex = v.vertex;
                o.normal = v.normal;
                o.uv = v.uv;
                return o;
            }

            #ifdef UNITY_CAN_COMPILE_TESSELLATION
                // struct UnityTessellationFactors {
                    //     float edge[3] : SV_TessFactor;
                    //     float inside : SV_InsideTessFactor;
                // };

                float _TessellationFactors;

                UnityTessellationFactors hsConstFunc(InputPatch<v2t, 3> v) {
                    UnityTessellationFactors o;
                    o.edge[0] = _TessellationFactors; 
                    o.edge[1] = _TessellationFactors; 
                    o.edge[2] = _TessellationFactors;
                    o.inside = _TessellationFactors;
                    return o;
                }

                [UNITY_domain("tri")]
                // integer,fractional_odd,fractional_even
                [UNITY_partitioning("fractional_even")]
                [UNITY_outputtopology("triangle_cw")]
                [UNITY_patchconstantfunc("hsConstFunc")]
                [UNITY_outputcontrolpoints(3)]
                [maxtessfactor(64.0f)]
                // hull 着色器（细分控制着色器）函数 hs 
                v2t hs(InputPatch<v2t, 3> v, uint id : SV_OutputControlPointID) {
                    return v[id];
                }

                // t2f vert2frag(a2v v) {
                    //     t2f o;
                    //     o.pos = UnityObjectToClipPos(v.vertex);
                    //     o.worldNormalDir = v.worldNormalDir;
                    //     return o;
                // }


                // domain 着色器 （细分计算着色器）
                // bary: 重心坐标
                [UNITY_domain("tri")]
                t2g ds(UnityTessellationFactors tessFactors, const OutputPatch<v2t, 3> vi, float3 bary : SV_DomainLocation) {
                    t2g v;
                    v.pos = vi[0].vertex * bary.x + vi[1].vertex * bary.y + vi[2].vertex * bary.z;
                    v.normal = vi[0].normal * bary.x + vi[1].normal * bary.y + vi[2].normal * bary.z;
                    v.uv = vi[0].uv * bary.x + vi[1].uv * bary.y + vi[2].uv * bary.z;

                    v.uv = TRANSFORM_TEX(v.uv, _GroundTex);
                    
                    // ------------------------与物体交互----------------------
                    //转化到Ground相机的投影空间
                    float4x4 groundMVP = mul(_GroundCameraMatrixVP, unity_ObjectToWorld);
                    float4 groundProjectSpacePos = mul(groundMVP, v.pos);
                    //转化到Ground所对应的屏幕空间(0,1)区间位置
                    v.mask_uv = ComputeScreenPos(groundProjectSpacePos);
                    float4 maskTexVar = tex2Dlod(_MaskTex,v.mask_uv);
                    // 下陷
                    v.pos -= v.normal * maskTexVar.r * _SnikPower;

                    // ------------------------生成随机高度----------------------
                    v.height_uv = float4(TRANSFORM_TEX(v.uv, _HeightNoiseTex),0,0);
                    // v.height_uv = float4(v.uv,0,0);
                    float4 height = tex2Dlod(_HeightNoiseTex,v.height_uv).r;
                    v.pos += v.normal * height * _HeightPower;

                    // ------------------------调整整体中心----------------------
                    v.pos += v.normal * _Displacement;

                    // v.worldPos = UnityObjectToWorldDir(v.pos);
                    v.worldPos = mul(unity_ObjectToWorld, v.pos).xyz;
                    // 最后需要转换到Clip裁剪空间
                    v.pos = UnityObjectToClipPos(v.pos);
                    return v;
                }
            #endif

            // https://forum.unity.com/threads/calculate-vertex-normals-in-shader-from-heightmap.169871/
            float3 FindNormal(sampler2D tex, float2 uv, float u,float power)
            {
                //u is one uint size, ie 1.0/texture size
                float2 offsets[4];
                offsets[0] = uv + float2(u, 0);
                offsets[1] = uv + float2(-u, 0);
                offsets[2] = uv + float2(0, -u);
                offsets[3] = uv + float2(0, u);

                float hts[4];
                for (int i = 0; i < 4; i++)
                {
                    hts[i] = tex2D(tex, float2( offsets[i].x, offsets[i].y)).r * power;
                }

                float2 _step = float2(1.0, 0.0);

                float3 va = normalize(float3(_step.xy, hts[1] - hts[0]));
                float3 vb = normalize(float3(_step.yx, hts[3] - hts[2]));

                return cross(va, vb).rbg; //you may not need to swizzle the normal
                // return cross(vb,va).rbg; //you may not need to swizzle the normal
            }
            
            // 这个效果更好
            // https://polycount.com/discussion/117185/creating-normals-from-alpha-heightmap-inside-a-shader
            float3 FindNormal2(sampler2D tex, float2 uv, float u,float3 normal,float power)
            {

                float me = tex2D(tex,uv).x;
                float n = tex2D(tex,float2(uv.x,uv.y+u)).x;
                float s = tex2D(tex,float2(uv.x,uv.y-u)).x;
                float e = tex2D(tex,float2(uv.x-u,uv.y)).x;
                float w = tex2D(tex,float2(uv.x+u,uv.y)).x;
                
                float3 norm = normal;
                float3 temp = norm; //a temporary vector that is not parallel to norm
                if(norm.x==1)
                temp.y+=0.5;
                else
                temp.x+=0.5;
                
                //form a basis with norm being one of the axes:
                float3 perp1 = normalize(cross(norm,temp));
                float3 perp2 = normalize(cross(norm,perp1));
                
                //use the basis to move the normal in its own space by the offset
                float3 normalOffset = -power * ( ( (n-me) - (s-me) ) * perp1 + ( ( e - me ) - ( w - me ) ) * perp2 );
                norm += normalOffset;
                norm = normalize(norm);
                return norm;
            }

            fixed4 frag(t2g i) : SV_Target {
                // float3 maskNormal = FindNormal(_MaskTex,i.mask_uv,_MaskTex_TexelSize.x,_SnikPower*3);
                // float3 heightNormal = FindNormal(_HeightNoiseTex,i.height_uv,_HeightNoiseTex_TexelSize.x,_HeightPower*3);
                // float3 normalDir = normalize(maskNormal+heightNormal);

                float3 maskNormal = FindNormal2(_MaskTex,i.mask_uv,_MaskTex_TexelSize.x,i.normal,_SnikPower*3);
                float3 heightNormal = FindNormal2(_HeightNoiseTex,i.height_uv,_HeightNoiseTex_TexelSize.x,i.normal,_HeightPower*_HeightNormalPower);
                float3 normalDir = normalize(maskNormal+heightNormal);

                // float3 normalDir = FindNormal2(_HeightNoiseTex,i.height_uv,_HeightNoiseTex_TexelSize.x,i.normal,_HeightPower);
                // float3 normalDir = FindNormal2(_MaskTex,i.mask_uv,_MaskTex_TexelSize.x,i.normal,_SnikPower);
                // float3 normalDir = FindNormal(_HeightNoiseTex,i.height_uv,_HeightNoiseTex_TexelSize.x,_HeightPower);
                // float3 normalDir = normalize(cross(ddy(i.worldPos),ddx(i.worldPos)));

                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                //半兰伯特漫反射 值范围0-1
                float3 halfLambert = dot(normalDir,lightDir)*0.5+0.5;	
                // float3 halfLambert = dot(normalDir,lightDir);	
                float3 diffuse = _LightColor0.rgb * halfLambert;

                // 积雪下陷
                float4 amount = tex2Dlod(_MaskTex,i.mask_uv).r;
                float4 floorCol = tex2D(_GroundTex,i.uv) * _GroundColor;
                float4 snowCol = tex2D(_GroundTex,i.uv)* _SnowColor;
                float4 res = lerp(snowCol,floorCol,amount);

                res.rgb *= diffuse;
                return res;
                // return fixed4(normalDir,1);
                // return tex2D(_HeightNoiseTex,i.uv);

                // return fixed4(i.uv,0,1);
                
            }
            
            ENDCG
        }
    } 
    FallBack "Diffuse"
}