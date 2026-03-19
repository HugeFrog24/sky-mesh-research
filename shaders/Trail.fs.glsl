#version 460

layout(location = 1) in vec4 _37;
layout(location = 0) in vec2 _42;
layout(location = 0) out vec4 _50;
layout(location = 1) out vec4 _59;

void main()
{
    float _25 = 1.0 / gl_FragCoord.w;
    float _36 = _37.w * max(0.0, 1.0 - dot(_42, _42));
    _50 = vec4(_37.xyz, _36);
    float _61 = _25;
    float _63 = 256.0;
    float _91 = max(log(_61 * 20.0) * (_63 * 0.079292468726634979248046875), 0.0);
    _59 = vec4(_91, 0.0, 0.0, _36);
}

