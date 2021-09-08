Shader "lcl/SubsurfaceScattering/FastSSS2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BaseColor("Base Color",Color) = (1,1,1,1)
        _PowerValue("Power Value", Range(0, 10)) = 1
        _ScaleValue("Scale Value", Range(0, 10)) = 0.2
        _WrapValue("_WrapValue", Range(0, 10)) = 0.2
        _SpecularPowerValue("_SpecularPowerValue", Range(0, 10)) = 0.2
        _SpecularScaleValue("_SpecularScaleValue", Range(0, 10)) = 0.2
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
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal: NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normalDir: TEXCOORD1;
                float3 worldPos: TEXCOORD2;
                float3 viewDir: TEXCOORD3;
                float3 lightDir: TEXCOORD4;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _BaseColor;
            float _PowerValue;
            float _ScaleValue;
            float _WrapValue;
            float _SpecularPowerValue;
            float _SpecularScaleValue;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = mul (unity_ObjectToWorld, v.vertex);
                o.normalDir = UnityObjectToWorldNormal (v.normal);
                o.viewDir = UnityWorldSpaceViewDir(o.worldPos);
                o.lightDir = UnityWorldSpaceLightDir(o.worldPos);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * _BaseColor;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                fixed3 N = normalize(i.normalDir);
                fixed3 V = normalize(i.viewDir);
                float3 L = normalize(i.lightDir);



                // float _SSSValue =0.6;
                // float3 N_Shift = -normalize(normalDir*_SSSValue+lightDir);//沿着光线方向上偏移法线，最后在取反
                // float BackLight = saturate(pow(saturate( dot(N_Shift,viewDir)) ,_PowerValue)*_ScaleValue);
                // float FinalColor = BackLight;


                //WrapLight
                float WrapLight = pow(dot(N,L)*_WrapValue+(1-_WrapValue),2);
                //Blin-Phong
                float3 R = reflect(-L,N);
                float3 H = normalize(V+L);
                // float3 R = normalize(  -L + 2* N* dot(N,L) );
                float VR = saturate(dot(V,R));
                float NH = saturate(dot(N,H));
                float NL = saturate(dot(N,L));
                float4 Specular = pow(NH,_SpecularPowerValue)*_SpecularScaleValue;
                float4 Diffuse = WrapLight;
                //模拟透射现象
                float _SSSValue =0.6;
                float3 N_Shift = -normalize(N*_SSSValue+L);//沿着光线方向上偏移法线，最后在取反
                float BackLight = saturate(pow(saturate( dot(N_Shift,V)) ,_PowerValue)*_ScaleValue);
                fixed4 FinalColor = (Diffuse + Specular + BackLight) * col;
                
                return BackLight;
            }
            ENDCG
        }
    }
}
