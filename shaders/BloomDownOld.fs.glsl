#version 460

layout(binding = 0) uniform sampler2D _18;

layout(location = 0) in vec2 _22;
layout(location = 1) in vec4 _30;
layout(location = 2) in vec4 _46;
layout(location = 0) out vec4 _90;

void main()
{
    float _8 = 1.0030000209808349609375;
    float _10 = 1.10000002384185791015625;
    vec3 _14 = texture(_18, _22).xyz;
    vec3 _27 = texture(_18, _30.xy).xyz * 0.5;
    vec3 _37 = texture(_18, _30.zw).xyz * 0.5;
    vec3 _44 = texture(_18, _46.xy).xyz * 0.5;
    vec3 _52 = texture(_18, _46.zw).xyz * 0.5;
    vec3 _59 = ((_27 + _37) + _44) + _52;
    _14 *= vec3(_8, 1.0, 1.0 / _8);
    _59 *= vec3(1.0 / _8, 1.0, _8);
    vec3 _82 = min(vec3(1000.0), _59 - _14);
    _90 = vec4(pow(max(_82, vec3(0.0)), vec3(_10)), 0.0);
}

