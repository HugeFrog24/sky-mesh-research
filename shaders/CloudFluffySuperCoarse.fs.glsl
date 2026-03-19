#version 460

layout(binding = 2, std140) uniform _60_62
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
} _62;

layout(binding = 1, std140) uniform _457_459
{
    vec4 _m0;
} _459;

layout(binding = 3) uniform sampler3D _85;
layout(binding = 4) uniform sampler3D _127;
layout(binding = 0) uniform sampler3D _180;
layout(binding = 5) uniform sampler2D _452;

layout(location = 1) in vec4 _246;
layout(location = 0) in vec2 _455;
layout(location = 0) out float _537;

void main()
{
    float _574 = _246.w;
    vec4 _575 = vec4(_246.xyz, _574);
    vec4 _432 = _575;
    float _434 = inversesqrt(dot(_432.xyz, _432.xyz));
    vec3 _444 = _432.xyz * _434;
    _432 = vec4(_444.x, _444.y, _444.z, _432.w);
    float _447 = 0.0;
    float _448 = textureLod(_452, _455 + (_459._m0.zw * vec2(0.25)), 0.0).x;
    _448 = max(_448, textureLod(_452, _455 + (_459._m0.zw * vec2(-0.25, 0.25)), 0.0).x);
    _448 = max(_448, textureLod(_452, _455 + (_459._m0.zw * vec2(0.25, -0.25)), 0.0).x);
    _448 = max(_448, textureLod(_452, _455 + (_459._m0.zw * vec2(-0.25)), 0.0).x);
    float _508 = _448;
    float _510 = 1000.0;
    float _586 = abs(_508 * (15000.0 / _510));
    _448 = (_586 / _434) + 2.5;
    vec4 _517 = _432;
    float _519 = _447;
    float _521 = _448;
    vec3 _593 = _62._m77 - _62._m16;
    vec3 _594 = (_62._m77 + _62._m78) - _62._m16;
    vec3 _595 = vec3(1.0) / _517.xyz;
    vec3 _596 = _593 * _595;
    vec3 _597 = _594 * _595;
    vec3 _598 = min(_596, _597);
    vec3 _599 = max(_596, _597);
    float _600 = min(_599.x, min(_599.y, _599.z));
    float _601 = max(_598.x, max(_598.y, _598.z));
    vec2 _602 = vec2(max(_519, _601), min(_521, _600));
    vec2 _516 = _602;
    vec4 _525 = _432;
    vec2 _527 = _516;
    float _656 = _527.x;
    float _657 = max(_656, _527.y);
    float _658 = _525.w;
    float _659 = -1000000.0;
    float _790;
    while (_656 < _657)
    {
        vec3 _660 = _62._m16 + (_525.xyz * _656);
        vec3 _662 = _660;
        float _663 = _656;
        vec3 _763 = _662;
        float _764 = _663;
        do
        {
            float _791 = 0.0;
            _763 -= vec3(0.5 * _62._m72.x);
            vec3 _792 = (_763 - _62._m77) * 0.0625;
            vec3 _793 = floor(_792);
            vec3 _794 = (_793 + vec3(0.5)) * (vec3(16.0) / _62._m78);
            vec3 _795 = textureLod(_127, _794, 0.0).xyz;
            if (_795.x == 1.0)
            {
                _790 = (_795.z * 110.0) + (-10.0);
                break;
            }
            vec3 _796 = _792 - _793;
            vec3 _797 = vec3(0.5 * _62._m72.z) + (_796 * (1.0 - _62._m72.z));
            vec3 _798 = vec3(((_795.xy * 255.0) + _797.xy) * _62._m74, _797.z);
            float _799 = textureLod(_180, _798, 0.0).x;
            _791 += ((_799 * 10.0) + (-6.0));
            _790 = max(_791, _62._m70.w - _764);
            break;
        } while(false);
        float _800 = _790;
        float _762 = _800;
        float _880 = 0.0;
        float _765 = _880;
        vec3 _768 = _662;
        float _769 = 1.0;
        _769 *= 0.5;
        vec3 _882 = (((_768 - _62._m70.xyz) * _769) * 0.015625) * 6.0;
        float _883 = _62._m69.w * textureLod(_85, _882, 0.0).x;
        float _767 = _883;
        _767 *= (1.0 + _765);
        float _770 = (_762 - _767) - _765;
        float _661 = _770;
        float _664 = _656 * _658;
        float _665 = _656 + _661;
        if (_661 >= _659)
        {
            _656 += (_661 * 1.60000002384185791015625);
            _659 = _656 - _665;
            if (_661 <= _664)
            {
                float _723 = max(_527.x, _665 - _664);
                _657 = _723;
                _656 = _723;
            }
        }
        else
        {
            _656 += (-_659);
            _659 = -1000000.0;
        }
    }
    if (_659 > 0.0)
    {
        _657 -= _659;
        vec3 _666 = _62._m16 + (_525.xyz * _657);
        vec3 _668 = _666;
        float _669 = _657;
        vec3 _904 = _668;
        float _905 = _669;
        float _931;
        do
        {
            float _932 = 0.0;
            _904 -= vec3(0.5 * _62._m72.x);
            vec3 _933 = (_904 - _62._m77) * 0.0625;
            vec3 _934 = floor(_933);
            vec3 _935 = (_934 + vec3(0.5)) * (vec3(16.0) / _62._m78);
            vec3 _936 = textureLod(_127, _935, 0.0).xyz;
            if (_936.x == 1.0)
            {
                _931 = (_936.z * 110.0) + (-10.0);
                break;
            }
            vec3 _937 = _933 - _934;
            vec3 _938 = vec3(0.5 * _62._m72.z) + (_937 * (1.0 - _62._m72.z));
            vec3 _939 = vec3(((_936.xy * 255.0) + _938.xy) * _62._m74, _938.z);
            float _940 = textureLod(_180, _939, 0.0).x;
            _932 += ((_940 * 10.0) + (-6.0));
            _931 = max(_932, _62._m70.w - _905);
            break;
        } while(false);
        float _941 = _931;
        float _903 = _941;
        float _1021 = 0.0;
        float _906 = _1021;
        vec3 _909 = _668;
        float _910 = 1.0;
        _910 *= 0.5;
        vec3 _1023 = (((_909 - _62._m70.xyz) * _910) * 0.015625) * 6.0;
        float _1024 = _62._m69.w * textureLod(_85, _1023, 0.0).x;
        float _908 = _1024;
        _908 *= (1.0 + _906);
        float _911 = (_903 - _908) - _906;
        float _667 = _911;
        float _670 = _657 * _658;
        _657 = max(_527.x, _657 + (_667 - _670));
    }
    float _671 = _657;
    float _524 = _671;
    bool _531 = _524 < _516.y;
    float _539;
    if (_531)
    {
        _539 = _524 * _434;
    }
    else
    {
        _539 = 258000.0;
    }
    float _547 = _539;
    float _549 = 1000.0;
    float _1044 = max(0.0, _547 * (_549 * 6.6666667407844215631484985351562e-05));
    _537 = _1044;
}

