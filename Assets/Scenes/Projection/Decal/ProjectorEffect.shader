Shader "lcl/Decal/ProjectorEffectShader" 
{ 
    Properties 
    {
        _Color ("Main Color", Color) = (1,1,1,1)
        _DecalTex ("Cookie", 2D) = "" {}
    }
    
    Subshader 
    {
        Pass 
        {
            ZWrite Off
            Fog { Color (0, 0, 0) }
            ColorMask RGB
            Blend SrcAlpha OneMinusSrcAlpha
            Offset -1, -1
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            struct v2f 
            {
                float4 uvDecal : TEXCOORD0;
                float4 pos : SV_POSITION;
            };
            
            float4x4 _ProjectorVPMatrix;
            
            fixed4 _Color;
            sampler2D _DecalTex;
            
            v2f vert (float4 vertex : POSITION)
            {
                v2f o;
                o.pos = UnityObjectToClipPos (vertex);
                //转化到Decal相机的投影空间
                float4x4 decalMVP = mul(_ProjectorVPMatrix, unity_ObjectToWorld);
                float4 decalProjectSpacePos = mul(decalMVP, vertex);
                //转化到Decal所对应的屏幕空间(0,1)区间位置
                o.uvDecal = ComputeScreenPos(decalProjectSpacePos);
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 decal = tex2Dproj (_DecalTex, i.uvDecal);
                decal *= _Color;
                return decal;
            }
            
            ENDCG
        }
    }
}