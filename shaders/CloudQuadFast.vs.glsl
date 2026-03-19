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

layout(binding = 0, std140) uniform _228_230
{
    float _m0;
    float _m1;
} _230;

layout(location = 3) out float _240;
layout(location = 0) out vec4 _286;
layout(location = 4) in vec4 _326;
layout(location = 3) in vec4 _337;
layout(location = 7) out float _342;
layout(location = 5) in vec4 _343;
layout(location = 1) out vec4 _346;
layout(location = 2) in vec4 _347;
layout(location = 1) in vec4 _350;
layout(location = 6) in float _361;
layout(location = 2) out vec2 _379;
layout(location = 0) in vec3 _381;
layout(location = 5) out float _427;
layout(location = 6) out float _431;
layout(location = 4) out float _434;
layout(location = 13) out float _437;
layout(location = 12) out float _440;
layout(location = 11) out float _486;
layout(location = 8) out vec3 _502;
layout(location = 10) out vec3 _578;
layout(location = 9) out vec3 _584;

void main()
{
    float _324 = _326.x;
    float _330 = _326.y;
    float _333 = _326.w;
    vec4 _336 = _337 + vec4(0.00196078442968428134918212890625);
    _342 = _343.w;
    _346 = _347;
    float _349 = _350.w;
    vec3 _353 = _350.xyz * 6.0;
    float _360 = _361;
    vec2 _370 = vec2(float(_360 > 0.0), (abs(_360) > 0.5) ? 0.0 : 1.0);
    _286 = vec4(_286.x, _286.y, _370.x, _370.y);
    vec4 _373 = _336;
    float _375 = _330;
    _375 = clamp(_375, -1.0, (_230._m0 * _230._m1) * 0.999000012874603271484375);
    _240 = fract(_375);
    float _636 = floor(_375 / _230._m0);
    float _637 = floor(_375 - (_636 * _230._m0));
    vec2 _638 = _373.zw * vec2(1.0 / _230._m0, 1.0 / _230._m1);
    vec2 _639 = _373.xy + (_638 * vec2(_637, _636 + 1.0));
    _638.y *= (-1.0);
    vec2 _640 = _639 + (_638 * (vec2(0.5) + ((_286.zw - vec2(0.5)) * 0.980000019073486328125)));
    vec2 _641;
    if (_375 >= 0.0)
    {
        _641 = _640;
    }
    else
    {
        _641 = (_373.xy + vec2(0.0, _373.w)) + (_286.zw * vec2(_373.z, -_373.w));
    }
    _286 = vec4(_641.x, _641.y, _286.z, _286.w);
    _379 = vec2(0.0);
    vec3 _387 = _381;
    vec3 _389 = _353;
    float _393 = _349;
    vec2 _395 = _286.zw;
    float _398 = _324;
    float _400 = _333;
    vec2 _404 = _379;
    vec4 _724 = _37._m8 * vec4(_387, 1.0);
    vec4 _725 = _37._m10 * vec4(_387 - _389, 1.0);
    _725 = (_725 * _393) + (_724 * (1.0 - _393));
    vec4 _726 = _724 - ((_725 + _724) * 0.5);
    _725 += _726;
    _724 += _726;
    vec4 _727 = _725 - _724;
    _725 -= (_727 * 0.25);
    _724 += (_727 * 0.25);
    vec2 _728 = _724.xy / vec2(_724.w);
    vec2 _729 = _725.xy / vec2(_725.w);
    vec2 _730 = _728 - _729;
    float _731 = length(_730);
    vec2 _733;
    if (_731 < 0.001000000047497451305389404296875)
    {
        _733 = vec2(0.0);
    }
    else
    {
        _733 = _730 / vec2(_731);
    }
    vec2 _732 = _733;
    mat2 _734 = mat2(vec2(cos(_400), sin(_400)), vec2(-sin(_400), cos(_400)));
    vec4 _735 = vec4((vec2(_37._m7[0].x, _37._m7[1].y) * _398) * (_734 * (_395 - vec2(0.5))), 0.0, 0.0);
    vec4 _736 = _724 + _735;
    vec4 _737 = _725 + _735;
    vec2 _738 = (_395 - vec2(0.5)) * 1.41421353816986083984375;
    float _739 = 0.5 + (0.5 * dot(_732, _738));
    vec4 _403 = mix(_737, _736, vec4(_739));
    vec3 _402 = (_37._m9 * _403).xyz;
    float _740 = ((1.41421353816986083984375 * _37._m7[0].x) * _398) / _403.w;
    float _741;
    if (_740 < 0.001000000047497451305389404296875)
    {
        _741 = 0.0;
    }
    else
    {
        _741 = _740 / (_740 + _731);
    }
    float _406 = _741;
    vec3 _382 = _402;
    gl_Position = _403;
    _379 = _404;
    float _386 = _406;
    _346.w *= (_386 * _386);
    _379 = vec2(0.0);
    _346.w *= smoothstep(0.0, 1.0, gl_Position.z);
    _427 = 1.0 / sqrt(_324);
    _431 = gl_Position.w;
    _434 = _324 * 0.5;
    _437 = _326.z;
    _440 = _343.x;
    vec3 _443 = _37._m16 - _382;
    vec3 _450 = -_37._m38;
    vec3 _455 = normalize(_443);
    vec3 _458 = normalize(_455 + (_450 * 1.02499997615814208984375));
    vec3 _465 = _458;
    float _467 = 1.0 - clamp(_324 * 0.0005000000237487256526947021484375, 0.0, 1.0);
    _467 *= _440;
    float _476 = mix(0.00999999977648258209228515625, 1.0, pow(clamp(1.0 - dot(_455, _458), 0.0, 1.0), 5.0));
    _486 = float(_343.z > 0.0);
    float _491 = abs(_343.z);
    _491 *= (1.0 - (_486 * 0.300000011920928955078125));
    _502 = _37._m49 * ((_486 > 0.5) ? 0.300000011920928955078125 : 1.0);
    vec3 _510 = _37._m41;
    float _516;
    if (_486 > 0.5)
    {
        _516 = 1.0;
    }
    else
    {
        _516 = clamp((dot(_465, _450) + 2.0) * 0.3333333432674407958984375, 0.0, 1.0) + ((_467 * dot(_455, _450)) * dot(_455, _450));
    }
    _510 *= _516;
    vec3 _542 = (_37._m41 * clamp(dot(_465, _450), 0.0, 1.0)) * vec3((32.0 * _476) * pow(clamp(dot(_465, _458), 0.0, 1.0), 2.0));
    vec3 _561 = (_37._m41 * ((128.0 * _476) * _476)) * pow(clamp(1.0 - dot(_455, _465), 0.0, 1.0), 8.0);
    _578 = (_542 + _561) * _491;
    _584 = _510 * _491;
    vec3 _601 = _346.xyz * mix(1.0, 0.20000000298023223876953125 + (0.800000011920928955078125 * _286.w), 1.0 - clamp(_491 * 5.0, 0.0, 1.0));
    _346 = vec4(_601.x, _601.y, _601.z, _346.w);
    gl_Position.z = 0.5 * (gl_Position.z + gl_Position.w);
}

