Shader "lcl/ShaderPropertyDrawer/ShaderGUI"
{
    Properties
    {
        [Foldout]   _MytestName("溶解面板",Range (0,1)) = 0
        [if(_MytestName)] [Toggle] _Mytest ("启动溶解宏", Float) = 0
        [if(_MytestName)] _Value("溶解参数1",Range (0,1)) = 0
        [if(_MytestName)] [SingleLine] _MainTex2 ("溶解图", 2D) = "white" {}
        [if(_MytestName)] [SingleLine] [Normal] _MainTex3 ("溶解图2", 2D) = "white" {}
        [if(_MytestName)] [PowerSlider(3.0)] _Shininess ("溶解参数3", Range (0.01, 1)) = 0.08
        [if(_MytestName)] [IntRange] _Alpha ("溶解参数4", Range (0, 255)) = 100
        
        [Foldout] _Mytest1Name("扰动面板",Range (0,1)) = 0
        [if(_Mytest1Name)] [Toggle] _Mytest1 ("启动扰动宏", Float) = 0
        [if(_Mytest1Name)] _Value1("扰动参数1",Range (0,1)) = 0
        [if(_Mytest1Name)] [SingleLine] _MainTex4 ("扰动图", 2D) = "white" {}
        [if(_Mytest1Name)] [SingleLine] [Normal] _MainTex5 ("扰动图2", 2D) = "white" {}
        [if(_Mytest1Name)] [Header(A group of things)][Space(10)] _Prop1 ("扰动参数2", Float) = 0
        [if(_Mytest1Name)] [KeywordEnum(Red, Green, Blue)] _ColorMode ("扰动颜色枚举", Float) = 0
        
        [Foldout] _Mytest2Name("特殊面板",Range (0,1)) = 0
        [if(_Mytest2Name)] [Toggle] _Mytest2 ("启动特殊宏", Float) = 0
        [if(_Mytest2Name)] _FirstColor("特殊颜色", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            // ...later on in CGPROGRAM code:
            #pragma multi_compile _OVERLAY_NONE _OVERLAY_ADD _OVERLAY_MULTIPLY

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
    
    CustomEditor "CustomShaderGUI"
}
