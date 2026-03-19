#version 460

layout(binding = 1, std140) uniform _129_131
{
    vec4 _m0;
} _131;

layout(location = 0) in vec4 _92;
layout(location = 2) in vec3 _103;
layout(location = 0) out vec4 _158;
layout(location = 1) in vec3 _159;

void main()
{
    vec2 _89 = _92.xy;
    vec2 _95 = _92.zw;
    vec2 _98 = (_89 + (_95 * _103.x)) * _103.y;
    vec2 _114 = _98;
    float _116 = 2.0;
    float _191 = atan(_114.x, _114.y);
    float _192 = _191 * 9.0;
    float _193 = (cos(_192) * 0.01750000007450580596923828125) + dot(_114, _114);
    float _194 = _116;
    float _195 = _193;
    float _217 = smoothstep(0.0, 1.0, (1.0 - _195) * _194);
    vec2 _196 = vec2(_217, _193);
    vec2 _112 = _196;
    vec2 _143 = _89;
    float _145 = _103.z;
    float _149 = _131._m0.y * 0.5;
    float _150 = _131._m0.y * 4.9999998736893758177757263183594e-05;
    float _224 = 6.283185482025146484375 / _149;
    float _225 = atan(_143.y, _143.x) + _145;
    float _226 = step(mod(_225, _224), _150 / length(_143));
    float _128 = clamp((_226 * 0.25) + 0.75, 0.0, 1.0);
    _158 = vec4(_159 * (_128 * _112.x), 0.0);
}

