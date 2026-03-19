#version 460

layout(binding = 2, std140) uniform _29_31
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
} _31;

layout(binding = 0, std140) uniform _95_97
{
    mat4 _m0;
    mat4 _m1;
    vec3 _m2;
    float _m3;
    float _m4;
} _97;

layout(binding = 3) uniform samplerCube _217;

layout(location = 2) in vec4 _76;
layout(location = 3) in vec4 _78;
layout(location = 4) in vec4 _80;
layout(location = 3) out vec4 _83;
layout(location = 4) out vec4 _84;
layout(location = 5) out vec4 _85;
layout(location = 1) out vec3 _94;
layout(location = 1) in vec4 _110;
layout(location = 0) in vec3 _120;
layout(location = 2) out vec4 _150;
layout(location = 0) out vec3 _158;
layout(location = 7) out vec4 _171;
layout(location = 8) out vec2 _194;
layout(location = 9) out vec3 _212;
layout(location = 10) out vec3 _224;
layout(location = 5) in vec4 _230;
layout(location = 6) out vec4 _235;

void main()
{
    vec4 _86 = vec4(((_76.xyz * _76.xyz) / vec3(_76.w)) * mix(_31._m45, _31._m41, vec3(_78.x)), _78.w * exp2((255.0 * _78.z) - 128.0));
    vec4 _87 = vec4(_78.y * _78.y, 0.0, 0.0, 0.0);
    vec4 _88 = vec4((_80.xyz * 2.007874011993408203125) - vec3(1.007874011993408203125), _80.w);
    _83 = _86;
    _84 = _87;
    _85 = _88;
    _94 = mat3(_97._m1[0].xyz, _97._m1[1].xyz, _97._m1[2].xyz) * _110.xyz;
    vec3 _115 = (_97._m0 * vec4(_120, 1.0)).xyz;
    vec3 _129 = _115;
    gl_Position = _31._m8 * vec4(_129, 1.0);
    float _145 = _97._m3;
    _150 = vec4(_97._m2, 1.0);
    _158 = _31._m16 - _129;
    vec3 _164 = normalize(_158);
    vec3 _167 = _115 * _145;
    vec2 _181 = _167.zy * vec2(-sign(_94.x), -1.0);
    _171 = vec4(_181.x, _181.y, _171.z, _171.w);
    vec2 _190 = _167.xz * vec2(sign(_94.y), 1.0);
    _171 = vec4(_171.x, _171.y, _190.x, _190.y);
    _194 = _167.xy * vec2(sign(_94.z), -1.0);
    _194.y += 0.5;
    vec3 _207 = reflect(-_164, _94);
    _212 = vec3(1.0) / textureLod(_217, _94, 5.0).xyz;
    _224 = vec3(1.0) / textureLod(_217, _207, 5.0).xyz;
    _150.w = _230.w;
    _235 = vec4(mix((_150.xyz * 0.014999999664723873138427734375) + vec3(0.0350000001490116119384765625), _150.xyz, vec3(_97._m4)), 1.0 - _97._m4);
    gl_Position.z = 0.5 * (gl_Position.z + gl_Position.w);
}

