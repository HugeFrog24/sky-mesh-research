#version 460

layout(binding = 0, std140) uniform _12_14
{
    mat4 _m0;
    mat4 _m1;
    vec3 _m2;
    float _m3;
} _14;

layout(binding = 2, std140) uniform _49_51
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
} _51;

layout(location = 0) in vec3 _21;
layout(location = 1) in vec4 _43;
layout(location = 3) in vec4 _100;
layout(location = 2) in vec4 _110;
layout(location = 0) out vec4 _207;
layout(location = 4) in vec4 _213;
layout(location = 5) in vec4 _232;

void main()
{
    vec3 _9 = (_14._m0 * vec4(_21, 1.0)).xyz;
    vec3 _30 = mat3(_14._m1[0].xyz, _14._m1[1].xyz, _14._m1[2].xyz) * _43.xyz;
    vec3 _47 = normalize(_51._m16 - _9);
    vec3 _59 = -_51._m38;
    vec3 _64 = _51._m73 - _9;
    _9 -= (_30 * (4.0 * max(0.5, 1.0 - (0.012500000186264514923095703125 * dot(_64, _64)))));
    gl_Position = _51._m8 * vec4(_9, 1.0);
    float _99 = _100.y * _100.y;
    vec3 _109 = ((_110.xyz * _110.xyz) / vec3(_110.w)) * mix(_51._m45, _51._m41, vec3(_100.x));
    _109 += (_51._m60 * (_100.w * exp2((255.0 * _100.z) - 128.0)));
    float _150 = dot(_47, _59);
    float _154 = _99 * (0.5 + (0.5 * mix(max(0.0, dot(_30, _59)), 1.0, max(0.0, -_150))));
    vec3 _168 = _14._m2 * ((_51._m41 * _154) + _109);
    float _179 = 0.02500000037252902984619140625;
    float _181 = _179 / (_179 - ((-1.0) - _150));
    _181 /= (_179 * log((2.0 / _179) + 1.0));
    _168 += (_51._m41 * ((2.0 * _181) * _99));
    _207 = vec4(_168.x, _168.y, _168.z, _207.w);
    vec4 _212 = vec4(equal(ivec4(_213 * 256.0), ivec4(int(_14._m3))));
    _207.w = dot(_212, _232);
    gl_Position.z = 0.5 * (gl_Position.z + gl_Position.w);
}

