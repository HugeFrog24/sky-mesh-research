#version 460

layout(binding = 2, std140) uniform _32_34
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
} _34;

layout(binding = 0, std140) uniform _272_274
{
    float _m0;
    float _m1;
    vec3 _m2;
} _274;

layout(binding = 1, std140) uniform _282_284
{
    vec4 _m0;
} _284;

layout(binding = 4) uniform sampler2D _58;
layout(binding = 3) uniform sampler2D _153;

layout(location = 0) in vec3 _96;
layout(location = 1) out vec3 _222;
layout(location = 1) in vec4 _232;
layout(location = 0) out vec3 _239;

void main()
{
    vec3 _94 = _96;
    vec3 _98 = _34._m16 - _94;
    float _104 = length(_98);
    float _112 = min(_104 * 0.00999999977648258209228515625, 1.0);
    vec3 _118 = _94;
    float _120 = 1.0;
    float _353 = 0.039999999105930328369140625 * _120;
    float _354 = 0.02500000037252902984619140625 * _120;
    vec2 _355 = fract((_118.xz * _353) + _34._m58.xz);
    vec2 _356 = fract((_118.xz * _354) + _34._m59.xz);
    vec2 _357 = (textureLod(_58, _356, 0.0).xy * 2.0) - vec2(1.0);
    vec4 _358 = textureLod(_58, _355, 0.0);
    vec2 _401 = ((_358.xy - vec2(0.5)) * _357) + vec2(0.5);
    _358 = vec4(_401.x, _401.y, _358.z, _358.w);
    vec2 _359 = vec2(1.0) - (_358.xy * 2.0);
    vec2 _360 = _359;
    vec2 _117 = _360;
    vec2 _129 = _94.xz + (_117 * mix(0.0500000007450580596923828125, 1.0, _112));
    _94 = vec3(_129.x, _94.y, _129.y);
    _94.y += 0.00999999977648258209228515625;
    vec2 _138 = (_94.xz - _34._m54.xy) * _34._m54.w;
    vec4 _152 = textureLod(_153, _138, 0.0);
    float _157 = max((_152.w * 8.0) - 4.0, 0.0);
    vec2 _165 = (_152.xy * 2.0) * _157;
    vec2 _174 = _94.xz - _165;
    _94 = vec3(_174.x, _94.y, _174.y);
    vec3 _187 = normalize(vec3(-_117.x, 0.5, -_117.y));
    vec3 _201 = vec3(_34._m6[0].x, _34._m6[1].x, _34._m6[2].x);
    vec3 _213 = vec3(_34._m6[0].y, _34._m6[1].y, _34._m6[2].y);
    _222 = vec3(normalize(vec2(dot(_201, _187), dot(_213, _187))), _232.w);
    _239 = vec3(0.0);
    float _241 = 0.20000000298023223876953125 * _232.x;
    gl_Position = _34._m8 * vec4(_94, 1.0);
    gl_Position.z -= 0.001000000047497451305389404296875;
    float _268 = ((((0.5 * _232.z) * _274._m1) * _34._m17) * _284._m0.y) / pow(gl_Position.w, 0.75);
    _268 *= (1.0 + clamp(abs(_94.y - _34._m16.y) * 0.00999999977648258209228515625, 0.0, 1.0));
    float _305 = min(1.0, _268 * 0.5);
    _241 *= pow(_305, 1.5);
    gl_PointSize = max(_268, 2.0);
    _222 = vec3((_222.z < 0.5) ? _241 : 0.0, (_222.z < 0.5) ? 0.0 : _241, (_222.z * _222.x) * 0.4000000059604644775390625);
    gl_Position.z = 0.5 * (gl_Position.z + gl_Position.w);
}

