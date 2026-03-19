#version 460

layout(binding = 0, std140) uniform _108_110
{
    vec4 _m0;
    float _m1;
    float _m2;
} _110;

layout(binding = 3) uniform sampler2D _77;
layout(binding = 4) uniform sampler2D _83;

layout(location = 2) in vec3 _42;
layout(location = 1) in vec3 _51;
layout(location = 3) in vec4 _69;
layout(location = 0) in vec4 _72;
layout(location = 0) out vec4 _200;
layout(location = 1) out vec4 _209;

void main()
{
    float _40 = length(_42);
    vec3 _45 = _42 / vec3(_40);
    vec3 _50 = normalize(_51);
    vec4 _67 = _69;
    vec4 _71 = _72 * texture(_77, _67.xy);
    _71.w *= texture(_83, _67.zw).w;
    vec4 _95 = _71;
    vec3 _97 = vec3(0.0);
    float _99 = dot(_71.xyz, vec3(0.2989999949932098388671875, 0.58700001239776611328125, 0.114000000059604644775390625));
    bool _116 = _110._m0.x > 0.0;
    bool _125;
    if (_116)
    {
        _125 = _99 > (1.0 - _110._m0.x);
    }
    else
    {
        _125 = _116;
    }
    if (_125)
    {
        _97 = ((_71.xyz * _110._m0.y) * ((_99 - 1.0) + _110._m0.x)) / vec3(_110._m0.x);
    }
    _97 *= (1.0 + _110._m0.z);
    vec3 _153 = _95.xyz + _97;
    _95 = vec4(_153.x, _153.y, _153.z, _95.w);
    float _156 = dot(_50, _45);
    if (_110._m2 >= 0.0)
    {
        _95.w *= mix(1.0, pow(abs(_156), 3.0), _110._m2);
    }
    else
    {
        _95.w *= mix(1.0, pow(1.0099999904632568359375 - abs(_156), 3.0), -_110._m2);
    }
    _95.w *= (1.0 - _110._m1);
    _200 = vec4(_95.xyz, _95.w);
    float _216 = 1.0 / gl_FragCoord.w;
    float _217 = 256.0;
    float _238 = max(log(_216 * 20.0) * (_217 * 0.079292468726634979248046875), 0.0);
    _209 = vec4(_238, 0.0, 0.0, _95.w);
}

