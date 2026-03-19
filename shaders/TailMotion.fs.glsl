#version 460

layout(binding = 1, std140) uniform _15_17
{
    vec4 _m0;
} _17;

layout(binding = 2, std140) uniform _38_40
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
} _40;

layout(location = 2) in vec3 _46;
layout(location = 0) out vec4 _89;
layout(location = 1) in vec4 _93;
layout(location = 0) in vec2 _123;

void main()
{
    vec2 _9 = gl_FragCoord.xy * _17._m0.zw;
    float _26 = 1.0 / gl_FragCoord.w;
    vec4 _35 = _40._m10 * vec4(_46, 1.0);
    _35 /= vec4(_35.w);
    _35 = (_35 * 0.5) + vec4(0.5);
    vec2 _63 = _9 - _35.xy;
    _63 = clamp(_63, vec2(-0.5), vec2(0.5));
    vec2 _73 = _63 * _17._m0.xy;
    float _79 = 0.00019999999494757503271102905273438 + dot(_73 * 0.100000001490116119384765625, _73 * 0.100000001490116119384765625);
    _89 = vec4((_63 * 1024.0) * _93.w, _26, _79 * _93.w);
}

