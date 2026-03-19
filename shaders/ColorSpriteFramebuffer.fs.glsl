#version 460

layout(binding = 0) uniform sampler2D _13;

layout(location = 1) in vec2 _17;
layout(location = 2) in vec4 _31;
layout(location = 0) in vec4 _35;
layout(location = 0) out vec4 _67;
layout(location = 3) in vec2 _89;

void main()
{
    vec4 _9 = texture(_13, _17);
    float _21 = _9.x;
    vec4 _26 = vec4(1.0);
    vec4 _29 = vec4(mix(_31.xyz, _35.xyz, vec3(pow(_21, 3.0))), (_21 * _35.w) * _26.w);
    vec4 _56 = _9 * _35;
    _56 = mix(_56, _29, vec4(_31.w));
    _67 = _56;
}

