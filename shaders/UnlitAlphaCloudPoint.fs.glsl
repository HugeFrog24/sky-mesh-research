#version 460

layout(binding = 0, std140) uniform _60_62
{
    vec4 _m0;
    float _m1;
    float _m2;
    float _m3;
} _62;

layout(binding = 4) uniform sampler2D _49;
layout(binding = 3) uniform sampler2D _117;

layout(location = 4) in float _30;
layout(location = 2) in vec3 _85;
layout(location = 1) in vec3 _94;
layout(location = 3) in vec2 _110;
layout(location = 0) in vec4 _115;
layout(location = 0) out vec4 _227;
layout(location = 1) out vec4 _236;

void main()
{
    float _83 = length(_85);
    vec3 _88 = _85 / vec3(_83);
    vec3 _93 = normalize(_94);
    vec2 _109 = _110;
    vec4 _113 = _115 * texture(_117, _109);
    vec4 _122 = _113;
    vec3 _124 = vec3(0.0);
    float _126 = dot(_113.xyz, vec3(0.2989999949932098388671875, 0.58700001239776611328125, 0.114000000059604644775390625));
    bool _138 = _62._m0.x > 0.0;
    bool _146;
    if (_138)
    {
        _146 = _126 > (1.0 - _62._m0.x);
    }
    else
    {
        _146 = _138;
    }
    if (_146)
    {
        _124 = ((_113.xyz * _62._m0.y) * ((_126 - 1.0) + _62._m0.x)) / vec3(_62._m0.x);
    }
    _124 *= (1.0 + _62._m0.z);
    vec3 _174 = _122.xyz + _124;
    _122 = vec4(_174.x, _174.y, _174.z, _122.w);
    float _177 = dot(_93, _88);
    if (_62._m2 >= 0.0)
    {
        _122.w *= mix(1.0, pow(abs(_177), 3.0), _62._m2);
    }
    else
    {
        _122.w *= mix(1.0, pow(1.0099999904632568359375 - abs(_177), 3.0), -_62._m2);
    }
    _122.w *= (1.0 - _62._m1);
    float _264 = _30;
    vec2 _265 = (gl_PointCoord * vec2(1.0, 0.25)) + vec2(0.0, _264);
    float _266 = texture(_49, _265).x;
    float _267 = (_266 * _266) * _62._m3;
    _122.w *= _267;
    _227 = vec4(_122.xyz, _122.w);
    float _242 = 1.0 / gl_FragCoord.w;
    float _243 = 256.0;
    float _285 = max(log(_242 * 20.0) * (_243 * 0.079292468726634979248046875), 0.0);
    _236 = vec4(_285, 0.0, 0.0, _122.w);
}

