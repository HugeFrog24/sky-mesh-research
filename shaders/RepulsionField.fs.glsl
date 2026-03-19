#version 460

layout(binding = 0, std140) uniform _41_43
{
    vec3 _m0;
    float _m1;
    float _m2;
} _43;

layout(binding = 2, std140) uniform _71_73
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
} _73;

layout(binding = 1, std140) uniform _306_308
{
    vec4 _m0;
} _308;

layout(binding = 3) uniform sampler2D _318;

layout(location = 1) in vec3 _79;
layout(location = 0) in vec4 _120;
layout(location = 0) out vec4 _344;
layout(location = 1) out vec4 _353;

void main()
{
    float _49 = 1.0 - _43._m2;
    float _37 = 0.20000000298023223876953125 - (_49 * 0.17000000178813934326171875);
    float _53 = 0.1500000059604644775390625 - (_49 * 0.119999997317790985107421875);
    vec4 _63 = vec4(0.5, 0.5, 0.5, _37);
    vec3 _68 = (_73._m73 - _79) * (1.0 - (_43._m1 * 0.25));
    float _89 = max(0.0, 1.0 - dot(_68, _68));
    _89 *= (_89 * _89);
    float _100 = abs((length(_68) * 1.2999999523162841796875) - 1.0);
    float _107 = (max(0.0, 1.0 - (_100 * 30.0)) * 0.5) * _43._m1;
    vec2 _118 = ((_120.xy * vec2(4.0 + (_89 * 3.0))) * 1.5) + vec2((_73._m20 * 0.300000011920928955078125) * _43._m2);
    float _153 = _73._m20 * _43._m2;
    float _142 = (0.100000001490116119384765625 + cos(_118.y + sin(0.1480000019073486328125 - _153))) + ((2.400000095367431640625 * _73._m20) * _43._m2);
    float _167 = (0.89999997615814208984375 + sin(_118.x + cos(0.6280000209808349609375 + _153))) - ((0.699999988079071044921875 * _73._m20) * _43._m2);
    float _191 = length(_118);
    float _194 = ((7.0 * _43._m2) * cos(_191 + _167)) * sin(_142 + _167);
    vec3 _209 = (cos(vec3(_194) + vec3(-1.2000000476837158203125, -1.10000002384185791015625, -1.2999999523162841796875)) * 0.5) + vec3(0.5);
    _63.w += (_53 * cos(_194));
    vec3 _237 = _63.xyz * (_209 * _43._m0);
    _63 = vec4(_237.x, _237.y, _237.z, _63.w);
    _63.w += _107;
    _63.w = clamp(_63.w - (_89 * ((_43._m1 * 2.0) - 1.0)), 0.0, 1.0) * 0.5;
    vec3 _267 = _63.xyz + (((_209 * 30.0) * _43._m0) * _89);
    _63 = vec4(_267.x, _267.y, _267.z, _63.w);
    vec2 _270 = (_120.zw * 2.0) - vec2(1.0);
    vec2 _276 = vec2(1.0) - pow(abs(_270), vec2(2.0));
    _63.w *= min(_276.x, _276.y);
    vec3 _299 = _63.xyz * (sqrt(_73._m49) * 0.25);
    _63 = vec4(_299.x, _299.y, _299.z, _63.w);
    vec2 _302 = gl_FragCoord.xy * _308._m0.zw;
    vec4 _314 = texture(_318, _302);
    float _326 = 1.0 / gl_FragCoord.w;
    float _322 = _326;
    float _329 = _314.w;
    float _332 = 1000.0;
    float _379 = abs(_329 * (15000.0 / _332));
    float _327 = _379;
    _63.w *= clamp(abs(_327 - _322), 0.0, 1.0);
    _344 = vec4(_63.xyz, _63.w);
    float _358 = _326;
    float _359 = 256.0;
    float _386 = max(log(_358 * 20.0) * (_359 * 0.079292468726634979248046875), 0.0);
    _353 = vec4(_386, 0.0, 0.0, _63.w);
}

