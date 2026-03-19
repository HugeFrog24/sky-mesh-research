#version 460

layout(binding = 2, std140) uniform _110_112
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
} _112;

layout(binding = 0, std140) uniform _302_304
{
    float _m0;
} _304;

layout(binding = 3) uniform sampler2D _138;
layout(binding = 5) uniform sampler2D _172;
layout(binding = 4) uniform samplerCube _296;

layout(location = 6) in vec3 _106;
layout(location = 1) in vec3 _152;
layout(location = 0) in vec3 _166;
layout(location = 3) in vec4 _174;
layout(location = 4) in vec4 _203;
layout(location = 7) in vec2 _375;
layout(location = 5) in float _439;
layout(location = 8) in vec2 _447;
layout(location = 2) in vec3 _538;
layout(location = 0) out vec4 _552;

void main()
{
    float _537 = length(_538);
    float _541 = 1.0 / gl_FragCoord.w;
    vec3 _545 = -(_538 / vec3(_537));
    vec3 _559 = _545;
    vec3 _612 = -_559;
    vec3 _613 = vec3(0.0);
    vec3 _614 = vec3(0.0);
    vec2 _615 = (_106.xz - _112._m54.xy) * _112._m54.w;
    if (all(equal(_615, clamp(_615, vec2(0.0), vec2(1.0)))))
    {
        _614 = textureLod(_138, _615, 0.0).xyz;
    }
    vec3 _616 = normalize(vec3(_614.xy, 0.039999999105930328369140625));
    vec3 _617 = _152;
    vec3 _618 = -_112._m38;
    vec3 _619 = normalize(_612 + _618);
    vec3 _620 = normalize(_166 + _617);
    vec2 _622 = _174.xy;
    vec4 _941 = texture(_172, _622);
    vec2 _621 = _941.xy;
    vec2 _625 = _174.zw;
    vec4 _946 = texture(_172, _625);
    vec2 _624 = _946.xy;
    vec2 _628 = _203.xy;
    vec4 _951 = texture(_172, _628);
    vec2 _627 = _951.xy;
    vec2 _630 = (((_621 + _624) + _627) * 0.3333333432674407958984375) - vec2(0.5);
    vec2 _738 = _620.xz + _630;
    _620 = vec3(_738.x, _620.y, _738.y);
    vec2 _745 = _620.xz + _616.xy;
    _620 = vec3(_745.x, _620.y, _745.y);
    _620 = normalize(_620);
    vec2 _631 = _630 * 7.0;
    float _632 = 0.5;
    float _633 = max(dot(_617, _618) + _632, 0.0) / (1.0 + _632);
    float _634 = max(dot(_620, _618), 0.0);
    float _635 = mix(0.00999999977648258209228515625, 0.60000002384185791015625, pow(clamp(1.0 - dot(_612, _620), 0.0, 1.0), 7.0));
    float _636 = mix(0.039999999105930328369140625, 0.800000011920928955078125, pow(clamp(1.0 - dot(_612, _619), 0.0, 1.0), 7.0));
    vec3 _637 = reflect(-_612, _620);
    _637.y = abs(_637.y);
    vec3 _638 = textureLod(_296, _637, 0.0).xyz;
    float _639 = _304._m0;
    vec3 _640 = _620;
    vec2 _797 = _640.xz + _631;
    _640 = vec3(_797.x, _640.y, _797.y);
    _640 = normalize(_640);
    vec3 _641 = _112._m41 * ((((((_112._m39 * _112._m40.y) * _112._m40.x) * 1000.0) * _639) * _634) * pow(max(dot(_640, _619), 0.0), 20.0 + (480.0 * _112._m39)));
    vec3 _642 = vec3(0.00999999977648258209228515625, 0.02999999932944774627685546875, 0.0599999986588954925537109375) * min(vec3(1.0), _112._m49 * 0.20000000298023223876953125);
    vec3 _643 = _112._m41 * _633;
    vec3 _644 = _643 * _642;
    vec2 _646 = _375;
    vec2 _957 = _646;
    vec2 _967 = dFdx(_957);
    vec2 _968 = dFdy(_957);
    vec2 _969 = max(abs(_967), abs(_968)) * 0.75;
    vec2 _956 = _969;
    vec4 _958 = textureGrad(_172, _646, _956, _956);
    vec3 _645 = _958.xyz;
    vec2 _648 = _375 * 7.0;
    vec2 _982 = _648;
    vec2 _992 = dFdx(_982);
    vec2 _993 = dFdy(_982);
    vec2 _994 = max(abs(_992), abs(_993)) * 0.75;
    vec2 _981 = _994;
    vec4 _983 = textureGrad(_172, _648, _981, _981);
    vec4 _647 = _983;
    float _649 = float((0.5 - ((_645.y * _647.x) * 2.2000000476837158203125)) > 0.0);
    float _650 = 0.0;
    float _652;
    if (_647.x > 0.5)
    {
        _652 = _647.x;
    }
    else
    {
        _652 = 0.0;
    }
    vec3 _651 = mix(vec3(2.0, 1.89999997615814208984375, 1.0), vec3(0.5, 1.0, 0.100000001490116119384765625), vec3(_652));
    _651 *= _651;
    vec3 _654;
    if (_649 == 1.0)
    {
        _654 = _651 * _643;
    }
    else
    {
        _654 = _638 * _633;
    }
    vec3 _653 = _654;
    _613 = mix(_644, _653, vec3(_635));
    float _655 = min(1.0, max(0.0, (_439 * 0.0024999999441206455230712890625) - 1.0));
    vec2 _657 = _447;
    vec2 _1007 = _657;
    vec2 _1017 = dFdx(_1007);
    vec2 _1018 = dFdy(_1007);
    vec2 _1019 = max(abs(_1017), abs(_1018)) * 0.75;
    vec2 _1006 = _1019;
    vec4 _1008 = textureGrad(_172, _657, _1006, _1006);
    vec3 _656 = _1008.xyz;
    vec2 _659 = _447 * 7.0;
    vec2 _1032 = _659;
    vec2 _1042 = dFdx(_1032);
    vec2 _1043 = dFdy(_1032);
    vec2 _1044 = max(abs(_1042), abs(_1043)) * 0.75;
    vec2 _1031 = _1044;
    vec4 _1033 = textureGrad(_172, _659, _1031, _1031);
    vec4 _658 = _1033;
    _650 = ((((_656.x * _658.x) * 2.0) - 0.5) > 0.0) ? _655 : 0.0;
    float _660 = ((((_645.x * _647.x) * 2.0) - 0.5) > 0.0) ? _655 : 0.0;
    _613 = mix(mix(_613, vec3(0.0), vec3(_660 * 0.5)), _643, vec3(_650 * 2.0));
    _613 += ((_641 * _636) * (1.0 - (max(_649, _650) * 0.75)));
    vec3 _661 = _613;
    float _562 = _541;
    float _564 = 1000.0;
    float _1056 = max(0.0, _562 * (_564 * 6.6666667407844215631484985351562e-05));
    _552 = vec4(_661, _1056);
}

