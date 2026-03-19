#version 460

layout(binding = 2, std140) uniform _18_20
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
} _20;

layout(binding = 1, std140) uniform _52_54
{
    vec4 _m0;
} _54;

layout(binding = 3) uniform sampler2D _38;
layout(binding = 0) uniform sampler2D _103;

layout(location = 0) in vec2 _11;
layout(location = 0) out vec4 _140;
layout(location = 1) in vec4 _164;

void main()
{
    vec2 _9 = _11;
    vec2 _13 = (_9 - _20._m18.xy) * _20._m18.z;
    vec2 _34 = texture(_38, _9).xy;
    vec2 _43 = (_34 * 0.0009765625) + _13;
    float _50 = length(_43 * _54._m0.xy);
    float _62 = min(32.0, ceil(_50 * 0.5));
    if (_62 > 1.0)
    {
        _9 -= (_43 * 0.25);
        vec2 _80 = _43 * (0.5 / (_62 - 1.0));
        vec4 _88 = vec4(0.0);
        for (int _92 = 0; _92 < int(_62); _92++)
        {
            vec4 _102 = texture(_103, _9);
            _9 += _80;
            _88 += vec4(_102.xyz * _102.w, _102.w);
        }
        float _127 = min(1.0, (_88.w / _62) + (dot(_13, _13) * 10.0));
        _140 = vec4(_88.xyz / vec3(max(9.9999997473787516355514526367188e-05, _88.w)), _127);
    }
    else
    {
        _140 = vec4(texture(_103, _9).xyz, 0.0);
    }
}

