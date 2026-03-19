#version 460

layout(binding = 2, std140) uniform _104_106
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
} _106;

layout(binding = 1, std140) uniform _198_200
{
    vec4 _m0;
} _200;

layout(binding = 5) uniform sampler2D _81;
layout(binding = 0) uniform sampler2D _149;
layout(binding = 3) uniform sampler2D _173;
layout(binding = 4) uniform sampler2D _208;

layout(location = 0) in vec4 _65;
layout(location = 1) in vec3 _74;
layout(location = 0) out vec4 _234;
layout(location = 1) out vec4 _243;
layout(location = 2) in vec3 _267;

void main()
{
    vec2 _62 = _65.xy;
    vec2 _68 = _65.zw;
    vec2 _71 = _74.xy;
    float _77 = texture(_81, _68).w;
    _71 *= ((_77 - 0.5) * 2.0);
    vec4 _95 = texture(_81, _68 - _71);
    _95.w = 1.0;
    vec3 _117 = _95.xyz * (sqrt(_106._m49) * 0.25);
    _95 = vec4(_117.x, _117.y, _117.z, _95.w);
    vec2 _120 = (_62 * 2.0) - vec2(1.0);
    float _125 = dot(_120, _120);
    vec2 _130 = _120;
    float _268 = sqrt(dot(_130, _130));
    float _269 = atan(_130.y, _130.x);
    vec2 _270 = vec2(_268, _269);
    vec2 _129 = _270;
    _129.x += (_106._m20 * 0.20000000298023223876953125);
    _129.y += _125;
    float _148 = texture(_149, _129 * vec2(0.20000000298023223876953125, 0.31831014156341552734375)).x;
    _148 = pow(_148, 7.0);
    _148 *= _125;
    vec3 _169 = _95.xyz * (1.0 + (_148 * 50.0));
    _95 = vec4(_169.x, _169.y, _169.z, _95.w);
    float _172 = clamp(textureLod(_173, _129 * vec2(0.20000000298023223876953125, 0.31831014156341552734375), 2.0).x + (1.0 - pow(_125, 0.666666686534881591796875)), 0.0, 1.0);
    _95.w *= pow(_172, _125 * 10.0);
    vec2 _194 = gl_FragCoord.xy * _200._m0.zw;
    vec4 _207 = texture(_208, _194);
    float _216 = 1.0 / gl_FragCoord.w;
    float _212 = _216;
    float _219 = _207.w;
    float _222 = 1000.0;
    float _284 = abs(_219 * (15000.0 / _222));
    float _217 = _284;
    _95.w *= clamp(abs(_217 - _212), 0.0, 1.0);
    _234 = vec4(_95.xyz, _95.w);
    float _248 = _216;
    float _249 = 256.0;
    float _291 = max(log(_248 * 20.0) * (_249 * 0.079292468726634979248046875), 0.0);
    _243 = vec4(_291, 0.0, 0.0, _95.w);
}

