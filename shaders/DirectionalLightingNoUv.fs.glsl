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

layout(binding = 0, std140) uniform _155_157
{
    vec4 _m0;
} _157;

layout(location = 2) in vec3 _39;
layout(location = 1) in vec3 _48;
layout(location = 0) in vec4 _66;
layout(location = 0) out vec4 _203;

void main()
{
    vec3 _24 = -_30._m38;
    float _37 = length(_39);
    vec3 _42 = _39 / vec3(_37);
    vec3 _47 = normalize(_48);
    vec3 _51 = normalize(_42 + (_24 * 1.02499997615814208984375));
    float _58 = max(dot(_47, _24), 0.0);
    vec4 _64 = _66;
    vec4 _68 = _64;
    vec3 _70 = _30._m41 * 1.0;
    vec3 _76 = _30._m49 * 1.0;
    vec3 _81 = _70 * _58;
    float _85 = mix(0.00999999977648258209228515625, 1.0, pow(clamp(1.0 - dot(_42, _51), 0.0, 1.0), 5.0));
    vec3 _95 = (_30._m41 * clamp(dot(_47, _24), 0.0, 1.0)) * vec3((4.0 * _85) * pow(max(dot(_47, _51), 0.0), 2.0));
    _95 += ((_76 * 0.5) * pow(clamp(1.0 - dot(_42, _47), 0.0, 1.0), 8.0));
    _68 = vec4((_64.xyz * (_76 + _81)) + _95, _64.w);
    vec3 _144 = vec3(0.0);
    float _146 = dot(_64.xyz, vec3(0.2989999949932098388671875, 0.58700001239776611328125, 0.114000000059604644775390625));
    bool _163 = _157._m0.x > 0.0;
    bool _171;
    if (_163)
    {
        _171 = _146 > (1.0 - _157._m0.x);
    }
    else
    {
        _171 = _163;
    }
    if (_171)
    {
        _144 = ((_64.xyz * _157._m0.y) * ((_146 - 1.0) + _157._m0.x)) / vec3(_157._m0.x);
    }
    _144 *= (1.0 + _157._m0.z);
    vec3 _199 = _68.xyz + _144;
    _68 = vec4(_199.x, _199.y, _199.z, _68.w);
    float _212 = 1.0 / gl_FragCoord.w;
    float _213 = 1000.0;
    float _238 = max(0.0, _212 * (_213 * 6.6666667407844215631484985351562e-05));
    _203 = vec4(_68.xyz, _238);
}

