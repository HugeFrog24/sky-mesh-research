#version 460

layout(binding = 1, std140) uniform _58_60
{
    vec4 _m0;
} _60;

layout(binding = 2, std140) uniform _71_73
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
} _73;

layout(binding = 0, std140) uniform _114_116
{
    vec4 _m0;
    float _m1;
    float _m2;
    mat4 _m3;
    vec2 _m4;
    vec2 _m5;
    vec2 _m6;
    vec2 _m7;
    vec2 _m8;
    vec2 _m9;
    vec2 _m10;
    vec2 _m11;
    float _m12;
} _116;

layout(binding = 4) uniform sampler2D _91;
layout(binding = 3) uniform sampler2D _209;

layout(location = 2) in vec3 _155;
layout(location = 1) in vec3 _164;
layout(location = 4) in vec2 _181;
layout(location = 3) in vec3 _183;
layout(location = 0) in vec4 _207;
layout(location = 0) out vec4 _284;
layout(location = 1) out vec4 _293;

void main()
{
    vec2 _179 = _181;
    vec3 _187 = _183;
    vec2 _318 = gl_FragCoord.xy * _60._m0.zw;
    vec3 _319 = normalize(_187 - _73._m16);
    vec3 _320 = normalize(-_73._m11[2].xyz);
    float _321 = texture(_91, _318).w;
    float _322 = 1000.0;
    float _366 = abs(_321 * (15000.0 / _322));
    float _191 = _366;
    vec3 _189 = _73._m16 + ((_319 * _191) / vec3(dot(_319, _320)));
    vec3 _190 = (_116._m3 * vec4(_189, 1.0)).xyz * 2.0;
    vec3 _185 = _190;
    _179 = clamp((_185.xz * 0.5) + vec2(0.5), vec2(0.0), vec2(1.0));
    vec4 _206 = _207 * texture(_209, _179);
    vec3 _214 = _185;
    float _373 = clamp((1.0 - abs(_214.y)) / clamp(_116._m12, 0.00999999977648258209228515625, 1.0), 0.0, 1.0);
    float _374 = smoothstep(0.0, 1.0, _373);
    _206.w *= _374;
    vec4 _221 = _206;
    vec3 _223 = vec3(0.0);
    float _225 = dot(_206.xyz, vec3(0.2989999949932098388671875, 0.58700001239776611328125, 0.114000000059604644775390625));
    bool _237 = _116._m0.x > 0.0;
    bool _245;
    if (_237)
    {
        _245 = _225 > (1.0 - _116._m0.x);
    }
    else
    {
        _245 = _237;
    }
    if (_245)
    {
        _223 = ((_206.xyz * _116._m0.y) * ((_225 - 1.0) + _116._m0.x)) / vec3(_116._m0.x);
    }
    _223 *= (1.0 + _116._m0.z);
    vec3 _272 = _221.xyz + _223;
    _221 = vec4(_272.x, _272.y, _272.z, _221.w);
    _221.w *= (1.0 - _116._m1);
    _284 = vec4(_221.xyz, _221.w);
    float _299 = 1.0 / gl_FragCoord.w;
    float _300 = 256.0;
    float _387 = max(log(_299 * 20.0) * (_300 * 0.079292468726634979248046875), 0.0);
    _293 = vec4(_387, 0.0, 0.0, _221.w);
}

