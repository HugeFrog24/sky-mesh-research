#version 460

layout(location = 1) in vec4 _37;
layout(location = 0) in vec2 _42;
layout(location = 0) out vec4 _53;
layout(location = 1) out vec4 _62;

void main()
{
    float _25 = 1.0 / gl_FragCoord.w;
    float _36 = _37.w * max(0.0, 1.0 - (_42.x * _42.x));
    _53 = vec4(_37.xyz, _36);
    float _64 = _25;
    float _66 = 256.0;
    float _94 = max(log(_64 * 20.0) * (_66 * 0.079292468726634979248046875), 0.0);
    _62 = vec4(_94, 0.0, 0.0, _36);
}

