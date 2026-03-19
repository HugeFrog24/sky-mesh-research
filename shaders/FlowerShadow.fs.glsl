#version 460

layout(binding = 0) uniform sampler2D _37;

layout(location = 1) in vec3 _15;
layout(location = 0) out vec4 _49;
layout(location = 0) in vec3 _50;

void main()
{
    vec2 _9 = gl_PointCoord;
    _9.x += (_15.z * (1.0 - _9.y));
    vec2 _33 = texture(_37, _9).xy;
    float _43 = dot(_33, _15.xy);
    _49 = vec4(_50, _43);
}

