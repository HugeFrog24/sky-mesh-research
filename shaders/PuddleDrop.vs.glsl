#version 460

layout(location = 0) in vec3 _15;

void main()
{
    gl_Position = vec4(_15, 1.0);
    gl_Position.z = 0.5 * (gl_Position.z + gl_Position.w);
}

