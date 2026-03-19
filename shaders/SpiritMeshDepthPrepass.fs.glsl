#version 460

layout(binding = 0, std140) uniform _370_372
{
    float _m0;
} _372;

layout(binding = 2, std140) uniform _394_396
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
} _396;

layout(location = 2) in vec3 _366;
layout(location = 4) in vec4 _384;
layout(location = 0) out vec4 _427;
layout(location = 1) out vec4 _428;
layout(location = 0) in vec3 _448;
layout(location = 1) in vec3 _449;
layout(location = 3) in vec4 _450;

void main()
{
    vec3 _364 = normalize(_366);
    float _369 = _372._m0;
    vec3 _404 = (_364 * 100.0) + vec3(_396._m20 * 2.5);
    vec3 _451 = floor(_404 + vec3(dot(_404, vec3(0.3333333432674407958984375))));
    vec3 _452 = (_404 - _451) + vec3(dot(_451, vec3(0.16666667163372039794921875)));
    vec3 _453 = step(_452.yzx, _452);
    vec3 _454 = vec3(1.0) - _453;
    vec3 _455 = min(_453, _454.zxy);
    vec3 _456 = max(_453, _454.zxy);
    vec3 _457 = (_452 - _455) + vec3(0.16666667163372039794921875);
    vec3 _458 = (_452 - _456) + vec3(0.3333333432674407958984375);
    vec3 _459 = _452 - vec3(0.5);
    _451 = mod(_451, vec3(289.0));
    vec4 _461 = vec4(_451.z) + vec4(0.0, _455.z, _456.z, 1.0);
    vec4 _749 = mod(((_461 * _461) * 34.0) + _461, vec4(289.0));
    vec4 _462 = (_749 + vec4(_451.y)) + vec4(0.0, _455.y, _456.y, 1.0);
    vec4 _759 = mod(((_462 * _462) * 34.0) + _462, vec4(289.0));
    vec4 _463 = (_759 + vec4(_451.x)) + vec4(0.0, _455.x, _456.x, 1.0);
    vec4 _769 = mod(((_463 * _463) * 34.0) + _463, vec4(289.0));
    vec4 _460 = _769;
    float _464 = 0.14285714924335479736328125;
    vec3 _465 = (vec3(2.0, 0.5, 1.0) * _464) - vec3(0.0, 1.0, 0.0);
    vec4 _466 = _460 - (floor((_460 * _465.z) * _465.z) * 49.0);
    vec4 _467 = floor(_466 * _465.z);
    vec4 _468 = floor(_466 - (_467 * 7.0));
    vec4 _469 = (_467 * _465.x) + _465.yyyy;
    vec4 _470 = (_468 * _465.x) + _465.yyyy;
    vec4 _471 = (vec4(1.0) - abs(_469)) - abs(_470);
    vec4 _472 = vec4(_469.xy, _470.xy);
    vec4 _473 = vec4(_469.zw, _470.zw);
    vec4 _474 = (floor(_472) * 2.0) + vec4(1.0);
    vec4 _475 = (floor(_473) * 2.0) + vec4(1.0);
    vec4 _476 = -step(_471, vec4(0.0));
    vec4 _477 = _472.xzyw + (_474.xzyw * _476.xxyy);
    vec4 _478 = _473.xzyw + (_475.xzyw * _476.zzww);
    vec3 _479 = vec3(_477.xy, _471.x);
    vec3 _480 = vec3(_477.zw, _471.y);
    vec3 _481 = vec3(_478.xy, _471.z);
    vec3 _482 = vec3(_478.zw, _471.w);
    vec4 _484 = vec4(dot(_479, _479), dot(_480, _480), dot(_481, _481), dot(_482, _482));
    vec4 _779 = vec4(1.792842864990234375) - (_484 * 0.8537347316741943359375);
    vec4 _483 = _779;
    _479 *= _483.x;
    _480 *= _483.y;
    _481 *= _483.z;
    _482 *= _483.w;
    vec4 _485 = max(vec4(0.60000002384185791015625) - vec4(dot(_452, _452), dot(_457, _457), dot(_458, _458), dot(_459, _459)), vec4(0.0));
    _485 *= _485;
    float _486 = 42.0 * dot(_485 * _485, vec4(dot(_479, _452), dot(_480, _457), dot(_481, _458), dot(_482, _459)));
    float _378 = smoothstep(0.0, 0.100000001490116119384765625, clamp((1.10000002384185791015625 * ((1.0 - _369) - _384.w)) - _486, 0.0, 1.0));
    float _409 = 1.0 - float(_369 > (_378 * (1.0 - _384.w)));
    if (_409 <= 0.001000000047497451305389404296875)
    {
        discard;
    }
    _427 = vec4(0.0);
    _428 = vec4(0.0);
}

