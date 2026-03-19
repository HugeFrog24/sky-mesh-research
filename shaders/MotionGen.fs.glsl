#version 460

layout(binding = 1, std140) uniform _29_31
{
    vec4 _m0;
} _31;

layout(binding = 2, std140) uniform _43_45
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
} _45;

layout(binding = 0) uniform sampler2D _79;
layout(binding = 3) uniform sampler2D _89;

layout(location = 0) out vec4 _178;
layout(location = 0) in vec2 _188;
layout(location = 1) in vec4 _189;

void main()
{
    vec2 _23 = gl_FragCoord.xy * _31._m0.zw;
    vec3 _41 = (_45._m35 + (_45._m33 * (_23.x + _45._m31.x))) + (_45._m34 * (_23.y + _45._m31.y));
    float _84 = texture(_79, _23).x;
    float _86 = 1000.0;
    float _190 = abs(_84 * (15000.0 / _86));
    float _75 = _190;
    float _93 = texture(_89, _23).x;
    float _95 = 1000.0;
    float _197 = abs(_93 * (15000.0 / _95));
    float _88 = _197;
    float _97 = max(0.0, 1.0 - exp2((-2.0) * (_75 - _88)));
    vec3 _108 = _45._m69.xyz * _97;
    _75 = mix(_75, _88, _97);
    vec3 _119 = (_45._m16 + (_41 * _75)) - _108;
    vec4 _130 = _45._m10 * vec4(_119, 1.0);
    _130 /= vec4(_130.w);
    _130 = (_130 * 0.5) + vec4(0.5);
    vec2 _152 = _23 - _130.xy;
    _152 = clamp(_152, vec2(-0.5), vec2(0.5));
    vec2 _162 = _152 * _31._m0.xy;
    float _168 = 0.00019999999494757503271102905273438 + dot(_162 * 0.100000001490116119384765625, _162 * 0.100000001490116119384765625);
    _178 = vec4(_152 * 1024.0, _75, _168);
}

