#version 460

layout(location = 0) in vec4 _11;
layout(location = 0) out vec4 _18;

void main()
{
    float _8 = _11.w;
    _18 = vec4(_11.xyz, _8);
}

