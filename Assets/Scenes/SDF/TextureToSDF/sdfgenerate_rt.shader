Shader "ShaderMan/sdfgenerate_rt"
    {

    Properties{
        _MainTex ("MainTex", 2D) = "white" {}
        _range ("range", Range(16, 256)) = 16
    }

    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }

        Pass
        {
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        CGPROGRAM
        #pragma vertex vert
        #pragma fragment frag
        #include "UnityCG.cginc"

        struct VertexInput {
            fixed4 vertex : POSITION;
            fixed2 uv:TEXCOORD0;
            fixed4 tangent : TANGENT;
            fixed3 normal : NORMAL;
           //VertexInput
        };


        struct VertexOutput {
            fixed4 pos : SV_POSITION;
            fixed2 uv:TEXCOORD0;
            //VertexOutput
        };

        //Variables
        sampler2D _MainTex;
        uniform float4 _MainTex_TexelSize;
        float _range;

    
        bool isIn(fixed2 uv) {
            fixed4 texColor = tex2D(_MainTex, uv);
            return texColor.r > 0.5;
        }
        

        float squaredDistanceBetween(fixed2 uv1, fixed2 uv2)
        {
            fixed2 delta = uv1 - uv2;
            float dist = (delta.x * delta.x) + (delta.y * delta.y);
            return dist;
        }





        VertexOutput vert (VertexInput v)
        {
           VertexOutput o;
           o.pos = UnityObjectToClipPos (v.vertex);
           o.uv = v.uv;
           //VertexFactory
           return o;
        }
        fixed4 frag(VertexOutput i) : SV_Target
        {

            fixed2 uv = i.uv;

            const float range = _range;
            const int iRange = int(range);
            float halfRange = range / 2.0;
            fixed2 startPosition = fixed2(i.uv.x - halfRange * _MainTex_TexelSize.x, i.uv.y - halfRange * _MainTex_TexelSize.y);

            bool fragIsIn = isIn(uv);
            float squaredDistanceToEdge = (halfRange* _MainTex_TexelSize.x*halfRange*_MainTex_TexelSize.y)*2.0;

            // [unroll(100)]
            for (int dx = 0; dx < iRange; dx++) {
                // [unroll(100)]  
                for (int dy = 0; dy < iRange; dy++) {
                    fixed2 scanPositionUV = startPosition + float2(dx * _MainTex_TexelSize.x, dy* _MainTex_TexelSize.y);

                    bool scanIsIn = isIn(scanPositionUV / 1);
                    if (scanIsIn != fragIsIn) {
                        float scanDistance = squaredDistanceBetween(i.uv, scanPositionUV);
                        if (scanDistance < squaredDistanceToEdge) {
                            squaredDistanceToEdge = scanDistance;
                        }
                    }
                }
            }

            float normalised = squaredDistanceToEdge / ((halfRange * _MainTex_TexelSize.x*halfRange * _MainTex_TexelSize.y)*2.0);
            float distanceToEdge = sqrt(normalised);
            if (fragIsIn)
                distanceToEdge = -distanceToEdge;
            normalised = 0.5 - distanceToEdge;


            return fixed4(normalised, normalised, normalised, 1.0);
        }
        ENDCG

        }
    }
}