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

layout(binding = 3) uniform sampler2D _309;
layout(binding = 4) uniform sampler2D _351;
layout(binding = 7) uniform sampler2D _537;
layout(binding = 5) uniform sampler2D _588;
layout(binding = 6) uniform sampler2D _597;

layout(location = 0) in vec3 _532;
layout(location = 8) in vec4 _539;
layout(location = 7) in vec3 _574;
layout(location = 2) in vec4 _611;
layout(location = 0) out vec4 _635;
layout(location = 3) in vec4 _647;
layout(location = 1) in vec3 _701;
layout(location = 4) in vec4 _713;
layout(location = 5) in vec4 _715;
layout(location = 6) in vec4 _717;

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
        vec2 _650 = texture(_597, (_574.xy - (_547.xy * 0.125)) + (_596.xy * 0.02999999932944774627685546875)).xy;
        vec2 _666 = (mix(_596.xy, _650, vec2(_564)) * 2.0) - vec2(1.0);
        vec2 _676 = (((_666 * (3.0 - (2.0 * _640))) + ((_567 * _564) * 0.5)) * _564) * ((_587.y * 2.0) + 0.25);
        vec3 _694 = vec3(_676.x, 0.0, _676.y);
        vec3 _700 = _701 + (_694 * 0.5);
        vec3 _706 = _701 + (_694 * 1.25);
        float _1346 = _715.x;
        vec3 _1343 = _713.xyz + (_84._m60 * _713.w);
        vec3 _1352 = _1343;
        float _1355 = _1346;
        vec3 _1365 = _1352;
        float _1368 = _1355;
        float _856 = 0.89999997615814208984375;
        vec3 _1286 = vec3(0.0);
        vec3 _1287 = vec3(0.0);
        float _1289 = 1.0;
        float _861 = 0.0;
        float _862 = _84._m13.w;
        float _863 = 1.0 / _862;
        vec3 _864 = _527 + ((_701 - _706) * 0.20000000298023223876953125);
        ivec2 _865 = ivec2(floor(gl_FragCoord.xy * (vec2(32.0, 16.0) * _286._m0.zw)));
        int _866 = (_865.y * 32) + _865.x;
        ivec4 _867 = ivec4(texelFetch(_309, ivec2(0, _866), 0));
        bool _921 = _867.x == _866;
        bool _929;
        if (_921)
        {
            _929 = _867.y == (512 - _866);
        }
        else
        {
            _929 = _921;
        }
        if (_929)
        {
            int _868 = 1;
            while (_867.z > 0)
            {
                vec4 _870 = texelFetch(_309, ivec2(_868, _866), 0);
                vec3 _1009 = ((_84._m11[3].xyz + (_84._m11[0].xyz * _870.x)) + (_84._m11[1].xyz * _870.y)) + (_84._m11[2].xyz * _870.z);
                vec4 _1010 = vec4(_1009, _870.w);
                vec4 _869 = _1010;
                vec4 _871 = texelFetch(_351, ivec2(_868, _866), 0);
                vec4 _872 = _869;
                vec4 _873 = _871;
                vec3 _874 = _527;
                vec3 _875 = _706;
                vec3 _1304 = _1286;
                vec3 _1305 = _1287;
                float _1307 = _1289;
                float _1043 = _873.w;
                float _1044 = _872.w;
                vec3 _1045 = _872.xyz - _874;
                float _1046 = dot(_1045, _1045);
                float _1047 = _1043 * _1046;
                float _1048 = clamp((_1047 - _1044) / (_1047 - _1046), 0.0, 1.0);
                float _1049 = max(dot(_875, _1045) * inversesqrt(_1046), 0.0);
                _1305 += (_873.xyz * _1048);
                _1304 += ((_873.xyz * _1049) * _1048);
                _1286 = _1304;
                _1287 = _1305;
                _1289 = _1307;
                _868++;
                _867.z--;
            }
            while ((_867.w > 0) && (_861 < 1.0))
            {
                vec4 _878 = texelFetch(_309, ivec2(_868, _866), 0);
                vec3 _1098 = ((_84._m11[3].xyz + (_84._m11[0].xyz * _878.x)) + (_84._m11[1].xyz * _878.y)) + (_84._m11[2].xyz * _878.z);
                vec4 _1099 = vec4(_1098, _878.w);
                vec4 _877 = _1099;
                vec4 _879 = _877;
                vec3 _880 = _864;
                float _881 = _862;
                float _882 = _863;
                float _883 = _861;
                vec3 _1132 = _879.xyz - _880;
                vec3 _1133 = _84._m13.xyz * dot(_84._m13.xyz, _1132);
                float _1134 = 1.0 / dot(_1132, _1132);
                float _1135 = dot(_1132 - _1133, _1132 - _1133) * _1134;
                float _1136 = _879.w * _1134;
                float _1137 = clamp(((_1135 - _1136) - _881) / (_1136 * (-2.0)), 0.0, 1.0);
                float _1138 = (_1137 * _1137) * (3.0 - (2.0 * _1137));
                float _1139 = (_1136 * _882) * _1138;
                _883 = max(_883, _1139);
                _861 = _883;
                _868++;
                _867.w--;
            }
            _1286 = mix(_1287, _1286, vec3(_856));
            _1289 = clamp(1.0 + (_861 * _84._m13.y), 0.0, 1.0);
        }
        vec3 _1317 = _1286;
        float _1320 = _1289;
        vec3 _1330 = _1317;
        float _1333 = _1320;
        vec3 _1371 = _1330;
        float _1372 = _1333;
        _1365 += _1371;
        _1368 *= _1372;
        vec3 _737 = -_84._m38;
        vec3 _742 = normalize(_532);
        float _745 = max(0.0, dot(_706, _737));
        vec3 _750 = vec3(0.0);
        vec3 _751 = (_611.xyz * _646) * _745;
        vec3 _759 = _742;
        vec3 _761 = _700;
        vec3 _763 = _737;
        float _765 = _640;
        vec3 _767 = _647.xyz;
        vec3 _1195 = normalize(_759 + _763);
        float _1196 = _765;
        float _1197 = _1196 * _1196;
        float _1198 = max(dot(_761, _759), 0.0);
        float _1199 = max(dot(_761, _763), 0.0);
        float _1200 = max(dot(_761, _1195), 0.0);
        float _1201 = ((_1200 * _1200) * (_1197 - 1.0)) + 1.0;
        float _1202 = _1197 / (_1201 * _1201);
        float _1203 = _1198 + sqrt(((_1198 - (_1198 * _1197)) * _1198) + _1197);
        float _1204 = _1199 + sqrt(((_1199 - (_1199 * _1197)) * _1199) + _1197);
        float _1205 = _1202 / (_1203 * _1204);
        vec3 _1206 = mix(_767, vec3(1.0), vec3(pow(clamp(1.0 - dot(_759, _1195), 0.0, 0.999000012874603271484375), 5.0)));
        vec3 _1207 = _1206 * (_1199 * _1205);
        vec3 _1208 = _1207;
        vec3 _758 = _1208;
        _750 += ((_84._m41 * _1368) * (_751 + _758));
        float _783 = 3.0 * exp2(((4.0 * _640) - 10.0) * max(0.0, dot(_706, _742)));
        vec3 _797 = _611.xyz * (_646 + _783);
        _750 += ((_1365 * _797) * min((_1372 * 0.25) + 0.75, 1.0));
        _635 = vec4(_750, _616);
        break;
    } while(false);
}

