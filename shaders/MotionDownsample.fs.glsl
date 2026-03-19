#version 460

layout(binding = 2, std140) uniform _53_55
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
} _55;

layout(binding = 3) uniform sampler2D _34;
layout(binding = 0) uniform sampler2D _170;

layout(location = 0) in vec2 _27;
layout(location = 0) out vec4 _178;
layout(location = 1) in vec4 _202;

void main()
{
    vec2 _25 = _27;
    float _30 = abs(texture(_34, _25).w);
    if (_30 > 0.0401999987661838531494140625)
    {
        vec4 _50 = vec4(_25 + (_55._m1.zw * 1.5), _25 + (_55._m1.zw * (-1.5)));
        float _80[8];
        _80[0] = texture(_34, _50.xy).w;
        _80[1] = texture(_34, _50.zy).w;
        _80[2] = texture(_34, _50.xw).w;
        _80[3] = texture(_34, _50.zw).w;
        _80[4] = texture(_34, vec2(_50.x, _25.y)).w;
        _80[5] = texture(_34, vec2(_50.z, _25.y)).w;
        _80[6] = texture(_34, vec2(_25.x, _50.y)).w;
        _80[7] = texture(_34, vec2(_25.x, _50.w)).w;
        for (int _152 = 0; _152 < 8; _152++)
        {
            _30 = min(_30, abs(_80[_152]));
        }
    }
    vec3 _174 = texture(_170, _25).xyz;
    vec3 _203 = (vec3(1.0) / max(vec3(9.9999997473787516355514526367188e-05), _174)) - vec3(1.0);
    vec3 _169 = _203;
    _178 = vec4(_169, _30);
}

