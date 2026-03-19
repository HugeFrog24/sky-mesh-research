#version 460

layout(binding = 1, std140) uniform _82_84
{
    vec4 _m0;
} _84;

layout(binding = 0, std140) uniform _112_114
{
    float _m0;
    float _m1;
    float _m2;
} _114;

layout(binding = 2, std140) uniform _124_126
{
    vec4 _m0;
    vec4 _m1;
    vec4 _m2;
    vec4 _m3;
    vec4 _m4;
    vec4 _m5;
    mat4 _m6;
    mat4 _m7;
    mat4 _m8;
    mat4 _m9;
    mat4 _m10;
    mat4 _m11;
    vec4 _m12;
    vec4 _m13;
    vec4 _m14;
    vec4 _m15;
    vec3 _m16;
    float _m17;
    vec3 _m18;
    float _m19;
    float _m20;
    float _m21;
    float _m22;
    float _m23;
    float _m24;
    float _m25;
    float _m26;
    vec3 _m27;
    float _m28;
    vec3 _m29;
    float _m30;
    vec2 _m31;
    vec2 _m32;
    vec3 _m33;
    vec3 _m34;
    vec3 _m35;
    vec4 _m36;
    vec2 _m37;
    vec3 _m38;
    float _m39;
    vec4 _m40;
    vec3 _m41;
    float _m42;
    vec3 _m43;
    float _m44;
    vec3 _m45;
    float _m46;
    vec3 _m47;
    vec3 _m48;
    vec3 _m49;
    vec4 _m50;
    vec4 _m51;
    vec3 _m52;
    vec4 _m53;
    vec4 _m54;
    vec4 _m55;
    vec4 _m56;
    vec3 _m57;
    vec3 _m58;
    vec3 _m59;
    vec3 _m60;
    vec4 _m61;
    vec4 _m62;
    vec4 _m63;
    vec4 _m64;
    vec4 _m65;
    vec4 _m66;
    vec3 _m67;
    vec3 _m68;
    vec4 _m69;
    vec4 _m70;
    vec4 _m71;
    vec4 _m72;
    vec3 _m73;
    float _m74;
    vec3 _m75;
    float _m76;
    vec3 _m77;
    vec3 _m78;
    vec3 _m79;
    vec3 _m80;
    vec3 _m81;
    vec3 _m82;
} _126;

layout(binding = 3) uniform sampler2D _96;

layout(location = 0) in vec3 _140;
layout(location = 2) in vec3 _144;
layout(location = 1) in float _169;
layout(location = 0) out vec4 _200;
layout(location = 1) out vec4 _208;

void main()
{
    vec3 _138 = normalize(_140);
    vec3 _143 = normalize(_144);
    float _147 = dot(_138, _143);
    float _151 = step(0.0, _147);
    float _154 = ((1.0 - _147) * (1.0 - _147)) * 0.800000011920928955078125;
    float _162 = 1.0 + _147;
    float _165 = abs(_147);
    float _242 = 1.0 / gl_FragCoord.w;
    float _232 = _242;
    vec2 _233 = gl_FragCoord.xy * _84._m0.zw;
    float _235 = texture(_96, _233).w;
    float _236 = 1000.0;
    float _273 = abs(_235 * (15000.0 / _236));
    float _234 = _273;
    float _237 = _234 - _232;
    _237 = clamp((_237 * 0.5) / _114._m2, 0.0, 1.0);
    float _238 = smoothstep(0.0, 1.0, _237) * smoothstep(_126._m23, _126._m23 + 0.5, _232);
    float _168 = (((_169 * mix(_162, _154, _151)) * 0.5) * _238) * _114._m1;
    float _187 = _165;
    float _189 = 2.0 - _165;
    vec3 _280 = (vec3(-0.25, -0.5, -0.75) + vec3(_187)) * _189;
    vec3 _281 = max(vec3(1.0) - (_280 * _280), vec3(0.0));
    vec3 _183 = _281 * vec3(_114._m0 * _126._m22);
    _200 = vec4(_183, clamp(_168, 0.0, 1.0));
    float _213 = _242;
    float _214 = 256.0;
    float _295 = max(log(_213 * 20.0) * (_214 * 0.079292468726634979248046875), 0.0);
    _208 = vec4(_295, 0.0, 0.0, clamp(_168, 0.0, 1.0));
}

