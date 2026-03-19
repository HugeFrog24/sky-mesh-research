#version 460

layout(binding = 0, std140) uniform _55_57
{
    vec2 _m0;
    vec2 _m1;
} _57;

layout(location = 0) out vec2 _73;
layout(location = 1) out vec4 _77;
layout(location = 2) out vec4 _100;

void main()
{
    int _8 = gl_VertexID;
    gl_Position.x = (_8 == 0) ? (-3.0) : 1.0;
    gl_Position.y = (_8 == 2) ? 3.0 : (-1.0);
    gl_Position.z = 0.0;
    gl_Position.w = 1.0;
    vec2 _43 = (gl_Position.xy + vec2(1.0)) * vec2(0.5);
    vec2 _53 = (_57._m1 * 2.0) / _57._m0;
    vec2 _66 = vec2(0.6480000019073486328125) / _57._m0;
    _73 = _43 * _53;
    vec2 _87 = _73 + vec2(-_66.x, -_66.y);
    _77 = vec4(_87.x, _87.y, _77.z, _77.w);
    vec2 _97 = _73 + vec2(_66.x, -_66.y);
    _77 = vec4(_77.x, _77.y, _97.x, _97.y);
    vec2 _108 = _73 + vec2(-_66.x, _66.y);
    _100 = vec4(_108.x, _108.y, _100.z, _100.w);
    vec2 _117 = _73 + vec2(_66.x, _66.y);
    _100 = vec4(_100.x, _100.y, _117.x, _117.y);
    gl_Position.z = 0.5 * (gl_Position.z + gl_Position.w);
}

