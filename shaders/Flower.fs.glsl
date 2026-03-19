#version 460

layout(binding = 0) uniform sampler2D _54;

layout(location = 1) in vec3 _33;
layout(location = 0) out vec4 _66;
layout(location = 0) in vec3 _67;
layout(location = 1) out vec4 _74;

void main()
{
    vec2 _27 = gl_PointCoord;
    _27.x += (_33.z * (1.0 - _27.y));
    vec2 _50 = texture(_54, _27).xy;
    float _60 = dot(_50, _33.xy);
    _66 = vec4(_67, _60);
    float _82 = 1.0 / gl_FragCoord.w;
    float _83 = 256.0;
    float _107 = max(log(_82 * 20.0) * (_83 * 0.079292468726634979248046875), 0.0);
    _74 = vec4(_107, 0.0, 0.0, _60);
}

