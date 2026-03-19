#version 460

layout(binding = 2, std140) uniform _69_71
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
} _71;

layout(binding = 4) uniform sampler3D _94;
layout(binding = 5) uniform sampler3D _135;
layout(binding = 3) uniform sampler3D _187;
layout(binding = 0) uniform sampler2D _234;
layout(binding = 6) uniform sampler2D _500;

layout(location = 0) in vec3 _453;
layout(location = 3) out vec3 _456;
layout(location = 4) out vec2 _475;
layout(location = 2) in vec4 _477;
layout(location = 1) out vec3 _524;
layout(location = 1) in vec4 _525;
layout(location = 0) out vec3 _528;
layout(location = 6) out float _531;
layout(location = 4) in vec4 _600;
layout(location = 3) in vec4 _607;
layout(location = 2) out vec3 _630;
layout(location = 5) out vec2 _678;

void main()
{
    vec3 _911;
    vec3 _916;
    vec3 _924;
    vec3 _926;
    vec3 _451 = _453;
    _456 = _71._m16 - _451;
    float _462 = length(_456);
    _475 = _477.xy;
    vec2 _480 = (_475 + (vec2(0.100000001490116119384765625, 0.0) * _71._m20)) * 0.20000000298023223876953125;
    vec2 _489 = ((_475 * 0.25) + (vec2(0.0, 0.0500000007450580596923828125) * _71._m20)) * 0.20000000298023223876953125;
    vec2 _499 = (textureLod(_500, _480, 0.0).xy * 2.0) - vec2(1.0);
    vec2 _508 = (textureLod(_500, _489, 0.0).xy * 2.0) - vec2(1.0);
    _475 += (((_499 + _508) * vec2(1.0, 0.25)) * 0.004999999888241291046142578125);
    _524 = _525.xyz;
    _528 = _451;
    _531 = pow(0.5 + (0.5 * _525.w), 4.0);
    gl_Position = _71._m8 * vec4(_451, 1.0);
    vec2 _565 = gl_Position.xy - ((_71._m32 * 2.0) * gl_Position.w);
    gl_Position = vec4(_565.x, _565.y, gl_Position.z, gl_Position.w);
    vec2 _569 = vec2(0.5) + ((gl_Position.xy / vec2(gl_Position.w)) * 0.5);
    vec3 _580 = normalize((_71._m35 + (_71._m33 * _569.x)) + (_71._m34 * _569.y));
    float _599 = _600.y * _600.y;
    vec3 _606 = (_607.xyz * _607.xyz) / vec3(_607.w);
    float _617 = _600.x;
    float _620 = _600.w * exp2((255.0 * _600.z) - 128.0);
    vec3 _631 = _451;
    vec3 _633 = _580;
    float _635 = _462;
    vec3 _637 = _606;
    float _639 = _617;
    float _641 = _599;
    float _643 = _620;
    float _645 = 1.0;
    vec3 _723 = _637 * mix(_71._m45, _71._m41, vec3(_639));
    _723 += (_71._m60 * _643);
    float _724 = 2.5;
    float _725 = 4.0;
    vec3 _726 = _631 - (_71._m38 * _724);
    vec3 _728 = _726;
    float _729 = _635 - (_724 * dot(_633, _71._m38));
    vec3 _879 = _728;
    float _880 = _729;
    float _895;
    do
    {
        float _896 = 0.0;
        _911 = vec3(0.5 * _71._m72.x);
        _879 -= _911;
        _916 = _71._m77;
        vec3 _897 = (_879 - _916) * 0.0625;
        vec3 _898 = floor(_897);
        _924 = _71._m78;
        _926 = vec3(16.0) / _924;
        vec3 _899 = (_898 + vec3(0.5)) * _926;
        vec3 _900 = textureLod(_135, _899, 0.0).xyz;
        if (_900.x == 1.0)
        {
            _895 = (_900.z * 110.0) + (-10.0);
            break;
        }
        vec3 _901 = _897 - _898;
        vec3 _902 = vec3(0.5 * _71._m72.z) + (_901 * (1.0 - _71._m72.z));
        vec3 _903 = vec3(((_900.xy * 255.0) + _902.xy) * _71._m74, _902.z);
        float _904 = textureLod(_187, _903, 0.0).x;
        _896 += ((_904 * 10.0) + (-6.0));
        _895 = max(_896, _71._m70.w - _880);
        break;
    } while(false);
    float _905 = _895;
    float _878 = _905;
    vec3 _882 = _728;
    float _883 = 1.0;
    _883 *= 0.5;
    vec3 _985 = (((_882 - _71._m70.xyz) * _883) * 0.015625) * 6.0;
    float _986 = _71._m69.w * textureLod(_94, _985, 0.0).x;
    float _881 = _986;
    float _884 = _878 - _881;
    float _727 = _884;
    float _730 = (_71._m71.w * 0.20000000298023223876953125) * max(0.0, 0.25 - ((1.75 * _725) * _727));
    _730 *= _645;
    vec3 _732 = _631;
    vec2 _1007;
    do
    {
        vec2 _1008 = (_732.xz - _71._m54.xy) * _71._m54.w;
        if (any(notEqual(clamp(_1008, vec2(0.0), vec2(1.0)), _1008)))
        {
            _1007 = vec2(0.0);
            break;
        }
        vec2 _1009 = textureLod(_234, _1008, 0.0).yw;
        float _1010 = clamp(_1009.x * 4.0, -1.0, 0.0);
        _1007 = vec2(_1010, (_1009.y * _1009.y) * _1009.y);
        break;
    } while(false);
    vec2 _1011 = _1007;
    vec2 _731 = _1011;
    float _733 = 1.0 + _731.x;
    float _734 = 0.75;
    float _735 = 0.25;
    float _736 = 0.699999988079071044921875;
    float _737 = _733 * exp2((-2.75) * sqrt(_730));
    float _738 = dot(_633, -_71._m38);
    float _739 = mix(0.20000000298023223876953125, 0.004999999888241291046142578125, clamp(_641 * _737, 0.0, 1.0));
    float _740 = _739 / (_739 - (_738 - 1.0));
    _740 /= (_739 * log((2.0 / _739) + 1.0));
    float _741 = (8.0 * _740) * _737;
    vec3 _742 = (_723 * _734) * (vec3(1.0 + ((1.5 * _735) * _736)) + (_71._m41 * ((0.5 * _639) * _737)));
    vec3 _743 = (_71._m41 * _641) * ((_737 * _736) + ((0.5 + (0.5 * _641)) * _741));
    vec3 _744 = _71._m71.xyz * (_743 + _742);
    _744 += ((_744 * vec3(3.0, 0.4000000059604644775390625, 0.100000001490116119384765625)) * _731.y);
    vec3 _745 = _744;
    _630 = _745;
    vec3 _647 = (_451 - _916) / _924;
    bool _656 = all(equal(_647, clamp(_647, vec3(0.0), vec3(1.0))));
    float _667;
    if (_656)
    {
        vec3 _670 = _451;
        float _672 = _462;
        float _1052;
        do
        {
            float _1053 = 0.0;
            _670 -= _911;
            vec3 _1054 = (_670 - _916) * 0.0625;
            vec3 _1055 = floor(_1054);
            vec3 _1056 = (_1055 + vec3(0.5)) * _926;
            vec3 _1057 = textureLod(_135, _1056, 0.0).xyz;
            if (_1057.x == 1.0)
            {
                _1052 = (_1057.z * 110.0) + (-10.0);
                break;
            }
            vec3 _1058 = _1054 - _1055;
            vec3 _1059 = vec3(0.5 * _71._m72.z) + (_1058 * (1.0 - _71._m72.z));
            vec3 _1060 = vec3(((_1057.xy * 255.0) + _1059.xy) * _71._m74, _1059.z);
            float _1061 = textureLod(_187, _1060, 0.0).x;
            _1053 += ((_1061 * 10.0) + (-6.0));
            _1052 = max(_1053, _71._m70.w - _672);
            break;
        } while(false);
        float _1062 = _1052;
        _667 = _1062;
    }
    else
    {
        _667 = 1000.0;
    }
    float _665 = _667;
    float _679 = _665;
    float _681 = 4.0;
    float _682 = 2.0;
    float _1142 = clamp((_679 * (1.0 / (_682 - _681))) - (_681 / (_682 - _681)), 0.0, 1.0);
    _678 = vec2(_1142, float(_665 < 6.0));
    gl_Position.z = 0.5 * (gl_Position.z + gl_Position.w);
}

