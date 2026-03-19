#version 460

layout(binding = 0, std140) uniform _68_70
{
    vec4 _m0;
    vec4 _m1;
    vec4 _m2;
    vec4 _m3;
    vec4 _m4;
} _70;

layout(location = 0) out vec4 _128;
layout(location = 0) in vec2 _148;

void main()
{
    vec2 _84 = gl_FragCoord.xy;
    float _89 = 1.0;
    vec2 _92 = _84;
    vec4 _94 = _70._m0;
    float _158;
    do
    {
        if (_94.z <= 0.00999999977648258209228515625)
        {
            _158 = 1.0;
            break;
        }
        vec2 _159 = (_92 - _94.xy) / vec2(_94.z);
        float _160 = length(pow(abs(_159), vec2(_94.w)));
        float _161 = _160;
        float _162 = 1.0;
        float _163 = 1.0 + _70._m4.z;
        float _194 = clamp((_161 * (1.0 / (_163 - _162))) - (_162 / (_163 - _162)), 0.0, 1.0);
        _158 = _194;
        break;
    } while(false);
    float _164 = _158;
    _89 = min(_89, _164);
    vec2 _102 = _84;
    vec4 _104 = _70._m1;
    float _210;
    do
    {
        if (_104.z <= 0.00999999977648258209228515625)
        {
            _210 = 1.0;
            break;
        }
        vec2 _211 = (_102 - _104.xy) / vec2(_104.z);
        float _212 = length(pow(abs(_211), vec2(_104.w)));
        float _213 = _212;
        float _214 = 1.0;
        float _215 = 1.0 + _70._m4.z;
        float _246 = clamp((_213 * (1.0 / (_215 - _214))) - (_214 / (_215 - _214)), 0.0, 1.0);
        _210 = _246;
        break;
    } while(false);
    float _216 = _210;
    _89 = min(_89, _216);
    vec2 _111 = _84;
    vec4 _113 = _70._m2;
    float _262;
    do
    {
        if (_113.z <= 0.00999999977648258209228515625)
        {
            _262 = 1.0;
            break;
        }
        vec2 _263 = (_111 - _113.xy) / vec2(_113.z);
        float _264 = length(pow(abs(_263), vec2(_113.w)));
        float _265 = _264;
        float _266 = 1.0;
        float _267 = 1.0 + _70._m4.z;
        float _298 = clamp((_265 * (1.0 / (_267 - _266))) - (_266 / (_267 - _266)), 0.0, 1.0);
        _262 = _298;
        break;
    } while(false);
    float _268 = _262;
    _89 = min(_89, _268);
    vec2 _120 = _84;
    vec4 _122 = _70._m3;
    float _314;
    do
    {
        if (_122.z <= 0.00999999977648258209228515625)
        {
            _314 = 1.0;
            break;
        }
        vec2 _315 = (_120 - _122.xy) / vec2(_122.z);
        float _316 = length(pow(abs(_315), vec2(_122.w)));
        float _317 = _316;
        float _318 = 1.0;
        float _319 = 1.0 + _70._m4.z;
        float _350 = clamp((_317 * (1.0 / (_319 - _318))) - (_318 / (_319 - _318)), 0.0, 1.0);
        _314 = _350;
        break;
    } while(false);
    float _320 = _314;
    _89 = min(_89, _320);
    _128 = vec4(0.0, 0.0, 0.0, pow(_89, _70._m4.y) * _70._m4.x);
}

