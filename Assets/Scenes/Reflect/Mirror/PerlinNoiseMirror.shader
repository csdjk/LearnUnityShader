Shader "lcl/Reflect/Mirror/PerlinNoiseMirror" {
    Properties {
        [NoScaleOffset] _MainTex ("MainTex", 2D) = "white" {}               // 主纹理
        [NoScaleOffset] _NoiseTex ("NoiseTex", 2D) = "white" {}             // 噪点图
        _NoiseScaleX ("NoiseScaleX", Range(0, 1)) = 0.1                     // 水平噪点放大系数
        _NoiseScaleY ("NoiseScaleY", Range(0, 1)) = 0.1                     // 垂直放大系数
        _NoiseSpeedX ("NoiseSpeedX", Range(0, 10)) = 1                      // 水平扰动速度
        _NoiseSpeedY ("NoiseSpeedY", Range(0, 10)) = 1                      // 垂直扰动速度
        _NoiseBrightOffset ("NoiseBrightOffset", Range(0, 0.9)) = 0.25      // 噪点图整体的数值偏移
        _NoiseFalloff ("NoiseFalloff", Range(0, 1)) = 1                     // 扰动衰减

        _MirrorRange ("MirrorRange", Range(0, 3)) = 1                       // 镜面范围（最大范围，超出该范围就不反射）
        _MirrorAlpha ("MirrorAlpha", Range(0, 1)) = 1                       // 镜面图像不透明度
        _MirrorFadeAlpha ("_MirrorFadeAlpha", Range(0,1)) = 0.5             // 镜面范围值边缘位置的不透明度，如果调整为0，意思越接近该最大范围的透明就越接近该值：0
    }
    CGINCLUDE
    #include "UnityCG.cginc"
    #include "Lighting.cginc"
    #include "AutoLight.cginc"
    struct appdata {
        float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
        float3 normal : NORMAL;
    };
    struct v2f {
        float4 vertex : SV_POSITION;
        float2 uv : TEXCOORD0;
        float3 wPos : TEXCOORD1;
    };
    struct v2f_m {
        float4 vertex : SV_POSITION;
        float2 uv : TEXCOORD0;
        float4 normal : TEXCOORD1;
        float4 wPos : TEXCOORD2;
    };
    sampler2D _MainTex;
    sampler2D _NoiseTex;
    fixed _NoiseScaleX, _NoiseScaleY;
    fixed _NoiseSpeedX, _NoiseSpeedY;
    fixed _NoiseBrightOffset;
    fixed _NoiseFalloff;
    float _MirrorRange, _MirrorAlpha, _MirrorFadeAlpha;
    float3 n, p; // 镜面法线，镜面任意点
    v2f vert_normal (appdata v) {
        v2f o;
        o.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
        o.vertex = UnityObjectToClipPos(v.vertex);
        o.uv = v.uv;
        return o;
    }
    fixed4 frag_normal (v2f i) : SV_Target {
        float3 dir = i.wPos.xyz - p;                // 平面与插值点的指向
        half d = dot(dir, n);                       // 与反向镜面的距离
        if (d < 0) discard;                         // 如果平面背面，那就丢弃

        return tex2D(_MainTex, i.uv);
    }
    v2f_m vert_mirror (appdata v) {
        v2f_m o;

        o.wPos = mul(unity_ObjectToWorld, v.vertex);

        float3 nn = -n;                 // 法线反向
        float3 dp = o.wPos.xyz - p;     // 平面点与世界空间的点的向量（即：从平面的点指向世界空间点的方向）
        half nd = dot(n, dp);           // 计算出点与平面的垂直距离
        o.wPos.xyz += nn * (nd * 2);    // 将垂直距离反向2倍的距离，就是镜像的位置
        
        o.vertex = mul(unity_MatrixVP, o.wPos);
        o.normal.xyz = UnityObjectToWorldNormal(v.normal);

        fixed t = nd / _MirrorRange;       // 将位置与镜面最大范围比利作为fade alpha的插值系数
        fixed a = lerp(_MirrorAlpha, _MirrorAlpha * _MirrorFadeAlpha, t);
        o.normal.w = a;     // 透明度我们存于o.normal.w
        o.wPos.w = nd;      // 距离存于o.wPos.w
        o.uv = v.uv;
        
        return o;
    }
    fixed4 frag_mirror (v2f_m i) : SV_Target {
        if (i.wPos.w > _MirrorRange) discard;       // 超过镜像范围也丢弃
        if (i.normal.w <= 0) discard;               // 透明度为0丢弃

        float3 dir = i.wPos.xyz - p;                // 平面与插值点的指向
        half d = dot(dir, n);                       // 与反向镜面的距离
        if (d > 0) discard;                         // 如果超过了平面，那就丢弃

        fixed2 ouvxy = fixed2( // 噪点图采样，用于主纹理的UV偏移的
            tex2D(_NoiseTex, i.uv + fixed2(_Time.x * _NoiseSpeedX, 0)).r,
            tex2D(_NoiseTex, i.uv + fixed2(0, _Time.x * _NoiseSpeedY)).r);
        ouvxy -= _NoiseBrightOffset; // 0~1 to ==> -_NoiseBrightOffset~ 1 - _NoiseBrightOffset
        ouvxy *= fixed2(_NoiseScaleX, _NoiseScaleY);    // 扰动放大系数
        
        float scale = i.wPos.w / _MirrorRange;          // 用距离来作为扰动衰减
        scale = lerp(scale, 1, (1 - _NoiseFalloff));    // 距离越近扰动越是衰减（即：与镜面距离越近，基本是不扰动的，所以我们可以看到边缘与镜面的像素是吻合的）
        ouvxy *= scale;
        
        fixed4 col = tex2D(_MainTex, i.uv + ouvxy);     // 加上扰动UV后再采样主纹理
        return fixed4(col.rgb, i.normal.w);
    }
    ENDCG
    SubShader {
        Tags { "Queue"="Geometry+2" "RenderType"="Opaque" }
        Pass {
            Cull front
            ZTest Always
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Stencil {
                Ref 1
                Comp Equal
            }
            CGPROGRAM
            #pragma vertex vert_mirror
            #pragma fragment frag_mirror
            ENDCG
        }
        Pass {
            CGPROGRAM
            #pragma vertex vert_normal
            #pragma fragment frag_normal
            ENDCG
        }
    }
}
