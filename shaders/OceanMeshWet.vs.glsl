#version 460

layout(binding = 0, std140) uniform _38_40
{
    mat4 _m0;
    vec3 _m1;
    vec3 _m2;
    vec3 _m3;
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
layout(location = 6) out vec3 _93;
layout(location = 2) out vec3 _95;
layout(location = 3) out vec4 _118;
layout(location = 4) out vec4 _176;
layout(location = 5) out float _206;

void main()
{
    vec3 _35 = (_40._m0 * vec4(_47.xyz, 1.0)).xyz;
    _57 = normalize(_35 - _62._m50.xyz);
    _70 = normalize((_71.xyz * 3.0) + _57);
    _93 = _35;
    _95 = _62._m16 - _35;
    gl_Position = _62._m8 * vec4(_93, 1.0);
    float _117 = 1.0;
    vec2 _145 = (((((_35.xz + _62._m27.xz) * 77.0) * vec2(0.00048828125)) - floor((_62._m16.xz * 77.0) * vec2(0.00048828125))) * _117) + _40._m1.xz;
    _118 = vec4(_145.x, _145.y, _118.z, _118.w);
    vec2 _173 = (((((_35.xz + _62._m27.xz) * 296.0) * vec2(0.001953125)) - floor((_62._m16.xz * 296.0) * vec2(0.001953125))) * _117) + _40._m2.xz;
    _118 = vec4(_118.x, _118.y, _173.x, _173.y);
    vec2 _202 = (((((_35.xz + _62._m27.xz) * 104.0) * vec2(0.0009765625)) - floor((_62._m16.xz * 104.0) * vec2(0.0009765625))) * _117) + _40._m3.xz;
    _176 = vec4(_202.x, _202.y, _176.z, _176.w);
    _206 = length(_62._m50.xyz - _62._m16) - _62._m50.w;
    gl_Position.z = 0.5 * (gl_Position.z + gl_Position.w);
}

