#version 460

layout(binding = 2, std140) uniform _31_33
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
} _33;

layout(binding = 0, std140) uniform _171_173
{
    vec4 _m0;
    float _m1;
    float _m2;
} _173;

layout(binding = 3) uniform sampler2D _79;

layout(location = 2) in vec3 _42;
layout(location = 1) in vec3 _51;
layout(location = 3) in vec2 _69;
layout(location = 0) in vec4 _74;
layout(location = 0) out vec4 _262;
layout(location = 1) out vec4 _271;

void main()
{
    vec3 _27 = -_33._m38;
    float _40 = length(_42);
    vec3 _45 = _42 / vec3(_40);
    vec3 _50 = normalize(_51);
    vec3 _54 = normalize(_45 + (_27 * 1.02499997615814208984375));
    float _61 = max(dot(_50, _27), 0.0);
    vec2 _67 = _69;
    vec4 _72 = _74 * texture(_79, _67);
    vec4 _84 = _72;
    vec3 _86 = _33._m41 * 1.0;
    vec3 _92 = _33._m49 * 1.0;
    vec3 _97 = _86 * _61;
    float _101 = mix(0.00999999977648258209228515625, 1.0, pow(clamp(1.0 - dot(_45, _54), 0.0, 1.0), 5.0));
    vec3 _111 = (_33._m41 * clamp(dot(_50, _27), 0.0, 1.0)) * vec3((4.0 * _101) * pow(max(dot(_50, _54), 0.0), 2.0));
    _111 += ((_92 * 0.5) * pow(clamp(1.0 - dot(_45, _50), 0.0, 1.0), 8.0));
    _84 = vec4((_72.xyz * (_92 + _97)) + _111, _72.w);
    vec3 _160 = vec3(0.0);
    float _162 = dot(_72.xyz, vec3(0.2989999949932098388671875, 0.58700001239776611328125, 0.114000000059604644775390625));
    bool _179 = _173._m0.x > 0.0;
    bool _187;
    if (_179)
    {
        _187 = _162 > (1.0 - _173._m0.x);
    }
    else
    {
        _187 = _179;
    }
    if (_187)
    {
        _160 = ((_72.xyz * _173._m0.y) * ((_162 - 1.0) + _173._m0.x)) / vec3(_173._m0.x);
    }
    _160 *= (1.0 + _173._m0.z);
    vec3 _215 = _84.xyz + _160;
    _84 = vec4(_215.x, _215.y, _215.z, _84.w);
    float _218 = dot(_50, _45);
    if (_173._m2 >= 0.0)
    {
        _84.w *= mix(1.0, pow(abs(_218), 3.0), _173._m2);
    }
    else
    {
        _84.w *= mix(1.0, pow(1.0099999904632568359375 - abs(_218), 3.0), -_173._m2);
    }
    _84.w *= (1.0 - _173._m1);
    _262 = vec4(_84.xyz, _84.w);
    float _278 = 1.0 / gl_FragCoord.w;
    float _279 = 256.0;
    float _299 = max(log(_278 * 20.0) * (_279 * 0.079292468726634979248046875), 0.0);
    _271 = vec4(_299, 0.0, 0.0, _84.w);
}

