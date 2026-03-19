#version 460

layout(binding = 2, std140) uniform _104_106
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
} _106;

layout(location = 0) out vec3 _9;
layout(location = 0) in vec3 _11;
layout(location = 1) out vec3 _13;
layout(location = 4) in vec4 _16;
layout(location = 2) out vec3 _19;
layout(location = 2) in vec3 _20;
layout(location = 3) out vec3 _22;
layout(location = 3) in vec3 _23;
layout(location = 4) out vec3 _25;
layout(location = 1) in vec3 _26;
layout(location = 5) in vec4 _31;
layout(location = 6) out vec2 _37;
layout(location = 7) out vec4 _50;
layout(location = 6) in vec4 _51;
layout(location = 8) out vec4 _53;
layout(location = 7) in vec4 _54;
layout(location = 9) out vec4 _60;
layout(location = 8) in vec4 _61;
layout(location = 10) out vec4 _63;
layout(location = 9) in vec4 _64;
layout(location = 11) out vec4 _70;
layout(location = 10) in vec4 _71;
layout(location = 12) out vec4 _74;
layout(location = 11) in vec4 _75;
layout(location = 5) out vec2 _249;

void main()
{
    _9 = _11;
    _13 = _16.xyz;
    _19 = _20;
    _22 = _23;
    _25 = _26;
    vec3 _29 = _31.xyz * 128.0;
    _37 = vec2(_16.w, floor(256.0 * _31.w));
    _50 = _51;
    _53 = _54 * vec4(0.5, 0.5, 0.5, 2.0);
    _60 = _61;
    _63 = _64 * vec4(8.0, 8.0, 8.0, 1.0);
    _70 = _71 * vec4(8.0, 8.0, 8.0, 1.0);
    _74 = _75 * vec4(8.0, 8.0, 8.0, 1.0);
    vec3 _78 = cross(_19, _22);
    mat3 _84 = mat3(_19, _22, _78);
    vec3 _102 = _106._m16 - _25;
    vec3 _114 = vec3(dot(_19, _102), dot(_22, _102), dot(_78, _102)) / _13;
    float _128 = length(_114);
    vec3 _131 = _114 / vec3(_128);
    vec3 _144;
    if (abs(_131.x) >= 0.57735002040863037109375)
    {
        _144 = vec3(_131.y, -_131.x, 0.0);
    }
    else
    {
        _144 = vec3(0.0, _131.z, -_131.y);
    }
    vec3 _136 = normalize(_144);
    vec3 _164 = cross(_131, _136);
    vec3 _168 = (_136 * _9.x) + (_164 * _9.y);
    vec3 _179 = _131;
    vec3 _181 = _168 * (1.14999997615814208984375 * sqrt((_128 - 1.0) / (_128 + 1.0)));
    _9 = _179 + _181;
    vec3 _195 = vec3(dot(_19, _29), dot(_22, _29), dot(_78, _29)) / _13;
    vec3 _208 = _195 - (_131 * dot(_131, _195));
    float _216 = length(_208);
    float _223;
    if (_216 > 0.001000000047497451305389404296875)
    {
        _223 = dot(_208, _168) / _216;
    }
    else
    {
        _223 = 0.0;
    }
    float _219 = _223;
    float _236;
    if (_216 > 0.001000000047497451305389404296875)
    {
        _236 = 1.14999997615814208984375 / _216;
    }
    else
    {
        _236 = 1.0;
    }
    float _233 = _236;
    _219 *= clamp(_216 - 0.25, 0.0, 1.0);
    _249.x = (_219 * 1.14999997615814208984375) * (0.5 + _233);
    _249.y = _233;
    vec3 _258 = _25 + (_84 * (_13 * _9));
    _258 += (_29 * (0.5 * _219));
    gl_Position = _106._m8 * vec4(_258, 1.0);
    gl_Position.z = 0.5 * (gl_Position.z + gl_Position.w);
}

