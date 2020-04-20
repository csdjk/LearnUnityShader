// ---------------------------【能量柱】---------------------------
Shader "lcl/shader3D/GuiPaiQiGong/halfSphere"
{
    // ---------------------------【属性】---------------------------
    Properties
    {
        _NoiseTex ("NoiseTex", 2D) = "white" {}
        _Color("Color",Color) = (1,1,1,1)
        _Color1("Color1",Color) = (1,1,1,1)
        _Speed("Speed",Range(-5,5)) = 1
        _Area("Area",Range(0,1)) = 0
        // 光晕相关参数
        [Header(Glow)]
        // 光晕开关
        // [Toggle]_GlowSwith("Clow Switch",Float) = 0
        _GlowRange("GlowRange",Range(0,1)) = 0
        [HDR]_GlowColor("Glow Color", Color) = (1,1,0,1)
        _Strength("Glow Strength", Range(5.0, 1.0)) = 2.0
    }
    // ---------------------------【公共部分】---------------------------
    CGINCLUDE
    #include "UnityCG.cginc"
   
    sampler2D _NoiseTex;
    float4 _NoiseTex_ST;
    float4 _Color;
    float4 _Color1;
    float _Speed;
    float _Area;
    // 光晕相关参数
    float _GlowSwith;
    float4 _GlowColor;
    float _GlowRange;
    float _Strength;
    // ---------------------------【背面渲染通道-光晕】---------------------------
    struct v2f_back
    {
        float4 vertex : SV_POSITION;
        float4 col : TEXCOORD0;
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

    // ---------------------------【正面渲染通道】---------------------------
    struct v2f_front
    {
        float2 uv : TEXCOORD0;
        float4 vertex : SV_POSITION;
    };

    v2f_front vert_front (appdata_base v)
    {
        v2f_front o;
        o.vertex = UnityObjectToClipPos(v.vertex);
        o.uv = TRANSFORM_TEX(v.texcoord, _NoiseTex);
        return o;
    }

    fixed4 frag_front (v2f_front i) : SV_Target
    {
        float2 uv_offset = float2(0,0);
        // uv_offset.x = _Time.y * _Speed;
        uv_offset.y = _Time.y * _Speed;
        i.uv += uv_offset;
        
        // 获取噪声纹理
        fixed3 col = tex2D(_NoiseTex,i.uv);
        float opacity = step(_Area,col.x);
        fixed3 result = lerp(_Color,_Color1,pow(col.x,1));
        return fixed4(result.rgb,opacity);
    }
    ENDCG

    // ---------------------------【子着色器】---------------------------
    SubShader
    {
        Blend SrcAlpha OneMinusSrcAlpha
        Tags{ "Queue" = "Transparent"}

        // ---------------------------【背面 - 光晕】---------------------------
        Pass
        {
            Cull front
            CGPROGRAM
            #pragma vertex vert_back
            #pragma fragment frag_back
            ENDCG
        }

        // ---------------------------【正面】---------------------------
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
