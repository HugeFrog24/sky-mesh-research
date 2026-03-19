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

layout(binding = 0, std140) uniform _104_106
{
    vec4 _m0;
} _106;

layout(binding = 3) uniform sampler2D _44;

layout(location = 0) in vec3 _66;
layout(location = 0) out vec4 _100;
layout(location = 1) in vec4 _102;
layout(location = 1) out vec2 _112;
layout(location = 2) in vec2 _114;
layout(location = 2) out vec4 _116;
layout(location = 3) in vec4 _117;
layout(location = 3) out vec2 _119;

void main()
{
    gl_Position = _21._m8 * vec4(_66, 1.0);
    vec2 _89 = gl_Position.xy + ((_21._m31 * 2.0) * gl_Position.w);
    gl_Position = vec4(_89.x, _89.y, gl_Position.z, gl_Position.w);
    gl_Position.y *= _21._m30;
    _100 = _102 * _106._m0;
    _112 = _114;
    _116 = _117;
    vec2 _126 = gl_Position.xy * vec2(0.5, -0.5);
    vec2 _144 = _126 * vec2(1.0, _21._m4.x);
    float _145 = dot(_144, _144) * _21._m4.y;
    vec2 _146 = textureLod(_44, vec2(_145, 0.5), 0.0).xy;
    vec2 _147 = _144 * _146;
    _119 = _147;
    gl_Position.y *= (-1.0);
    gl_Position.z = 0.5 * (gl_Position.z + gl_Position.w);
}

