#version 460

layout(binding = 0, std140) uniform _40_42
{
    mat4 _m0;
} _42;

layout(binding = 2, std140) uniform _62_64
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
} _64;

layout(location = 0) in vec4 _49;
layout(location = 1) out vec3 _59;
layout(location = 0) out vec3 _72;
layout(location = 1) in vec4 _73;
layout(location = 6) out vec3 _141;
layout(location = 2) out vec3 _143;
layout(location = 3) out vec4 _166;
layout(location = 4) out vec4 _224;
layout(location = 5) out float _254;

void main()
{
    float _31 = 1.0;
    float _32 = 1.0;
    _31 = 0.25;
    _32 = 0.5;
    vec3 _37 = (_42._m0 * vec4(_49.xyz, 1.0)).xyz;
    _59 = normalize(_37 - _64._m50.xyz);
    _72 = normalize((_73.xyz * 3.0) + _59);
    float _91 = length(_37 - _64._m16);
    float _92 = 25.0;
    float _93 = 10.0;
    float _290 = clamp((_91 * (1.0 / (_93 - _92))) - (_92 / (_93 - _92)), 0.0, 1.0);
    float _81 = _290;
    float _95 = ((sin(_37.x) * sin(((_37.z * 0.300000011920928955078125) / _31) + _64._m20)) + sin(((_37.x * (-0.4000000059604644775390625)) / _31) + (_64._m20 * 1.25))) * 0.0500000007450580596923828125;
    _37.y += ((_95 * _32) * _81);
    _141 = _37;
    _143 = _64._m16 - _37;
    gl_Position = _64._m8 * vec4(_141, 1.0);
    float _165 = 1.0;
    vec2 _193 = (((((_37.xz + _64._m27.xz) * 77.0) * vec2(0.00048828125)) - floor((_64._m16.xz * 77.0) * vec2(0.00048828125))) * _165) + _64._m57.xz;
    _166 = vec4(_193.x, _193.y, _166.z, _166.w);
    vec2 _221 = (((((_37.xz + _64._m27.xz) * 296.0) * vec2(0.001953125)) - floor((_64._m16.xz * 296.0) * vec2(0.001953125))) * _165) + _64._m58.xz;
    _166 = vec4(_166.x, _166.y, _221.x, _221.y);
    vec2 _250 = (((((_37.xz + _64._m27.xz) * 104.0) * vec2(0.0009765625)) - floor((_64._m16.xz * 104.0) * vec2(0.0009765625))) * _165) + _64._m59.xz;
    _224 = vec4(_250.x, _250.y, _224.z, _224.w);
    _254 = length(_64._m50.xyz - _64._m16) - _64._m50.w;
    gl_Position.z = 0.5 * (gl_Position.z + gl_Position.w);
}

