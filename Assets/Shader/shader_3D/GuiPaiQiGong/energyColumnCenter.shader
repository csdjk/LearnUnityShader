//--------------------------- 【描边】 - 法线扩张---------------------
//create by 长生但酒狂
Shader "lcl/shader3D/GuiPaiQiGong/energyColumnCenter"
{
    //---------------------------【属性】---------------------------
    Properties
    {
        // 噪声纹理
        _NoiseTex ("Texture", 2D) = "white" {}
        // 中心颜色
        _CenterColor("Color",Color)=(1,1,1,1)
        // 边缘颜色
        _EdgeColor("lineColor",Color)=(1,1,1,1)
        // 描边强度
        _power("lineWidth",Range(0,10)) = 1
        // 破碎纹理
        _Color("Color",Color) = (1,1,1,1)
        _Speed("Speed",Range(-5,5)) = 1
        _Area("Area",Range(0,1)) = 0
        // 光晕相关参数
        [Header(Glow)]
        _GlowRange("GlowRange",Range(0,1)) = 0
        [HDR]_GlowColor("Glow Color", Color) = (1,1,0,1)
        _Strength("Glow Strength", Range(10.0, 1.0)) = 2.0
    }
    // ------------------------【CG代码】---------------------------
    CGINCLUDE

    #include "UnityCG.cginc"
    #include "Lighting.cginc"
    // ------------------------【变量声明】---------------------------
    sampler2D _NoiseTex;
    float4 _CenterColor;
    float _power;
    float4 _EdgeColor;
    //
    float4 _Color;
    float _Speed;
    float _Area;
    // 光晕相关参数
    float4 _GlowColor;
    float _GlowRange;
    float _Strength;
    // ---------------------------【背面渲染-光晕】---------------------------
    struct v2f_back
    {
        float4 vertex : SV_POSITION;
        float2 uv : TEXCOORD0;//纹理坐标
        float4 col : TEXCOORD1;
    };
    //顶点着色器
    v2f_back vert_back(appdata_base v) {
        v2f_back o;
        // 世界空间下法线和视野方向
        float3 worldNormalDir = mul(v.normal, unity_WorldToObject);
        float3 worldViewDir = _WorldSpaceCameraPos - mul(unity_ObjectToWorld, v.vertex).xyz;
        //根据法线和视野夹角计算透明度
        float strength = abs(dot(normalize(worldViewDir), normalize(worldNormalDir)));
        float opacity = pow(strength, _Strength);
        o.col = float4(_GlowColor.xyz, opacity);
        // 向法线方向扩张
        float3 pos = v.vertex + (v.normal * _GlowRange);
        // 转换到裁剪空间
        o.vertex = UnityObjectToClipPos(pos);
        return o;
    }

    //片元着色器
    float4 frag_back(v2f_back i) : COLOR {
 
        return i.col;
    }

    // ---------------------------【正面渲染】---------------------------
    //顶点着色器输出结构体
    struct v2f_front
    {
        float4 vertex : SV_POSITION;//像素坐标
        float2 uv : TEXCOORD0;//纹理坐标
        float3 worldNormalDir:COLOR0;//世界空间里的法线方向
        float3 worldPos:COLOR1;//世界空间里的坐标
    };

    // 顶点着色器
    v2f_front vert_front (appdata_base v)
    {
        v2f_front o;
        o.uv = v.texcoord;
        o.worldNormalDir = mul(v.normal,(float3x3) unity_WorldToObject);
        o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;  
        o.vertex = UnityObjectToClipPos(v.vertex);
        return o;
    }
    // 片元着色器
    fixed4 frag_front (v2f_front i) : SV_Target
    {
        // ---------------------------【渐变色】---------------------------
        //视角方向
        float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
        //法线方向
        float3 normaleDir = normalize(i.worldNormalDir);
        //计算视角方向与法线的夹角(夹角越大，value值越小，越接近边缘)
        float value = dot(viewDir,normaleDir);
        value = 1 - saturate(value);
        //通过_power调节描边强度
        value = pow(value,_power);
        //源颜色值和描边颜色做插值
        fixed3 result =lerp(_CenterColor,_EdgeColor,value);

        // ---------------------------【破碎纹理】---------------------------
        float2 uv_offset = float2(0,0);
        uv_offset.y = _Time.y * _Speed;
        i.uv += uv_offset;
        // 获取噪声纹理
        fixed3 col = tex2D(_NoiseTex,i.uv);
        float opacity = step(_Area,col.x);
        return float4(result,opacity);
    }
    ENDCG
    

    // ---------------------------【子着色器】---------------------------
    SubShader
    {
        Blend SrcAlpha OneMinusSrcAlpha
        Tags{ "Queue" = "Transparent"}

        // ---------------------------【背面渲染通道 - 光晕】---------------------------
        Pass
        {
            Cull front
            CGPROGRAM
            #pragma vertex vert_back
            #pragma fragment frag_back
            ENDCG
        }

        // ---------------------------【正面渲染通道】---------------------------
        Pass
        {
            ZWrite Off 
            // Cull Off
            CGPROGRAM
            #pragma vertex vert_front
            #pragma fragment frag_front
            ENDCG
        }
    }
}
