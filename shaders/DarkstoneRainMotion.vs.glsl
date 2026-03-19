#version 460

layout(binding = 0, std140) uniform _67_69
{
    vec3 _m0;
} _69;

layout(binding = 2, std140) uniform _91_93
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
} _93;

layout(location = 0) in vec4 _11;
layout(location = 2) in vec3 _21;
layout(location = 3) in vec3 _23;
layout(location = 5) in vec3 _63;
layout(location = 0) out vec3 _107;
layout(location = 1) in vec4 _121;
layout(location = 4) in vec4 _151;
layout(location = 6) in vec3 _152;
layout(location = 7) in vec4 _153;
layout(location = 8) in vec4 _154;

void main()
{
    float _8 = _11.w;
    vec3 _19 = cross(_21, _23);
    vec3 _26 = _21 * _8;
    vec3 _30 = _23 * _8;
    vec3 _34 = (_19 * _8) * 1.5;
    mat3 _42 = mat3(_26, _30, _34);
    vec3 _61 = _42 * _63;
    _61 = (_61 + ((_69._m0 * dot(_61, _69._m0)) * 0.5)) + _11.xyz;
    gl_Position = _93._m8 * vec4(_61, 1.0);
    _107 = _42 * _63;
    _107 = (_107 + ((_69._m0 * dot(_107, _69._m0)) * 0.5)) + _121.xyz;
    gl_Position.z = 0.5 * (gl_Position.z + gl_Position.w);
}

