#version 330 core
#include hg_sdf.glsl

layout(location = 0) out vec4 fragColor;
uniform vec2 u_resolution;
uniform vec2 u_mouse;

const float FOV = 1.0;
const int MAX_STEPS = 256;
const float MAX_DIST = 500.0;
const float EPSILON = 0.001;

vec2 fOpUnionId(vec2 res1, vec2 res2) {
    return res1.x < res2.x ? res1 : res2;
}
vec2 map(vec3 p) {
    // floor
    float planeDist = fPlane(p, vec3(0.0, 1.0, 0.0), 1.0);
    float planeId = 2.0;
    vec2 plane = vec2(planeDist, planeId);
    // sphere
    float sphereDist = fSphere(p, 1.0);
    float sphereId = 1.0;
    vec2 sphere = vec2(sphereDist, sphereId);
    // final
    vec2 res = fOpUnionId(plane, sphere);
    return res;
}
vec2 ray_marching(vec3 ro, vec3 rd) {
    // {delta_distanse, current_id}
    vec2 hit;
    // {distance, id}
    vec2 object = vec2(0.0); 
    for (int i = 0; i < MAX_STEPS; i++) {
        // current position of ray
        vec3 p = ro + object.x * rd;
        hit = map(p);
        // update distance and id
        object.x += hit.x;
        object.y = hit.y;
        // check border conditions
        if (abs(hit.x) < EPSILON || abs(object.x) > MAX_DIST)
            break;
    }
    return object;
}
vec3 getNormal(vec3 p) {
    vec2 e = vec2(EPSILON, 0.0);
    // do some hack: get normilize((dx,dy,dz)) ~ real normal
    vec3 n = vec3(map(p).x) - vec3(map(p - e.xyy).x, map(p - e.yxy).x, map(p - e.yyx).x);
    return normalize(n);
}
vec3 getLight(vec3 p, vec3 rd, vec3 color) {
    // light position {x, y, z}
    vec3 lightPos = vec3(40.0, 20.0, -30.0);
    // normal from surface of object to light
    vec3 L = normalize(lightPos - p);
    // normal for point on surface
    vec3 N = getNormal(p);

    vec3 V = -rd;
    vec3 R = reflect(-L, N);
    vec3 specColor = vec3(0.5);
    vec3 specular = specColor * pow(clamp(dot(R, V), 0.0, 1.0), 10.0);
    vec3 ambient = color * 0.05;
    // Lambert's law 
    // clamp(minVal, maxVal) <=> min(max(x, minVal), maxVal)
    float lambert = dot(L,N);
    // diffuse light based on Lambert's law 
    vec3 diffuse = color * clamp(lambert, 0.0, 1.0);

    // shadows: cast new rays from point on surface to light
    float d = ray_marching(p + N * 0.02, normalize(lightPos)).x;
    // compare d and distance from light to surface
    if (d < length(lightPos - p)) 
        return ambient;

    return diffuse + ambient + specular;
}
vec3 get_material(vec3 p, float id) {
    vec3 m = vec3(0.0);
    // table colors of all objects
    switch (int(id)) {
        case 1: 
            m = vec3(0.9, 0.9, 0.0); 
            break;
        case 2: 
            m = vec3(0.2 + 0.4 * mod(floor(p.x) + floor(p.z), 2)); 
            break;
    }
    return m;
}
mat3 getcamera(vec3 ro, vec3 lookAt) {
    vec3 camF = normalize(vec3(lookAt - ro));
    vec3 camR = normalize(cross(vec3(0,1,0), camF));
    vec3 camU = cross(camF, camR);
    return mat3(camR, camU, camF);
}
void mouse_control(inout vec3 ro) {
    vec2 m = u_mouse / u_resolution;
    pR(ro.yz, m.y * PI * 0.5 - 0.5);
    pR(ro.xz, m.x * TAU);
}
void render(inout vec3 col, in vec2 uv) {
    // ro (ray origin) - camera position
    vec3 ro = vec3(3.0, 3.0, -3.0);
    mouse_control(ro);
    vec3 lookAt = vec3(0.0, 0.0, 0.0);

    // rd (ray direction) - cast ray in objects for projection color on screen
    vec3 rd = getcamera(ro, lookAt) * normalize(vec3(uv, FOV));
    // object = {distance_to_object, id_object}
    vec2 object = ray_marching(ro, rd);
    // color of sky
    vec3 background = vec3(0.5, 0.8, 0.9);

    // check existance of intersection
    if (object.x < MAX_DIST) {
        // point on surface in object
        vec3 p = ro + object.x * rd;
        // get color object assosiated with {id_object}
        vec3 material = get_material(p, object.y);
        // light + shadows
        col += getLight(p, rd, material);

        // add fog on horizont
        col = mix(col, background, 1.0 - exp(-0.0008 * object.x * object.x)); 
    } else {
        // ??
        col += background - max(0.95 * rd.y, 0.0);
    }
}
void main() {
    // uv ([-k,k], [-1,1]) with center in screen center
    vec2 uv = (2.0 * gl_FragCoord.xy - u_resolution.xy) / u_resolution.y;
    // default color is black
    vec3 col = vec3(0.0); 
    // render scene
    render(col, uv);
    // Gamma correction (default coeff = 0.4545)
    col = pow(col, vec3(0.4545));

    fragColor = vec4(col, 1.0);
}