#version 460

layout(binding = 0, std140) uniform _97_99
{
    vec4 _m0;
    float _m1;
    float _m2;
} _99;

layout(binding = 3) uniform sampler2D _79;

layout(location = 2) in vec3 _42;
layout(location = 1) in vec3 _51;
layout(location = 3) in vec2 _69;
layout(location = 0) in vec4 _74;
layout(location = 0) out vec4 _191;
layout(location = 1) out vec4 _200;

void main()
{
    float _40 = length(_42);
    vec3 _45 = _42 / vec3(_40);
    vec3 _50 = normalize(_51);
    vec2 _67 = _69;
    vec4 _72 = _74 * texture(_79, _67);
    vec4 _84 = _72;
    vec3 _86 = vec3(0.0);
    float _88 = dot(_72.xyz, vec3(0.2989999949932098388671875, 0.58700001239776611328125, 0.114000000059604644775390625));
    bool _106 = _99._m0.x > 0.0;
    bool _115;
    if (_106)
    {
        _115 = _88 > (1.0 - _99._m0.x);
    }
    else
    {
        _115 = _106;
    }
    if (_115)
    {
        _86 = ((_72.xyz * _99._m0.y) * ((_88 - 1.0) + _99._m0.x)) / vec3(_99._m0.x);
    }
    _86 *= (1.0 + _99._m0.z);
    vec3 _143 = _84.xyz + _86;
    _84 = vec4(_143.x, _143.y, _143.z, _84.w);
    float _146 = dot(_50, _45);
    if (_99._m2 >= 0.0)
    {
        _84.w *= mix(1.0, pow(abs(_146), 3.0), _99._m2);
    }
    else
    {
        _84.w *= mix(1.0, pow(1.0099999904632568359375 - abs(_146), 3.0), -_99._m2);
    }
    _84.w *= (1.0 - _99._m1);
    _191 = vec4(_84.xyz, _84.w);
    float _207 = 1.0 / gl_FragCoord.w;
    float _208 = 256.0;
    float _229 = max(log(_207 * 20.0) * (_208 * 0.079292468726634979248046875), 0.0);
    _200 = vec4(_229, 0.0, 0.0, _84.w);
}

