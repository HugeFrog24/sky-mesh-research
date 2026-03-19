#version 460

layout(binding = 2, std140) uniform _155_157
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
} _157;

layout(location = 0) in vec2 _132;
layout(location = 1) in vec4 _198;
layout(location = 0) out vec4 _205;
layout(location = 1) out vec4 _215;

void main()
{
    vec2 _133 = _132;
    _133 *= 1.10000002384185791015625;
    _133 += vec2(0.0, 0.3499999940395355224609375);
    float _247 = (_133.y * 0.60000002384185791015625) + 0.4000000059604644775390625;
    float _249;
    if (_247 < 0.0)
    {
        _249 = 0.0;
    }
    else
    {
        _249 = dot(_133, _133) - 0.810000002384185791015625;
    }
    float _248 = _249;
    float _250 = _248 / max(0.87999999523162841796875 * _247, 0.00999999977648258209228515625);
    float _251 = min(1.0, _250);
    float _130 = _251;
    float _136 = 1.0 - (((_130 - 0.5) * (_130 - 0.5)) * 4.0);
    if (_136 <= 0.001000000047497451305389404296875)
    {
        discard;
    }
    float _152 = _157._m20 * 0.100000001490116119384765625;
    vec2 _171 = _132 + vec2(0.0, 1.0);
    float _172 = _152;
    float _174 = 300.0;
    float _175 = 0.0199999995529651641845703125;
    float _278 = 6.283185482025146484375 / _174;
    float _279 = atan(_171.y, _171.x) + _172;
    float _280 = step(mod(_279, _278), _175 / length(_171));
    float _165 = clamp((_280 * 0.75) + 0.25, 0.0, 1.0);
    float _187 = _130 * _130;
    float _188 = 2.5;
    vec3 _299 = (vec3(-0.25, -0.5, -0.75) + vec3(_187)) * _188;
    vec3 _300 = max(vec3(1.0) - (_299 * _299), vec3(0.0));
    vec4 _182 = vec4(_300, _136 * _165);
    _182 *= (_198 * 1.75);
    _205 = vec4(_182.xyz, _182.w);
    float _222 = 1.0 / gl_FragCoord.w;
    float _223 = 256.0;
    float _314 = max(log(_222 * 20.0) * (_223 * 0.079292468726634979248046875), 0.0);
    _215 = vec4(_314, 0.0, 0.0, _182.w);
}

