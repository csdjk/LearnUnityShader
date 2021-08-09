
reflect
float3 Shade(inout Ray ray, RayHit hit)
{
	float3 normalDir = normalize(f.worldNormal);
    float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
    float3 diffuse = _LightColor0.rgb * max(dot(normalDir,lightDir),0) * _Diffuse.rgb;

}



float3 Shade(inout Ray ray, RayHit hit, int depth)
{
    
    if (hit.distance < 1.#INF && depth < (_TraceCount - 1))
    {
        float3 specular = float3(0, 0, 0);
        
        float eta;
        float3 normal;
        
        // out
        if (dot(ray.direction, hit.normal) > 0)
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
        
        ray.origin = hit.position - normal * 0.001f;
        
        float3 refractRay;
        float refracted = Refract(ray.direction, normal, eta, refractRay);
        
        if (depth == 0.0)
        {
            float3 reflectDir = reflect(ray.direction, hit.normal);
            reflectDir = normalize(reflectDir);
            
            float3 reflectProb = FresnelSchlick(normal, ray.direction, eta) * _Specular;
            specular = SampleCubemap(reflectDir) * reflectProb;
            ray.energy *= 1 - reflectProb;
        }
        else
        {
            ray.absorbDistance += hit.distance;
        }
        
        // Refraction
        if (refracted == 1.0)
        {
            ray.direction = refractRay;
        }
        // Total Internal Reflection
        else
        {
            ray.direction = reflect(ray.direction, normal);
        }
        
        ray.direction = normalize(ray.direction);
        
        return specular;
    }
    else
    {
        ray.energy = 0.0f;

        float3 cubeColor = SampleCubemap(ray.direction);
        float3 absorbColor = float3(1.0, 1.0, 1.0) - _Color;
        float3 absorb = exp(-absorbColor * ray.absorbDistance * _AbsorbIntensity);

        return cubeColor * absorb * _ColorMultiply + _ColorAdd * _Color;
    }
}

