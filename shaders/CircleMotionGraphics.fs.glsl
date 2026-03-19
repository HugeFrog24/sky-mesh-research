#version 460

layout(location = 2) in vec4 _69;
layout(location = 3) in float _74;
layout(location = 1) in vec2 _132;
layout(location = 0) in vec4 _140;
layout(location = 0) out vec4 _155;

void main()
{
    vec2 _130 = _132;
    _130.y = 1.0 - _130.y;
    vec2 _146 = _130;
    vec3 _180 = vec3(0.0);
    vec2 _181 = vec2(0.5) - _146;
    float _182 = 0.0;
    float _183 = length(_181) * 2.0;
    float _184 = _69.x;
    _180 = vec3(1.0 - smoothstep(_184 - _74, _184 + _74, _183));
    _182 = _180.x;
    vec2 _185 = (_146 * 2.0) - vec2(1.0);
    vec2 _187 = _185;
    vec2 _244 = vec2(0.0, 1.0);
    float _245 = atan(_244.y, _244.x) - atan(_187.y, _187.x);
    _245 *= 57.297466278076171875;
    if (_245 < 0.0)
    {
        _245 += 360.0;
    }
    float _246 = _245;
    float _186 = _246;
    float _218 = _74 * 90.0;
    float _231 = _74 * 1.39999997615814208984375;
    float _188 = smoothstep(_186 - _218, _186 + _218, _69.z) * clamp(_182 - (1.0 - smoothstep(_69.y - _231, _69.y + _231, _183)), 0.0, 1.0);
    vec4 _139 = vec4(_140.xyz, _140.w * _188);
    _155 = _139;
}

