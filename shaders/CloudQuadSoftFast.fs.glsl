#version 460

layout(binding = 1, std140) uniform _49_51
{
    vec4 _m0;
} _51;

layout(binding = 3) uniform sampler2D _63;
layout(binding = 4) uniform sampler2D _109;
layout(binding = 0) uniform sampler2D _169;

layout(location = 6) in float _78;
layout(location = 4) in float _81;
layout(location = 5) in float _91;
layout(location = 0) in vec4 _104;
layout(location = 12) in float _117;
layout(location = 9) in vec3 _125;
layout(location = 8) in vec3 _131;
layout(location = 10) in vec3 _139;
layout(location = 1) in vec4 _147;
layout(location = 7) in float _151;
layout(location = 13) in float _157;
layout(location = 3) in float _180;
layout(location = 0) out vec4 _196;
layout(location = 1) out vec4 _205;
layout(location = 2) in vec2 _234;
layout(location = 11) in float _235;

void main()
{
    vec4 _101 = vec4(0.0, 0.0, 0.0, 1.0);
    vec2 _103 = _104.zw;
    float _107 = 0.5 + (0.5 * texture(_109, _103).x);
    _107 = (_117 < 0.5) ? 1.0 : _107;
    vec3 _128 = _125 * _107;
    _101 = vec4(_128.x, _128.y, _128.z, _101.w);
    vec3 _135 = _101.xyz + _131;
    _101 = vec4(_135.x, _135.y, _135.z, _101.w);
    vec3 _144 = _101.xyz + (_139 * 0.20000000298023223876953125);
    _101 = vec4(_144.x, _144.y, _144.z, _101.w);
    _101 *= _147;
    _101 *= _151;
    vec3 _162 = _101.xyz + (_147.xyz * _157);
    _101 = vec4(_162.x, _162.y, _162.z, _101.w);
    vec2 _165 = _104.xy;
    vec2 _168 = texture(_169, _165).wz;
    float _174 = mix(_168.x, _168.y, _180);
    _101.w *= _174;
    float _188 = _174;
    vec2 _236 = gl_FragCoord.xy * _51._m0.zw;
    float _237 = textureLod(_63, _236, 0.0).w;
    float _239 = _237;
    float _240 = 1000.0;
    float _272 = abs(_239 * (15000.0 / _240));
    float _238 = _272;
    float _241 = _78;
    _241 -= (_188 * _81);
    float _242 = _238 - _241;
    _242 = clamp(_242 * _91, 0.0, 1.0);
    float _243 = smoothstep(0.0, 1.0, _242);
    _101.w *= _243;
    _196 = vec4(_101.xyz, _101.w);
    float _210 = 1.0 / gl_FragCoord.w;
    float _211 = 256.0;
    float _279 = max(log(_210 * 20.0) * (_211 * 0.079292468726634979248046875), 0.0);
    _205 = vec4(_279, 0.0, 0.0, _101.w);
}

