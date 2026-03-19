#version 460

layout(binding = 2, std140) uniform _75_77
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
} _77;

layout(binding = 0) uniform sampler2D _112;

layout(location = 0) in vec2 _67;
layout(location = 1) out vec4 _193;
layout(location = 0) out vec4 _337;
layout(location = 1) in vec4 _343;

void main()
{
    vec4 _65;
    _65 = vec4(_67.x, _67.y, _65.z, _65.w);
    vec2 _91 = (_65.xy / vec2(_77._m54.w)) + _77._m54.xy;
    _65 = vec4(_65.x, _65.y, _91.x, _91.y);
    float _94 = min(0.0500000007450580596923828125, _77._m21);
    vec2 _100 = _65.xy + _77._m55.xy;
    vec4 _108 = textureLodOffset(_112, _100, 0.0, ivec2(0));
    vec2 _119 = textureLodOffset(_112, _100, 0.0, ivec2(0, -1)).xw;
    vec2 _126 = textureLodOffset(_112, _100, 0.0, ivec2(1, 0)).xw;
    vec2 _133 = textureLodOffset(_112, _100, 0.0, ivec2(0, 1)).xw;
    vec2 _139 = textureLodOffset(_112, _100, 0.0, ivec2(-1, 0)).xw;
    float _145 = (((_119.x - _108.x) + (_133.x - _108.x)) + (_139.x - _108.x)) + (_126.x - _108.x);
    _108.w = max(max(max(max(_119.y, _133.y), _139.y), _126.y) * 0.949999988079071044921875, _108.w) * (1.0 - _94);
    vec3 _210 = clamp(vec3(_139.x - _108.x, _119.x - _108.x, _108.x), vec3(-1.0), vec3(1.0));
    _193 = vec4(_210.x, _210.y, _210.z, _193.w);
    _193.w = _108.w;
    vec3 _218 = vec3(1.0) - (vec3(0.100000001490116119384765625, 0.00999999977648258209228515625, 1.0) * _94);
    vec3 _228 = _108.xyz * _218;
    _108 = vec4(_228.x, _228.y, _228.z, _108.w);
    _108.z += (_145 * (50.0 * _94));
    _108.z = min(1.0, abs(_108.z)) * sign(_108.z);
    _108.x += (_108.z * _94);
    vec2 _260 = _65.zw;
    vec2 _263 = _77._m56.xy;
    vec2 _267 = _77._m56.zw;
    vec2 _344 = _267 - _263;
    vec2 _345 = _260 - _263;
    float _346 = dot(_345, _344);
    float _347 = dot(_344, _344);
    float _348 = _346 / _347;
    vec2 _349 = _263 + (_344 * _348);
    _349 = mix(_349, _263, bvec2(_346 <= 0.0));
    _349 = mix(_349, _267, bvec2(_347 <= _346));
    float _350 = distance(_260, _349);
    float _258 = _350;
    float _272 = max(1.0 - (_258 * 4.0), 0.0) * _77._m55.z;
    if (_272 > 0.0)
    {
        float _285 = max(_108.x + _272, 0.0);
        _108.x -= _285;
        _108.z += (_285 * 0.20000000298023223876953125);
        _108.w = 1.0;
    }
    float _308;
    if (_77._m54.z > 0.0)
    {
        _308 = max(1.0 - (_258 / _77._m54.z), 0.0) * _77._m55.w;
    }
    else
    {
        _308 = 0.0;
    }
    float _304 = _308;
    if (_304 > 0.0)
    {
        float _326 = max(_108.y + _304, 0.0);
        _108.y -= _326;
    }
    _337 = _108;
}

