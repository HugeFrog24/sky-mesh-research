#version 460

layout(binding = 2, std140) uniform _66_68
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
} _68;

layout(binding = 0, std140) uniform _132_134
{
    mat4 _m0;
    mat4 _m1;
} _134;

layout(location = 0) in vec3 _140;
layout(location = 0) out vec3 _164;
layout(location = 2) in vec3 _176;
layout(location = 1) out vec4 _180;
layout(location = 1) in vec4 _182;
layout(location = 5) out vec3 _184;
layout(location = 6) out vec4 _194;
layout(location = 3) in vec4 _195;
layout(location = 7) out vec4 _197;
layout(location = 4) in vec4 _198;
layout(location = 8) out vec4 _200;
layout(location = 2) out vec4 _234;
layout(location = 3) out vec4 _268;
layout(location = 4) out vec4 _269;

void main()
{
    vec3 _131 = (_134._m0 * vec4(_140, 1.0)).xyz;
    gl_Position = _68._m8 * vec4(_131, 1.0);
    _164 = normalize(mat3(_134._m1[0].xyz, _134._m1[1].xyz, _134._m1[2].xyz) * _176);
    _180 = _182;
    _184 = _68._m16 - _131;
    _194 = _195;
    _197 = _198;
    vec3 _208 = max(vec3(0.0), log2(_182.xzy) * (-4.0));
    _200 = vec4(_208.x, _208.y, _208.z, _200.w);
    _200.y = -sqrt(1.25 * _200.y);
    _200.w = exp2((-1.6875) * _200.x);
    _200.x = -sqrt(4.0 * _200.x);
    float _233 = 1.0;
    vec3 _235 = _164;
    vec4 _270 = vec4(0.2820948064327239990234375, _235 * 0.3257350027561187744140625);
    vec4 _271 = vec4(0.078847892582416534423828125 * dot(vec3(-1.0, -1.0, 2.0), _235 * _235), (_235.yzx * 0.2731371223926544189453125) * _235.zxy);
    float _272 = 0.13656856119632720947265625 * ((_235.x * _235.x) - (_235.y * _235.y));
    vec3 _273;
    _273.x = (dot(_68._m61, _270) + dot(_68._m62, _271)) + (_68._m67.x * _272);
    _273.y = (dot(_68._m63, _270) + dot(_68._m64, _271)) + (_68._m67.y * _272);
    _273.z = (dot(_68._m65, _270) + dot(_68._m66, _271)) + (_68._m67.z * _272);
    vec3 _274 = max(vec3(9.9999997473787516355514526367188e-05), _273);
    _234 = vec4(_274.x, _274.y, _274.z, _234.w);
    _234.w = sqrt(_233);
    gl_Position.z = 0.5 * (gl_Position.z + gl_Position.w);
}

