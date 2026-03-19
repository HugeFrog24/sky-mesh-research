#version 460

layout(binding = 0) uniform sampler2D _76;

layout(location = 2) in vec3 _39;
layout(location = 1) in vec3 _48;
layout(location = 3) in vec2 _66;
layout(location = 0) in vec4 _71;
layout(location = 0) out vec4 _84;

void main()
{
    vec2 _64 = _66;
    vec4 _69 = _71 * texture(_76, _64);
    vec4 _81 = _69;
    float _96 = 1.0 / gl_FragCoord.w;
    float _97 = 1000.0;
    float _119 = max(0.0, _96 * (_97 * 6.6666667407844215631484985351562e-05));
    _84 = vec4(_81.xyz, _119);
}

