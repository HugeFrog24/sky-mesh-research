#version 460

layout(binding = 2, std140) uniform _32_34
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
} _34;

layout(binding = 0, std140) uniform _139_141
{
    float _m0;
    float _m1;
    vec3 _m2;
} _141;

layout(binding = 1, std140) uniform _465_467
{
    vec4 _m0;
} _467;

layout(binding = 4) uniform sampler2D _58;
layout(binding = 3) uniform sampler2D _171;

layout(location = 0) in vec3 _96;
layout(location = 1) in vec4 _147;
layout(location = 1) out vec3 _239;
layout(location = 0) out vec3 _274;
layout(location = 2) in vec4 _275;
layout(location = 3) in vec4 _298;
layout(location = 5) in vec4 _359;
layout(location = 4) in vec4 _366;

void main()
{
    vec3 _94 = _96;
    vec3 _98 = _34._m16 - _94;
    float _104 = length(_98);
    vec3 _107 = _98 / vec3(_104);
    float _112 = min(_104 * 0.00999999977648258209228515625, 1.0);
    vec3 _118 = _94;
    float _120 = 1.0;
    float _532 = 0.039999999105930328369140625 * _120;
    float _533 = 0.02500000037252902984619140625 * _120;
    vec2 _534 = fract((_118.xz * _532) + _34._m58.xz);
    vec2 _535 = fract((_118.xz * _533) + _34._m59.xz);
    vec2 _536 = (textureLod(_58, _535, 0.0).xy * 2.0) - vec2(1.0);
    vec4 _537 = textureLod(_58, _534, 0.0);
    vec2 _580 = ((_537.xy - vec2(0.5)) * _536) + vec2(0.5);
    _537 = vec4(_580.x, _580.y, _537.z, _537.w);
    vec2 _538 = vec2(1.0) - (_537.xy * 2.0);
    vec2 _539 = _538;
    vec2 _117 = _539;
    vec2 _129 = _94.xz + (_117 * mix(0.0500000007450580596923828125, 1.0, _112));
    _94 = vec3(_129.x, _94.y, _129.y);
    _94.y += 0.00999999977648258209228515625;
    float _138 = _141._m0 * _147.y;
    _94.y += _138;
    vec2 _157 = (_94.xz - _34._m54.xy) * _34._m54.w;
    vec4 _170 = textureLod(_171, _157, 0.0);
    float _175 = max((_170.w * 8.0) - 4.0, 0.0);
    vec2 _183 = (_170.xy * 2.0) * _175;
    vec2 _192 = _94.xz - _183;
    _94 = vec3(_192.x, _94.y, _192.y);
    float _195 = pow(1.0 - max(0.0, _107.y), 4.0) * pow(1.0 - _112, 4.0);
    vec3 _205 = normalize(vec3(-_117.x, 0.5, -_117.y));
    vec3 _219 = vec3(_34._m6[0].x, _34._m6[1].x, _34._m6[2].x);
    vec3 _230 = vec3(_34._m6[0].y, _34._m6[1].y, _34._m6[2].y);
    _239 = vec3(normalize(vec2(dot(_219, _205), dot(_230, _205))), _147.w);
    _94.y -= ((0.800000011920928955078125 * _138) * _195);
    float _262 = 1.5 + (_175 * ((_239.z < 0.5) ? 4.0 : 1.0));
    _274 = _275.xyz * _262;
    float _280 = 0.75 * _147.x;
    vec3 _285 = -_34._m38;
    vec3 _290 = normalize(_107 + (_285 * 1.02499997615814208984375));
    vec3 _301 = _298.xyz * 2.0;
    vec3 _297 = normalize(_301 + vec3(_117.x, 0.0, _117.y));
    vec3 _309 = normalize(_301 + vec3(_117.x, 0.0, _117.y));
    float _320 = mix(0.00999999977648258209228515625, 1.0, pow(min(1.0, 1.0 - dot(_107, _290)), 5.0));
    vec3 _329 = (_34._m41 * ((6.0 * _320) * _320)) * pow(min(1.0, 1.0 - dot(_107, _309)), 8.0);
    float _346 = pow(1.0 - abs(dot(_107, _309)), 4.0);
    float _353 = max(0.0, dot(_297, _285));
    float _358 = _359.y * _359.y;
    vec3 _365 = ((_366.xyz * _366.xyz) / vec3(_366.w)) * mix(_34._m45, _34._m41, vec3(_359.x));
    vec3 _386 = _34._m60 * (_359.w * exp2((255.0 * _359.z) - 128.0));
    float _401 = dot(_34._m41, vec3(0.063780002295970916748046875, 0.2145600020885467529296875, 0.0216600000858306884765625));
    _274 *= (((_34._m41 * _358) * (vec3(_353) + (_329 * 3.0))) + ((_365 + _386) * (1.0 + (_346 * 3.0))));
    _274 += ((_141._m2 * _401) * pow(_346, 8.0));
    gl_Position = _34._m8 * vec4(_94, 1.0);
    float _454 = ((((0.5 * _147.z) * _141._m1) * _34._m17) * _467._m0.y) / pow(gl_Position.w, 0.75);
    _454 *= (1.0 + clamp(abs(_94.y - _34._m16.y) * 0.00999999977648258209228515625, 0.0, 1.0));
    float _487 = min(1.0, _454 * 0.5);
    _280 *= pow(_487, 1.5);
    gl_PointSize = max(_454, 2.0);
    _239 = vec3((_239.z < 0.5) ? _280 : 0.0, (_239.z < 0.5) ? 0.0 : _280, (_239.z * _239.x) * 0.4000000059604644775390625);
    gl_Position.z = 0.5 * (gl_Position.z + gl_Position.w);
}

