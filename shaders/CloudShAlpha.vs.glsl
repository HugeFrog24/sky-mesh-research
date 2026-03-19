#version 460

layout(binding = 0, std140) uniform _12_14
{
    mat4 _m0;
    mat4 _m1;
    vec3 _m2;
    float _m3;
} _14;

layout(binding = 2, std140) uniform _49_51
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
} _51;

layout(location = 0) in vec3 _21;
layout(location = 1) in vec4 _43;
layout(location = 3) in vec4 _108;
layout(location = 2) in vec4 _117;
layout(location = 0) out vec4 _213;
layout(location = 4) in vec4 _219;
layout(location = 5) in vec4 _238;

void main()
{
    vec3 _9 = (_14._m0 * vec4(_21, 1.0)).xyz;
    vec3 _30 = mat3(_14._m1[0].xyz, _14._m1[1].xyz, _14._m1[2].xyz) * _43.xyz;
    vec3 _47 = normalize(_51._m16 - _9);
    vec3 _59 = -_51._m38;
    vec3 _64 = _51._m73 - _9;
    _9 -= (_30 * (4.0 * max(0.5, 1.0 - (0.012500000186264514923095703125 * dot(_64, _64)))));
    gl_Position = _51._m8 * vec4(_9, 1.0);
    gl_Position.z -= 0.0005000000237487256526947021484375;
    float _107 = _108.y * _108.y;
    vec3 _116 = ((_117.xyz * _117.xyz) / vec3(_117.w)) * mix(_51._m45, _51._m41, vec3(_108.x));
    _116 += (_51._m60 * (_108.w * exp2((255.0 * _108.z) - 128.0)));
    float _156 = dot(_47, _59);
    float _160 = _107 * (0.5 + (0.5 * mix(max(0.0, dot(_30, _59)), 1.0, max(0.0, -_156))));
    vec3 _174 = _14._m2 * ((_51._m41 * _160) + _116);
    float _185 = 0.02500000037252902984619140625;
    float _187 = _185 / (_185 - ((-1.0) - _156));
    _187 /= (_185 * log((2.0 / _185) + 1.0));
    _174 += (_51._m41 * ((2.0 * _187) * _107));
    _213 = vec4(_174.x, _174.y, _174.z, _213.w);
    vec4 _218 = vec4(equal(ivec4(_219 * 256.0), ivec4(int(_14._m3))));
    _213.w = dot(_218, _238);
    gl_Position.z = 0.5 * (gl_Position.z + gl_Position.w);
}

