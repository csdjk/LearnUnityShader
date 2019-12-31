//--------------------------- 【描边】 - 法线扩张---------------------
//create by 长生但酒狂

Shader "lcl/shader3D/outLine3D_swell"
{
    //---------------------------【属性】---------------------------
    Properties
    {   
        // 主纹理
        _MainTex ("Texture", 2D) = "white" {}
        // 主颜色
        _Color("Color",Color)=(1,1,1,1)
        // 描边强度
        _power("power",Range(0,0.2)) = 0.05
        // 描边颜色
        _lineColor("lineColor",Color)=(1,1,1,1)
    }
    // ------------------------【CG代码】---------------------------
    CGINCLUDE
    #include "UnityCG.cginc"
    #include "Lighting.cginc"
    //顶点着色器输入结构体
    struct appdata
    {
        float4 vertex : POSITION;//顶点坐标
        float2 uv : TEXCOORD0;//纹理坐标
        float3 normal:NORMAL;//法线
    };
    //顶点着色器输出结构体
    struct v2f
    {
        float4 vertex : SV_POSITION;//像素坐标
        float2 uv : TEXCOORD0;//纹理坐标
        float3 worldNormalDir:COLOR0;//世界空间里的法线方向
        float3 worldPos:COLOR1;//世界空间里的坐标

    };
    // ------------------------【变量声明】---------------------------
    //纹理
    sampler2D _MainTex;
    //内置的变量，纹理中的单像素尺寸
    float4 _MainTex_TexelSize;
    //主颜色
    float4 _Color;
    //描边强度
    float _power;
    //描边颜色
    float4 _lineColor;

    // ------------------------【背面-顶点着色器】---------------------------
    v2f vert_back (appdata v)
    {
        v2f o;
        //法线方向
        v.normal = normalize(v.normal);
        //顶点沿着法线方向扩张
        v.vertex.xyz +=  v.normal * _power;
        //由模型坐标系转换到裁剪空间
        o.vertex = UnityObjectToClipPos(v.vertex);
        //输出结果
        return o;
    }

    // ------------------------【背面-片元着色器】---------------------------
    fixed4 frag_back (v2f i) : SV_Target
    {
        //直接输出颜色
        return _lineColor;
    }

    // ------------------------【正面-顶点着色器】---------------------------
    v2f vert_front (appdata v)
    {
        //正常渲染
        v2f o;
        o.uv = v.uv;
        o.worldNormalDir = mul(v.normal,(float3x3) unity_WorldToObject);
        o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;  
        v.normal = normalize(v.normal);
        o.vertex = UnityObjectToClipPos(v.vertex);
        return o;
    }
    // ------------------------【正面-片元着色器】---------------------------
    fixed4 frag_front (v2f i) : SV_Target
    {
        //正常渲染
        //纹理颜色值
        fixed4 col = tex2D(_MainTex, i.uv);
        //环境光
        fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * _Color.xyz;
        //视角方向
        float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
        //法线方向
        float3 normaleDir = normalize(i.worldNormalDir);
        //光照方向归一化
        fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
        //半兰伯特模型
        fixed3 lambert = 0.5 * dot(normaleDir, worldLightDir) + 0.5;
        //漫反射
        fixed3 diffuse = lambert * _Color.xyz * _LightColor0.xyz + ambient;
        //最终结果
        fixed3 result = diffuse * col.xyz;
        return float4(result,1);
    }
    ENDCG
    // ------------------------【子着色器】---------------------------
    SubShader
    {
        Blend SrcAlpha OneMinusSrcAlpha
        Tags{ "Queue" = "Transparent"}
        
        // ------------------------【背面通道】---------------------------
        Pass
        {
            Cull Front
            //防止背面模型穿透正面模型有两种方法：
            //1.控制深度偏移，描边pass远离相机一些，防止与正常pass穿插（这个方法效果不是很好）
            // Offset [_OffsetFactor],1
            //2.关闭深度写入，为了让正面的pass完全覆盖背面，同时要把渲染队列改成Transparent，此时物体渲染顺序是从后到前的
            ZWrite Off

            CGPROGRAM
            #pragma vertex vert_back
            #pragma fragment frag_back
            ENDCG
        }

        // ------------------------【正面通道】---------------------------
        Pass
        {
            Cull Back
            CGPROGRAM
            #pragma vertex vert_front
            #pragma fragment frag_front
            ENDCG
        }
    }
}
