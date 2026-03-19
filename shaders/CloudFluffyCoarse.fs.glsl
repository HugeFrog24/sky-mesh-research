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

layout(binding = 3) uniform sampler3D _85;
layout(binding = 4) uniform sampler3D _127;
layout(binding = 0) uniform sampler3D _180;
layout(binding = 5) uniform sampler2D _421;

layout(location = 1) in vec4 _246;
layout(location = 0) in vec2 _424;
layout(location = 0) out float _456;

void main()
{
    float _496 = _246.w;
    _496 *= 0.699999988079071044921875;
    vec4 _497 = vec4(_246.xyz, _496);
    vec4 _402 = _497;
    float _404 = inversesqrt(dot(_402.xyz, _402.xyz));
    vec3 _414 = _402.xyz * _404;
    _402 = vec4(_414.x, _414.y, _414.z, _402.w);
    float _428 = textureLod(_421, _424, 0.0).x;
    float _430 = 1000.0;
    float _510 = abs(_428 * (15000.0 / _430));
    float _417 = _510 / _404;
    float _434 = 15000.0;
    vec4 _436 = _402;
    float _438 = _417;
    float _440 = _434;
    vec3 _517 = _62._m77 - _62._m16;
    vec3 _518 = (_62._m77 + _62._m78) - _62._m16;
    vec3 _519 = vec3(1.0) / _436.xyz;
    vec3 _520 = _517 * _519;
    vec3 _521 = _518 * _519;
    vec3 _522 = min(_520, _521);
    vec3 _523 = max(_520, _521);
    float _524 = min(_523.x, min(_523.y, _523.z));
    float _525 = max(_522.x, max(_522.y, _522.z));
    vec2 _526 = vec2(max(_438, _525), min(_440, _524));
    vec2 _435 = _526;
    vec4 _444 = _402;
    vec2 _446 = _435;
    float _580 = _446.x;
    float _581 = max(_580, _446.y);
    float _582 = _444.w;
    float _583 = -1000000.0;
    float _681;
    while (_580 < _581)
    {
        vec3 _584 = _62._m16 + (_444.xyz * _580);
        vec3 _586 = _584;
        float _587 = _580;
        vec3 _654 = _586;
        float _655 = _587;
        do
        {
            float _682 = 0.0;
            _654 -= vec3(0.5 * _62._m72.x);
            vec3 _683 = (_654 - _62._m77) * 0.0625;
            vec3 _684 = floor(_683);
            vec3 _685 = (_684 + vec3(0.5)) * (vec3(16.0) / _62._m78);
            vec3 _686 = textureLod(_127, _685, 0.0).xyz;
            if (_686.x == 1.0)
            {
                _681 = (_686.z * 110.0) + (-10.0);
                break;
            }
            vec3 _687 = _683 - _684;
            vec3 _688 = vec3(0.5 * _62._m72.z) + (_687 * (1.0 - _62._m72.z));
            vec3 _689 = vec3(((_686.xy * 255.0) + _688.xy) * _62._m74, _688.z);
            float _690 = textureLod(_180, _689, 0.0).x;
            _682 += ((_690 * 10.0) + (-6.0));
            _681 = max(_682, _62._m70.w - _655);
            break;
        } while(false);
        float _691 = _681;
        float _653 = _691;
        float _771 = 0.0;
        float _656 = _771;
        vec3 _659 = _586;
        float _660 = 1.0;
        _660 *= 0.5;
        vec3 _773 = (((_659 - _62._m70.xyz) * _660) * 0.015625) * 6.0;
        float _774 = _62._m69.w * textureLod(_85, _773, 0.0).x;
        float _658 = _774;
        _658 *= (1.0 + _656);
        float _661 = (_653 - _658) - _656;
        float _585 = _661;
        float _588 = _580 * _582;
        float _589 = _580 + _585;
        if (_585 >= _583)
        {
            _580 += (_585 * 1.60000002384185791015625);
            _583 = _580 - _589;
            if (_585 <= _588)
            {
                float _642 = max(_446.x, _589 - _588);
                _581 = _642;
                _580 = _642;
            }
        }
        else
        {
            _580 += (-_583);
            _583 = -1000000.0;
        }
    }
    float _590 = _581;
    float _443 = _590;
    bool _450 = _443 < _435.y;
    float _458;
    if (_450)
    {
        _458 = _443 * _404;
    }
    else
    {
        _458 = 258000.0;
    }
    float _466 = _458;
    float _468 = 1000.0;
    float _794 = max(0.0, _466 * (_468 * 6.6666667407844215631484985351562e-05));
    _456 = _794;
}

