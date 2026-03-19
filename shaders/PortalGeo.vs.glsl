#version 460

layout(binding = 0, std140) uniform _12_14
{
    mat4 _m0;
    mat4 _m1;
    float _m2;
} _14;

layout(binding = 2, std140) uniform _34_36
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
} _36;

layout(location = 2) out vec3 _9;
layout(location = 0) in vec3 _21;
layout(location = 0) out vec4 _68;
layout(location = 1) in vec2 _70;
layout(location = 1) out vec3 _133;
layout(location = 2) in vec4 _164;
layout(location = 3) in vec3 _165;

void main()
{
    _9 = (_14._m0 * vec4(_21, 1.0)).xyz;
    gl_Position = _36._m8 * vec4(_9, 1.0);
    vec2 _49 = _36._m53.xy * 0.1500000059604644775390625;
    float _58 = _14._m2 * _36._m53.x;
    _68 = vec4(_70.x, _70.y, _68.z, _68.w);
    vec2 _94 = (vec2(fract(_58), floor(_58) * _36._m53.y) + _49) + ((_36._m53.xy - (_49 * 2.0)) * _70);
    _68 = vec4(_68.x, _68.y, _94.x, _94.y);
    vec3 _98 = _14._m0[3].xyz;
    vec3 _103 = normalize(_36._m16 - _98);
    vec3 _111 = _14._m0[2].xyz;
    vec3 _115 = _14._m0[0].xyz;
    float _119 = length(_111);
    float _122 = length(_115);
    _111 /= vec3(_119);
    _115 /= vec3(_122);
    vec2 _142 = vec2(dot(_115, _103), dot(_111, _103)) * (-0.0500000007450580596923828125);
    _133 = vec3(_142.x, _142.y, _133.z);
    _133.z = _119 / _122;
    gl_Position.z = 0.5 * (gl_Position.z + gl_Position.w);
}

