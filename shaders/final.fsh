#version 120

varying vec4 texcoord;
uniform sampler2D gcolor;
uniform int worldTime;

uint hash(uint x) {
    x += (x << 10u);
    x ^= (x >>  6u);
    x += (x <<  3u);
    x ^= (x >> 11u);
    x += (x << 15u);
    return x;
}

uint hash(uvec2 v) { return hash(v.x ^ hash(v.y)); }
uint hash(uvec3 v) { return hash(v.x ^ hash(v.y) ^ hash(v.z)); }
uint hash(uvec4 v) { return hash(v.x ^ hash(v.y) ^ hash(v.z) ^ hash(v.w)); }

float floatConstruct(uint m) {
    m &= 0x007FFFFFu;
    m |= 0x3F800000u;
    return uintBitsToFloat(m) - 1.0;
}

float random(vec3 v) { return floatConstruct(hash(floatBitsToUint(v))); }

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
    vec2 point = texcoord.st;
    vec3 color = texture2D(gcolor, point).rgb;
    color.rgb *= hsv2rgb(vec3(random(worldTime % 20 / 20.0 * color), 1.0, 1.0));
    gl_FragColor = vec4(color, 1.0);
}