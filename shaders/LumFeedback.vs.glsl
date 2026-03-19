#version 460

layout(binding = 0, std140) uniform _32_34
{
    float _m0;
    float _m1;
    vec2 _m2;
} _34;

layout(binding = 1) uniform sampler2D _53;

layout(location = 0) flat out float _116;

void main()
{
    float _8 = 0.0;
    float _10 = 0.0;
    for (float _11 = 0.0; _11 < 8.0; _11 += 1.0)
    {
        for (float _21 = 0.0; _21 < 8.0; _21 += 1.0)
        {
            vec2 _31 = fract(_34._m2 + (vec2(_11, _21) * 0.125));
            vec3 _49 = textureLod(_53, _31, 0.0).xyz;
            float _59 = _34._m0 * dot(_49, vec3(0.2989999949932098388671875, 0.58700001239776611328125, 0.114000000059604644775390625));
            _8 += log2(clamp(isnan(_59) ? 0.0 : _59, 0.00390625, 200.0));
            _10 += (isnan(_59) ? 0.0 : 1.0);
        }
    }
    _8 /= _10;
    float _94 = log2(_34._m0);
    float _98 = mix(_94, _8, _34._m1);
    float _105 = clamp(_98, -8.0, 7.643856048583984375);
    _105 = isnan(_105) ? _94 : _105;
    _116 = _105;
    gl_Position = vec4(0.0, 0.0, 0.0, 1.0);
    gl_PointSize = 1.0;
}

