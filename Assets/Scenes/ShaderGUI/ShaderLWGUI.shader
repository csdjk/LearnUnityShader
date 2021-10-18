// shader GUI插件LWGUI
Shader "lcl/ShaderGUI/ShaderLWGUI"
{
    Properties
    {
        [Queue] _Queue ( "Queue", float) = 2000
        
        // use Header on builtin attribute
        [Header(Header)][NoScaleOffset]
        _MainTex ("Color Map", 2D) = "white" { }
        [HDR] _Color ("Color", Color) = (1, 1, 1, 1)
        [Ramp]_Ramp ("Ramp", 2D) = "white" { }
        
        // use Title on LWGUI attribute
        [Title(_, Title)]
        // 水平显示多个属性
        [Tex(_, _mColor2)] _tex ("tex color", 2D) = "white" { }
        
        /// 创建一个折叠组
        /// group：group key，不提供则使用shader property name
        /// keyword：_为忽略，不填和__为属性名大写 + _ON
        /// style：0 默认关闭；1 默认打开；2 默认关闭无toggle；3 默认打开无toggle
        // Main(string group = "", string keyWord = "", float style = 0)
        [Main(g1)] _group ("group", float) = 1


        [Sub(g1)]  _float ("float", float) = 2
        
        [KWEnum(g1, name1, key1, name2, key2, name3, key3)]
        _enum ("enum", float) = 0
        
        // Display when the keyword ("group + keyword") is activated
        [Sub(g1key1)] _enum1("enum1", float) = 0
        [Sub(g1key2)] _enum2 ("enum2", float) = 0
        [Sub(g1key3)] _enum3 ("enum3", float) = 0
        [Sub(g1key3)] _enum3_range ("enum3_range", Range(0, 1)) = 0
        
        [Tex(g1)][Normal] _normal ("normal", 2D) = "bump" { }
        [Sub(g1)][HDR] _hdr ("hdr", Color) = (1, 1, 1, 1)
        [Title(g1, Sample Title)]
        [SubToggle(g1, _)] _toggle ("toggle", float) = 0

        // ---------Toggle 隐藏、显示-------
        [SubToggle(g1, _KEYWORD)] _toggle_keyword ("toggle_keyword", float) = 0
        [Sub(g1_KEYWORD)]  _float_keyword ("float_keyword", float) = 0
        // ---------End-------


        [SubPowerSlider(g1, 2)] _powerSlider ("powerSlider", Range(0, 100)) = 0

        // Display up to 4 colors in a single line
        [Color(g1, _, _mColor1, _mColor2, _mColor3)]
        _mColor ("multicolor", Color) = (1, 1, 1, 1)
        [HideInInspector] _mColor1 (" ", Color) = (1, 0, 0, 1)
        [HideInInspector] _mColor2 (" ", Color) = (0, 1, 0, 1)
        [HideInInspector] [HDR] _mColor3 (" ", Color) = (0, 0, 1, 1)
        
        // Create a drop-down menu that opens by default, without toggle
        [Main(g2, _KEYWORD, 3)] _group2 ("group2 without toggle", float) = 1
        [Sub(g2)]  _float2 ("float2", float) = 2
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            #pragma multi_compile _ _GROUP_ON 

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
    CustomEditor "JTRP.ShaderDrawer.LWGUI"
}
