#version 460

layout(binding = 0) uniform sampler2D _19;

layout(location = 0) in vec2 _11;
layout(location = 0) out vec4 _15;
layout(location = 1) in vec4 _41;

void main()
{
    vec2 _9 = _11;
    vec4 _23 = textureLod(_19, _9, 0.0);
    _15 = vec4(_23.x, _23.y, _23.z, _15.w);
    _15.w = 1.0;
}

