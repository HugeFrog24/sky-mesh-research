#version 460

layout(binding = 3) uniform sampler2D _42;
layout(binding = 0) uniform sampler2D _104;

layout(location = 0) in vec4 _34;
layout(location = 12) in float _52;
layout(location = 9) in vec3 _60;
layout(location = 8) in vec3 _66;
layout(location = 10) in vec3 _74;
layout(location = 1) in vec4 _82;
layout(location = 7) in float _86;
layout(location = 13) in float _92;
layout(location = 3) in float _115;
layout(location = 0) out vec4 _125;
layout(location = 1) out vec4 _134;
layout(location = 2) in vec2 _168;
layout(location = 4) in float _169;
layout(location = 5) in float _170;
layout(location = 6) in float _171;
layout(location = 11) in float _172;

void main()
{
    vec4 _27 = vec4(0.0, 0.0, 0.0, 1.0);
    vec2 _32 = _34.zw;
    float _37 = 0.5 + (0.5 * texture(_42, _32).x);
    _37 = (_52 < 0.5) ? 1.0 : _37;
    vec3 _63 = _60 * _37;
    _27 = vec4(_63.x, _63.y, _63.z, _27.w);
    vec3 _70 = _27.xyz + _66;
    _27 = vec4(_70.x, _70.y, _70.z, _27.w);
    vec3 _79 = _27.xyz + (_74 * 0.20000000298023223876953125);
    _27 = vec4(_79.x, _79.y, _79.z, _27.w);
    _27 *= _82;
    _27 *= _86;
    vec3 _97 = _27.xyz + (_82.xyz * _92);
    _27 = vec4(_97.x, _97.y, _97.z, _27.w);
    vec2 _100 = _34.xy;
    vec2 _103 = texture(_104, _100).wz;
    float _109 = mix(_103.x, _103.y, _115);
    _27.w *= _109;
    _125 = vec4(_27.xyz, _27.w);
    float _140 = 1.0 / gl_FragCoord.w;
    float _141 = 256.0;
    float _173 = max(log(_140 * 20.0) * (_141 * 0.079292468726634979248046875), 0.0);
    _134 = vec4(_173, 0.0, 0.0, _27.w);
}

