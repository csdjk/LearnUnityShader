// 前向渲染，光照衰减
Shader "lcl/PointLight/ForwardRenderingAtten"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1) // 漫反射颜色
        _Specular ("Specular", Color) = (1, 1, 1, 1) // 高光反射颜色
        _Gloss ("Gloss", Range(8, 256)) = 20 // 高光区域大小
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }

        // Base Pass 计算平行光、环境光
        pass
        {
            Tags { "LightMode" = "ForwardBase" }
            
            CGPROGRAM
            
            // 编译指令，保证在pass中得到Pass中得到正确的光照变量
            #pragma multi_compile_fwdbase

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            // 应用传递给顶点着色器的数据
            struct a2v
            {
                float4 vertex: POSITION; // 语义: 顶点坐标
                float3 normal: NORMAL; // 语义: 法线
            };

            // 顶点着色器传递给片元着色器的数据
            struct v2f
            {
                float4 pos: SV_POSITION; // 语义: 裁剪空间的顶点坐标
                float3 worldNormal: TEXCOORD;
                float3 worldPos: TEXCOORD1;
            };

            // 顶点着色器
            v2f vert(a2v v)
            {
                v2f o;

                // 将顶点坐标从模型空间变换到裁剪空间
                // 等价于o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                o.pos = UnityObjectToClipPos(v.vertex);

                // 将法线从模型空间变换到世界空间
                // 等价于o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);

                // 将顶点坐标从模型空间变换到世界空间
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);

                return o;
            }

            // 片元着色器
            fixed4 frag(v2f i): SV_TARGET
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                // 获得世界空间下单位光向量 (是ForwardBase的pass，光一定是平行光)
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

                // 计算漫反射
                // 兰伯特公式：Id = Ip * Kd * N * L
                // IP：入射光的光颜色；
                // Kd：漫反射颜色；
                // N：单位法向量，L：单位光向量
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));

                // 观察方向
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                // 半角向量
                float3 halfDir = normalize(worldLightDir + viewDir);
                // 计算高光反射
                // Blinn-Phong高光反射公式：
                // Cspecular=(Clight * Mspecular) * max(0,n.h)^mgloss
                // Clight：入射光颜色；
                // Mspecular：高光反射颜色；
                // n: 单位法向量；
                // h: 半角向量：光线和视线夹角一半方向上的单位向量 h = (V + L)/(| V + L |)
                // mgloss：反射系数；
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

                // 环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                // 平行光无光照衰减
                fixed atten = 1.0;

                return fixed4(ambient + (diffuse + specular) * atten, 1);
            }
            
            ENDCG
            
        }

        // Add pass 计算额外的逐像素光源(点光源、聚光灯等), 每个pass对应1个光源
        pass
        {
            Tags { "LightMode" = "ForwardAdd" }

            // 开启混合，
            Blend One One
            CGPROGRAM
            
            #pragma multi_compile_fwdadd
            
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            
            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            // 应用传递给顶点着色器的数据
            struct a2v
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
            };

            // 顶点着色器传递给片元着色器的数据
            struct v2f
            {
                float4 pos: SV_POSITION;
                float3 worldNormal: TEXCOORD0;
                float3 worldPos: TEXCOORD1;
            };

            // 顶点着色器
            v2f vert(a2v v)
            {
                v2f o;

                // 将顶点坐标从模型空间变换到裁剪空间
                // 等价于o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                o.pos = UnityObjectToClipPos(v.vertex);

                // 将法线从模型空间变换到世界空间
                // 等价于o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);

                // 将顶点坐标从模型空间变换到世界空间
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                return o;
            }

            // 片元着色器
            fixed4 frag(v2f i): SV_TARGET
            {
                fixed3 worldNormal = normalize(i.worldNormal);

                // 世界空间光向量一般直接用Unity内置函数计算
                // 即：fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos))
                #ifdef USING_DIRECTIONAL_LIGHT
                    // 平行光
                    fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                #else
                    // 非平行光
                    fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
                #endif

                // 计算漫反射颜色
                // 兰伯特公式：Id = Ip * Kd * N * L
                // IP：入射光的光颜色；
                // Kd：漫反射颜色；
                // N：单位法向量，L：单位光向量
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));

                // 观察向量
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                // 半角向量
                fixed3 halfDir = normalize(worldLightDir + viewDir);
                // 计算高光反射
                // Blinn-Phong高光反射公式：
                // Cspecular=(Clight * Mspecular) * max(0,n.h)^mgloss
                // Clight：入射光颜色；
                // Mspecular：高光反射颜色；
                // n: 单位法向量；
                // h: 半角向量：光线和视线夹角一半方向上的单位向量 h = (V + L)/(| V + L |)
                // mgloss：反射系数；
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

                // 计算光照衰减 (一般都直接用Unity内置函数计算: UNITY_LIGHT_ATTENUATION，会在后续文章中用到)
                #ifdef USING_DIRECTIONAL_LIGHT // 平行光
                    // 平行光，光照衰减不变
                    fixed atten = 1.0;
                #else
                    #if defined(POINT) // 点光源
                        // 把顶点坐标从世界空间变换到点光源坐标空间中
                        // unity_WorldToLight由引擎代码计算后传递到shader中，这里包含了对点光源范围的计算，具体可参考Unity引擎源码。
                        // 经过unity_WorldToLight变换后，在点光源中心处lightCoord为(0, 0, 0)，在点光源的范围边缘处lightCoord模为1。
                        float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;
                        // 使用点到光源中心距离的平方dot(lightCoord, lightCoord)构成二维采样坐标(r,r)，对衰减纹理_LightTexture0采样。
                        // UNITY_ATTEN_CHANNEL是衰减值所在的纹理通道，可以在内置的HLSLSupport.cginc文件中查看。
                        // 一般PC和主机平台的话UNITY_ATTEN_CHANNEL是r通道，移动平台的话是a通道。
                        fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
                    #elif defined(SPOT) // 聚光灯
                        // 把顶点坐标从世界空间变换到点光源坐标空间中
                        // unity_WorldToLight由引擎代码计算后传递到shader中，这里面包含了对聚光灯的范围、角度的计算，具体可参考Unity引擎源码。
                        // 经过unity_WorldToLight变换后，在聚光灯光源中心处或聚光灯范围外的lightCoord为(0, 0, 0)，在聚光灯光源的范围边缘处lightCoord模为1。
                        float4 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1));
                        // 与点光源不同，由于聚光灯有更多的角度等要求，因此为了得到衰减值，除了需要对衰减纹理采样外，还需要对聚光灯的范围、张角和方向进行判断。
                        // 此时衰减纹理存储到了_LightTextureB0中，这张纹理和点光源中的_LightTexture0是等价的。
                        // 聚光灯的_LightTexture0存储的不再是基于距离的衰减纹理，而是一张基于张角范围的衰减纹理。在张角中心，即坐标0.5处衰减值为1，而在两侧是接近0的。
                        fixed atten = (lightCoord.z > 0) * tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w * tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
                    #else
                        fixed atten = 1.0;
                    #endif
                #endif

                // 尽管纹理采样方法可以减少计算衰减时的复杂度，有时也可以使用数学公式计算光照衰减：
                // float distance = length(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
                // float atten = 1.0 / distance;

                return fixed4((diffuse + specular) * atten, 1.0);
            }
            ENDCG
            
        }
    }
}
