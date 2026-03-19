#version 460

layout(binding = 2, std140) uniform _32_34
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
} _34;

layout(binding = 1, std140) uniform _92_94
{
    vec4 _m0;
} _94;

layout(binding = 0) uniform sampler3D _57;
layout(binding = 4) uniform sampler2D _104;
layout(binding = 3) uniform sampler2D _130;

layout(location = 6) in float _128;
layout(location = 4) in vec2 _133;
layout(location = 5) in vec2 _141;
layout(location = 1) in vec3 _149;
layout(location = 3) in vec3 _151;
layout(location = 0) in vec3 _167;
layout(location = 0) out vec4 _188;
layout(location = 2) in vec3 _189;
layout(location = 1) out vec4 _196;

void main()
{
    vec2 _87 = gl_FragCoord.xy * _94._m0.zw;
    float _109 = texture(_104, _87).w;
    float _111 = 1000.0;
    float _221 = abs(_109 * (15000.0 / _111));
    float _100 = _221;
    float _113 = 1.0 / gl_FragCoord.w;
    float _119 = max(0.0, 1.0 - exp2((-2.0) * (_100 - _113)));
    _119 *= (_128 * texture(_130, _133).w);
    _119 *= (1.0 + (5.0 * _141.x));
    _119 *= abs(dot(_149, normalize(_151)));
    _119 *= (clamp(_113 - 2.0, 0.0, 10.0) * 0.100000001490116119384765625);
    vec3 _169 = _167;
    float _171 = 0.25;
    _171 *= 0.5;
    vec3 _228 = (((_169 - _34._m70.xyz) * _171) * 0.015625) * 6.0;
    float _229 = _34._m69.w * textureLod(_57, _228, 0.0).x;
    _119 *= mix(1.0, _229 / _34._m69.w, _141.y);
    _119 = 1.0 - exp2((-3.0) * _119);
    _188 = vec4(_189, _119);
    float _198 = _113;
    float _200 = 256.0;
    float _249 = max(log(_198 * 20.0) * (_200 * 0.079292468726634979248046875), 0.0);
    _196 = vec4(_249, 0.0, 0.0, _119);
}

