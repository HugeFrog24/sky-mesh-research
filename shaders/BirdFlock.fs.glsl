#version 460

layout(location = 0) out vec4 _24;

void main()
{
    float _31 = gl_FrontFacing ? 1.25 : 0.3499999940395355224609375;
    float _44 = 1.0 / gl_FragCoord.w;
    float _45 = 1000.0;
    float _75 = max(0.0, _44 * (_45 * 6.6666667407844215631484985351562e-05));
    _24 = vec4(_31, _31, _31, _75);
}

