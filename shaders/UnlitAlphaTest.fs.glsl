#version 460

layout(binding = 0, std140) uniform _94_96
{
    vec4 _m0;
} _96;

layout(binding = 3) uniform sampler2D _76;

layout(location = 2) in vec3 _39;
layout(location = 1) in vec3 _48;
layout(location = 3) in vec2 _66;
layout(location = 0) in vec4 _71;
layout(location = 0) out vec4 _152;

void main()
{
    vec2 _64 = _66;
    vec4 _69 = _71 * texture(_76, _64);
    vec4 _81 = _69;
    vec3 _83 = vec3(0.0);
    float _85 = dot(_69.xyz, vec3(0.2989999949932098388671875, 0.58700001239776611328125, 0.114000000059604644775390625));
    bool _103 = _96._m0.x > 0.0;
    bool _112;
    if (_103)
    {
        _112 = _85 > (1.0 - _96._m0.x);
    }
    else
    {
        _112 = _103;
    }
    if (_112)
    {
        _83 = ((_69.xyz * _96._m0.y) * ((_85 - 1.0) + _96._m0.x)) / vec3(_96._m0.x);
    }
    _83 *= (1.0 + _96._m0.z);
    vec3 _140 = _81.xyz + _83;
    _81 = vec4(_140.x, _140.y, _140.z, _81.w);
    if (_81.w < 0.5)
    {
        discard;
    }
    float _161 = 1.0 / gl_FragCoord.w;
    float _162 = 1000.0;
    float _184 = max(0.0, _161 * (_162 * 6.6666667407844215631484985351562e-05));
    _152 = vec4(_81.xyz, _184);
}

