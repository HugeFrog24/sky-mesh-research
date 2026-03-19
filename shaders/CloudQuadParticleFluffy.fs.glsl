#version 460

layout(binding = 1, std140) uniform _49_51
{
    vec4 _m0;
} _51;

layout(binding = 3) uniform sampler2D _63;
layout(binding = 0) uniform sampler2D _114;

layout(location = 6) in float _78;
layout(location = 4) in float _81;
layout(location = 5) in float _91;
layout(location = 1) in vec4 _103;
layout(location = 7) in float _105;
layout(location = 0) in vec4 _110;
layout(location = 3) in float _126;
layout(location = 0) out vec4 _142;
layout(location = 1) out vec4 _152;
layout(location = 2) in vec2 _181;

void main()
{
    vec4 _101 = vec4(0.0, 0.0, 0.0, 1.0);
    _101 = _103;
    _101 *= _105;
    vec2 _109 = _110.xy;
    vec2 _113 = texture(_114, _109).wz;
    float _119 = mix(_113.x, _113.y, _126);
    _101.w *= _119;
    float _134 = _119;
    vec2 _182 = gl_FragCoord.xy * _51._m0.zw;
    float _183 = textureLod(_63, _182, 0.0).w;
    float _185 = _183;
    float _186 = 1000.0;
    float _218 = abs(_185 * (15000.0 / _186));
    float _184 = _218;
    float _187 = _78;
    _187 -= (_134 * _81);
    float _188 = _184 - _187;
    _188 = clamp(_188 * _91, 0.0, 1.0);
    float _189 = smoothstep(0.0, 1.0, _188);
    _101.w *= _189;
    _142 = vec4(_101.xyz, _101.w);
    float _157 = 1.0 / gl_FragCoord.w;
    float _158 = 256.0;
    float _225 = max(log(_157 * 20.0) * (_158 * 0.079292468726634979248046875), 0.0);
    _152 = vec4(_225, 0.0, 0.0, _101.w);
}

