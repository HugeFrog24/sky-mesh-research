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

layout(binding = 0, std140) uniform _641_643
{
    float _m0;
} _643;

layout(binding = 4) uniform sampler2D _309;
layout(binding = 5) uniform sampler2D _351;
layout(binding = 8) uniform sampler2D _537;
layout(binding = 6) uniform sampler2D _588;
layout(binding = 7) uniform sampler2D _597;
layout(binding = 3) uniform sampler2D _656;

layout(location = 0) in vec3 _532;
layout(location = 8) in vec4 _539;
layout(location = 7) in vec3 _574;
layout(location = 2) in vec4 _611;
layout(location = 0) out vec4 _635;
layout(location = 3) in vec4 _647;
layout(location = 1) in vec3 _728;
layout(location = 4) in vec4 _740;
layout(location = 5) in vec4 _742;
layout(location = 6) in vec4 _744;

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
        float _573 = _574.z * 5.0;
        vec2 _584 = _547.xy * ((1.0 - _573) * 5.0);
        _547 = vec3(_584.x, _584.y, _547.z);
        vec3 _587 = texture(_588, _574.xy * 0.25).xyz;
        vec3 _596 = texture(_597, (_574.xy * vec2(0.5, 0.25)) - (_547.xy * 0.00999999977648258209228515625)).xyz;
        float _610 = _611.w * _573;
        float _616 = (((_596.z + (_587.z * 0.5)) + (_610 * 2.0)) - 1.5) * 2.0;
        if (_616 <= 9.9999997473787516355514526367188e-05)
        {
            _635 = vec4(0.0);
            break;
        }
        _616 = min(_616, 1.0);
        float _640 = _643._m0;
        float _646 = _647.w;
        vec2 _650 = _527.xz * 0.4000000059604644775390625;
        float _655 = textureLod(_656, _650, 0.0).z;
        _564 += (abs(_655) * 2.0);
        _567 *= max(1.0 - (abs(_655) * 2.0), 0.0);
        _646 -= (_655 * 0.20000000298023223876953125);
        vec2 _677 = texture(_597, (_574.xy - (_547.xy * 0.125)) + (_596.xy * 0.02999999932944774627685546875)).xy;
        vec2 _693 = (mix(_596.xy, _677, vec2(_564)) * 2.0) - vec2(1.0);
        vec2 _703 = (((_693 * (3.0 - (2.0 * _640))) + ((_567 * _564) * 0.5)) * _564) * ((_587.y * 2.0) + 0.25);
        vec3 _721 = vec3(_703.x, 0.0, _703.y);
        vec3 _727 = _728 + (_721 * 0.5);
        vec3 _733 = _728 + (_721 * 1.25);
        float _1372 = _742.x;
        vec3 _1369 = _740.xyz + (_84._m60 * _740.w);
        vec3 _1378 = _1369;
        float _1381 = _1372;
        vec3 _1391 = _1378;
        float _1394 = _1381;
        float _882 = 0.89999997615814208984375;
        vec3 _1312 = vec3(0.0);
        vec3 _1313 = vec3(0.0);
        float _1315 = 1.0;
        float _887 = 0.0;
        float _888 = _84._m13.w;
        float _889 = 1.0 / _888;
        vec3 _890 = _527 + ((_728 - _733) * 0.20000000298023223876953125);
        ivec2 _891 = ivec2(floor(gl_FragCoord.xy * (vec2(32.0, 16.0) * _286._m0.zw)));
        int _892 = (_891.y * 32) + _891.x;
        ivec4 _893 = ivec4(texelFetch(_309, ivec2(0, _892), 0));
        bool _947 = _893.x == _892;
        bool _955;
        if (_947)
        {
            _955 = _893.y == (512 - _892);
        }
        else
        {
            _955 = _947;
        }
        if (_955)
        {
            int _894 = 1;
            while (_893.z > 0)
            {
                vec4 _896 = texelFetch(_309, ivec2(_894, _892), 0);
                vec3 _1035 = ((_84._m11[3].xyz + (_84._m11[0].xyz * _896.x)) + (_84._m11[1].xyz * _896.y)) + (_84._m11[2].xyz * _896.z);
                vec4 _1036 = vec4(_1035, _896.w);
                vec4 _895 = _1036;
                vec4 _897 = texelFetch(_351, ivec2(_894, _892), 0);
                vec4 _898 = _895;
                vec4 _899 = _897;
                vec3 _900 = _527;
                vec3 _901 = _733;
                vec3 _1330 = _1312;
                vec3 _1331 = _1313;
                float _1333 = _1315;
                float _1069 = _899.w;
                float _1070 = _898.w;
                vec3 _1071 = _898.xyz - _900;
                float _1072 = dot(_1071, _1071);
                float _1073 = _1069 * _1072;
                float _1074 = clamp((_1073 - _1070) / (_1073 - _1072), 0.0, 1.0);
                float _1075 = max(dot(_901, _1071) * inversesqrt(_1072), 0.0);
                _1331 += (_899.xyz * _1074);
                _1330 += ((_899.xyz * _1075) * _1074);
                _1312 = _1330;
                _1313 = _1331;
                _1315 = _1333;
                _894++;
                _893.z--;
            }
            while ((_893.w > 0) && (_887 < 1.0))
            {
                vec4 _904 = texelFetch(_309, ivec2(_894, _892), 0);
                vec3 _1124 = ((_84._m11[3].xyz + (_84._m11[0].xyz * _904.x)) + (_84._m11[1].xyz * _904.y)) + (_84._m11[2].xyz * _904.z);
                vec4 _1125 = vec4(_1124, _904.w);
                vec4 _903 = _1125;
                vec4 _905 = _903;
                vec3 _906 = _890;
                float _907 = _888;
                float _908 = _889;
                float _909 = _887;
                vec3 _1158 = _905.xyz - _906;
                vec3 _1159 = _84._m13.xyz * dot(_84._m13.xyz, _1158);
                float _1160 = 1.0 / dot(_1158, _1158);
                float _1161 = dot(_1158 - _1159, _1158 - _1159) * _1160;
                float _1162 = _905.w * _1160;
                float _1163 = clamp(((_1161 - _1162) - _907) / (_1162 * (-2.0)), 0.0, 1.0);
                float _1164 = (_1163 * _1163) * (3.0 - (2.0 * _1163));
                float _1165 = (_1162 * _908) * _1164;
                _909 = max(_909, _1165);
                _887 = _909;
                _894++;
                _893.w--;
            }
            _1312 = mix(_1313, _1312, vec3(_882));
            _1315 = clamp(1.0 + (_887 * _84._m13.y), 0.0, 1.0);
        }
        vec3 _1343 = _1312;
        float _1346 = _1315;
        vec3 _1356 = _1343;
        float _1359 = _1346;
        vec3 _1397 = _1356;
        float _1398 = _1359;
        _1391 += _1397;
        _1394 *= _1398;
        vec3 _764 = -_84._m38;
        vec3 _769 = normalize(_532);
        float _772 = max(0.0, dot(_733, _764));
        vec3 _777 = vec3(0.0);
        vec3 _778 = (_611.xyz * _646) * _772;
        vec3 _786 = _769;
        vec3 _788 = _727;
        vec3 _790 = _764;
        float _792 = _640;
        vec3 _794 = _647.xyz;
        vec3 _1221 = normalize(_786 + _790);
        float _1222 = _792;
        float _1223 = _1222 * _1222;
        float _1224 = max(dot(_788, _786), 0.0);
        float _1225 = max(dot(_788, _790), 0.0);
        float _1226 = max(dot(_788, _1221), 0.0);
        float _1227 = ((_1226 * _1226) * (_1223 - 1.0)) + 1.0;
        float _1228 = _1223 / (_1227 * _1227);
        float _1229 = _1224 + sqrt(((_1224 - (_1224 * _1223)) * _1224) + _1223);
        float _1230 = _1225 + sqrt(((_1225 - (_1225 * _1223)) * _1225) + _1223);
        float _1231 = _1228 / (_1229 * _1230);
        vec3 _1232 = mix(_794, vec3(1.0), vec3(pow(clamp(1.0 - dot(_786, _1221), 0.0, 0.999000012874603271484375), 5.0)));
        vec3 _1233 = _1232 * (_1225 * _1231);
        vec3 _1234 = _1233;
        vec3 _785 = _1234;
        _777 += ((_84._m41 * _1394) * (_778 + _785));
        float _810 = 3.0 * exp2(((4.0 * _640) - 10.0) * max(0.0, dot(_733, _769)));
        vec3 _824 = _611.xyz * (_646 + _810);
        _777 += ((_1391 * _824) * min((_1398 * 0.25) + 0.75, 1.0));
        _635 = vec4(_777, _616);
        break;
    } while(false);
}

