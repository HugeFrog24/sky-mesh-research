#version 460

layout(binding = 0, std140) uniform _28_30
{
    float _m0;
} _30;

layout(binding = 3) uniform sampler2D _13;

layout(location = 1) in vec2 _17;
layout(location = 4) in vec4 _45;
layout(location = 0) in vec4 _49;
layout(location = 0) out vec4 _81;
layout(location = 2) in vec2 _103;
layout(location = 3) in vec2 _104;
layout(location = 5) in vec2 _105;

void main()
{
    vec4 _9 = texture(_13, _17);
    _9 = mix(_9, vec4(1.0, 1.0, 1.0, _9.x), vec4(_30._m0));
    float _38 = _9.x;
    vec4 _41 = vec4(1.0);
    vec4 _43 = vec4(mix(_45.xyz, _49.xyz, vec3(pow(_38, 3.0))), (_38 * _49.w) * _41.w);
    vec4 _70 = _9 * _49;
    _70 = mix(_70, _43, vec4(_45.w));
    _81 = _70;
}

