#version 460

layout(binding = 0) uniform sampler2D _16;

layout(location = 1) in vec2 _20;
layout(location = 0) in vec4 _33;
layout(location = 0) out vec4 _37;

void main()
{
    vec4 _9 = vec4(1.0, 1.0, 1.0, texture(_16, _20).x);
    vec4 _30 = _9 * _33;
    _37 = _30;
}

