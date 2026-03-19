#version 460

layout(binding = 0, std140) uniform _105_107
{
    vec4 _m0;
} _107;

layout(binding = 3) uniform sampler2D _74;
layout(binding = 4) uniform sampler2D _80;

layout(location = 2) in vec3 _39;
layout(location = 1) in vec3 _48;
layout(location = 3) in vec4 _66;
layout(location = 0) in vec4 _69;
layout(location = 0) out vec4 _161;

void main()
{
    vec4 _64 = _66;
    vec4 _68 = _69 * texture(_74, _64.xy);
    _68.w += texture(_80, _64.zw).w;
    vec4 _92 = _68;
    vec3 _94 = vec3(0.0);
    float _96 = dot(_68.xyz, vec3(0.2989999949932098388671875, 0.58700001239776611328125, 0.114000000059604644775390625));
    bool _113 = _107._m0.x > 0.0;
    bool _122;
    if (_113)
    {
        _122 = _96 > (1.0 - _107._m0.x);
    }
    else
    {
        _122 = _113;
    }
    if (_122)
    {
        _94 = ((_68.xyz * _107._m0.y) * ((_96 - 1.0) + _107._m0.x)) / vec3(_107._m0.x);
    }
    _94 *= (1.0 + _107._m0.z);
    vec3 _150 = _92.xyz + _94;
    _92 = vec4(_150.x, _150.y, _150.z, _92.w);
    if (_92.w < 0.5)
    {
        discard;
    }
    float _170 = 1.0 / gl_FragCoord.w;
    float _171 = 1000.0;
    float _193 = max(0.0, _170 * (_171 * 6.6666667407844215631484985351562e-05));
    _161 = vec4(_92.xyz, _193);
}

