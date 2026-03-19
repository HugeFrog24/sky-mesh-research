#version 460

layout(binding = 1, std140) uniform _29_31
{
    vec4 _m0;
} _31;

layout(binding = 0, std140) uniform _78_80
{
    float _m0;
} _80;

layout(binding = 4) uniform sampler2D _51;
layout(binding = 3) uniform sampler2D _61;

layout(location = 0) out float _76;

void main()
{
    vec2 _23 = gl_FragCoord.xy * _31._m0.zw;
    float _39 = 1.0 / gl_FragCoord.w;
    float _56 = texture(_51, _23, 1000.0).w;
    float _58 = 1000.0;
    float _109 = abs(_56 * (15000.0 / _58));
    float _47 = _109;
    float _65 = texture(_61, _23).x;
    float _68 = 1000.0;
    float _116 = abs(_65 * (15000.0 / _68));
    float _60 = _116;
    _47 = min(min(_47, _60), _39);
    _76 = (_47 * _80._m0) * (gl_FrontFacing ? 0.001000000047497451305389404296875 : (-0.001000000047497451305389404296875));
}

