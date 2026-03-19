#version 460

layout(location = 0) out vec4 _9;
layout(location = 0) in vec4 _11;

void main()
{
    _9 = _11;
    vec3 _21 = _9.xyz * _9.w;
    _9 = vec4(_21.x, _21.y, _21.z, _9.w);
}

