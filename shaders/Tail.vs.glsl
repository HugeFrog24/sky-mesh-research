#version 460

layout(binding = 2, std140) uniform _33_35
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
} _35;

layout(binding = 1, std140) uniform _96_98
{
    vec4 _m0;
} _98;

layout(binding = 0, std140) uniform _140_142
{
    float _m0;
} _142;

layout(location = 2) in vec4 _11;
layout(location = 1) in vec4 _17;
layout(location = 0) in vec3 _42;
layout(location = 0) out vec2 _52;
layout(location = 1) out vec4 _58;
layout(location = 3) in float _123;

void main()
{
    vec4 _9 = _11 * _11;
    float _16 = (abs(_17.x) * 0.24899999797344207763671875) + 0.001000000047497451305389404296875;
    vec3 _30 = (_35._m6 * vec4(_42, 1.0)).xyz;
    float _55 = sign(_17.x);
    _52 = vec2(_55);
    vec3 _62 = _9.xyz * 16.0;
    _58 = vec4(_62.x, _62.y, _62.z, _58.w);
    _58.w = _9.w;
    float _70 = min(1.0, max(0.0, (-0.800000011920928955078125) - _30.z) * 0.769230782985687255859375);
    _58.w *= pow(_70, 4.0);
    float _89 = ((_16 * _35._m17) * _98._m0.y) / (-_30.z);
    float _108 = max(1.0, (_58.w * 2.0) / _89);
    _16 *= _108;
    float _119 = _35._m20 - _123;
    float _126 = min(1.0, 8.0 * _119);
    float _131 = sqrt(1.0 - ((1.0 - _126) * (1.0 - _126)));
    float _139 = pow(clamp((_142._m0 - _119) / _142._m0, 0.0, 1.0), 1.2999999523162841796875);
    float _152 = 1.0;
    vec3 _153 = _17.yzw;
    vec3 _156 = normalize(_35._m16 - _42);
    vec3 _164 = cross(_153, _156);
    vec3 _168 = _42 + (_164 * (((((2.0 * _152) * _131) * _139) * _16) * _55));
    gl_Position = _35._m8 * vec4(_168, 1.0);
    gl_Position.z = 0.5 * (gl_Position.z + gl_Position.w);
}

