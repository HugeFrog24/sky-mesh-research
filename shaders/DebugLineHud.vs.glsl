#version 460

layout(location = 0) in vec3 _15;
layout(location = 0) out vec4 _24;
layout(location = 1) in vec4 _26;

void main()
{
    gl_Position = vec4(_15, 1.0);
    _24 = _26;
    gl_Position.z = 0.5 * (gl_Position.z + gl_Position.w);
}

