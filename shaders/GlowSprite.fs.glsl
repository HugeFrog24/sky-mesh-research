#version 460

layout(location = 1) in vec2 _67;
layout(location = 0) in vec4 _78;
layout(location = 2) in vec4 _86;
layout(location = 0) out vec4 _106;

void main()
{
    vec2 _65 = _67;
    _65.y = 1.0 - _65.y;
    vec2 _87 = _65;
    float _89 = _86.x;
    float _92 = _86.y;
    float _95 = _86.z;
    float _132;
    if (_95 > 0.5)
    {
        _132 = dot(_87 - vec2(0.5), _87 - vec2(0.5)) * 3.0;
    }
    else
    {
        _132 = abs(abs(_87.x - 0.5) - 0.5) * 2.0;
    }
    float _131 = _132;
    float _133;
    if (_95 > 0.5)
    {
        _133 = 1.0 - smoothstep(_89, _92, _131);
    }
    else
    {
        _133 = pow(smoothstep(_89, _92, _131), 2.0);
    }
    float _134 = _133;
    vec4 _76 = vec4(_78.xyz, _78.w * _134);
    _106 = _76;
}

