#version 460

layout(binding = 2, std140) uniform _28_30
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
} _30;

layout(binding = 0, std140) uniform _168_170
{
    vec4 _m0;
} _170;

layout(binding = 3) uniform sampler2D _76;

layout(location = 2) in vec3 _39;
layout(location = 1) in vec3 _48;
layout(location = 3) in vec2 _66;
layout(location = 0) in vec4 _71;
layout(location = 0) out vec4 _216;

void main()
{
    vec3 _24 = -_30._m38;
    float _37 = length(_39);
    vec3 _42 = _39 / vec3(_37);
    vec3 _47 = normalize(_48);
    vec3 _51 = normalize(_42 + (_24 * 1.02499997615814208984375));
    float _58 = max(dot(_47, _24), 0.0);
    vec2 _64 = _66;
    vec4 _69 = _71 * texture(_76, _64);
    vec4 _81 = _69;
    vec3 _83 = _30._m41 * 1.0;
    vec3 _89 = _30._m49 * 1.0;
    vec3 _94 = _83 * _58;
    float _98 = mix(0.00999999977648258209228515625, 1.0, pow(clamp(1.0 - dot(_42, _51), 0.0, 1.0), 5.0));
    vec3 _108 = (_30._m41 * clamp(dot(_47, _24), 0.0, 1.0)) * vec3((4.0 * _98) * pow(max(dot(_47, _51), 0.0), 2.0));
    _108 += ((_89 * 0.5) * pow(clamp(1.0 - dot(_42, _47), 0.0, 1.0), 8.0));
    _81 = vec4((_69.xyz * (_89 + _94)) + _108, _69.w);
    vec3 _157 = vec3(0.0);
    float _159 = dot(_69.xyz, vec3(0.2989999949932098388671875, 0.58700001239776611328125, 0.114000000059604644775390625));
    bool _176 = _170._m0.x > 0.0;
    bool _184;
    if (_176)
    {
        _184 = _159 > (1.0 - _170._m0.x);
    }
    else
    {
        _184 = _176;
    }
    if (_184)
    {
        _157 = ((_69.xyz * _170._m0.y) * ((_159 - 1.0) + _170._m0.x)) / vec3(_170._m0.x);
    }
    _157 *= (1.0 + _170._m0.z);
    vec3 _212 = _81.xyz + _157;
    _81 = vec4(_212.x, _212.y, _212.z, _81.w);
    float _225 = 1.0 / gl_FragCoord.w;
    float _226 = 1000.0;
    float _247 = max(0.0, _225 * (_226 * 6.6666667407844215631484985351562e-05));
    _216 = vec4(_81.xyz, _247);
}

