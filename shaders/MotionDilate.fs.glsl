#version 460

layout(binding = 0) uniform sampler2D _19;

layout(location = 0) in vec2 _11;
layout(location = 0) out vec2 _88;
layout(location = 1) in vec4 _100;

void main()
{
    vec2 _9 = _11;
    vec4 _15 = textureOffset(_19, _9, ivec2(0));
    vec4 _27 = textureOffset(_19, _9, ivec2(-1));
    vec4 _33 = textureOffset(_19, _9, ivec2(1, -1));
    vec4 _39 = textureOffset(_19, _9, ivec2(-1, 1));
    vec4 _44 = textureOffset(_19, _9, ivec2(1));
    vec4 _49 = _15;
    if (_49.z > _27.z)
    {
        _49 = _27;
    }
    if (_49.z > _33.z)
    {
        _49 = _33;
    }
    if (_49.z > _39.z)
    {
        _49 = _39;
    }
    if (_49.z > _44.z)
    {
        _49 = _44;
    }
    _88 = _49.xy;
}

