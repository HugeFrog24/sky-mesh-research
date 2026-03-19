#version 460

layout(binding = 1, std140) uniform _61_63
{
    vec4 _m0;
} _63;

layout(binding = 2, std140) uniform _74_76
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
} _76;

layout(binding = 0, std140) uniform _117_119
{
    mat4 _m0;
    vec4 _m1;
    vec2 _m2;
    vec2 _m3;
    vec2 _m4;
    vec2 _m5;
    vec2 _m6;
    vec2 _m7;
    vec2 _m8;
    vec2 _m9;
    float _m10;
} _119;

layout(binding = 3) uniform sampler2D _94;

layout(location = 0) in vec3 _253;
layout(location = 0) out vec4 _344;
layout(location = 1) out vec4 _351;

void main()
{
    vec3 _257 = _253;
    vec2 _374 = gl_FragCoord.xy * _63._m0.zw;
    vec3 _375 = normalize(_257 - _76._m16);
    vec3 _376 = normalize(-_76._m11[2].xyz);
    float _377 = texture(_94, _374).w;
    float _378 = 1000.0;
    float _422 = abs(_377 * (15000.0 / _378));
    float _261 = _422;
    vec3 _259 = _76._m16 + ((_375 * _261) / vec3(dot(_375, _376)));
    vec3 _260 = (_119._m0 * vec4(_259, 1.0)).xyz * 2.0;
    vec3 _254 = _259;
    vec3 _255 = _260;
    float _266 = length(_255.xz);
    float _270 = 0.5 + ((0.5 * sin(_76._m20 * 1.2999999523162841796875)) * sin((_76._m20 * 2.4700000286102294921875) + 1.5299999713897705078125));
    vec3 _288 = _119._m1.xyz * (10.0 - (5.0 * _270));
    float _299 = 0.0500000007450580596923828125;
    float _301 = 0.60000002384185791015625 * smoothstep(1.0, 0.0, abs(_266 - (1.0 - _299)) / _299);
    _301 += (0.4000000059604644775390625 * smoothstep(0.0, 1.0, 1.0 - (0.800000011920928955078125 * _266)));
    _301 *= (_119._m1.w * (_76._m22 * 8.0));
    vec3 _331 = _254;
    float _429 = 1.0;
    _429 *= clamp((length(_331.xz - _119._m2) - 0.3499999940395355224609375) * 3.5, 0.0, 1.0);
    _429 *= clamp((length(_331.xz - _119._m3) - 0.3499999940395355224609375) * 3.5, 0.0, 1.0);
    _429 *= clamp((length(_331.xz - _119._m4) - 0.3499999940395355224609375) * 3.5, 0.0, 1.0);
    _429 *= clamp((length(_331.xz - _119._m5) - 0.3499999940395355224609375) * 3.5, 0.0, 1.0);
    _429 *= clamp((length(_331.xz - _119._m6) - 0.3499999940395355224609375) * 3.5, 0.0, 1.0);
    _429 *= clamp((length(_331.xz - _119._m7) - 0.3499999940395355224609375) * 3.5, 0.0, 1.0);
    _429 *= clamp((length(_331.xz - _119._m8) - 0.3499999940395355224609375) * 3.5, 0.0, 1.0);
    _429 *= clamp((length(_331.xz - _119._m9) - 0.3499999940395355224609375) * 3.5, 0.0, 1.0);
    float _430 = _429;
    _301 *= _430;
    vec3 _336 = _255;
    float _521 = clamp((1.0 - abs(_336.y)) / clamp(_119._m10, 0.00999999977648258209228515625, 1.0), 0.0, 1.0);
    float _522 = smoothstep(0.0, 1.0, _521);
    _301 *= _522;
    _301 = clamp(_301, 0.0, 1.0);
    _344 = vec4(_288, _301);
    float _357 = 1.0 / gl_FragCoord.w;
    float _358 = 256.0;
    float _535 = max(log(_357 * 20.0) * (_358 * 0.079292468726634979248046875), 0.0);
    _351 = vec4(_535, 0.0, 0.0, _301);
}

