#version 460

layout(binding = 2, std140) uniform _96_98
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
} _98;

layout(binding = 0) uniform sampler2D _80;
layout(binding = 3) uniform sampler2D _87;
layout(binding = 4) uniform sampler2D _144;

layout(location = 0) in vec2 _74;
layout(location = 0) out vec4 _200;
layout(location = 1) in vec4 _218;

void main()
{
    vec2 _72 = _74;
    vec2 _76 = textureLod(_80, _72, 0.0).xy;
    vec3 _86 = textureLod(_87, _72, 0.0).xyz;
    vec3 _92 = textureLod(_87, _72 + _98._m14.xy, 0.0).xyz;
    vec3 _108 = textureLod(_87, _72 + _98._m14.zw, 0.0).xyz;
    vec3 _117 = textureLod(_87, _72 + _98._m15.xy, 0.0).xyz;
    vec3 _127 = textureLod(_87, _72 + _98._m15.zw, 0.0).xyz;
    vec2 _136 = _72 - (_76 * 0.0009765625);
    vec4 _143 = textureLod(_144, _136, 0.0);
    vec3 _148 = min(_92, min(_108, min(_86, min(_117, _127))));
    vec3 _158 = max(_92, max(_108, max(_86, max(_117, _127))));
    vec3 _173;
    if (_98._m26 > 0.0)
    {
        _173 = _86;
    }
    else
    {
        vec3 _179 = _143.xyz;
        vec3 _182 = _148;
        vec3 _184 = _158;
        bool _186 = false;
        vec3 _219 = (_184 + _182) * 0.5;
        vec3 _220 = (_184 - _182) * 0.5;
        vec3 _221 = _179 - _219;
        vec3 _222 = abs(_220) / max(abs(_221), vec3(9.9999997473787516355514526367188e-05));
        float _223 = clamp(min(_222.x, min(_222.y, _222.z)) + (_186 ? 0.75 : 0.0), 0.0, 1.0);
        vec3 _224 = _219 + (_221 * _223);
        _173 = _224;
    }
    _143 = vec4(_173.x, _173.y, _173.z, _143.w);
    float _191 = max(1.0 - (length(_76) * 0.20000000298023223876953125), 0.85000002384185791015625);
    vec3 _208 = mix(_86, _143.xyz, vec3(0.800000011920928955078125 * _191));
    _200 = vec4(_208.x, _208.y, _208.z, _200.w);
    _200.w = 1.0;
}

