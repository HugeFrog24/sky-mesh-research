#version 460

layout(binding = 0) uniform sampler2D _34;

layout(location = 1) in vec2 _38;
layout(location = 0) in vec4 _51;
layout(location = 0) out vec4 _55;
layout(location = 1) out vec4 _65;

void main()
{
    vec4 _27 = vec4(1.0, 1.0, 1.0, texture(_34, _38).x);
    vec4 _48 = _27 * _51;
    _55 = vec4(_48.xyz, _48.w);
    float _72 = 1.0 / gl_FragCoord.w;
    float _73 = 256.0;
    float _98 = max(log(_72 * 20.0) * (_73 * 0.079292468726634979248046875), 0.0);
    _65 = vec4(_98, 0.0, 0.0, _48.w);
}

