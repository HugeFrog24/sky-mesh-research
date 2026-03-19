#version 460

layout(binding = 1, std140) uniform _49_51
{
    vec4 _m0;
} _51;

layout(binding = 3) uniform sampler2D _63;
layout(binding = 0) uniform sampler2D _110;

layout(location = 6) in float _78;
layout(location = 4) in float _81;
layout(location = 5) in float _91;
layout(location = 1) in vec4 _103;
layout(location = 0) in vec4 _106;
layout(location = 3) in float _122;
layout(location = 0) out vec4 _138;
layout(location = 1) out vec4 _148;
layout(location = 2) in vec2 _177;

void main()
{
    vec4 _101 = vec4(0.0, 0.0, 0.0, 1.0);
    _101 = _103;
    vec2 _105 = _106.xy;
    vec2 _109 = texture(_110, _105).wz;
    float _115 = mix(_109.x, _109.y, _122);
    _101.w *= _115;
    float _130 = _115;
    vec2 _178 = gl_FragCoord.xy * _51._m0.zw;
    float _179 = textureLod(_63, _178, 0.0).w;
    float _181 = _179;
    float _182 = 1000.0;
    float _214 = abs(_181 * (15000.0 / _182));
    float _180 = _214;
    float _183 = _78;
    _183 -= (_130 * _81);
    float _184 = _180 - _183;
    _184 = clamp(_184 * _91, 0.0, 1.0);
    float _185 = smoothstep(0.0, 1.0, _184);
    _101.w *= _185;
    _138 = vec4(_101.xyz, _101.w);
    float _153 = 1.0 / gl_FragCoord.w;
    float _154 = 256.0;
    float _221 = max(log(_153 * 20.0) * (_154 * 0.079292468726634979248046875), 0.0);
    _148 = vec4(_221, 0.0, 0.0, _101.w);
}

