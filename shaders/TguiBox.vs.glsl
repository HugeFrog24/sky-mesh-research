#version 460

layout(binding = 2, std140) uniform _19_21
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
} _21;

layout(binding = 0, std140) uniform _74_76
{
    vec4 _m0;
} _76;

layout(binding = 3) uniform sampler2D _44;

layout(location = 0) in vec3 _62;
layout(location = 0) out vec4 _70;
layout(location = 1) in vec4 _72;
layout(location = 1) out vec2 _82;
layout(location = 2) in vec2 _84;
layout(location = 2) out vec2 _86;
layout(location = 3) in vec2 _87;
layout(location = 3) out vec2 _89;
layout(location = 4) in vec2 _90;
layout(location = 4) out vec4 _92;
layout(location = 5) in vec4 _93;
layout(location = 5) out vec2 _95;

void main()
{
    gl_Position = vec4(_62, 1.0);
    _70 = _72 * _76._m0;
    _82 = _84;
    _86 = _87;
    _89 = _90;
    _92 = _93;
    vec2 _102 = gl_Position.xy * vec2(0.5, -0.5);
    vec2 _122 = _102 * vec2(1.0, _21._m4.x);
    float _123 = dot(_122, _122) * _21._m4.y;
    vec2 _124 = textureLod(_44, vec2(_123, 0.5), 0.0).xy;
    vec2 _125 = _122 * _124;
    _95 = _125;
    gl_Position.y *= (-1.0);
    gl_Position.z = 0.5 * (gl_Position.z + gl_Position.w);
}

