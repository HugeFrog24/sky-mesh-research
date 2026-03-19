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

layout(binding = 0, std140) uniform _628_630
{
    float _m0;
} _630;

layout(binding = 3) uniform sampler2D _309;
layout(binding = 4) uniform sampler2D _351;
layout(binding = 7) uniform sampler2D _537;
layout(binding = 5) uniform sampler2D _574;
layout(binding = 6) uniform sampler2D _584;

layout(location = 0) in vec3 _532;
layout(location = 8) in vec4 _539;
layout(location = 7) in vec3 _576;
layout(location = 2) in vec4 _598;
layout(location = 0) out vec4 _622;
layout(location = 3) in vec4 _634;
layout(location = 1) in vec3 _688;
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
        float _602 = (((_583.z + _573.z) + (_597 * 1.5)) - 1.25) * 1.5;
        if (_602 <= 9.9999997473787516355514526367188e-05)
        {
            _622 = vec4(0.0);
            break;
        }
        _602 = min(_602, 1.0);
        float _627 = _630._m0;
        float _633 = _634.w;
        vec2 _637 = texture(_584, (_576.xy - (_547.xy * 0.125)) + (_583.xy * 0.02999999932944774627685546875)).xy;
        vec2 _653 = (mix(_583.xy, _637, vec2(_564)) * 2.0) - vec2(1.0);
        vec2 _663 = (((_653 * (3.0 - (2.0 * _627))) + ((_567 * _564) * 0.5)) * _564) * ((_573.y * 2.0) + 0.25);
        vec3 _681 = vec3(_663.x, 0.0, _663.y);
        vec3 _687 = _688 + (_681 * 0.5);
        vec3 _693 = _688 + (_681 * 1.25);
        float _1340 = _701.x;
        vec3 _1337 = _699.xyz + (_84._m60 * _699.w);
        vec3 _1346 = _1337;
        float _1349 = _1340;
        vec3 _1359 = _1346;
        float _1362 = _1349;
        float _850 = 0.89999997615814208984375;
        vec3 _1280 = vec3(0.0);
        vec3 _1281 = vec3(0.0);
        float _1283 = 1.0;
        float _855 = 0.0;
        float _856 = _84._m13.w;
        float _857 = 1.0 / _856;
        vec3 _858 = _527 + ((_688 - _693) * 0.20000000298023223876953125);
        ivec2 _859 = ivec2(floor(gl_FragCoord.xy * (vec2(32.0, 16.0) * _286._m0.zw)));
        int _860 = (_859.y * 32) + _859.x;
        ivec4 _861 = ivec4(texelFetch(_309, ivec2(0, _860), 0));
        bool _915 = _861.x == _860;
        bool _923;
        if (_915)
        {
            _923 = _861.y == (512 - _860);
        }
        else
        {
            _923 = _915;
        }
        if (_923)
        {
            int _862 = 1;
            while (_861.z > 0)
            {
                vec4 _864 = texelFetch(_309, ivec2(_862, _860), 0);
                vec3 _1003 = ((_84._m11[3].xyz + (_84._m11[0].xyz * _864.x)) + (_84._m11[1].xyz * _864.y)) + (_84._m11[2].xyz * _864.z);
                vec4 _1004 = vec4(_1003, _864.w);
                vec4 _863 = _1004;
                vec4 _865 = texelFetch(_351, ivec2(_862, _860), 0);
                vec4 _866 = _863;
                vec4 _867 = _865;
                vec3 _868 = _527;
                vec3 _869 = _693;
                vec3 _1298 = _1280;
                vec3 _1299 = _1281;
                float _1301 = _1283;
                float _1037 = _867.w;
                float _1038 = _866.w;
                vec3 _1039 = _866.xyz - _868;
                float _1040 = dot(_1039, _1039);
                float _1041 = _1037 * _1040;
                float _1042 = clamp((_1041 - _1038) / (_1041 - _1040), 0.0, 1.0);
                float _1043 = max(dot(_869, _1039) * inversesqrt(_1040), 0.0);
                _1299 += (_867.xyz * _1042);
                _1298 += ((_867.xyz * _1043) * _1042);
                _1280 = _1298;
                _1281 = _1299;
                _1283 = _1301;
                _862++;
                _861.z--;
            }
            while ((_861.w > 0) && (_855 < 1.0))
            {
                vec4 _872 = texelFetch(_309, ivec2(_862, _860), 0);
                vec3 _1092 = ((_84._m11[3].xyz + (_84._m11[0].xyz * _872.x)) + (_84._m11[1].xyz * _872.y)) + (_84._m11[2].xyz * _872.z);
                vec4 _1093 = vec4(_1092, _872.w);
                vec4 _871 = _1093;
                vec4 _873 = _871;
                vec3 _874 = _858;
                float _875 = _856;
                float _876 = _857;
                float _877 = _855;
                vec3 _1126 = _873.xyz - _874;
                vec3 _1127 = _84._m13.xyz * dot(_84._m13.xyz, _1126);
                float _1128 = 1.0 / dot(_1126, _1126);
                float _1129 = dot(_1126 - _1127, _1126 - _1127) * _1128;
                float _1130 = _873.w * _1128;
                float _1131 = clamp(((_1129 - _1130) - _875) / (_1130 * (-2.0)), 0.0, 1.0);
                float _1132 = (_1131 * _1131) * (3.0 - (2.0 * _1131));
                float _1133 = (_1130 * _876) * _1132;
                _877 = max(_877, _1133);
                _855 = _877;
                _862++;
                _861.w--;
            }
            _1280 = mix(_1281, _1280, vec3(_850));
            _1283 = clamp(1.0 + (_855 * _84._m13.y), 0.0, 1.0);
        }
        vec3 _1311 = _1280;
        float _1314 = _1283;
        vec3 _1324 = _1311;
        float _1327 = _1314;
        vec3 _1365 = _1324;
        float _1366 = _1327;
        _1359 += _1365;
        _1362 *= _1366;
        vec3 _723 = -_84._m38;
        vec3 _728 = normalize(_532);
        float _731 = max(0.0, dot(_693, _723));
        vec3 _736 = vec3(0.0);
        vec3 _737 = (_598.xyz * _633) * _731;
        vec3 _745 = _728;
        vec3 _747 = _687;
        vec3 _749 = _723;
        float _751 = _627;
        vec3 _753 = _634.xyz;
        vec3 _1189 = normalize(_745 + _749);
        float _1190 = _751;
        float _1191 = _1190 * _1190;
        float _1192 = max(dot(_747, _745), 0.0);
        float _1193 = max(dot(_747, _749), 0.0);
        float _1194 = max(dot(_747, _1189), 0.0);
        float _1195 = ((_1194 * _1194) * (_1191 - 1.0)) + 1.0;
        float _1196 = _1191 / (_1195 * _1195);
        float _1197 = _1192 + sqrt(((_1192 - (_1192 * _1191)) * _1192) + _1191);
        float _1198 = _1193 + sqrt(((_1193 - (_1193 * _1191)) * _1193) + _1191);
        float _1199 = _1196 / (_1197 * _1198);
        vec3 _1200 = mix(_753, vec3(1.0), vec3(pow(clamp(1.0 - dot(_745, _1189), 0.0, 0.999000012874603271484375), 5.0)));
        vec3 _1201 = _1200 * (_1193 * _1199);
        vec3 _1202 = _1201;
        vec3 _744 = _1202;
        _736 += ((_84._m41 * _1362) * (_737 + _744));
        float _769 = 3.0 * exp2(((4.0 * _627) - 10.0) * max(0.0, dot(_693, _728)));
        vec3 _783 = _598.xyz * (_633 + _769);
        _736 += ((_1359 * _783) * min((_1366 * 0.25) + 0.75, 1.0));
        _736 += (_736 * (_602 * (_602 - 1.0)));
        _622 = vec4(_736, _602);
        break;
    } while(false);
}

