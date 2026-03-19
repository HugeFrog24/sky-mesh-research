#version 460

layout(binding = 3) uniform sampler2D _79;

layout(location = 2) in vec3 _42;
layout(location = 1) in vec3 _51;
layout(location = 3) in vec2 _69;
layout(location = 0) in vec4 _74;
layout(location = 0) out vec4 _87;
layout(location = 1) out vec4 _98;

void main()
{
    vec2 _67 = _69;
    vec4 _72 = _74 * texture(_79, _67);
    vec4 _84 = _72;
    _87 = vec4(_84.xyz, _84.w);
    float _106 = 1.0 / gl_FragCoord.w;
    float _107 = 256.0;
    float _132 = max(log(_106 * 20.0) * (_107 * 0.079292468726634979248046875), 0.0);
    _98 = vec4(_132, 0.0, 0.0, _84.w);
}

