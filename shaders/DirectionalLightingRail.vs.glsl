#version 460

layout(binding = 0, std140) uniform _238_240
{
    mat4 _m0;
    mat4 _m1;
    vec3 _m2;
    vec4 _m3;
    vec4 _m4;
    vec2 _m5;
} _240;

layout(binding = 2, std140) uniform _475_477
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
} _477;

layout(binding = 3) uniform sampler2D _264;
layout(binding = 4) uniform sampler2D _280;

layout(location = 4) in vec2 _129;
layout(location = 5) in vec3 _365;
layout(location = 6) in vec3 _375;
layout(location = 0) in vec3 _461;
layout(location = 1) out vec3 _464;
layout(location = 1) in vec3 _465;
layout(location = 2) out vec3 _474;
layout(location = 0) out vec4 _485;
layout(location = 2) in vec4 _487;
layout(location = 3) out vec2 _495;
layout(location = 3) in vec2 _496;

void main()
{
    vec3 _460 = _461;
    _464 = _465;
    vec3 _467 = _460;
    vec3 _469 = _464;
    float _537 = dot(_467, _365) / dot(_365, _365);
    mat3 _538 = mat3(normalize(cross(_375, _365)), _375, normalize(_365));
    _467 -= (_365 * dot(_365, _467));
    _467 = transpose(_538) * _467;
    _469 = transpose(_538) * _469;
    float _540 = _537;
    uint _631 = uint(_129.x);
    uint _632 = uint(_129.y);
    _540 = clamp(_540, 0.0, 1.0);
    uint _633[4];
    _633[1] = uint(_540 * float(_632 - 1u));
    uint _634;
    if (_633[1] == (_632 - 1u))
    {
        _634 = _632 - 2u;
    }
    else
    {
        _634 = _633[1];
    }
    _633[1] = _634;
    _633[2] = _633[1] + 1u;
    uint _635;
    if (_633[1] != 0u)
    {
        _635 = _633[1] - 1u;
    }
    else
    {
        _635 = _633[1];
    }
    _633[0] = _635;
    uint _636;
    if (_633[2] != (_632 - 1u))
    {
        _636 = _633[2] + 1u;
    }
    else
    {
        _636 = _633[2];
    }
    _633[3] = _636;
    float _934 = (_540 * float(_632 - 1u)) - float(_633[1]);
    vec3 _929[4];
    vec3 _931[2];
    float _933[2];
    for (uint _638 = 0u; _638 < 4u; _638++)
    {
        ivec2 _639 = ivec2(int((_631 + _633[_638]) % uint(_240._m5.x)), int(uint(float(_631 + _633[_638]) / _240._m5.x)));
        _929[_638] = texelFetch(_264, _639, 0).xyz;
        if ((_638 == 1u) || (_638 == 2u))
        {
            vec4 _640 = texelFetch(_280, _639, 0);
            _931[_638 - 1u] = (_640.xyz * 2.0) - vec3(1.0);
            _933[_638 - 1u] = _640.w;
        }
    }
    vec3 _984 = _929[0];
    vec3 _985 = _929[1];
    vec3 _986 = _929[2];
    vec3 _987 = _929[3];
    vec3 _997 = _931[0];
    vec3 _998 = _931[1];
    float _1004 = _933[0];
    float _1005 = _933[1];
    float _946 = _934;
    vec3 _1011 = _984;
    vec3 _1012 = _985;
    vec3 _1013 = _986;
    vec3 _1014 = _987;
    vec3 _1019 = _997;
    vec3 _1020 = _998;
    float _1023 = _1004;
    float _1024 = _1005;
    float _967 = _946;
    float _777 = _967;
    vec3 _778 = _1011;
    vec3 _779 = _1012;
    vec3 _780 = _1013;
    vec3 _781 = _1014;
    vec3 _833 = ((_779 * 2.0) + ((((-_778) + _780) + ((((((_778 * 2.0) - (_779 * 5.0)) + (_780 * 4.0)) - _781) + (((((-_778) + (_779 * 3.0)) - (_780 * 3.0)) + _781) * _777)) * _777)) * _777)) * 0.5;
    vec3 _906 = _833;
    float _782 = _967;
    vec3 _783 = _1011;
    vec3 _784 = _1012;
    vec3 _785 = _1013;
    vec3 _786 = _1014;
    vec3 _871 = (((-_783) + _785) + (((((((_783 * 2.0) - (_784 * 5.0)) + (_785 * 4.0)) - _786) * 2.0) + ((((((-_783) + (_784 * 3.0)) - (_785 * 3.0)) + _786) * _782) * 3.0)) * _782)) * 0.5;
    vec3 _907 = normalize(_871);
    vec3 _908 = normalize(mix(_1019, _1020, vec3(_967)));
    float _909 = mix(_1023, _1024, _967);
    vec3 _915 = _906;
    vec3 _916 = _907;
    vec3 _917 = _908;
    float _918 = _909;
    vec3 _956 = _915;
    vec3 _957 = _916;
    vec3 _958 = _917;
    float _959 = _918;
    mat3 _542 = mat3(normalize(cross(_958, _957)), _958, _957);
    _542[1] = normalize(cross(_542[2], _542[0]));
    _467 = _956 + ((_542 * _467) * _959);
    _469 = _542 * _469;
    _460 = _467;
    _464 = _469;
    _474 = _477._m16 - _460;
    _485 = vec4(1.0, 1.0, 1.0, _487.w);
    _495 = (_496 + _240._m3.xy) + (_240._m4.xy * _477._m20);
    gl_Position = _477._m8 * vec4(_460, 1.0);
    gl_Position.z = 0.5 * (gl_Position.z + gl_Position.w);
}

