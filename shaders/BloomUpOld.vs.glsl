#version 460

layout(binding = 0, std140) uniform _54_56
{
    vec2 _m0;
    vec2 _m1;
} _56;

layout(location = 0) out vec4 _65;

void main()
{
    int _8 = gl_VertexID;
    gl_Position.x = (_8 == 0) ? (-3.0) : 1.0;
    gl_Position.y = (_8 == 2) ? 3.0 : (-1.0);
    gl_Position.z = 0.0;
    gl_Position.w = 1.0;
    vec2 _43 = (gl_Position.xy + vec2(1.0)) * vec2(0.5);
    vec2 _53 = (_56._m0 * 0.5) / _56._m1;
    _65 = vec4(_43.x, _43.y, _65.z, _65.w);
    vec2 _71 = _43 * _53;
    _65 = vec4(_65.x, _65.y, _71.x, _71.y);
    gl_Position.z = 0.5 * (gl_Position.z + gl_Position.w);
}

