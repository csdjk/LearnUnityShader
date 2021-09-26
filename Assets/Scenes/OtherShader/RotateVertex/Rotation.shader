Shader "lcl/RotateVertex/Rotation"
{
    Properties
    {
        _RotateVector("RotateVector", Vector) = (0,0,0,0)
        [PowerSlider(3.0)]_Angle("Angle", Range (-90, 90)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

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

            float4 _RotateVector;
            float _Angle;

            v2f vert (appdata v)
            {
                v2f o;
                float s,c;
                sincos(radians(-_Angle),s,c);
                
                float4x4 rotateMatrix_X =
                {			
                    1,0,0, 0,
                    0,c,-s,0,
                    0,s,c, 0,
                    0,0,0, 1
                };
                float4x4 rotateMatrix_Y =
                {			
                    c,0,s, 0,
                    0,1,0,0,
                    -s,0,c, 0,
                    0,0,0, 1
                };
                float4x4 rotateMatrix_Z =
                {			
                    c,-s,0,0,
                    s,c,0,0,
                    0,0,1,0,
                    0,0,0,1
                };
                float offset = 0.5f;

                v.vertex += float4(0,offset,0,0);
                float4x4 matrixm = mul(rotateMatrix_X,rotateMatrix_Y);
                v.vertex.xyz = mul(matrixm,v.vertex);
                v.vertex += float4(0,-offset,0,0);


                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return 1;
            }
            ENDCG
        }
    }
}
