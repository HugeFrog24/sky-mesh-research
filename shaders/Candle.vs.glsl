#version 460

layout(binding = 0, std140) uniform _11_13
{
    mat4 _m0;
    mat4 _m1;
    vec4 _m2;
} _13;

layout(binding = 2, std140) uniform _50_52
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
} _52;

layout(location = 0) out vec4 _9;
layout(location = 0) in vec3 _21;
layout(location = 1) out vec3 _30;
layout(location = 2) in vec3 _42;
layout(location = 2) out vec4 _59;
layout(location = 1) in vec4 _61;
layout(location = 4) out vec4 _73;
layout(location = 3) out vec4 _89;

void main()
{
    _9 = _13._m0 * vec4(_21, 1.0);
    _30 = normalize(mat3(_13._m1[0].xyz, _13._m1[1].xyz, _13._m1[2].xyz) * _42);
    gl_Position = _52._m8 * _9;
    _59 = _61;
    _59.z = (_59.z * 2.007874011993408203125) - 1.007874011993408203125;
    vec3 _86 = normalize(_52._m16 - (_9.xyz / vec3(_9.w)));
    _73 = vec4(_86.x, _86.y, _86.z, _73.w);
    _89 = _13._m2;
    _73.w = length(_21.xz) * 30.0;
    gl_Position.z = 0.5 * (gl_Position.z + gl_Position.w);
}

