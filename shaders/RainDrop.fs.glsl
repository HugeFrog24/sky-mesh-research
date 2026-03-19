#version 460

layout(location = 0) out vec4 _27;
layout(location = 0) in vec3 _30;
layout(location = 1) out vec4 _39;

void main()
{
    _27 = vec4(_30 * 5.0, 0.100000001490116119384765625);
    float _50 = 1.0 / gl_FragCoord.w;
    float _51 = 256.0;
    float _77 = max(log(_50 * 20.0) * (_51 * 0.079292468726634979248046875), 0.0);
    _39 = vec4(_77, 0.0, 0.0, 0.100000001490116119384765625);
}

