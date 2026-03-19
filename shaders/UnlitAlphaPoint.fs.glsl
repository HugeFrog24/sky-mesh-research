#version 460

layout(binding = 0, std140) uniform _32_34
{
    vec4 _m0;
    float _m1;
    float _m2;
    float _m3;
    vec4 _m4;
} _34;

layout(binding = 4) uniform sampler2D _53;
layout(binding = 3) uniform sampler2D _116;

layout(location = 2) in vec3 _84;
layout(location = 1) in vec3 _93;
layout(location = 3) in vec2 _109;
layout(location = 0) in vec4 _114;
layout(location = 0) out vec4 _227;
layout(location = 1) out vec4 _236;

void main()
{
    float _82 = length(_84);
    vec3 _87 = _84 / vec3(_82);
    vec3 _92 = normalize(_93);
    vec2 _108 = _109;
    vec4 _112 = _114 * texture(_116, _108);
    vec4 _121 = _112;
    vec3 _123 = vec3(0.0);
    float _125 = dot(_112.xyz, vec3(0.2989999949932098388671875, 0.58700001239776611328125, 0.114000000059604644775390625));
    bool _138 = _34._m0.x > 0.0;
    bool _147;
    if (_138)
    {
        _147 = _125 > (1.0 - _34._m0.x);
    }
    else
    {
        _147 = _138;
    }
    if (_147)
    {
        _123 = ((_112.xyz * _34._m0.y) * ((_125 - 1.0) + _34._m0.x)) / vec3(_34._m0.x);
    }
    _123 *= (1.0 + _34._m0.z);
    vec3 _175 = _121.xyz + _123;
    _121 = vec4(_175.x, _175.y, _175.z, _121.w);
    float _178 = dot(_92, _87);
    if (_34._m2 >= 0.0)
    {
        _121.w *= mix(1.0, pow(abs(_178), 3.0), _34._m2);
    }
    else
    {
        _121.w *= mix(1.0, pow(1.0099999904632568359375 - abs(_178), 3.0), -_34._m2);
    }
    _121.w *= (1.0 - _34._m1);
    vec2 _265 = _34._m4.xy + (gl_PointCoord * _34._m4.zw);
    float _266 = texture(_53, _265).w;
    float _267 = (_266 * _266) * _34._m3;
    _121.w *= _267;
    _227 = vec4(_121.xyz, _121.w);
    float _243 = 1.0 / gl_FragCoord.w;
    float _244 = 256.0;
    float _288 = max(log(_243 * 20.0) * (_244 * 0.079292468726634979248046875), 0.0);
    _236 = vec4(_288, 0.0, 0.0, _121.w);
}

