//--------------------------- 【描边】 - 基于法线与视角夹角---------------------
//create by 长生但酒狂
Shader "lcl/shader3D/outline/outline3D"
{
    //---------------------------【属性】---------------------------
    Properties
    {
        // 主纹理
        _MainTex ("Texture", 2D) = "white" {}
        // 主颜色
        _Color("Color",Color)=(1,1,1,1)
        // 描边强度
        _power("lineWidth",Range(0,10)) = 1
        // 描边颜色
        _lineColor("lineColor",Color)=(1,1,1,1)
    }
    // ------------------------【子着色器】---------------------------
    SubShader
    {
        //渲染队列
        Tags{
            "Queue" = "Transparent"
        }
        Blend SrcAlpha OneMinusSrcAlpha
        // 通道
        Pass
        {
            // ------------------------【CG代码】---------------------------
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

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

            // ------------------------【顶点着色器】---------------------------
            v2f vert (appdata v)
            {
                v2f o;
                o.uv = v.uv;
                o.worldNormalDir = mul(v.normal,(float3x3) unity_WorldToObject);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;  
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }
            // ------------------------【变量声明】---------------------------
            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            float4 _Color;
            float _power;
            float4 _lineColor;
            // ------------------------【片元着色器】---------------------------
            fixed4 frag (v2f i) : SV_Target
            {
                //纹理颜色
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
                fixed3 result = diffuse * col.xyz;
                //计算视角方向与法线的夹角(夹角越大，value值越小，越接近边缘)
                float value = dot(viewDir,normaleDir);
                //
                value = 1 - saturate(value);
                //通过_power调节描边强度
                value = pow(value,_power);
                //源颜色值和描边颜色做插值
                result =lerp(result,_lineColor,value);

                return float4(result,1);
            }
            ENDCG
        }
    }
}
