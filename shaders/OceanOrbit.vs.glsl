#version 460

layout(binding = 0, std140) uniform _38_40
{
    mat4 _m0;
} _40;

layout(binding = 2, std140) uniform _60_62
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
} _62;

layout(location = 0) in vec4 _47;
layout(location = 1) out vec3 _57;
layout(location = 0) out vec3 _70;
layout(location = 1) in vec4 _71;
layout(location = 6) out vec3 _139;
layout(location = 2) out vec3 _141;
layout(location = 3) out vec4 _164;
layout(location = 4) out vec4 _222;
layout(location = 5) out float _252;
layout(location = 7) out vec2 _265;
layout(location = 8) out vec2 _272;

void main()
{
    float _31 = 1.0;
    float _32 = 1.0;
    vec3 _35 = (_40._m0 * vec4(_47.xyz, 1.0)).xyz;
    _57 = normalize(_35 - _62._m50.xyz);
    _70 = normalize((_71.xyz * 3.0) + _57);
    float _89 = length(_35 - _62._m16);
    float _90 = 25.0;
    float _91 = 10.0;
    float _311 = clamp((_89 * (1.0 / (_91 - _90))) - (_90 / (_91 - _90)), 0.0, 1.0);
    float _79 = _311;
    float _93 = ((sin(_35.x) * sin(((_35.z * 0.300000011920928955078125) / _31) + _62._m20)) + sin(((_35.x * (-0.4000000059604644775390625)) / _31) + (_62._m20 * 1.25))) * 0.0500000007450580596923828125;
    _35.y += ((_93 * _32) * _79);
    _139 = _35;
    _141 = _62._m16 - _35;
    gl_Position = _62._m8 * vec4(_139, 1.0);
    float _163 = 1.0;
    vec2 _191 = (((((_35.xz + _62._m27.xz) * 77.0) * vec2(0.00048828125)) - floor((_62._m16.xz * 77.0) * vec2(0.00048828125))) * _163) + _62._m57.xz;
    _164 = vec4(_191.x, _191.y, _164.z, _164.w);
    vec2 _219 = (((((_35.xz + _62._m27.xz) * 296.0) * vec2(0.001953125)) - floor((_62._m16.xz * 296.0) * vec2(0.001953125))) * _163) + _62._m58.xz;
    _164 = vec4(_164.x, _164.y, _219.x, _219.y);
    vec2 _248 = (((((_35.xz + _62._m27.xz) * 104.0) * vec2(0.0009765625)) - floor((_62._m16.xz * 104.0) * vec2(0.0009765625))) * _163) + _62._m59.xz;
    _222 = vec4(_248.x, _248.y, _222.z, _222.w);
    _252 = length(_62._m50.xyz - _62._m16) - _62._m50.w;
    vec2 _270 = vec2(_62._m50.w);
    _265 = _35.xz / _270;
    _272 = (_35.xz + (_141.xz * (400.0 / _252))) / _270;
    gl_Position.z = 0.5 * (gl_Position.z + gl_Position.w);
}

