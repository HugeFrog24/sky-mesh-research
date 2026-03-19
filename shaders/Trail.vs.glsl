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

layout(binding = 1, std140) uniform _252_254
{
    vec4 _m0;
} _254;

layout(location = 2) in vec4 _11;
layout(location = 1) in vec4 _18;
layout(location = 4) in vec4 _38;
layout(location = 0) out vec2 _49;
layout(location = 0) in vec3 _62;
layout(location = 3) in vec4 _94;
layout(location = 1) out vec4 _130;

void main()
{
    vec4 _9 = _11 * _11;
    vec2 _17 = _18.xy;
    float _22 = _18.z;
    bool _30 = _22 == 0.0;
    vec3 _36 = _38.xyz * 9.19999980926513671875;
    float _42 = 4.0 * _38.w;
    _49 = _17;
    vec3 _51 = normalize(_55._m16 - _62);
    vec3 _66 = -_55._m38;
    float _71 = dot(_51, _66);
    float _75 = 0.0500000007450580596923828125;
    float _77 = (1.25 * _75) / pow(1.0 - ((1.0 - _75) * pow(max(0.0, -_71), 2.0)), 2.0);
    float _93 = _94.w;
    vec3 _99;
    if (_30)
    {
        _99 = _9.xyz;
    }
    else
    {
        _99 = _9.xyz * 16.0;
    }
    vec3 _97 = _99;
    vec3 _110 = (_97 * (_55._m45 + (_55._m41 * _93))) + (_55._m41 * (_77 * _93));
    _130 = vec4(_110.x, _110.y, _110.z, _130.w);
    float _135;
    if (_30)
    {
        _135 = _9.w / max(1.0, (625.0 * _42) * _42);
    }
    else
    {
        _135 = _9.w;
    }
    _130.w = _135;
    vec3 _153 = (_55._m6 * vec4(_62, 1.0)).xyz;
    vec3 _165 = mat3(_55._m6[0].xyz, _55._m6[1].xyz, _55._m6[2].xyz) * _36;
    vec3 _178 = _153 + _165;
    vec2 _182 = (_178.xy / vec2(_178.z)) - (_153.xy / vec2(_153.z));
    float _196 = length(_182);
    vec2 _203;
    if (_196 > 9.9999999747524270787835121154785e-07)
    {
        _203 = (-_182) / vec2(_196);
    }
    else
    {
        _203 = vec2(1.0, 0.0);
    }
    vec2 _199 = _203;
    vec2 _214 = vec2(-_199.y, _199.x);
    float _223 = min(1.0, max(0.001000000047497451305389404296875, (-0.5) - _153.z) * 0.4000000059604644775390625);
    _42 /= sqrt(_223);
    _130.w *= (_223 * _223);
    float _245 = ((_42 * _55._m17) * _254._m0.y) / (-_153.z);
    float _263 = max(1.0, 1.0 / _245);
    _42 *= _263;
    _130.w /= _263;
    vec3 _275 = mix(_178, _153, bvec3(_17.x < 0.0)) + vec3(((_199 * _17.x) + (_214 * _17.y)) * _42, 0.0);
    gl_Position = _55._m7 * vec4(_275, 1.0);
    if (_130.w < 0.001000000047497451305389404296875)
    {
        gl_Position = vec4(0.0, 0.0, 0.0, 1.0);
    }
    gl_Position.z = 0.5 * (gl_Position.z + gl_Position.w);
}

