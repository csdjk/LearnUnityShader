//--------------------------- 卡通渲染 - 描边---------------------
Shader "lcl/ToonShading/OutLine/Toon_OutLine_Stencil"
{
    Properties
    {   
        // 主纹理
        _MainTex ("Texture", 2D) = "white" {}
        // 主颜色
        _Color("Color",Color)=(1,1,1,1)
        // 描边强度
        _Power("power",Range(0,0.2)) = 0.05
        // 描边颜色
        _LineColor("lineColor",Color)=(1,1,1,1)

        _RefValue("Stencil RefValue",Range(0,200)) = 0
        _OffsetFactor ("Offset Factor", Range(0,200)) = 0
        _OffsetUnits ("Offset Units", Range(0,200)) = 0
    }
    // ------------------------【CG代码】---------------------------
    CGINCLUDE
    #include "UnityCG.cginc"
    #include "Lighting.cginc"
    //顶点着色器输入结构体
    struct appdata
    {
        float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
        float3 normal:NORMAL;
        float4 tangent : TANGENT;
    };
    //顶点着色器输出结构体
    struct v2f
    {
        float4 vertex : SV_POSITION;
        float2 uv : TEXCOORD0;
        float3 worldNormalDir:COLOR0;
        float3 worldPos:COLOR1;
    };
    // ------------------------【变量声明】---------------------------
    //纹理
    sampler2D _MainTex;
    //内置的变量，纹理中的单像素尺寸
    float4 _MainTex_TexelSize;
    //主颜色
    float4 _Color;
    //描边强度
    float _Power;
    //描边颜色
    float4 _LineColor;
    ENDCG

    SubShader
    {
        Blend SrcAlpha OneMinusSrcAlpha
        Tags{ "Queue" = "Transparent"}
        
        
        // ------------------------【正常渲染】---------------------------
        Pass
        {
            Cull Back
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            v2f vert (appdata v)
            {
                //正常渲染
                v2f o;
                o.uv = v.uv;
                o.worldNormalDir = mul(v.normal,(float3x3) unity_WorldToObject);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz; 
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * _Color.xyz;
                float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 normaleDir = normalize(i.worldNormalDir);
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 lambert = 0.5 * dot(normaleDir, worldLightDir) + 0.5;
                fixed3 diffuse = lambert * _Color.xyz * _LightColor0.xyz + ambient;
                fixed3 result = diffuse * col.xyz;
                return float4(result,1);
            }

            ENDCG
        }
        
        
        // ------------------------【描边通道】---------------------------
        Pass
        {
            Stencil{
                Ref [_RefValue]
                Comp Equal 
                Pass IncrSat
            }
            // ZWrite Off
            // Offset [_OffsetFactor], [_OffsetUnits]
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            v2f vert (appdata v)
            {
                v2f o;
                //顶点沿着平均法线方向扩张
                v.vertex.xyz +=  v.normal * _Power;
                // v.vertex.xyz +=  normalize(v.tangent.xyz) * _Power;
                //由模型空间坐标系转换到裁剪空间
                o.vertex = UnityObjectToClipPos(v.vertex);
                //输出结果
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //直接输出颜色
                return _LineColor;
            }
            ENDCG
        }
    }
}
