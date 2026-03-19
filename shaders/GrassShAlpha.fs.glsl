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

layout(binding = 3) uniform sampler2D _309;
layout(binding = 4) uniform sampler2D _351;
layout(binding = 7) uniform sampler2D _537;
layout(binding = 5) uniform sampler2D _574;
layout(binding = 6) uniform sampler2D _584;

layout(location = 0) in vec3 _532;
layout(location = 8) in vec4 _539;
layout(location = 7) in vec3 _576;
layout(location = 2) in vec4 _598;
layout(location = 0) out vec4 _621;
layout(location = 3) in vec4 _633;
layout(location = 1) in vec3 _687;
layout(location = 4) in vec4 _699;
layout(location = 5) in vec4 _701;
layout(location = 6) in vec4 _703;

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
        vec2 _636 = texture(_584, (_576.xy - (_547.xy * 0.125)) + (_583.xy * 0.02999999932944774627685546875)).xy;
        vec2 _652 = (mix(_583.xy, _636, vec2(_564)) * 2.0) - vec2(1.0);
        vec2 _662 = (((_652 * (3.0 - (2.0 * _626))) + ((_567 * _564) * 0.5)) * _564) * ((_573.y * 2.0) + 0.25);
        vec3 _680 = vec3(_662.x, 0.0, _662.y);
        vec3 _686 = _687 + (_680 * 0.5);
        vec3 _692 = _687 + (_680 * 1.25);
        float _1332 = _701.x;
        vec3 _1329 = _699.xyz + (_84._m60 * _699.w);
        vec3 _1338 = _1329;
        float _1341 = _1332;
        vec3 _1351 = _1338;
        float _1354 = _1341;
        float _842 = 0.89999997615814208984375;
        vec3 _1272 = vec3(0.0);
        vec3 _1273 = vec3(0.0);
        float _1275 = 1.0;
        float _847 = 0.0;
        float _848 = _84._m13.w;
        float _849 = 1.0 / _848;
        vec3 _850 = _527 + ((_687 - _692) * 0.20000000298023223876953125);
        ivec2 _851 = ivec2(floor(gl_FragCoord.xy * (vec2(32.0, 16.0) * _286._m0.zw)));
        int _852 = (_851.y * 32) + _851.x;
        ivec4 _853 = ivec4(texelFetch(_309, ivec2(0, _852), 0));
        bool _907 = _853.x == _852;
        bool _915;
        if (_907)
        {
            _915 = _853.y == (512 - _852);
        }
        else
        {
            _915 = _907;
        }
        if (_915)
        {
            int _854 = 1;
            while (_853.z > 0)
            {
                vec4 _856 = texelFetch(_309, ivec2(_854, _852), 0);
                vec3 _995 = ((_84._m11[3].xyz + (_84._m11[0].xyz * _856.x)) + (_84._m11[1].xyz * _856.y)) + (_84._m11[2].xyz * _856.z);
                vec4 _996 = vec4(_995, _856.w);
                vec4 _855 = _996;
                vec4 _857 = texelFetch(_351, ivec2(_854, _852), 0);
                vec4 _858 = _855;
                vec4 _859 = _857;
                vec3 _860 = _527;
                vec3 _861 = _692;
                vec3 _1290 = _1272;
                vec3 _1291 = _1273;
                float _1293 = _1275;
                float _1029 = _859.w;
                float _1030 = _858.w;
                vec3 _1031 = _858.xyz - _860;
                float _1032 = dot(_1031, _1031);
                float _1033 = _1029 * _1032;
                float _1034 = clamp((_1033 - _1030) / (_1033 - _1032), 0.0, 1.0);
                float _1035 = max(dot(_861, _1031) * inversesqrt(_1032), 0.0);
                _1291 += (_859.xyz * _1034);
                _1290 += ((_859.xyz * _1035) * _1034);
                _1272 = _1290;
                _1273 = _1291;
                _1275 = _1293;
                _854++;
                _853.z--;
            }
            while ((_853.w > 0) && (_847 < 1.0))
            {
                vec4 _864 = texelFetch(_309, ivec2(_854, _852), 0);
                vec3 _1084 = ((_84._m11[3].xyz + (_84._m11[0].xyz * _864.x)) + (_84._m11[1].xyz * _864.y)) + (_84._m11[2].xyz * _864.z);
                vec4 _1085 = vec4(_1084, _864.w);
                vec4 _863 = _1085;
                vec4 _865 = _863;
                vec3 _866 = _850;
                float _867 = _848;
                float _868 = _849;
                float _869 = _847;
                vec3 _1118 = _865.xyz - _866;
                vec3 _1119 = _84._m13.xyz * dot(_84._m13.xyz, _1118);
                float _1120 = 1.0 / dot(_1118, _1118);
                float _1121 = dot(_1118 - _1119, _1118 - _1119) * _1120;
                float _1122 = _865.w * _1120;
                float _1123 = clamp(((_1121 - _1122) - _867) / (_1122 * (-2.0)), 0.0, 1.0);
                float _1124 = (_1123 * _1123) * (3.0 - (2.0 * _1123));
                float _1125 = (_1122 * _868) * _1124;
                _869 = max(_869, _1125);
                _847 = _869;
                _854++;
                _853.w--;
            }
            _1272 = mix(_1273, _1272, vec3(_842));
            _1275 = clamp(1.0 + (_847 * _84._m13.y), 0.0, 1.0);
        }
        vec3 _1303 = _1272;
        float _1306 = _1275;
        vec3 _1316 = _1303;
        float _1319 = _1306;
        vec3 _1357 = _1316;
        float _1358 = _1319;
        _1351 += _1357;
        _1354 *= _1358;
        vec3 _723 = -_84._m38;
        vec3 _728 = normalize(_532);
        float _731 = max(0.0, dot(_692, _723));
        vec3 _736 = vec3(0.0);
        vec3 _737 = (_598.xyz * _632) * _731;
        vec3 _745 = _728;
        vec3 _747 = _686;
        vec3 _749 = _723;
        float _751 = _626;
        vec3 _753 = _633.xyz;
        vec3 _1181 = normalize(_745 + _749);
        float _1182 = _751;
        float _1183 = _1182 * _1182;
        float _1184 = max(dot(_747, _745), 0.0);
        float _1185 = max(dot(_747, _749), 0.0);
        float _1186 = max(dot(_747, _1181), 0.0);
        float _1187 = ((_1186 * _1186) * (_1183 - 1.0)) + 1.0;
        float _1188 = _1183 / (_1187 * _1187);
        float _1189 = _1184 + sqrt(((_1184 - (_1184 * _1183)) * _1184) + _1183);
        float _1190 = _1185 + sqrt(((_1185 - (_1185 * _1183)) * _1185) + _1183);
        float _1191 = _1188 / (_1189 * _1190);
        vec3 _1192 = mix(_753, vec3(1.0), vec3(pow(clamp(1.0 - dot(_745, _1181), 0.0, 0.999000012874603271484375), 5.0)));
        vec3 _1193 = _1192 * (_1185 * _1191);
        vec3 _1194 = _1193;
        vec3 _744 = _1194;
        _736 += ((_84._m41 * _1354) * (_737 + _744));
        float _769 = 3.0 * exp2(((4.0 * _626) - 10.0) * max(0.0, dot(_692, _728)));
        vec3 _783 = _598.xyz * (_632 + _769);
        _736 += ((_1351 * _783) * min((_1358 * 0.25) + 0.75, 1.0));
        _621 = vec4(_736, _602);
        break;
    } while(false);
}

