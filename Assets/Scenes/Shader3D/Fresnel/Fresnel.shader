//10.1.5,菲尼尔反射
Shader "lcl/shader3D/Fresnel"
{
    Properties
    {
        //物体颜色
        _Color("Color Tint",Color) = (1,1,1,1)
        //菲尼尔反射强度
        _FresnelScale("Fresnel Scale",Range(0,1))=0.5
        //模拟反射的环境映射纹理
        _Cubemap("Reflection Cubemap",Cube) = "_Skybox"{}
    }
    SubShader
    {
        //渲染类型=不透明  队列=几何
        Tags{ "RenderType" = "Opaque" "Queue" = "Geometry" }
        
        Pass
        {
            //光照模式=向前渲染
            Tags{ "LightMode" = "ForwardBase" }
            
            CGPROGRAM
            
            //定义顶点片元
            #pragma vertex vert
            #pragma fragment frag
            
            //确保光照衰减等光照变量可以被正确赋值
            #pragma multi_compile_fwdbase
            
            //包含引用的内置文件
            #include "UnityCG.cginc"
            #include "Lighting.cginc"  
            #include "AutoLight.cginc"
            
            //声明属性变量
            fixed4 _Color;
            fixed4 _ReflectColor;
            float _FresnelScale;
            
            //cube 属性用 samplerCUBE 来声明
            samplerCUBE _Cubemap;
            
            //定义输入结构体
            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal:NORMAL;
                
            };
            
            //定义输出结构体
            struct v2f
            {
                
                float4 pos:SV_POSITION;
                fixed3 worldNormal : TEXCOORD0;
                float3 worldPos:TEXCOORD1;
                fixed3 worldViewDir : TEXCOORD2;
                fixed3 worldRefl : TEXCOORD3;
                
                //添加内置宏，声明一个用于阴影纹理采集的坐标，参数是下一个可用的插值寄存器的索引值
                SHADOW_COORDS(4)
            };
            
            //顶点着色器
            v2f vert(a2v v) {
                v2f o;
                //转换顶点坐标到裁剪空间
                o.pos = UnityObjectToClipPos(v.vertex);
                //转换法线到世界空间
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                //转换顶点坐标到世界空间
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                //获取世界空间下的视角方向
                o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
                
                //compute the reflect dir in world space（计算世界空间中的反射方向）
                //用CG的reflect函数来计算该处顶点的反射方向       reflect（物体反射到摄像机的光线方向，法线方向）
                //物体反射到摄像机的的光线方向，可以由光路可逆的原则反向求得，
                o.worldRefl = reflect(-o.worldViewDir, o.worldNormal);
                //o.worldRefl = reflect(-normalize(o.worldViewDir), normalize(o.worldNormal));
                
                //内置宏，计算上一步中声明的阴影纹理坐标
                TRANSFER_SHADOW(o);
                
                return o;
            }
            
            //片元着色器
            fixed4 frag(v2f i) :SV_Target{
                
                //获取归一化的法线
                fixed3 worldNormal = normalize(i.worldNormal);
                
                //获取归一化的光线方向
                //fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                //获取归一化的视角方向
                //fixed3 worldViewDir = normalize(i.worldViewDir);
                fixed3 worldViewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                
                //获取环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                
                //漫反射计算  =光照颜色*物体颜色*大于零的 法线和光照方向的点积
                fixed3 diffuse = _LightColor0.rgb*_Color.rgb*max(0, dot(worldNormal, worldLightDir));
                
                //在世界空间中使用折射方向访问立方体贴图
                fixed3 reflection = texCUBE(_Cubemap, i.worldRefl).rgb;
                
                //光照衰减程度
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
                //使用Schlick菲尼尔近似式计算fresnel变量
                fixed fresnel = _FresnelScale + (1 - _FresnelScale)*pow(1 - dot(worldViewDir, worldNormal), 5);
                
                //环境光+插值（漫反射，反射，0到1之间的菲尼尔）*光照衰减程度
                return fixed4(ambient + lerp(diffuse, reflection, saturate(fresnel))*atten, 1.0);
                
            }
            ENDCG
        }
    }
    FallBack "Reflective/VertexLit"
}