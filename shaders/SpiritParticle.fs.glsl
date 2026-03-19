#version 460

layout(binding = 1, std140) uniform _133_135
{
    vec4 _m0;
} _135;

layout(binding = 0) uniform samplerCube _62;
layout(binding = 3) uniform sampler2D _146;

layout(location = 1) in vec3 _41;
layout(location = 2) in vec4 _72;
layout(location = 0) in vec4 _106;
layout(location = 0) out vec4 _186;
layout(location = 1) out vec4 _193;

void main()
{
    vec3 _39 = normalize(_41);
    float _44 = 0.0;
    vec3 _58 = textureLod(_62, -_39, 1.0).xyz;
    vec4 _70 = vec4(_72.xyz, 1.0);
    vec3 _79 = _70.xyz * ((_58 * 2.0) + vec3(0.100000001490116119384765625));
    float _89 = dot(_70.xyz, vec3(0.2989999949932098388671875, 0.58700001239776611328125, 0.114000000059604644775390625));
    vec3 _97 = (_79 * 40.0) * clamp(2.0 * _89, 0.0, 1.0);
    float _105 = max(0.0, 1.0 - (_106.w * 1.5));
    _79 += ((_97 * _105) * (1.0 + ((_44 * _44) * 50.0)));
    vec2 _129 = gl_FragCoord.xy * _135._m0.zw;
    vec4 _142 = texture(_146, _129);
    float _150 = 1.0 / gl_FragCoord.w;
    float _156 = _142.w;
    float _159 = 1000.0;
    float _210 = abs(_156 * (15000.0 / _159));
    float _154 = _210;
    float _161 = clamp((_154 - _150) * 0.5, 0.0, 1.0);
    vec2 _168 = gl_PointCoord - vec2(0.5);
    float _174 = float(dot(_168, _168) < 0.25);
    _161 *= _174;
    _186 = vec4(_79, _161);
    float _195 = _150;
    float _197 = 256.0;
    float _217 = max(log(_195 * 20.0) * (_197 * 0.079292468726634979248046875), 0.0);
    _193 = vec4(_217, 0.0, 0.0, _161);
}

