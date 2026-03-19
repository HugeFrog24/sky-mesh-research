#version 460

layout(binding = 0) uniform sampler2D _31;

layout(location = 1) in vec2 _35;
layout(location = 2) in vec4 _48;
layout(location = 0) in vec4 _52;
layout(location = 0) out vec4 _84;
layout(location = 1) out vec4 _93;
layout(location = 3) in vec2 _125;

void main()
{
    vec4 _27 = texture(_31, _35);
    float _38 = _27.x;
    vec4 _43 = vec4(1.0);
    vec4 _46 = vec4(mix(_48.xyz, _52.xyz, vec3(pow(_38, 3.0))), (_38 * _52.w) * _43.w);
    vec4 _73 = _27 * _52;
    _73 = mix(_73, _46, vec4(_48.w));
    _84 = vec4(_73.xyz, _73.w);
    float _99 = 1.0 / gl_FragCoord.w;
    float _100 = 256.0;
    float _127 = max(log(_99 * 20.0) * (_100 * 0.079292468726634979248046875), 0.0);
    _93 = vec4(_127, 0.0, 0.0, _73.w);
}

