#version 460

layout(binding = 0, std140) uniform _26_28
{
    mat4 _m0;
    mat4 _m1;
    vec3 _m2;
    vec4 _m3;
    vec4 _m4;
    float _m5;
} _28;

layout(binding = 2, std140) uniform _36_38
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
} _38;

layout(binding = 1, std140) uniform _43_45
{
    vec4 _m0;
} _45;

layout(location = 4) out float _10;
layout(location = 5) in float _13;
layout(location = 4) in float _21;
layout(location = 0) in vec3 _68;
layout(location = 2) out vec3 _78;
layout(location = 1) out vec3 _85;
layout(location = 1) in vec3 _96;
layout(location = 0) out vec4 _100;
layout(location = 2) in vec4 _103;
layout(location = 3) out vec2 _113;
layout(location = 3) in vec2 _115;

void main()
{
    vec3 _63 = (_28._m0 * vec4(_68, 1.0)).xyz;
    _78 = _38._m16 - _63;
    _85 = mat3(_28._m1[0].xyz, _28._m1[1].xyz, _28._m1[2].xyz) * _96;
    _100 = vec4(1.0, 1.0, 1.0, _103.w);
    _100.z = 1.0;
    _113 = (_115 + _28._m3.xy) + (_28._m4.xy * _38._m20);
    _100.w = 1.0;
    gl_Position = _38._m8 * vec4(_63, 1.0);
    _10 = fract(floor(4.0 * _13) * 0.25);
    float _152 = (((_21 * _28._m5) * _38._m17) * _45._m0.y) / gl_Position.w;
    gl_PointSize = _152;
    gl_Position.z = 0.5 * (gl_Position.z + gl_Position.w);
}

