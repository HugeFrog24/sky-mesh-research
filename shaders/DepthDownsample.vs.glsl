#version 460

layout(binding = 2, std140) uniform _58_60
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
} _60;

layout(binding = 1, std140) uniform _89_91
{
    vec4 _m0;
} _91;

layout(location = 0) out vec2 _43;
layout(location = 1) out vec4 _55;

void main()
{
    int _8 = gl_VertexID;
    gl_Position.x = (_8 == 0) ? (-3.0) : 1.0;
    gl_Position.y = (_8 == 2) ? 3.0 : (-1.0);
    gl_Position.z = 0.0;
    gl_Position.w = 1.0;
    _43 = (gl_Position.xy * vec2(0.5)) + vec2(0.5);
    vec2 _53 = _43;
    vec3 _79 = (_60._m35 + (_60._m33 * _53.x)) + (_60._m34 * _53.y);
    _55 = vec4(_79.x, _79.y, _79.z, _55.w);
    _55.w = (0.5 * length(_60._m33 + _60._m34)) / length(_91._m0.xy);
    gl_Position.z = 0.5 * (gl_Position.z + gl_Position.w);
}

