#version 460

layout(binding = 2, std140) uniform _96_98
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
} _98;

layout(binding = 1, std140) uniform _297_299
{
    vec4 _m0;
} _299;

layout(binding = 0, std140) uniform _611_613
{
    float _m0;
} _613;

layout(binding = 4) uniform sampler2D _322;
layout(binding = 5) uniform sampler2D _364;
layout(binding = 8) uniform sampler2D _550;
layout(binding = 6) uniform sampler2D _587;
layout(binding = 7) uniform sampler2D _597;
layout(binding = 3) uniform sampler2D _627;

layout(location = 0) in vec3 _545;
layout(location = 8) in vec4 _552;
layout(location = 7) in vec3 _589;
layout(location = 3) in vec4 _617;
layout(location = 1) in vec3 _699;
layout(location = 4) in vec4 _711;
layout(location = 5) in vec4 _713;
layout(location = 6) in vec4 _715;
layout(location = 2) in vec4 _750;
layout(location = 0) out vec4 _817;

void main()
{
    vec3 _540 = _98._m16 - _545;
    vec2 _549 = (texture(_550, _552.zw).xy * 2.0) - vec2(1.0);
    vec3 _560 = texture(_550, _552.xy).xyz;
    vec2 _574 = ((_560.xy - vec2(0.5)) * _549) + vec2(0.5);
    _560 = vec3(_574.x, _574.y, _560.z);
    float _577 = _560.z;
    vec2 _580 = (_560.xy * 2.0) - vec2(1.0);
    vec3 _586 = texture(_587, _589.xy * 0.25).xyz;
    vec3 _596 = texture(_597, (_589.xy * vec2(0.5, 0.25)) - (_560.xy * 0.00999999977648258209228515625)).xyz;
    float _610 = _613._m0;
    float _616 = _617.w;
    vec2 _621 = _540.xz * 0.4000000059604644775390625;
    float _626 = textureLod(_627, _621, 0.0).z;
    _577 += (abs(_626) * 2.0);
    _580 *= max(1.0 - (abs(_626) * 2.0), 0.0);
    _616 -= (_626 * 0.20000000298023223876953125);
    vec2 _648 = texture(_597, (_589.xy - (_560.xy * 0.125)) + (_596.xy * 0.02999999932944774627685546875)).xy;
    vec2 _664 = (mix(_596.xy, _648, vec2(_577)) * 2.0) - vec2(1.0);
    vec2 _674 = (((_664 * (3.0 - (2.0 * _610))) + ((_580 * _577) * 0.5)) * _577) * ((_586.y * 2.0) + 0.25);
    vec3 _692 = vec3(_674.x, 0.0, _674.y);
    vec3 _698 = _699 + (_692 * 0.5);
    vec3 _704 = _699 + (_692 * 1.25);
    float _1353 = _713.x;
    vec3 _1350 = _711.xyz + (_98._m60 * _711.w);
    vec3 _1359 = _1350;
    float _1362 = _1353;
    vec3 _1372 = _1359;
    float _1375 = _1362;
    float _856 = 0.89999997615814208984375;
    vec3 _1293 = vec3(0.0);
    vec3 _1294 = vec3(0.0);
    float _1296 = 1.0;
    float _861 = 0.0;
    float _862 = _98._m13.w;
    float _863 = 1.0 / _862;
    vec3 _864 = _540 + ((_699 - _704) * 0.20000000298023223876953125);
    ivec2 _865 = ivec2(floor(gl_FragCoord.xy * (vec2(32.0, 16.0) * _299._m0.zw)));
    int _866 = (_865.y * 32) + _865.x;
    ivec4 _867 = ivec4(texelFetch(_322, ivec2(0, _866), 0));
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
            vec4 _870 = texelFetch(_322, ivec2(_868, _866), 0);
            vec3 _1009 = ((_98._m11[3].xyz + (_98._m11[0].xyz * _870.x)) + (_98._m11[1].xyz * _870.y)) + (_98._m11[2].xyz * _870.z);
            vec4 _1010 = vec4(_1009, _870.w);
            vec4 _869 = _1010;
            vec4 _871 = texelFetch(_364, ivec2(_868, _866), 0);
            vec4 _872 = _869;
            vec4 _873 = _871;
            vec3 _874 = _540;
            vec3 _875 = _704;
            vec3 _1311 = _1293;
            vec3 _1312 = _1294;
            float _1314 = _1296;
            float _1043 = _873.w;
            float _1044 = _872.w;
            vec3 _1045 = _872.xyz - _874;
            float _1046 = dot(_1045, _1045);
            float _1047 = _1043 * _1046;
            float _1048 = clamp((_1047 - _1044) / (_1047 - _1046), 0.0, 1.0);
            float _1049 = max(dot(_875, _1045) * inversesqrt(_1046), 0.0);
            _1312 += (_873.xyz * _1048);
            _1311 += ((_873.xyz * _1049) * _1048);
            _1293 = _1311;
            _1294 = _1312;
            _1296 = _1314;
            _868++;
            _867.z--;
        }
        while ((_867.w > 0) && (_861 < 1.0))
        {
            vec4 _878 = texelFetch(_322, ivec2(_868, _866), 0);
            vec3 _1098 = ((_98._m11[3].xyz + (_98._m11[0].xyz * _878.x)) + (_98._m11[1].xyz * _878.y)) + (_98._m11[2].xyz * _878.z);
            vec4 _1099 = vec4(_1098, _878.w);
            vec4 _877 = _1099;
            vec4 _879 = _877;
            vec3 _880 = _864;
            float _881 = _862;
            float _882 = _863;
            float _883 = _861;
            vec3 _1132 = _879.xyz - _880;
            vec3 _1133 = _98._m13.xyz * dot(_98._m13.xyz, _1132);
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
        _1293 = mix(_1294, _1293, vec3(_856));
        _1296 = clamp(1.0 + (_861 * _98._m13.y), 0.0, 1.0);
    }
    vec3 _1324 = _1293;
    float _1327 = _1296;
    vec3 _1337 = _1324;
    float _1340 = _1327;
    vec3 _1378 = _1337;
    float _1379 = _1340;
    _1372 += _1378;
    _1375 *= _1379;
    vec3 _735 = -_98._m38;
    vec3 _740 = normalize(_545);
    float _743 = max(0.0, dot(_704, _735));
    vec3 _748 = vec3(0.0);
    vec3 _749 = (_750.xyz * _616) * _743;
    vec3 _758 = _740;
    vec3 _760 = _698;
    vec3 _762 = _735;
    float _764 = _610;
    vec3 _766 = _617.xyz;
    vec3 _1195 = normalize(_758 + _762);
    float _1196 = _764;
    float _1197 = _1196 * _1196;
    float _1198 = max(dot(_760, _758), 0.0);
    float _1199 = max(dot(_760, _762), 0.0);
    float _1200 = max(dot(_760, _1195), 0.0);
    float _1201 = ((_1200 * _1200) * (_1197 - 1.0)) + 1.0;
    float _1202 = _1197 / (_1201 * _1201);
    float _1203 = _1198 + sqrt(((_1198 - (_1198 * _1197)) * _1198) + _1197);
    float _1204 = _1199 + sqrt(((_1199 - (_1199 * _1197)) * _1199) + _1197);
    float _1205 = _1202 / (_1203 * _1204);
    vec3 _1206 = mix(_766, vec3(1.0), vec3(pow(clamp(1.0 - dot(_758, _1195), 0.0, 0.999000012874603271484375), 5.0)));
    vec3 _1207 = _1206 * (_1199 * _1205);
    vec3 _1208 = _1207;
    vec3 _757 = _1208;
    _748 += ((_98._m41 * _1375) * (_749 + _757));
    float _782 = 3.0 * exp2(((4.0 * _610) - 10.0) * max(0.0, dot(_704, _740)));
    vec3 _796 = _750.xyz * (_616 + _782);
    _748 += ((_1372 * _796) * min((_1379 * 0.25) + 0.75, 1.0));
    float _823 = 1.0 / gl_FragCoord.w;
    float _824 = 1000.0;
    float _1286 = max(0.0, _823 * (_824 * 6.6666667407844215631484985351562e-05));
    _817 = vec4(_748, _1286);
}

