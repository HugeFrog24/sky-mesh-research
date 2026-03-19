#version 460

layout(binding = 2, std140) uniform _82_84
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
} _84;

layout(binding = 1, std140) uniform _284_286
{
    vec4 _m0;
} _286;

layout(binding = 0, std140) uniform _627_629
{
    float _m0;
} _629;

layout(binding = 4) uniform sampler2D _309;
layout(binding = 5) uniform sampler2D _351;
layout(binding = 8) uniform sampler2D _537;
layout(binding = 6) uniform sampler2D _574;
layout(binding = 7) uniform sampler2D _584;
layout(binding = 3) uniform sampler2D _642;

layout(location = 0) in vec3 _532;
layout(location = 8) in vec4 _539;
layout(location = 7) in vec3 _576;
layout(location = 2) in vec4 _598;
layout(location = 0) out vec4 _621;
layout(location = 3) in vec4 _633;
layout(location = 1) in vec3 _714;
layout(location = 4) in vec4 _726;
layout(location = 5) in vec4 _728;
layout(location = 6) in vec4 _730;

void main()
{
    do
    {
        vec3 _527 = _84._m16 - _532;
        vec2 _536 = (texture(_537, _539.zw).xy * 2.0) - vec2(1.0);
        vec3 _547 = texture(_537, _539.xy).xyz;
        vec2 _561 = ((_547.xy - vec2(0.5)) * _536) + vec2(0.5);
        _547 = vec3(_561.x, _561.y, _547.z);
        float _564 = _547.z;
        vec2 _567 = (_547.xy * 2.0) - vec2(1.0);
        vec3 _573 = texture(_574, _576.xy * 0.25).xyz;
        vec3 _583 = texture(_584, (_576.xy * vec2(0.5, 0.25)) - (_547.xy * 0.00999999977648258209228515625)).xyz;
        float _597 = _598.w;
        float _602 = (((_583.z + (_573.z * 0.5)) + (_597 * 2.0)) - 1.5) * 2.0;
        if (_602 <= 9.9999997473787516355514526367188e-05)
        {
            _621 = vec4(0.0);
            break;
        }
        _602 = min(_602, 1.0);
        float _626 = _629._m0;
        float _632 = _633.w;
        vec2 _636 = _527.xz * 0.4000000059604644775390625;
        float _641 = textureLod(_642, _636, 0.0).z;
        _564 += (abs(_641) * 2.0);
        _567 *= max(1.0 - (abs(_641) * 2.0), 0.0);
        _632 -= (_641 * 0.20000000298023223876953125);
        vec2 _663 = texture(_584, (_576.xy - (_547.xy * 0.125)) + (_583.xy * 0.02999999932944774627685546875)).xy;
        vec2 _679 = (mix(_583.xy, _663, vec2(_564)) * 2.0) - vec2(1.0);
        vec2 _689 = (((_679 * (3.0 - (2.0 * _626))) + ((_567 * _564) * 0.5)) * _564) * ((_573.y * 2.0) + 0.25);
        vec3 _707 = vec3(_689.x, 0.0, _689.y);
        vec3 _713 = _714 + (_707 * 0.5);
        vec3 _719 = _714 + (_707 * 1.25);
        float _1358 = _728.x;
        vec3 _1355 = _726.xyz + (_84._m60 * _726.w);
        vec3 _1364 = _1355;
        float _1367 = _1358;
        vec3 _1377 = _1364;
        float _1380 = _1367;
        float _868 = 0.89999997615814208984375;
        vec3 _1298 = vec3(0.0);
        vec3 _1299 = vec3(0.0);
        float _1301 = 1.0;
        float _873 = 0.0;
        float _874 = _84._m13.w;
        float _875 = 1.0 / _874;
        vec3 _876 = _527 + ((_714 - _719) * 0.20000000298023223876953125);
        ivec2 _877 = ivec2(floor(gl_FragCoord.xy * (vec2(32.0, 16.0) * _286._m0.zw)));
        int _878 = (_877.y * 32) + _877.x;
        ivec4 _879 = ivec4(texelFetch(_309, ivec2(0, _878), 0));
        bool _933 = _879.x == _878;
        bool _941;
        if (_933)
        {
            _941 = _879.y == (512 - _878);
        }
        else
        {
            _941 = _933;
        }
        if (_941)
        {
            int _880 = 1;
            while (_879.z > 0)
            {
                vec4 _882 = texelFetch(_309, ivec2(_880, _878), 0);
                vec3 _1021 = ((_84._m11[3].xyz + (_84._m11[0].xyz * _882.x)) + (_84._m11[1].xyz * _882.y)) + (_84._m11[2].xyz * _882.z);
                vec4 _1022 = vec4(_1021, _882.w);
                vec4 _881 = _1022;
                vec4 _883 = texelFetch(_351, ivec2(_880, _878), 0);
                vec4 _884 = _881;
                vec4 _885 = _883;
                vec3 _886 = _527;
                vec3 _887 = _719;
                vec3 _1316 = _1298;
                vec3 _1317 = _1299;
                float _1319 = _1301;
                float _1055 = _885.w;
                float _1056 = _884.w;
                vec3 _1057 = _884.xyz - _886;
                float _1058 = dot(_1057, _1057);
                float _1059 = _1055 * _1058;
                float _1060 = clamp((_1059 - _1056) / (_1059 - _1058), 0.0, 1.0);
                float _1061 = max(dot(_887, _1057) * inversesqrt(_1058), 0.0);
                _1317 += (_885.xyz * _1060);
                _1316 += ((_885.xyz * _1061) * _1060);
                _1298 = _1316;
                _1299 = _1317;
                _1301 = _1319;
                _880++;
                _879.z--;
            }
            while ((_879.w > 0) && (_873 < 1.0))
            {
                vec4 _890 = texelFetch(_309, ivec2(_880, _878), 0);
                vec3 _1110 = ((_84._m11[3].xyz + (_84._m11[0].xyz * _890.x)) + (_84._m11[1].xyz * _890.y)) + (_84._m11[2].xyz * _890.z);
                vec4 _1111 = vec4(_1110, _890.w);
                vec4 _889 = _1111;
                vec4 _891 = _889;
                vec3 _892 = _876;
                float _893 = _874;
                float _894 = _875;
                float _895 = _873;
                vec3 _1144 = _891.xyz - _892;
                vec3 _1145 = _84._m13.xyz * dot(_84._m13.xyz, _1144);
                float _1146 = 1.0 / dot(_1144, _1144);
                float _1147 = dot(_1144 - _1145, _1144 - _1145) * _1146;
                float _1148 = _891.w * _1146;
                float _1149 = clamp(((_1147 - _1148) - _893) / (_1148 * (-2.0)), 0.0, 1.0);
                float _1150 = (_1149 * _1149) * (3.0 - (2.0 * _1149));
                float _1151 = (_1148 * _894) * _1150;
                _895 = max(_895, _1151);
                _873 = _895;
                _880++;
                _879.w--;
            }
            _1298 = mix(_1299, _1298, vec3(_868));
            _1301 = clamp(1.0 + (_873 * _84._m13.y), 0.0, 1.0);
        }
        vec3 _1329 = _1298;
        float _1332 = _1301;
        vec3 _1342 = _1329;
        float _1345 = _1332;
        vec3 _1383 = _1342;
        float _1384 = _1345;
        _1377 += _1383;
        _1380 *= _1384;
        vec3 _750 = -_84._m38;
        vec3 _755 = normalize(_532);
        float _758 = max(0.0, dot(_719, _750));
        vec3 _763 = vec3(0.0);
        vec3 _764 = (_598.xyz * _632) * _758;
        vec3 _772 = _755;
        vec3 _774 = _713;
        vec3 _776 = _750;
        float _778 = _626;
        vec3 _780 = _633.xyz;
        vec3 _1207 = normalize(_772 + _776);
        float _1208 = _778;
        float _1209 = _1208 * _1208;
        float _1210 = max(dot(_774, _772), 0.0);
        float _1211 = max(dot(_774, _776), 0.0);
        float _1212 = max(dot(_774, _1207), 0.0);
        float _1213 = ((_1212 * _1212) * (_1209 - 1.0)) + 1.0;
        float _1214 = _1209 / (_1213 * _1213);
        float _1215 = _1210 + sqrt(((_1210 - (_1210 * _1209)) * _1210) + _1209);
        float _1216 = _1211 + sqrt(((_1211 - (_1211 * _1209)) * _1211) + _1209);
        float _1217 = _1214 / (_1215 * _1216);
        vec3 _1218 = mix(_780, vec3(1.0), vec3(pow(clamp(1.0 - dot(_772, _1207), 0.0, 0.999000012874603271484375), 5.0)));
        vec3 _1219 = _1218 * (_1211 * _1217);
        vec3 _1220 = _1219;
        vec3 _771 = _1220;
        _763 += ((_84._m41 * _1380) * (_764 + _771));
        float _796 = 3.0 * exp2(((4.0 * _626) - 10.0) * max(0.0, dot(_719, _755)));
        vec3 _810 = _598.xyz * (_632 + _796);
        _763 += ((_1377 * _810) * min((_1384 * 0.25) + 0.75, 1.0));
        _621 = vec4(_763, _602);
        break;
    } while(false);
}

