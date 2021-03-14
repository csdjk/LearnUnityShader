// ---------------------------【自发光球】---------------------------
// create by 长生但酒狂
// create time 2020.1.11
Shader "lcl/shader3D/Emissive/EmissiveOut"
{
    // ---------------------------【属性】---------------------------
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",Color) = (1,1,1,1)
        // 光晕相关参数
        [Header(Glow)]
        _GlowRange("GlowRange",Range(0,1)) = 0
        [HDR]_GlowColor("Glow Color", Color) = (1,1,0,1)
        _Strength("Glow Strength", Range(5.0, 1.0)) = 2.0
    }
    // ---------------------------【公共部分】---------------------------
    CGINCLUDE
    #include "UnityCG.cginc"
    #include "Assets/Shader/ShaderLibs/LightingModel.cginc"
    sampler2D _MainTex;
    float4 _MainTex_ST;
    float4 _Color;
    // 光晕相关参数
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
        float3 worldNormal: TEXCOORD1;
    };

    v2f_front vert_front (appdata_base v)
    {
        v2f_front o;
        o.vertex = UnityObjectToClipPos(v.vertex);
        o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
        o.worldNormal = mul(v.normal,unity_WorldToObject);
        return o;
    }

    fixed4 frag_front (v2f_front i) : SV_Target
    {
        // 获取纹理
        fixed3 col = tex2D(_MainTex,i.uv);
        fixed3 result = col * _Color;

        // fixed3 result = ComputeLambertLighting(i.worldNormal,_Color);
        // result = result * col;
        return fixed4(result.rgb,1);
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
            Cull Off
            CGPROGRAM
            #pragma vertex vert_front
            #pragma fragment frag_front
            ENDCG
        }
    }
}
