#version 460

layout(location = 0) out vec2 _38;

void main()
{
    int _8 = gl_VertexID;
    float _14 = ((_8 == 0) || (_8 == 3)) ? (-1.0) : 1.0;
    float _26 = (_8 < 2) ? 1.0 : (-1.0);
    vec2 _33 = vec2(_14, _26);
    _38 = _33;
    gl_Position = vec4((_33 * 2.0) - vec2(1.0), 0.0, 1.0);
    gl_Position.z = 0.5 * (gl_Position.z + gl_Position.w);
}

