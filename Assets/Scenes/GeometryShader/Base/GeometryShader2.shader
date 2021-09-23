Shader "lcl/Tessell/GeometryShader2" {
    Properties 
    { 
        _Color ("Color", Color) = (1, 1, 1, 1)
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
            //-------声明几何着色器 
            #pragma geometry geom 
            
            #include "UnityCG.cginc" 
            
            struct appdata 
            { 
                float4 vertex : POSITION; 
                float2 uv : TEXCOORD0; 
            }; 
            
            //-------顶点向几何阶段传递数据 
            struct v2g{ 
                float4 vertex:SV_POSITION; 
                float2 uv:TEXCOORD0; 
            }; 
            
            //-------几何阶段向片元阶段传递数据 
            struct g2f 
            { 
                float2 uv : TEXCOORD0; 
                float4 vertex : SV_POSITION; 
            }; 
            
            fixed4 _Color;
            
            v2g vert (appdata v) 
            { 
                v2g o; 
                o.vertex = UnityObjectToClipPos(v.vertex); 
                o.uv = v.uv; 
                return o; 
            } 
            
            //静态制定单个调用的最大顶点个数 
            // [NVIDIA08]指出，当GS输出在1到20个标量之间时，可以实现GS的性能峰值，如果GS输出在27-40个标量之间，则性能下降50％。
            [maxvertexcount(20)] 

            // 输入类型 point v2g input[1]
            // point ： 输入图元为点，1个顶点
            // line ： 输入图元为线，2个顶点
            // triangle ： 输入图元为三角形，3个顶点
            // lineadj ： 输入图元为带有邻接信息的直线，由4个顶点构成3条线
            // triangleadj ： 输入图元为带有邻接信息的三角形，由6个顶点构成

            // 输出类型  inout PointStream<g2f> outStream  可以自定义结构体，g2f、v2f...
            //inout:关键词
            //TriangleStream: 输出类型，如下：
            // PointStream ： 输出图元为点
            // LineStream ： 输出图元为线
            // TriangleStream ： 输出图元为三角形
            void geom(line v2g input[2], inout LineStream<g2f> outStream){ 
                for(int i=0;i<2;i++){ 
                    g2f o=(g2f)0; 
                    o.vertex=input[i].vertex; 
                    o.uv=input[i].uv; 
                    //-----将一个顶点添加到输出流列表 
                    outStream.Append(o); 
                } 
                
                // 对于TriangleStream ，如果需要改变输出图元，需要每输出点足够对应相应的图元后都要RestartStrip()一下再继续构成下一图元，
                // 如：tStream.RestartStrip();
                // outStream.RestartStrip(); 
            } 
            
            fixed4 frag (g2f i) : SV_Target 
            { 
                return _Color; 
            } 
            ENDCG 
        } 
    } 
}