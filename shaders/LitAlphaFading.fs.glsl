#version 460

layout(binding = 2, std140) uniform _53_55
{
    vec4 _m0;
    vec4 _m1;
    vec4 _m2;
    vec4 _m3;
    vec4 _m4;
    vec4 _m5;
    mat4 _m6;
    mat4 _m7;
    mat4 _m8;
    mat4 _m9;
    mat4 _m10;
    mat4 _m11;
    vec4 _m12;
    vec4 _m13;
    vec4 _m14;
    vec4 _m15;
    vec3 _m16;
    float _m17;
    vec3 _m18;
    float _m19;
    float _m20;
    float _m21;
    float _m22;
    float _m23;
    float _m24;
    float _m25;
    float _m26;
    vec3 _m27;
    float _m28;
    vec3 _m29;
    float _m30;
    vec2 _m31;
    vec2 _m32;
    vec3 _m33;
    vec3 _m34;
    vec3 _m35;
    vec4 _m36;
    vec2 _m37;
    vec3 _m38;
    float _m39;
    vec4 _m40;
    vec3 _m41;
    float _m42;
    vec3 _m43;
    float _m44;
    vec3 _m45;
    float _m46;
    vec3 _m47;
    vec3 _m48;
    vec3 _m49;
    vec4 _m50;
    vec4 _m51;
    vec3 _m52;
    vec4 _m53;
    vec4 _m54;
    vec4 _m55;
    vec4 _m56;
    vec3 _m57;
    vec3 _m58;
    vec3 _m59;
    vec3 _m60;
    vec4 _m61;
    vec4 _m62;
    vec4 _m63;
    vec4 _m64;
    vec4 _m65;
    vec4 _m66;
    vec3 _m67;
    vec3 _m68;
    vec4 _m69;
    vec4 _m70;
    vec4 _m71;
    vec4 _m72;
    vec3 _m73;
    float _m74;
    vec3 _m75;
    float _m76;
    vec3 _m77;
    vec3 _m78;
    vec3 _m79;
    vec3 _m80;
    vec3 _m81;
    vec3 _m82;
} _55;

layout(binding = 0, std140) uniform _192_194
{
    vec4 _m0;
    vec2 _m1;
    float _m2;
    float _m3;
} _194;

layout(binding = 3) uniform sampler2D _101;

layout(location = 2) in vec3 _64;
layout(location = 1) in vec3 _73;
layout(location = 3) in vec2 _91;
layout(location = 0) in vec4 _96;
layout(location = 0) out vec4 _301;
layout(location = 1) out vec4 _310;

void main()
{
    vec3 _49 = -_55._m38;
    float _62 = length(_64);
    vec3 _67 = _64 / vec3(_62);
    vec3 _72 = normalize(_73);
    vec3 _76 = normalize(_67 + (_49 * 1.02499997615814208984375));
    float _83 = max(dot(_72, _49), 0.0);
    vec2 _89 = _91;
    vec4 _94 = _96 * texture(_101, _89);
    vec4 _106 = _94;
    vec3 _108 = _55._m41 * 1.0;
    vec3 _113 = _55._m49 * 1.0;
    vec3 _118 = _108 * _83;
    float _122 = mix(0.00999999977648258209228515625, 1.0, pow(clamp(1.0 - dot(_67, _76), 0.0, 1.0), 5.0));
    vec3 _132 = (_55._m41 * clamp(dot(_72, _49), 0.0, 1.0)) * vec3((4.0 * _122) * pow(max(dot(_72, _76), 0.0), 2.0));
    _132 += ((_113 * 0.5) * pow(clamp(1.0 - dot(_67, _72), 0.0, 1.0), 8.0));
    _106 = vec4((_94.xyz * (_113 + _118)) + _132, _94.w);
    vec3 _181 = vec3(0.0);
    float _183 = dot(_94.xyz, vec3(0.2989999949932098388671875, 0.58700001239776611328125, 0.114000000059604644775390625));
    bool _200 = _194._m0.x > 0.0;
    bool _208;
    if (_200)
    {
        _208 = _183 > (1.0 - _194._m0.x);
    }
    else
    {
        _208 = _200;
    }
    if (_208)
    {
        _181 = ((_94.xyz * _194._m0.y) * ((_183 - 1.0) + _194._m0.x)) / vec3(_194._m0.x);
    }
    _181 *= (1.0 + _194._m0.z);
    vec3 _236 = _106.xyz + _181;
    _106 = vec4(_236.x, _236.y, _236.z, _106.w);
    float _239 = dot(_72, _67);
    if (_194._m3 >= 0.0)
    {
        _106.w *= mix(1.0, pow(abs(_239), 3.0), _194._m3);
    }
    else
    {
        _106.w *= mix(1.0, pow(1.0099999904632568359375 - abs(_239), 3.0), -_194._m3);
    }
    _106.w *= (1.0 - _194._m2);
    float _284 = _62;
    float _286 = _194._m1.x;
    float _289 = _194._m1.y;
    float _338 = clamp((_284 * (1.0 / (_289 - _286))) - (_286 / (_289 - _286)), 0.0, 1.0);
    float _282 = _338;
    _106.w *= (_282 * _282);
    _301 = vec4(_106.xyz, _106.w);
    float _317 = 1.0 / gl_FragCoord.w;
    float _318 = 256.0;
    float _353 = max(log(_317 * 20.0) * (_318 * 0.079292468726634979248046875), 0.0);
    _310 = vec4(_353, 0.0, 0.0, _106.w);
}

