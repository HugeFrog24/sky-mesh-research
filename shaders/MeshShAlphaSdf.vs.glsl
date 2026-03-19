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

layout(binding = 0, std140) uniform _77_79
{
    mat4 _m0;
    mat4 _m1;
} _79;

layout(binding = 3) uniform samplerCube _154;

layout(location = 0) in vec3 _85;
layout(location = 0) out vec3 _115;
layout(location = 2) in vec3 _127;
layout(location = 1) out vec4 _131;
layout(location = 1) in vec4 _133;
layout(location = 5) out vec3 _135;
layout(location = 8) out vec3 _149;
layout(location = 9) out vec3 _161;
layout(location = 6) out vec4 _167;
layout(location = 3) in vec4 _168;
layout(location = 7) out vec4 _170;
layout(location = 4) in vec4 _171;
layout(location = 5) in vec4 _173;
layout(location = 6) in vec4 _175;
layout(location = 7) in vec4 _177;
layout(location = 2) out vec4 _179;
layout(location = 3) out vec4 _180;
layout(location = 4) out vec4 _181;

void main()
{
    vec3 _76 = (_79._m0 * vec4(_85, 1.0)).xyz;
    gl_Position = _31._m8 * vec4(_76, 1.0);
    gl_Position.z -= 0.0005000000237487256526947021484375;
    _115 = normalize(mat3(_79._m1[0].xyz, _79._m1[1].xyz, _79._m1[2].xyz) * _127);
    _131 = _133;
    _135 = _31._m16 - _76;
    vec3 _141 = normalize(_135);
    vec3 _144 = reflect(-_141, _115);
    _149 = vec3(1.0) / textureLod(_154, _115, 5.0).xyz;
    _161 = vec3(1.0) / textureLod(_154, _144, 5.0).xyz;
    _167 = _168;
    _170 = _171;
    vec4 _182 = vec4(((_173.xyz * _173.xyz) / vec3(_173.w)) * mix(_31._m45, _31._m41, vec3(_175.x)), _175.w * exp2((255.0 * _175.z) - 128.0));
    vec4 _183 = vec4(_175.y * _175.y, 0.0, 0.0, 0.0);
    vec4 _184 = vec4((_177.xyz * 2.007874011993408203125) - vec3(1.007874011993408203125), _177.w);
    _179 = _182;
    _180 = _183;
    _181 = _184;
    gl_Position.z = 0.5 * (gl_Position.z + gl_Position.w);
}

