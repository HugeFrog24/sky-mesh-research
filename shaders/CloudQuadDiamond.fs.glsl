#version 460

layout(binding = 0) uniform sampler2D _39;

layout(location = 0) in vec4 _31;
layout(location = 12) in float _49;
layout(location = 9) in vec3 _57;
layout(location = 8) in vec3 _63;
layout(location = 10) in vec3 _71;
layout(location = 1) in vec4 _79;
layout(location = 7) in float _83;
layout(location = 13) in float _89;
layout(location = 0) out vec4 _98;
layout(location = 2) in vec2 _137;
layout(location = 3) in float _138;
layout(location = 4) in float _139;
layout(location = 5) in float _140;
layout(location = 6) in float _141;
layout(location = 11) in float _142;

void main()
{
    vec4 _24 = vec4(0.0, 0.0, 0.0, 1.0);
    vec2 _29 = _31.zw;
    float _34 = 0.5 + (0.5 * texture(_39, _29).x);
    _34 = (_49 < 0.5) ? 1.0 : _34;
    vec3 _60 = _57 * _34;
    _24 = vec4(_60.x, _60.y, _60.z, _24.w);
    vec3 _67 = _24.xyz + _63;
    _24 = vec4(_67.x, _67.y, _67.z, _24.w);
    vec3 _76 = _24.xyz + (_71 * 0.20000000298023223876953125);
    _24 = vec4(_76.x, _76.y, _76.z, _24.w);
    _24 *= _79;
    _24 *= _83;
    vec3 _94 = _24.xyz + (_79.xyz * _89);
    _24 = vec4(_94.x, _94.y, _94.z, _24.w);
    float _107 = 1.0 / gl_FragCoord.w;
    float _108 = 1000.0;
    float _143 = max(0.0, _107 * (_108 * 6.6666667407844215631484985351562e-05));
    _98 = vec4(_24.xyz, _143);
}

