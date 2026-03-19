#version 460

layout(location = 0) in vec2 _15;
layout(location = 0) out vec4 _29;
layout(location = 1) in vec4 _31;

void main()
{
    gl_Position = vec4(_15.x, -_15.y, 1.0, 1.0);
    vec3 _37 = pow(_31.xyz, vec3(2.2000000476837158203125));
    _29 = vec4(_37.x, _37.y, _37.z, _29.w);
    _29.w = _31.w;
    gl_Position.z = 0.5 * (gl_Position.z + gl_Position.w);
}

