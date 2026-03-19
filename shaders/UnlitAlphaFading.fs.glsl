#version 460

layout(binding = 0, std140) uniform _119_121
{
    vec4 _m0;
    vec2 _m1;
    float _m2;
    float _m3;
} _121;

layout(binding = 3) uniform sampler2D _101;

layout(location = 2) in vec3 _64;
layout(location = 1) in vec3 _73;
layout(location = 3) in vec2 _91;
layout(location = 0) in vec4 _96;
layout(location = 0) out vec4 _230;
layout(location = 1) out vec4 _239;

void main()
{
    float _62 = length(_64);
    vec3 _67 = _64 / vec3(_62);
    vec3 _72 = normalize(_73);
    vec2 _89 = _91;
    vec4 _94 = _96 * texture(_101, _89);
    vec4 _106 = _94;
    vec3 _108 = vec3(0.0);
    float _110 = dot(_94.xyz, vec3(0.2989999949932098388671875, 0.58700001239776611328125, 0.114000000059604644775390625));
    bool _128 = _121._m0.x > 0.0;
    bool _136;
    if (_128)
    {
        _136 = _110 > (1.0 - _121._m0.x);
    }
    else
    {
        _136 = _128;
    }
    if (_136)
    {
        _108 = ((_94.xyz * _121._m0.y) * ((_110 - 1.0) + _121._m0.x)) / vec3(_121._m0.x);
    }
    _108 *= (1.0 + _121._m0.z);
    vec3 _164 = _106.xyz + _108;
    _106 = vec4(_164.x, _164.y, _164.z, _106.w);
    float _167 = dot(_72, _67);
    if (_121._m3 >= 0.0)
    {
        _106.w *= mix(1.0, pow(abs(_167), 3.0), _121._m3);
    }
    else
    {
        _106.w *= mix(1.0, pow(1.0099999904632568359375 - abs(_167), 3.0), -_121._m3);
    }
    _106.w *= (1.0 - _121._m2);
    float _213 = _62;
    float _215 = _121._m1.x;
    float _218 = _121._m1.y;
    float _268 = clamp((_213 * (1.0 / (_218 - _215))) - (_215 / (_218 - _215)), 0.0, 1.0);
    float _211 = _268;
    _106.w *= (_211 * _211);
    _230 = vec4(_106.xyz, _106.w);
    float _246 = 1.0 / gl_FragCoord.w;
    float _247 = 256.0;
    float _283 = max(log(_246 * 20.0) * (_247 * 0.079292468726634979248046875), 0.0);
    _239 = vec4(_283, 0.0, 0.0, _106.w);
}

