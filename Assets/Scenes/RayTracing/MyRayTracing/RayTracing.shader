Shader "Unlit/RayTracing"
{
    Properties
    {
        _TraceCount ("Trace Count", Int) = 5
        _Color ("Color", Color) = (1, 1, 1, 1)
        _SkyBox("Sky Box",Cube) = "black"{}
        _IOR ("IOR", Range(1, 5)) = 2.417
        _Specular ("Specular", Range(0, 1)) = 1.0
        _AbsorbIntensity ("Absorb Intensity", Range(0, 10)) = 1.0
        _Gloss("Gloss",Range(8,200)) = 10
        _FresnelScale ("Fresnel Scale", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"= "Geometry+500" }
        LOD 100
        ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma target 5.0
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct a2v {
                float4 vertex : POSITION;
                fixed3 normal : NORMAL;
                fixed2 uv : TEXCOORD0;
            };

            struct v2f 
            {
                float4 pos : POSITION;
                fixed2 uv : TEXCOORD0;
                fixed3 vertex : TEXCOORD1;
                float3 ray : TEXCOORD2;
            };

            
            float _Specular;
            float3 _LightPos;
            float _IOR;
            int _TraceCount;
            samplerCUBE _SkyBox;
            float3 _Color;
            float _AbsorbIntensity;
            half _Gloss;
            fixed _FresnelScale;

            uniform float4 _Vertices[800];

            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.vertex = v.vertex;
                o.uv = v.uv;

                float4 cameraRay = mul(unity_CameraInvProjection, float4(v.uv * 2 - 1, 1, 1));
                cameraRay.z *= -1;
                o.ray = cameraRay.xyz / cameraRay.w;

                return o;
            }            
            
            // ------------------------------Ray Tracing--------------------------
            const float noIntersectionT = 1.#INF;

            struct Light 
            {
                float3 position;
                float3 color;
            };
            struct Ray
            {
                float3 origin;
                float3 direction;
                float3 energy;
                float absorbDistance;
            };
            struct Intersection 
            {
                float3 position;
                float distance;
                float3 normal;
                bool inside;
            };
            
            Intersection CreateIntersection() 
            {
                Intersection intersection;
                intersection.position = float3(0.0, 0.0, 0.0);
                intersection.distance = noIntersectionT;
                intersection.normal = float3(0.0, 0.0, 0.0);
                intersection.inside = false;
                return intersection;
            }
            bool hasIntersection(Intersection i) 
            {
                return i.distance != noIntersectionT;
            }
            float4 GetSkyColor(fixed3 direction)
            {
                fixed4  spec_env = texCUBE(_SkyBox, direction);
                return fixed4(spec_env.xyz, 1);
            }

            Ray CreateRay(float3 origin, float3 direction)
            {
                Ray ray;
                ray.origin = origin;
                ray.direction = direction;
                ray.energy = float3(1.0f, 1.0f, 1.0f);
                ray.absorbDistance = 0;
                return ray;
            }

            //射线和圆求交
            bool IntersectSphere(float3 orig, float3 dir, float3 sphereOrig, float radius)
            {
                float t0, t1, t;
                
                float3 l = sphereOrig - orig;
                float tca = dot(l, dir);
                //if ( tca < 0.0 )
                //return false;
                float d2 = dot (l, l) - (tca * tca);
                float r2 = radius*radius;
                if ( d2 > r2 )
                return false;
                else
                return true;
            }
            //射线和三角形求交
            bool IntersectTriangle(float4 orig, float4 dir,
            float4 v0, float4 v1, float4 v2, inout Intersection intersection)
            {
                float t, u, v;

                // E1
                float4 E1 = v1 - v0;
                
                // E2
                float4 E2 = v2 - v0;
                
                // P
                float4 P = float4(cross(dir,E2), 1);
                
                // determinant
                float det = dot(E1,P);
                
                // keep det > 0, modify T accordingly
                float4 T;
                if( det >0 )
                {
                    T = orig - v0;
                }
                else
                {
                    T = v0 - orig;
                    det = -det;
                }
                
                // If determinant is near zero, ray lies in plane of triangle
                if( det < 0.0001f )
                return false;
                
                // Calculate u and make sure u <= 1
                u = dot(T,P);
                if( u < 0.0f || u > det )
                return false;
                
                // Q
                float4 Q = float4(cross(T,E1), 1);
                
                // Calculate v and make sure u + v <= 1
                v = dot(dir,Q);
                if( v < 0.0f || u + v > det )
                return false;
                
                // Calculate t, scale parameters, ray intersects triangle
                t = dot(E2,Q);
                
                float fInvDet = 1.0f / det;
                t *= fInvDet;
                u *= fInvDet;
                v *= fInvDet;

                intersection.position = orig + dir * t;
                intersection.distance = t;
                intersection.normal = normalize(cross(E1,E2));
                intersection.inside = dot(intersection.normal, dir) > 0;

                return true;
            }

            //求射线和场景最近的交点
            bool HitScene(Ray ray, inout Intersection minIntersection)
            {
                bool hitAnything = false;

                for (int i = 0; i < 700;)
                {
                    // 物体的顶点数量
                    int length = _Vertices[i+1].x;

                    if (length == 0)
                    break;
                    
                    // 包围求中心
                    half3 sphereOrig = _Vertices[i].xyz;
                    // 包围球半径
                    half radius = _Vertices[i].w;

                    i += 2;

                    // 检测射线和包围球是否相交
                    if (IntersectSphere(ray.origin, ray.direction, sphereOrig, radius))
                    {
                        // 遍历所有顶点
                        for (int j = 0; j < length; j+=3)
                        {
                            Intersection intersection = CreateIntersection();
                            float4 v0 = float4(_Vertices[i+j].xyz, 1);
                            float4 v1 = float4(_Vertices[i + j + 1].xyz, 1);
                            float4 v2 = float4(_Vertices[i + j + 2].xyz, 1);

                            if (IntersectTriangle(float4(ray.origin, 1), float4(ray.direction, 0), v0,v1 ,v2 , intersection) && intersection.distance > 0.001)
                            {
                                hitAnything = true;

                                if ((!hasIntersection(minIntersection) || intersection.distance < minIntersection.distance))
                                {
                                    // matIndex = _Vertices[i + j].w;
                                    minIntersection = intersection;
                                    // if(minIntersection.inside == inGeometry)
                                    // break;
                                }
                            }
                        }
                    }
                    // 该物体检测结束,开始下一个物体
                    i += length;
                }
                return hitAnything;
            }
            
            // 
            float3 lighting(Ray ray, Intersection intersection)
            {
                Light light;
                light.position = _LightPos;
                light.color = float3(1,1,1);
                
                float3 normal = intersection.normal *(intersection.inside ? -1 : 1);



                float2 uv = intersection.position.xz;

                float3 lightDir = normalize(light.position - intersection.position);
                float3 eyeDir = normalize(_WorldSpaceCameraPos - intersection.position);
                // diffuse
                float3 diffuse = light.color * max(dot(normal, lightDir), 0.0);
                float3 reflected = normalize(reflect(-lightDir, normal));

                // BlinnPhong
                fixed3 halfDir = normalize(lightDir+eyeDir);
                fixed3 specular = light.color * pow(max(0,dot(normal,halfDir)),1) * _Specular;
                
                return diffuse+specular;
            }
            
            float Refract(float3 i, float3 n, float eta, inout float3 o)
            {
                float cosi = dot(-i, n);
                float cost2 = 1.0f - eta * eta * (1 - cosi * cosi);
                
                o = eta * i + ((eta * cosi - sqrt(cost2)) * n);
                return 1 - step(cost2, 0);
            }

            float FresnelSchlick(float3 normal, float3 incident, float ref_idx)
            {
                float cosine = dot(-incident, normal);
                float r0 = (1 - ref_idx) / (1 + ref_idx); // ref_idx = n2/n1
                r0 = r0 * r0;
                float ret = r0 + (1 - r0) * pow((1 - cosine), 5);
                return ret;
            }
            // 着色
            float3 Shade(inout Ray ray, Intersection hit,int depth)
            {
                // 有交点
                if(hasIntersection(hit)){
                    Light light;
                    light.position = _LightPos;
                    light.color = float3(1,1,1);
                    
                    float3 lightDir = normalize(light.position - hit.position);

                    float3 normal;
                    float eta;
                    if (hit.inside)
                    {
                        normal = -hit.normal;
                        eta = _IOR;
                    }
                    // in
                    else
                    {
                        normal = hit.normal;
                        eta = 1.0 / _IOR;
                    }

                    float3 viewDir = normalize(_WorldSpaceCameraPos - hit.position);
                    float3 diffuse = max(dot(normal, lightDir),0.0);

                    fixed3 halfDir = normalize(lightDir+viewDir);
                    fixed3 specular = light.color * pow(max(0,dot(normal,halfDir)),_Gloss) * _Specular;

                    // 折射
                    float3 refractRay;
                    float refracted = Refract(ray.direction, normal, eta, refractRay);

                    // 菲涅尔
                    fixed fresnel = _FresnelScale + (1 - _FresnelScale) * pow(1 - saturate(dot(viewDir, normal)), 5);

                    float3 reflectDir = reflect(ray.direction, hit.normal);
                    reflectDir = normalize(reflectDir);

                    specular =lerp(diffuse, GetSkyColor(reflectDir), saturate(fresnel));

                    // 继续光线追踪
                    ray.origin = hit.position;
                    if (refracted == 1.0)
                    ray.direction = refractRay;
                    else
                    ray.direction = reflect(ray.direction, normal);

                    // 能量
                    float3 subEnergy = float3(0.2f, 0.2f, 0.2f);

                    ray.energy *= subEnergy;
                    // ray.energy *= 1 - fresnel;
                    return diffuse;
                }
                // 无交点
                else{
                    ray.energy = 0;
                    float3 cubeColor = GetSkyColor(ray.direction);
                    return cubeColor;
                }


                // if (hasIntersection(hit) && depth < (_TraceCount - 1)){
                    //     float3 specular = float3(0, 0, 0);
                    
                    //     float3 normal;
                    //     // 折射率
                    //     float eta;
                    //     // out
                    //     if (hit.inside)
                    //     {
                        //         normal = -hit.normal;
                        //         eta = _IOR;
                    //     }
                    //     // in
                    //     else
                    //     {
                        //         normal = hit.normal;
                        //         eta = 1.0 / _IOR;
                    //     }

                    //     ray.origin = hit.position - normal * 0.001f;
                    
                    //     float3 refractRay;
                    //     float refracted = Refract(ray.direction, normal, eta, refractRay);
                    
                    //     if (depth == 0.0)
                    //     {
                        //         float3 reflectDir = reflect(ray.direction, hit.normal);
                        //         reflectDir = normalize(reflectDir);
                        
                        //         float3 reflectProb = FresnelSchlick(normal, ray.direction, eta) * _Specular;
                        //         specular = GetSkyColor(reflectDir) * reflectProb;
                        //         ray.energy *= 1 - reflectProb;
                    //     }
                    //     else
                    //     {
                        //         ray.absorbDistance += hit.distance;
                    //     }
                    
                    //     // Refraction
                    //     if (refracted == 1.0)
                    //     {
                        //         ray.direction = refractRay;
                    //     }
                    //     // Total Internal Reflection
                    //     else
                    //     {
                        //         ray.direction = reflect(ray.direction, normal);
                    //     }
                    
                    //     ray.direction = normalize(ray.direction);
                    
                    //     return _Specular;
                    //     // return specular;


                // }
                // else
                // {
                    //     ray.energy = 0.0f;

                    //     float3 cubeColor = GetSkyColor(ray.direction);
                    //     float3 absorbColor = float3(1.0, 1.0, 1.0) - _Color;
                    //     float3 absorb = exp(-absorbColor * ray.absorbDistance * _AbsorbIntensity);

                    //     return cubeColor * absorb  +  _Color;
                // }
                
            }


            Intersection TraceRay(Ray ray)
            {
                Ray rayTemp = ray;
                Intersection intersection = CreateIntersection();
                HitScene(rayTemp, intersection);
                return intersection;
            }
            


            fixed4 frag (v2f i) : SV_Target
            {
                float4 viewPos = float4(i.ray, 1);
                float4 worldPos = mul(unity_CameraToWorld, viewPos);
                float3 viewDir = normalize(_WorldSpaceCameraPos - worldPos);
                
                float4 origin = float4(_WorldSpaceCameraPos,1);
                float4 dir = float4(-viewDir, 0);

                Ray ray = CreateRay(origin.xyz,dir.xyz);
                float3 result = float3(0, 0, 0);

                // [unroll(10)]
                for (int i = 0; i < _TraceCount; i ++)
                {
                    Intersection hit = TraceRay(ray);
                    result += ray.energy*Shade(ray, hit,i);
                }

                // Intersection hit = TraceRay(ray);
                // result += Shade(ray, hit,0);
                return half4(result, 1);
            }
            
            ENDCG
        }
    }
}
