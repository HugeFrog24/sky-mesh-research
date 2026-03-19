#version 460

layout(location = 2) in vec4 _64;
layout(location = 3) in float _69;
layout(location = 1) in vec2 _158;
layout(location = 0) in vec4 _166;
layout(location = 0) out vec4 _173;

void main()
{
    vec2 _156 = _158;
    _156.y = 1.0 - _156.y;
    vec2 _168 = _156;
    vec2 _199 = vec2(0.5) - _168;
    float _200 = length(_199) * 2.0;
    float _201 = 1.0 - smoothstep(_64.z - _69, _64.z + _69, _200);
    float _202 = 1.0 - smoothstep(_64.w - _69, _64.w + _69, _200);
    vec2 _203 = (_168 * 2.0) - vec2(1.0);
    vec2 _205 = _203;
    vec2 _291 = vec2(0.0, 1.0);
    float _292 = dot(_291, _205) * inversesqrt(dot(_205, _205));
    float _293 = acos(_292);
    _293 *= 57.297466278076171875;
    if (_205.x < 0.0)
    {
        _293 = 360.0 - _293;
    }
    float _294 = _293;
    float _204 = _294;
    float _246 = _69 * 90.0;
    float _206 = smoothstep(_204 - _246, _204 + _246, _64.x);
    float _207 = smoothstep(_204 - _246, _204 + _246, _64.y);
    float _208 = (_201 * _206) - _202;
    float _209;
    if (_64.x < _64.y)
    {
        _209 = _201 - (_201 * _207);
    }
    else
    {
        _209 = -_207;
    }
    _208 += _209;
    float _210 = clamp(_208, 0.0, 1.0);
    vec4 _165 = _166 * _210;
    _173 = _165;
}

