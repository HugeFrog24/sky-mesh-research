#version 460

layout(location = 0) in vec4 _11;
layout(location = 1) in vec4 _18;
layout(location = 0) out vec4 _31;

void main()
{
    float _8 = _11.w;
    float _17 = clamp(_18.w, 0.0, 1.0);
    _8 = clamp((_8 * _17) * _17, 0.0, 1.0);
    _31 = vec4(_11.xyz, _8);
}

