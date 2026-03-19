#version 460

layout(binding = 2, std140) uniform _23_25
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
} _25;

layout(binding = 0, std140) uniform _114_116
{
    float _m0;
    float _m1;
} _116;

layout(binding = 3) uniform sampler3D _48;
layout(binding = 4) uniform sampler2D _79;

layout(location = 0) in vec4 _74;
layout(location = 1) in vec2 _82;
layout(location = 2) in vec3 _88;
layout(location = 0) out vec4 _135;

void main()
{
    float _60 = 1.60000002384185791015625;
    vec4 _72 = _74 * texture(_79, _82);
    vec3 _102 = _88 + ((vec3(-14.38000011444091796875, 3.367000102996826171875, 20.936000823974609375) * _25._m20) * 20.0);
    float _103 = 9.9999997473787516355514526367188e-05;
    _103 *= 0.5;
    vec3 _164 = (((_102 - _25._m70.xyz) * _103) * 0.015625) * 6.0;
    float _165 = _25._m69.w * textureLod(_48, _164, 0.0).x;
    float _86 = _165 / _25._m69.w;
    _86 *= _86;
    _86 *= _60;
    vec3 _122 = _72.xyz * _116._m0;
    _72 = vec4(_122.x, _122.y, _122.z, _72.w);
    _72.w *= (_116._m1 * _86);
    _135 = vec4(_72.xyz, _72.w);
}

