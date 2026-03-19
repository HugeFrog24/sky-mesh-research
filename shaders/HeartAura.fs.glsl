#version 460

layout(binding = 2, std140) uniform _172_174
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
} _174;

layout(location = 0) in vec2 _150;
layout(location = 1) in vec4 _215;
layout(location = 0) out vec4 _222;
layout(location = 1) out vec4 _232;

void main()
{
    vec2 _151 = _150;
    _151 *= vec2(1.2999999523162841796875, 1.2000000476837158203125);
    _151 += vec2(0.0, 0.3499999940395355224609375);
    float _264 = abs(_151.x) + _151.y;
    _151 /= vec2((_264 * 0.5) + 0.5);
    float _265 = (_151.y * 0.60000002384185791015625) + 0.4000000059604644775390625;
    float _267;
    if (_265 < 0.0)
    {
        _267 = 0.0;
    }
    else
    {
        _267 = dot(_151, _151) - 0.810000002384185791015625;
    }
    float _266 = _267;
    float _268 = _266 / max(0.87999999523162841796875 * _265, 0.00999999977648258209228515625);
    float _269 = min(1.0, _268 * 4.5);
    float _148 = _269;
    float _154 = 1.0 - (((_148 - 0.5) * (_148 - 0.5)) * 4.0);
    if (_154 <= 0.001000000047497451305389404296875)
    {
        discard;
    }
    float _169 = _174._m20 * 0.100000001490116119384765625;
    vec2 _188 = _150 + vec2(0.0, 1.0);
    float _189 = _169;
    float _191 = 300.0;
    float _192 = 0.0199999995529651641845703125;
    float _309 = 6.283185482025146484375 / _191;
    float _310 = atan(_188.y, _188.x) + _189;
    float _311 = step(mod(_310, _309), _192 / length(_188));
    float _182 = clamp((_311 * 0.75) + 0.25, 0.0, 1.0);
    float _204 = _148 * _148;
    float _205 = 2.5;
    vec3 _330 = (vec3(-0.25, -0.5, -0.75) + vec3(_204)) * _205;
    vec3 _331 = max(vec3(1.0) - (_330 * _330), vec3(0.0));
    vec4 _199 = vec4(_331, _154 * _182);
    _199 *= (_215 * 1.75);
    _222 = vec4(_199.xyz, _199.w);
    float _239 = 1.0 / gl_FragCoord.w;
    float _240 = 256.0;
    float _345 = max(log(_239 * 20.0) * (_240 * 0.079292468726634979248046875), 0.0);
    _232 = vec4(_345, 0.0, 0.0, _199.w);
}

