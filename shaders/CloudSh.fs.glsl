#version 460

layout(location = 0) out vec4 _24;
layout(location = 0) in vec4 _26;

void main()
{
    float _39 = 1.0 / gl_FragCoord.w;
    float _40 = 1000.0;
    float _70 = max(0.0, _39 * (_40 * 6.6666667407844215631484985351562e-05));
    _24 = vec4(_26.xyz, _70);
}

