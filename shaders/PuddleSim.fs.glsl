#version 460

layout(binding = 2, std140) uniform _14_16
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
} _16;

layout(binding = 0) uniform sampler2D _32;

layout(location = 0) in vec2 _26;
layout(location = 1) out vec4 _90;
layout(location = 0) out vec4 _149;
layout(location = 1) in vec4 _159;

void main()
{
    float _8 = min(0.0500000007450580596923828125, _16._m21);
    vec2 _24 = _26;
    vec2 _28 = textureLodOffset(_32, _24, 0.0, ivec2(0)).xy;
    float _41 = textureLodOffset(_32, _24, 0.0, ivec2(0, -1)).x;
    float _50 = textureLodOffset(_32, _24, 0.0, ivec2(1, 0)).x;
    float _57 = textureLodOffset(_32, _24, 0.0, ivec2(0, 1)).x;
    float _63 = textureLodOffset(_32, _24, 0.0, ivec2(-1, 0)).x;
    float _69 = (((_41 - _28.x) + (_57 - _28.x)) + (_63 - _28.x)) + (_50 - _28.x);
    vec3 _106 = clamp(vec3(_63 - _28.x, _41 - _28.x, _28.x), vec3(-1.0), vec3(1.0));
    _90 = vec4(_106.x, _106.y, _106.z, _90.w);
    _90.w = 1.0;
    vec2 _112 = vec2(1.0) - (vec2(0.20000000298023223876953125, 1.0) * _8);
    _28 *= _112;
    _28.y += (_69 * (100.0 * _8));
    _28.y = min(1.0, abs(_28.y)) * sign(_28.y);
    _28.x += (_28.y * _8);
    _149 = vec4(_28.x, _28.y, _149.z, _149.w);
    _149 = vec4(_149.x, _149.y, vec2(1.0).x, vec2(1.0).y);
}

