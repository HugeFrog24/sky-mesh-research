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

layout(binding = 0, std140) uniform _268_270
{
    float _m0;
    float _m1;
} _270;

layout(location = 3) out float _280;
layout(location = 0) out vec4 _326;
layout(location = 4) in vec4 _366;
layout(location = 3) in vec4 _377;
layout(location = 7) out float _382;
layout(location = 5) in vec4 _383;
layout(location = 1) out vec4 _386;
layout(location = 2) in vec4 _387;
layout(location = 1) in vec4 _390;
layout(location = 6) in float _401;
layout(location = 2) out vec2 _419;
layout(location = 0) in vec3 _421;
layout(location = 5) out float _473;
layout(location = 6) out float _477;
layout(location = 4) out float _480;
layout(location = 13) out float _483;
layout(location = 12) out float _486;
layout(location = 11) out float _532;
layout(location = 8) out vec3 _548;
layout(location = 10) out vec3 _623;
layout(location = 9) out vec3 _629;

void main()
{
    float _364 = _366.x;
    float _370 = _366.y;
    vec4 _376 = _377 + vec4(0.00196078442968428134918212890625);
    _382 = _383.w;
    _386 = _387;
    vec3 _393 = _390.xyz * 6.0;
    float _400 = _401;
    vec2 _410 = vec2(float(_400 > 0.0), (abs(_400) > 0.5) ? 0.0 : 1.0);
    _326 = vec4(_326.x, _326.y, _410.x, _410.y);
    vec4 _413 = _376;
    float _415 = _370;
    _415 = clamp(_415, -1.0, (_270._m0 * _270._m1) * 0.999000012874603271484375);
    _280 = fract(_415);
    float _681 = floor(_415 / _270._m0);
    float _682 = floor(_415 - (_681 * _270._m0));
    vec2 _683 = _413.zw * vec2(1.0 / _270._m0, 1.0 / _270._m1);
    vec2 _684 = _413.xy + (_683 * vec2(_682, _681 + 1.0));
    _683.y *= (-1.0);
    vec2 _685 = _684 + (_683 * (vec2(0.5) + ((_326.zw - vec2(0.5)) * 0.980000019073486328125)));
    vec2 _686;
    if (_415 >= 0.0)
    {
        _686 = _685;
    }
    else
    {
        _686 = (_413.xy + vec2(0.0, _413.w)) + (_326.zw * vec2(_413.z, -_413.w));
    }
    _326 = vec4(_686.x, _686.y, _326.z, _326.w);
    _419 = vec2(0.0);
    vec3 _427 = _421;
    vec3 _429 = _393;
    vec2 _435 = _326.zw;
    float _438 = _364;
    vec2 _444 = _419;
    vec4 _769 = _37._m8 * vec4(_427, 1.0);
    vec4 _770 = _37._m8 * vec4(_427 - (_429 * 3.0), 1.0);
    vec4 _771 = _769 - ((_770 + _769) * 0.5);
    _770 += _771;
    _769 += _771;
    vec4 _772 = _770 - _769;
    _770 -= (_772 * 0.25);
    _769 += (_772 * 0.25);
    vec2 _773 = _769.xy / vec2(_769.w);
    vec2 _774 = _770.xy / vec2(_770.w);
    vec2 _775 = _773 - _774;
    float _776 = length(_775);
    vec2 _778;
    if (_776 < 0.001000000047497451305389404296875)
    {
        _778 = vec2(0.0);
    }
    else
    {
        _778 = _775 / vec2(_776);
    }
    vec2 _777 = _778;
    vec2 _784 = vec2(-_777.y, _777.x);
    mat2 _785 = mat2(-_777, -_784);
    _785 = mat2(vec2(0.707107245922088623046875, 0.707106292247772216796875), vec2(-0.707106292247772216796875, 0.707107245922088623046875)) * _785;
    _435 = _785 * _435;
    float _786 = (_438 * _37._m7[0].x) / _769.w;
    float _787;
    if (_786 < 9.9999997473787516355514526367188e-05)
    {
        _787 = 1.0;
    }
    else
    {
        _787 = clamp(0.0040000001899898052215576171875 / _786, 1.0, 3.0);
    }
    _435 *= _787;
    float _446 = min(1.0, _786 * 333.333343505859375);
    vec4 _788 = vec4((vec2(_37._m7[0].x, _37._m7[1].y) * _438) * (_435 - vec2(0.5)), 0.0, 0.0);
    vec4 _789 = _769 + _788;
    vec4 _790 = _770 + _788;
    vec2 _791 = (_435 - vec2(0.5)) * 1.41421353816986083984375;
    float _792 = 0.5 + (0.5 * dot(_777, _791));
    vec4 _443 = mix(_790, _789, vec4(_792));
    vec3 _442 = (_37._m9 * _443).xyz;
    vec3 _422 = _442;
    gl_Position = _443;
    _419 = _444;
    float _426 = _446;
    _386.w *= (_426 * _426);
    vec3 _463 = _386.xyz * _426;
    _386 = vec4(_463.x, _463.y, _463.z, _386.w);
    _419 = vec2(0.0);
    _386.w *= smoothstep(0.0, 1.0, gl_Position.z);
    _473 = 1.0 / sqrt(_364);
    _477 = gl_Position.w;
    _480 = _364 * 0.5;
    _483 = _366.z;
    _486 = _383.x;
    vec3 _489 = _37._m16 - _422;
    vec3 _496 = -_37._m38;
    vec3 _501 = normalize(_489);
    vec3 _504 = normalize(_501 + (_496 * 1.02499997615814208984375));
    vec3 _511 = _504;
    float _513 = 1.0 - clamp(_364 * 0.0005000000237487256526947021484375, 0.0, 1.0);
    _513 *= _486;
    float _522 = mix(0.00999999977648258209228515625, 1.0, pow(clamp(1.0 - dot(_501, _504), 0.0, 1.0), 5.0));
    _532 = float(_383.z > 0.0);
    float _537 = abs(_383.z);
    _537 *= (1.0 - (_532 * 0.300000011920928955078125));
    _548 = _37._m49 * ((_532 > 0.5) ? 0.300000011920928955078125 : 1.0);
    vec3 _556 = _37._m41;
    float _562;
    if (_532 > 0.5)
    {
        _562 = 1.0;
    }
    else
    {
        _562 = clamp((dot(_511, _496) + 2.0) * 0.3333333432674407958984375, 0.0, 1.0) + ((_513 * dot(_501, _496)) * dot(_501, _496));
    }
    _556 *= _562;
    vec3 _587 = (_37._m41 * clamp(dot(_511, _496), 0.0, 1.0)) * vec3((32.0 * _522) * pow(clamp(dot(_511, _504), 0.0, 1.0), 2.0));
    vec3 _606 = (_37._m41 * ((128.0 * _522) * _522)) * pow(clamp(1.0 - dot(_501, _511), 0.0, 1.0), 8.0);
    _623 = (_587 + _606) * _537;
    _629 = _556 * _537;
    vec3 _646 = _386.xyz * mix(1.0, 0.20000000298023223876953125 + (0.800000011920928955078125 * _326.w), 1.0 - clamp(_537 * 5.0, 0.0, 1.0));
    _386 = vec4(_646.x, _646.y, _646.z, _386.w);
    gl_Position.z = 0.5 * (gl_Position.z + gl_Position.w);
}

