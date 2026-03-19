#version 460

layout(binding = 2, std140) uniform _35_37
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
} _37;

layout(binding = 0, std140) uniform _276_278
{
    float _m0;
    float _m1;
} _278;

layout(location = 0) out vec3 _64;
layout(location = 4) in vec4 _374;
layout(location = 3) in vec4 _385;
layout(location = 1) in vec4 _391;
layout(location = 6) in float _402;
layout(location = 0) in vec3 _422;
layout(location = 2) in vec4 _489;
layout(location = 5) in vec4 _490;

void main()
{
    float _372 = _374.x;
    float _378 = _374.y;
    vec4 _384 = _385 + vec4(0.00196078442968428134918212890625);
    vec3 _394 = _391.xyz * 6.0;
    float _401 = _402;
    vec2 _411 = vec2(float(_401 > 0.0), (abs(_401) > 0.5) ? 0.0 : 1.0);
    vec4 _334;
    _334 = vec4(_334.x, _334.y, _411.x, _411.y);
    vec4 _414 = _384;
    float _416 = _378;
    _416 = clamp(_416, -1.0, (_278._m0 * _278._m1) * 0.999000012874603271484375);
    float _491 = floor(_416 / _278._m0);
    float _492 = floor(_416 - (_491 * _278._m0));
    vec2 _493 = _414.zw * vec2(1.0 / _278._m0, 1.0 / _278._m1);
    vec2 _494 = _414.xy + (_493 * vec2(_492, _491 + 1.0));
    _493.y *= (-1.0);
    vec2 _495 = _494 + (_493 * (vec2(0.5) + ((_334.zw - vec2(0.5)) * 0.980000019073486328125)));
    vec2 _496;
    if (_416 >= 0.0)
    {
        _496 = _495;
    }
    else
    {
        _496 = (_414.xy + vec2(0.0, _414.w)) + (_334.zw * vec2(_414.z, -_414.w));
    }
    _334 = vec4(_496.x, _496.y, _334.z, _334.w);
    vec3 _428 = _422;
    vec3 _430 = _394;
    vec2 _436 = _334.zw;
    float _439 = _372;
    vec4 _579 = _37._m8 * vec4(_428, 1.0);
    vec4 _580 = _37._m8 * vec4(_428 - (_430 * 3.0), 1.0);
    _64 = _428 - (_430 * 3.0);
    vec4 _581 = _579 - ((_580 + _579) * 0.5);
    _580 += _581;
    _579 += _581;
    vec4 _582 = _580 - _579;
    _580 -= (_582 * 0.25);
    _579 += (_582 * 0.25);
    vec2 _583 = _579.xy / vec2(_579.w);
    vec2 _584 = _580.xy / vec2(_580.w);
    vec2 _585 = _583 - _584;
    float _586 = length(_585);
    vec2 _588;
    if (_586 < 0.001000000047497451305389404296875)
    {
        _588 = vec2(0.0);
    }
    else
    {
        _588 = _585 / vec2(_586);
    }
    vec2 _587 = _588;
    vec2 _594 = vec2(-_587.y, _587.x);
    mat2 _595 = mat2(-_587, -_594);
    _595 = mat2(vec2(0.707107245922088623046875, 0.707106292247772216796875), vec2(-0.707106292247772216796875, 0.707107245922088623046875)) * _595;
    _436 = _595 * _436;
    _436 *= 1.0;
    float _596 = (_439 * _37._m7[0].x) / _579.w;
    float _597;
    if (_596 < 9.9999997473787516355514526367188e-05)
    {
        _597 = 1.0;
    }
    else
    {
        _597 = clamp(0.0040000001899898052215576171875 / _596, 1.0, 3.0);
    }
    _436 *= _597;
    vec4 _598 = vec4((vec2(_37._m7[0].x, _37._m7[1].y) * _439) * (_436 - vec2(0.5)), 0.0, 0.0);
    vec4 _599 = _579 + _598;
    vec4 _600 = _580 + _598;
    vec2 _601 = (_436 - vec2(0.5)) * 1.41421353816986083984375;
    float _602 = 0.5 + (0.5 * dot(_587, _601));
    vec4 _444 = mix(_600, _599, vec4(_602));
    gl_Position = _444;
    gl_Position.z = 0.5 * (gl_Position.z + gl_Position.w);
}

