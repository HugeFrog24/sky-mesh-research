#version 460

layout(location = 0) out vec4 _20;
layout(location = 0) in vec2 _39;
layout(location = 1) in vec4 _40;

void main()
{
    float _8 = 1.0 / gl_FragCoord.w;
    _20 = vec4(0.0, 0.0, _8, 0.0);
}

