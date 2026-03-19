#version 460

layout(binding = 1, std140) uniform _47_49
{
    vec4 _m0;
} _49;

layout(binding = 0) uniform sampler2D _61;

layout(location = 0) out vec4 _86;
layout(location = 0) in vec4 _87;

void main()
{
    float _37 = 0.00999999977648258209228515625;
    vec2 _41 = gl_FragCoord.xy * _49._m0.zw;
    float _66 = texture(_61, _41).w;
    float _70 = 1000.0;
    float _147 = abs(_66 * (15000.0 / _70));
    float _57 = _147;
    float _72 = (1.0 - _37) / gl_FragCoord.w;
    if (_72 < _57)
    {
        _86 = vec4(_87.xyz, abs(_87.w));
    }
    else
    {
        if (_87.w < 0.0)
        {
            float _104 = 0.699999988079071044921875;
            _86 = vec4(mix(_87.xyz, vec3(0.25), vec3(0.625)), _104 * abs(_87.w));
        }
        else
        {
            _86 = vec4(0.0);
        }
    }
    vec3 _124 = _86.xyz;
    vec3 _154 = vec3(1.0) / (vec3(1.0) + max(vec3(9.9999997473787516355514526367188e-05), _124));
    _86 = vec4(_154.x, _154.y, _154.z, _86.w);
}

