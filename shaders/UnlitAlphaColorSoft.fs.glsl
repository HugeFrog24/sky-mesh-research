#version 460

layout(binding = 0, std140) uniform _109_111
{
    vec4 _m0;
    float _m1;
    float _m2;
    float _m3;
} _111;

layout(binding = 1, std140) uniform _206_208
{
    vec4 _m0;
} _208;

layout(binding = 3) uniform sampler2D _91;
layout(binding = 4) uniform sampler2D _215;

layout(location = 2) in vec3 _54;
layout(location = 1) in vec3 _63;
layout(location = 3) in vec2 _81;
layout(location = 0) in vec4 _86;
layout(location = 0) out vec4 _246;
layout(location = 1) out vec4 _255;

void main()
{
    float _52 = length(_54);
    vec3 _57 = _54 / vec3(_52);
    vec3 _62 = normalize(_63);
    vec2 _79 = _81;
    vec4 _84 = _86 * texture(_91, _79);
    vec4 _96 = _84;
    vec3 _98 = vec3(0.0);
    float _100 = dot(_84.xyz, vec3(0.2989999949932098388671875, 0.58700001239776611328125, 0.114000000059604644775390625));
    bool _118 = _111._m0.x > 0.0;
    bool _127;
    if (_118)
    {
        _127 = _100 > (1.0 - _111._m0.x);
    }
    else
    {
        _127 = _118;
    }
    if (_127)
    {
        _98 = ((_84.xyz * _111._m0.y) * ((_100 - 1.0) + _111._m0.x)) / vec3(_111._m0.x);
    }
    _98 *= (1.0 + _111._m0.z);
    vec3 _155 = _96.xyz + _98;
    _96 = vec4(_155.x, _155.y, _155.z, _96.w);
    float _158 = dot(_62, _57);
    if (_111._m2 >= 0.0)
    {
        _96.w *= mix(1.0, pow(abs(_158), 3.0), _111._m2);
    }
    else
    {
        _96.w *= mix(1.0, pow(1.0099999904632568359375 - abs(_158), 3.0), -_111._m2);
    }
    _96.w *= (1.0 - _111._m1);
    vec2 _202 = gl_FragCoord.xy * _208._m0.zw;
    vec4 _214 = texture(_215, _202);
    float _223 = 1.0 / gl_FragCoord.w;
    float _219 = _223;
    float _226 = _214.w;
    float _229 = 1000.0;
    float _279 = abs(_226 * (15000.0 / _229));
    float _224 = _279;
    _96.w *= clamp(abs(_224 - _219) / (1.0 + _111._m3), 0.0, 1.0);
    _246 = vec4(_96.xyz, _96.w);
    float _260 = _223;
    float _261 = 256.0;
    float _286 = max(log(_260 * 20.0) * (_261 * 0.079292468726634979248046875), 0.0);
    _255 = vec4(_286, 0.0, 0.0, _96.w);
}

